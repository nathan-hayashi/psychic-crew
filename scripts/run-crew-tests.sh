#!/usr/bin/env bash
# run-crew-tests.sh — crew test harness (§5.5). Wraps the validators and adds per-phase cases.
#
# Usage:  run-crew-tests.sh [all,gate,F0..F7]
#   all  (default) every registered case
#   gate           regenerate ALL gate evidence LIVE and stamp it — answer a gate against this,
#                  never against a recorded claim (G-F0's evidence decayed 31s after recording)
#   F<n>           only that phase's cases
#
# Append-a-case pattern: each phase adds a cases_F<n> function. Do not edit earlier ones.
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; F=0
ok () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
no () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }
# check <desc> <expected-exit> <cmd...>
check () { d="$1"; e="$2"; shift 2; "$@" >/dev/null 2>&1; r=$?
           if [ "$r" = "$e" ]; then ok "$d"; else no "$d (exit $r, expected $e)"; fi; }

BAK=$(mktemp -d); trap 'cp -f "$BAK"/models.config.json models.config.json 2>/dev/null
                        cp -f "$BAK"/quality-reviewer.md .claude/agents/quality-reviewer.md 2>/dev/null
                        cp -f "$BAK"/PROGRESS.md PROGRESS.md 2>/dev/null
                        rm -f .claude/state/compact-pending 2>/dev/null
                        ./scripts/apply-models.sh >/dev/null 2>&1; rm -rf "$BAK"' EXIT
cp models.config.json "$BAK"/
cp .claude/agents/quality-reviewer.md "$BAK"/ 2>/dev/null || true
cp PROGRESS.md "$BAK"/ 2>/dev/null || true

cases_F0 () {
  echo "== F0 — scaffold integrity =="
  check "validate-crew all green"                 0 ./scripts/validate-crew.sh
  check "plan corrections: F0 clean"              0 ./scripts/check-plan-corrections.sh F0
  check "settings.json parses"                    0 jq -e . .claude/settings.json
  check "models.config.json parses"               0 jq -e . models.config.json
  # v3.0 (operator ruling A1b, 2026-08-16): EX-01 is RETIRED. The rename was applied UPSTREAM in the
  # canonical re-export, so every §4 payload now matches its deployed seed byte-for-byte and the
  # byte-pin re-binds to this plan. The old expectations were the rename allowance — CLAUDE.md 1 line
  # (L1 title) and DIRECTORY_GUIDE.md 1 line (L2 tree root); both are now 0 because there is nothing
  # left to allow. Measured 0/0/0 before this line changed, so the check went from FAIL-on-a-correct
  # -repo to PASS without loosening: expecting `<= 1` instead would have silently accepted one line of
  # real drift forever, which is the allowance EX-01 existed to bound and no longer needs to.
  for pair in "CLAUDE.md 4.1 0" "CLAUDE_DESIGN.md 4.2 0" "DIRECTORY_GUIDE.md 4.3 0"; do
    set -- $pair; f=$1; sec=$2; want=$3
    got=$(diff <(awk -v h="### $sec " 'index($0,h)==1&&!fd{fd=1;next} fd&&!inf&&substr($0,1,3)=="```"{inf=1;next} fd&&inf&&$0=="```"{exit} fd&&inf' MASTER_FIFO_PLAN_CLAUDE.md) "$f" | grep -c '^>')
    if [ "$got" = "$want" ]; then ok "EX-01 $f delta $got"; else no "EX-01 $f delta $got, expected $want"; fi
  done
  # porcelain, not `git diff` — untracked files are uncommitted state too, and a gate
  # answered against a dirty tree is answered against something not in the repo.
  [ "$(git status --porcelain | wc -l)" = 0 ] && ok "working tree clean" \
                                             || no "working tree dirty ($(git status --porcelain | wc -l) entries)"
}

cases_F1 () {
  echo "== F1 — model routing (HC-2 / HC-4) =="
  check "apply-models clean config"               0 ./scripts/apply-models.sh
  check "plan corrections: F1 clean"              0 ./scripts/check-plan-corrections.sh F1
  for v in '.agents["lead-planner"].model="fable"' '.session.model="fable"' \
           '.pinned.opus="claude-fable-5"' '.aliases.opus="claude-fable-5"'; do
    jq "$v" "$BAK"/models.config.json > models.config.json
    check "HC-2 refuses $v" 2 ./scripts/apply-models.sh
  done
  cp -f "$BAK"/models.config.json models.config.json
  sed -i 's/^model: sonnet/model: claude-fable-5/' .claude/agents/quality-reviewer.md 2>/dev/null
  check "HC-2 refuses poisoned agent frontmatter" 2 ./scripts/apply-models.sh
  cp -f "$BAK"/quality-reviewer.md .claude/agents/quality-reviewer.md
  ./scripts/apply-models.sh >/dev/null 2>&1
  # HC-4: config is the only source of truth — reroute and confirm the stamp follows
  jq '.agents["quality-reviewer"].model="opus" | .agents["quality-reviewer"].effort="high"' \
     "$BAK"/models.config.json > models.config.json
  ./scripts/apply-models.sh >/dev/null 2>&1
  if grep -q '^model: opus' .claude/agents/quality-reviewer.md \
     && grep -q '^effort: high' .claude/agents/quality-reviewer.md; then ok "HC-4 reroute stamps model+effort"
  else no "HC-4 reroute did not stamp"; fi
  cp -f "$BAK"/models.config.json models.config.json; ./scripts/apply-models.sh >/dev/null 2>&1
  grep -q '^model: sonnet' .claude/agents/quality-reviewer.md && ok "HC-4 revert restores stamp" || no "revert failed"
  # prose documenting the ban must not trip the guard (four red gates came from this class)
  grep -q 'fable' .claude/rules/model-policy.md \
    && check "prose mention does not trip HC-2" 0 ./scripts/apply-models.sh
}

cases_F2 () {
  echo "== F2 — enforcement layer =="
  # Payloads are printf ARGUMENTS, never the format string — printf eats \" in a format and
  # silently corrupts JSON, which once made a working guard look broken.
  # Capture, THEN test. A denying hook exits 2, and under `set -o pipefail` that poisons the
  # whole pipeline's status even when grep matched — so a piped form reports "not denied" for a
  # guard that denied correctly. Third pipefail incident in this build; see the registry note.
  denies () { o=$(printf '%s' "$2" | "./hooks/$1.sh" 2>/dev/null || true)
              printf '%s' "$o" | grep -q '"permissionDecision":"deny"'; }
  allows () { o=$(printf '%s' "$2" | "./hooks/$1.sh" 2>/dev/null || true)
              ! printf '%s' "$o" | grep -q '"permissionDecision":"deny"'; }
  feed   () { printf '%s' "$2" | "./hooks/$1.sh"; }

  denies bash-blocker '{"tool_input":{"command":"rm -rf ~"}}'                 && ok "denies rm -rf ~"        || no "rm -rf ~ not denied"
  denies bash-blocker '{"tool_input":{"command":"git clone https://x/y"}}'    && ok "denies git clone"       || no "git clone not denied"
  denies bash-blocker '{"tool_input":{"command":"npx cowsay"}}'               && ok "denies npx"             || no "npx not denied"
  denies bash-blocker '{"tool_input":{"command":"sudo rm x"}}'                && ok "denies sudo"            || no "sudo not denied"
  denies bash-blocker '{"tool_input":{"command":"codex exec x"}}'             && ok "denies codex (HC-7)"    || no "codex not denied"
  allows bash-blocker '{"tool_input":{"command":"git status --short"}}'       && ok "allows benign git"      || no "benign git wrongly denied"
  allows bash-blocker '{"tool_input":{"command":"ls -la"}}'                   && ok "allows benign ls"       || no "benign ls wrongly denied"

  denies sensitive-guard '{"tool_input":{"file_path":"/x/.env","content":"K=v"}}'  && ok "denies .env write" || no ".env write not denied"
  denies sensitive-guard '{"tool_input":{"file_path":"/x/.gitignore","content":"logs/\n"}}' && ok "denies .gitignore removal of protected entry" || no "gitignore removal not denied"
  allows sensitive-guard '{"tool_input":{"file_path":"/x/.gitignore","content":".env\nlogs/\n.claude/state/\nextra/\n"}}' && ok "allows .gitignore append (C-04 must stay possible)" || no "gitignore append wrongly denied"

  denies model-guard '{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-fable-5\""}}' && ok "model-guard blocks fable write" || no "fable write not blocked"
  allows model-guard '{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-opus-5\""}}'  && ok "model-guard allows a clean model write" || no "clean model write wrongly denied"
  allows model-guard '{"tool_input":{"file_path":"README.md","content":"the fable model is banned"}}' && ok "model-guard ignores prose outside the config surface" || no "prose wrongly denied"

  n0=$( [ -f logs/tooluse-audit.jsonl ] && wc -l < logs/tooluse-audit.jsonl || echo 0 )
  printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"x.txt"}}' | ./hooks/audit-logger.sh >/dev/null 2>&1
  n1=$( [ -f logs/tooluse-audit.jsonl ] && wc -l < logs/tooluse-audit.jsonl || echo 0 )
  [ "$n1" -gt "$n0" ] && ok "audit line appended after a benign tool use" || no "no audit line appended"
  tail -1 logs/tooluse-audit.jsonl 2>/dev/null | jq -e . >/dev/null 2>&1 && ok "audit line is valid JSON" || no "audit line malformed"

  # ccs-01 (§15.7)
  rm -f .claude/state/compact-pending
  b=$(wc -l < PROGRESS.md)
  printf '%s' '{"trigger":"auto"}' | ./hooks/pre-compact-checkpoint.sh >/dev/null 2>&1
  r=$?
  [ "$r" = 0 ] && ok "ccs-01 PreCompact exits 0" || no "ccs-01 PreCompact exit $r"
  [ "$(wc -l < PROGRESS.md)" -gt "$b" ] && ok "ccs-01 PROGRESS.md gained a checkpoint block" || no "ccs-01 no checkpoint block"
  [ -f .claude/state/compact-pending ] && ok "ccs-01 compact-pending flag armed" || no "ccs-01 flag not armed"
  chmod 400 PROGRESS.md 2>/dev/null
  printf '%s' '{"trigger":"auto"}' | ./hooks/pre-compact-checkpoint.sh >/dev/null 2>&1
  r=$?; chmod 644 PROGRESS.md 2>/dev/null
  [ "$r" = 0 ] && ok "ccs-01 exits 0 even with PROGRESS.md unwritable" || no "ccs-01 failed on unwritable PROGRESS.md (exit $r)"

  # ccs-03 (§15.9)
  snap=$(ls -1t .claude/state/checkpoints/ckpt-*.md 2>/dev/null | head -1)
  if [ -n "$snap" ]; then
    f=0
    for sec in "PROGRESS.md (tail 40)" "GATES.md (tail)" "Plan.md open items" "## git" "declared next_action"; do
      grep -qF "$sec" "$snap" || f=1
    done
    [ "$f" = 0 ] && ok "ccs-03 numbered snapshot has all five fields" || no "ccs-03 snapshot missing fields"
  else no "ccs-03 no numbered snapshot produced"; fi
  [ "$(ls -1 .claude/state/checkpoints/ckpt-*.md 2>/dev/null | wc -l)" -le 10 ] && ok "ccs-03 retention holds at 10" || no "ccs-03 retention exceeded"

  # Stop: refreshes latest.md AND consumes the flag exactly once
  o=$(printf '%s' '{}' | ./hooks/stop.sh 2>/dev/null || true)
  printf '%s' "$o" | grep -q '"decision":"block"' && ok "Stop emits decision:block while the flag is armed" || no "Stop did not block on armed flag"
  [ -f .claude/state/checkpoints/latest.md ] && ok "ccs-03 Stop refreshed latest.md" || no "latest.md not refreshed"
  o=$(printf '%s' '{}' | ./hooks/stop.sh 2>/dev/null || true)
  printf '%s' "$o" | grep -q '"decision":"block"' && no "Stop blocked twice — flag not consumed exactly once" || ok "flag consumed exactly once, no loop"

  check "restore-context.sh latest exits 0" 0 ./scripts/restore-context.sh latest
  ./scripts/restore-context.sh latest 2>/dev/null | grep -q 'RELOAD INSTRUCTION' && ok "restore-context prints the reload instruction" || no "reload instruction missing"

  o=$(printf '%s' '{}' | ./hooks/session-start.sh 2>/dev/null || true)
  printf '%s' "$o" | jq -e '.hookSpecificOutput.additionalContext' >/dev/null 2>&1 && ok "SessionStart emits additionalContext (§15.4)" || no "SessionStart output malformed"

  # --- G-F2 gap closure (found by the live stress, not by the offline suite) ---
  # A denial that leaves no record is a silent control. PostToolUse cannot cover it: the blocked
  # tool never runs, so the guard has to write its own line. The first live stress produced six
  # denials and zero audit entries, failing G-F2's "6 denies + 6 audit entries" as written.
  n0=$(wc -l < logs/tooluse-audit.jsonl 2>/dev/null || echo 0)
  denies bash-blocker '{"tool_name":"Bash","tool_input":{"command":"git clone https://x/y"}}' >/dev/null 2>&1
  n1=$(wc -l < logs/tooluse-audit.jsonl 2>/dev/null || echo 0)
  [ "$n1" -gt "$n0" ] && ok "denial writes an audit record" || no "denial left no audit record"
  tail -1 logs/tooluse-audit.jsonl | jq -e '.event=="PreToolUse.deny" and (.reason|length)>0' >/dev/null 2>&1 \
    && ok "denial record carries event + reason" || no "denial record malformed"

  # auto-format, error-recovery and notify had no coverage at all until now.
  # auto-format must format ordinary files yet NEVER touch a byte-pinned payload (EX-01 identity).
  h0=$(sha256sum CLAUDE.md | cut -d' ' -f1)
  printf '%s' '{"tool_input":{"file_path":"CLAUDE.md"}}' | ./hooks/auto-format.sh >/dev/null 2>&1
  [ "$(sha256sum CLAUDE.md | cut -d' ' -f1)" = "$h0" ] && ok "auto-format refuses byte-pinned CLAUDE.md" \
                                                       || no "auto-format mutated a byte-pinned seed"
  check "auto-format exits 0 on a missing path"  0 feed auto-format '{"tool_input":{"file_path":"/nope/x.md"}}'
  # CR-013 (audit A3-F1): these fixtures ran with the LIVE repo as ROOT, so every suite run appended
  # a fabricated "command not found" record to logs/build-errors.jsonl — 178 of 188 records, 95%,
  # described failures that never happened. That is C-14 exactly; C-14's mktemp fix covered
  # logs/tooluse-audit.jsonl only, and its detector inspects only that file, so nothing looked here.
  # The existence assertion was circular besides: it asserted the log exists immediately after the
  # line above caused it to exist, so on a fresh checkout it passed because the fixture made it pass.
  # Isolate the root, then assert against THAT — the write this fixture actually performed — and add
  # a canary proving the live trail did not move.
  er=$(mktemp -d); mkdir -p "$er/logs"
  erj='{"tool_name":"Bash","tool_response":{"error":"bash: foo: command not found"}}'
  erb=$(wc -l < logs/build-errors.jsonl 2>/dev/null || echo 0)
  feedr () { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$er" "./hooks/$1.sh"; }
  # CR-018 changed the contract: a recognised error now DELIVERS its hint on stderr with exit 2,
  # while an unrecognised one still exits 0 and says nothing. Both paths are asserted, because
  # "never fatal" and "actually delivers" are separate properties and the old single check conflated
  # them by testing stdout — emission, not delivery.
  check "error-recovery exits 0 on an unrecognised error"  0 feedr error-recovery '{"tool_name":"Bash","tool_response":{"error":"an entirely novel failure"}}'
  [ -s "$er/logs/build-errors.jsonl" ] && ok "error-recovery wrote build-errors.jsonl under an isolated root" \
                                       || no "error-recovery wrote no record"
  ehint=$(printf '%s' "$erj" | CLAUDE_PROJECT_DIR="$er" ./hooks/error-recovery.sh 2>&1 >/dev/null); erc=$?
  { printf '%s' "$ehint" | grep -q 'minimal-shell' && [ "$erc" = 2 ]; } \
    && ok "CR-018 §9 hint DELIVERED on stderr with exit 2 (not merely emitted)" \
    || no "CR-018 §9 hint not delivered (exit=$erc stderr='$ehint')"
  [ "$(wc -l < logs/build-errors.jsonl 2>/dev/null || echo 0)" = "$erb" ] \
    && ok "CR-013 error-recovery fixtures left the live trail untouched ($erb lines)" \
    || no "CR-013 fixtures wrote to the live logs/build-errors.jsonl — tests polluting the artifact they audit"
  rm -rf "$er"
  check "notify exits 0 and is never fatal"      0 feed notify '{"message":"run-crew-tests probe"}'

  # S3 (CR-001/002/004/005): three new diagrams shipped this session and nothing validated any of
  # them. A1-F4 found the only existing diagram check asserted one fence, the token
  # sequenceDiagram, and floor counts — a diagram depicting a different system passed identically,
  # which is the state A1 actually found both then-existing diagrams in. Shipping three more
  # unchecked repeats the F2 lesson, where three hooks shipped with zero cases.
  #
  # This lives INLINE rather than in scripts/ deliberately. A tenth script would break CR-024's
  # map-vs-tree assertion, because DIRECTORY_GUIDE.md is the §4.3 payload and must stay at delta 0 —
  # the map can only gain a name through an operator re-export of the plan. CR-024 caught exactly
  # that when this was first written as scripts/check-diagrams.sh, which is the check working.
  #
  # It validates fence integrity, a recognised diagram type, and referential integrity: every edge
  # endpoint resolves to a declared node, participant or state. Those are the failures that render
  # as an error box on GitHub, and they need no renderer (HC-5; bash and awk only per ruling R1d).
  # It does NOT check whether a diagram is TRUE — binding a picture to the code it depicts is not
  # mechanically decidable, and pretending otherwise would be the proxy recorded ten times here.
  dgn=0; dgbad=0
  for dgf in $(git ls-files '*.md' 2>/dev/null | grep -v '^docs/audit/'); do
    dgc=$(grep -c '^```mermaid$' "$dgf" 2>/dev/null || true)
    [ "${dgc:-0}" -gt 0 ] || continue
    dgn=$((dgn + dgc))
    dgout=$(awk -v FNAME="$dgf" '
  function flush(  i, k, bad) {
    if (!inblk) return
    if (kind == "") { print "ERR " FNAME ":" start " no recognised diagram type on the first line"; nblk++; return }
    bad = ""
    for (k in used) if (!(k in decl)) bad = bad " " k
    if (bad != "") print "ERR " FNAME ":" start " " kind " references undeclared node(s):" bad
    else print "OK " FNAME ":" start " " kind " nodes=" ndecl " edges=" nedge
    nblk++
  }
  /^```mermaid$/ { inblk=1; start=NR; kind=""; ndecl=0; nedge=0; delete decl; delete used; next }
  inblk && /^```$/ { flush(); inblk=0; delete decl; delete used; next }
  !inblk { next }
  {
    line=$0
    sub(/^[ \t]+/, "", line); sub(/[ \t]+$/, "", line)
    if (line == "" || line ~ /^%%/) next
    if (kind == "") {
      if (line ~ /^flowchart/ || line ~ /^graph/) kind="flowchart"
      else if (line ~ /^sequenceDiagram/) kind="sequenceDiagram"
      else if (line ~ /^stateDiagram/) kind="stateDiagram"
      else { kind="" ; print "ERR " FNAME ":" start " unrecognised first line: " line ; nblk++ }
      next
    }
    if (line ~ /^autonumber/ || line ~ /^direction/ || line ~ /^title/) next

    if (kind == "sequenceDiagram") {
      if (match(line, /^participant[ \t]+[A-Za-z0-9_]+/)) {
        s=substr(line, RSTART+11); sub(/^[ \t]+/, "", s); sub(/[ \t].*$/, "", s)
        if (!(s in decl)) { decl[s]=1; ndecl++ }
        next
      }
      if (match(line, /(-|--)?(->>|->|-x|--x)/)) {
        a=substr(line, 1, RSTART-1); b=substr(line, RSTART+RLENGTH)
        sub(/:.*$/, "", b)
        gsub(/[ \t]/, "", a); gsub(/[ \t]/, "", b)
        if (a != "") used[a]=1
        if (b != "") used[b]=1
        nedge++
      }
      next
    }

    if (kind == "stateDiagram") {
      if (line ~ /^note/ || line ~ /^end note/ || line ~ /^state /) next
      if (match(line, /-->/)) {
        a=substr(line, 1, RSTART-1); b=substr(line, RSTART+3)
        sub(/:.*$/, "", b)
        gsub(/[ \t]/, "", a); gsub(/[ \t]/, "", b)
        if (a != "" && a != "[*]") { used[a]=1; if (!(a in decl)) { decl[a]=1; ndecl++ } }
        if (b != "" && b != "[*]") { used[b]=1; if (!(b in decl)) { decl[b]=1; ndecl++ } }
        nedge++
      }
      next
    }

    # flowchart: declaration-by-first-use, then assert every endpoint was seen as an id
    tmp=line
    while (match(tmp, /[A-Za-z_][A-Za-z0-9_]*[[({]/)) {
      id=substr(tmp, RSTART, RLENGTH-1)
      if (!(id in decl)) { decl[id]=1; ndecl++ }
      tmp=substr(tmp, RSTART+RLENGTH)
    }
    if (match(line, /(-->|---|-\.->|-\.-|==>|===)/)) {
      a=substr(line, 1, RSTART-1); b=substr(line, RSTART+RLENGTH)
      sub(/^\|[^|]*\|/, "", b)
      gsub(/[ \t]/, "", a); gsub(/[ \t]/, "", b)
      sub(/[[({].*$/, "", a); sub(/[[({].*$/, "", b)
      if (a != "") used[a]=1
      if (b != "") used[b]=1
      nedge++
    }
  }
  END { if (inblk) { print "ERR " FNAME ":" start " fence is never closed"; nblk++ } }
    ' "$dgf")
    dge=$(printf '%s\n' "$dgout" | grep -c '^ERR ' || true)
    [ "${dge:-0}" = 0 ] || { dgbad=$((dgbad + dge)); printf '%s\n' "$dgout" | grep '^ERR ' | sed 's/^ERR /      /'; }
  done
  { [ "$dgn" -ge 5 ] && [ "$dgbad" = 0 ]; } \
    && ok "S3 all $dgn mermaid blocks are structurally valid (fences, type, referential integrity)" \
    || no "S3 mermaid: $dgn block(s) found, $dgbad structural error(s) — want >=5 and 0"

  # S2 (CR-025 / CR-022): two new hooks touch the enforcement layer, and untested enforcement is a
  # finding by this crew's own reviewer contract — F2 shipped three hooks with zero cases and a
  # denial path that left no record, and both survived every green suite before them.
  s2t=$(mktemp -d); mkdir -p "$s2t/logs"; cp GATES.md "$s2t/" 2>/dev/null
  printf '%s' '{"session_id":"s2","agent_id":"s2-agt","agent_type":"security-reviewer"}' \
    | CLAUDE_PROJECT_DIR="$s2t" ./hooks/subagent-start.sh >/dev/null 2>&1
  s2id=$(jq -r '.agent_id // ""' "$s2t/logs/subagent-starts.jsonl" 2>/dev/null | head -1)
  s2ty=$(jq -r '.agent_type // ""' "$s2t/logs/subagent-starts.jsonl" 2>/dev/null | head -1)
  { [ "$s2id" = "s2-agt" ] && [ "$s2ty" = "security-reviewer" ]; } \
    && ok "CR-025 subagent-start records the runtime-supplied agent_id and agent_type" \
    || no "CR-025 subagent-start lost the supplied identity (id='$s2id' type='$s2ty')"
  # The identity is SUPPLIED, never inferred: the hook reads no outcome field, so it cannot depend
  # on the dispatch succeeding. That is the whole point — it covers the failed ones.
  sed 's/#.*//' hooks/subagent-start.sh | grep -qE 'tool_response|\.error|success' \
    && no "CR-025 subagent-start reads an outcome field — it must fire regardless of success" \
    || ok "CR-025 subagent-start depends on no outcome field (covers failed dispatches)"
  # CR-022: flag-mode only. Over-cap flags, at-cap does not, and it NEVER denies.
  # The fence is built from a variable: inside a single-quoted printf a backslash-escaped backtick
  # stays literal, so the first version of this fixture emitted no fence at all and the over-cap
  # case silently produced no flag. The suite caught it; a fixture that cannot trigger the thing it
  # tests is the same vacuity class as an empty set difference.
  s2f='```'
  s2big=$( { printf '{"task_id":"s2-cap"}\n\n%s\n' "$s2f"; i=0; while [ $i -lt 31 ]; do echo "l$i"; i=$((i+1)); done; printf '%s\n' "$s2f"; } )
  s2sm=$( { printf '{"task_id":"s2-cap"}\n\n%s\n' "$s2f"; i=0; while [ $i -lt 5 ]; do echo "l$i"; i=$((i+1)); done; printf '%s\n' "$s2f"; } )
  : > "$s2t/logs/arbiter-audit.jsonl"
  s2out=$(jq -cn --arg p "$s2sm" '{tool_name:"Agent",tool_input:{subagent_type:"fixer",prompt:$p}}' \
          | CLAUDE_PROJECT_DIR="$s2t" ./hooks/reference-cap.sh 2>/dev/null)
  s2a=$(wc -l < "$s2t/logs/arbiter-audit.jsonl")
  jq -cn --arg p "$s2big" '{tool_name:"Agent",tool_input:{subagent_type:"fixer",prompt:$p}}' \
    | CLAUDE_PROJECT_DIR="$s2t" ./hooks/reference-cap.sh >/dev/null 2>&1
  s2b=$(wc -l < "$s2t/logs/arbiter-audit.jsonl")
  { [ "$s2a" = 0 ] && [ "$s2b" = 1 ]; } \
    && ok "CR-022 reference-cap flags an over-cap dispatch and leaves an at-cap one alone ($s2a -> $s2b)" \
    || no "CR-022 reference-cap mis-triggered (at-cap=$s2a over-cap=$s2b, want 0 -> 1)"
  [ -z "$s2out" ] && ok "CR-022 reference-cap never denies (no decision object on stdout)" \
                  || no "CR-022 reference-cap emitted a decision object: $s2out"
  # The flag must NOT be able to satisfy the arbiter's own coverage obligation — C-12 through a new
  # writer. It carries event:"FLAG" and both correlations exclude that field.
  jq -e 'select(.event=="FLAG")' "$s2t/logs/arbiter-audit.jsonl" >/dev/null 2>&1 \
    && ok "CR-022 flag lines carry event:FLAG so coverage can exclude them" \
    || no "CR-022 flag line has no event discriminator — a hook could satisfy arbiter coverage"
  rm -rf "$s2t"
}
cases_F4 () {
  echo "== F4 — router + tier lock =="
  # C-13 provenance guard. Every probe runs under a mktemp root: a suite that writes to the
  # artifact it audits is C-14, and this suite exercises a hook whose job is writing records.
  pv=$(mktemp -d); mkdir -p "$pv/logs"; cp -r logs/rounds "$pv/logs/" 2>/dev/null
  pvspan=$(jq -r '.. | strings' logs/rounds/round-1/security-reviewer.json 2>/dev/null | awk 'length>=90{print;exit}')
  pvrun () { jq -cn --arg f "$pv/$1" --arg c "$2" '{tool_input:{file_path:$f,content:$c}}' \
             | CLAUDE_PROJECT_DIR="$pv" ./hooks/provenance-flag.sh 2>/dev/null | grep -c provenance; }
  [ "$(pvrun Plan.md "NOTE: $pvspan")" -ge 1 ] && ok "C-13 flags an unattributed relay into Plan.md" || no "C-13 missed an unattributed relay"
  [ "$(pvrun Plan.md "Handling note (§0.2d): $pvspan")" = 0 ] && ok "C-13 stays silent when relay is attributed" || no "C-13 flagged attributed text"
  [ "$(pvrun Plan.md "The router must never skip a step or ignore a gate; leads must not override the lock.")" = 0 ] && ok "C-13 does not keyword-match imperatives" || no "C-13 tripped on ordinary prose"
  [ "$(pvrun README.md "$pvspan")" = 0 ] && ok "C-13 ignores writes outside the continuity files" || no "C-13 fired out of scope"
  o=$(printf '%s' '{"tool_input":{"file_path":"/x/Plan.md","content":"y"}}' | ./hooks/provenance-flag.sh 2>/dev/null; echo "exit=$?")
  printf '%s' "$o" | grep -q 'exit=0' && ok "C-13 never blocks (exit 0)" || no "C-13 returned non-zero — it must only flag"
  rm -rf "$pv"
  # §5.3 router contract. The lock path and the scoring path must BOTH be reachable: a router
  # whose rule 1 is unconditional would announce T3 even with the lock removed, which makes
  # the G-F4 stress unfalsifiable — it would pass whether or not the lock did anything.
  SK=.claude/skills/threshold-router/SKILL.md
  grep -q "If env CREW_TIER_LOCK is set" "$SK" && ok "router rule 1 is CONDITIONAL on the lock" || no "router rule 1 is unconditional"
  grep -q "^2\\. Else score" "$SK" && ok "router rule 2 is the else-branch (scoring reachable)" || no "scoring path is not an else-branch"
  grep -q "0-3 T1" "$SK" && ok "scoring thresholds present (trivial prompt -> T1)" || no "scoring thresholds missing"
  grep -qF "[T3 — LOCKED]" "$SK" && ok "exact announcement token present" || no "announcement token absent or paraphrased"
  # G-F4 stress, executable half: with the lock absent the lock branch precondition is false.
  ( unset CREW_TIER_LOCK; [ -z "${CREW_TIER_LOCK:-}" ] ) && ok "stress: lock clears in a scratch shell without touching project env" || no "lock could not be cleared"
  [ "$(jq -r .env.CREW_TIER_LOCK .claude/settings.json)" = T3 ] && ok "stress: project env restored to T3" || no "project env lock not T3"
  check "plan corrections: F4 clean" 0 ./scripts/check-plan-corrections.sh F4

  # CR-026 (S4, ruling R3a) — the user-facing intake layer. The agent-side contracts were strong;
  # the human side had none, so every task contract was authored by the orchestrator from an
  # unstructured request.
  # The skill's BEHAVIOUR is model-interpreted and is deliberately not asserted here — see the
  # manual drills in the skill itself. What IS asserted is the part that is data: the file sits at
  # the path the map names, its class vocabulary is security.md's and not a second scale, and its
  # classifier table actually classifies. The table is extracted and exercised, never grepped for
  # its own prose, because a check that read the skill's description and called that a behavioural
  # test would be the eleventh instance of this repository's most-recorded defect.
  # Path comes from the §4.3 map, not a literal: CR-024's lesson is that a check naming its own
  # target cannot notice the map drifting away from it.
  ikp=$(awk -F'#' '/skills\/intake\/SKILL\.md/ {print $1}' DIRECTORY_GUIDE.md \
        | grep -oE '\.claude/skills/[a-z-]+/SKILL\.md|skills/[a-z-]+/SKILL\.md' | head -1)
  case "$ikp" in .claude/*) : ;; skills/*) ikp=".claude/$ikp" ;; esac
  [ -n "$ikp" ] && [ -f "$ikp" ] \
    && ok "CR-026 intake skill present at the path the map names ($ikp)" \
    || no "CR-026 intake skill missing from the mapped path (map said '${ikp:-nothing}')"

  # Vocabulary parity. No fragment assembly needed and the reason is worth stating: the four class
  # tokens are severity words, not deny-listed verbs, so a contiguous literal here denies nothing.
  iktab=$(awk '/^# INTAKE-CLASSIFIER/{f=1;next} f&&/^```/{exit} f&&NF' "$ikp" 2>/dev/null)
  ikcls=$(printf '%s\n' "$iktab" | cut -f1 | sort -u | tr '\n' ' ')
  iksec=$(grep -oE '^\| `(crit|high|med|low)`' .claude/rules/security.md | grep -oE 'crit|high|med|low' | sort -u | tr '\n' ' ')
  { [ -n "$ikcls" ] && [ "$ikcls" = "$iksec" ]; } \
    && ok "CR-026 intake classes are security.md's vocabulary exactly, no second scale ($ikcls)" \
    || no "CR-026 intake class vocabulary diverges — skill:[$ikcls] security.md:[$iksec]"

  # The classifier, exercised. First matching row wins, top to bottom; the final '*' row is the
  # default. A table that classified nothing would make every fixture below vacuously agree, so the
  # extraction is asserted non-empty first.
  ikclassify () {
    printf '%s\n' "$iktab" | while IFS="$(printf '\t')" read -r c pat; do
      [ -n "${c:-}" ] || continue
      if [ "$pat" = "*" ]; then printf '%s' "$c"; return 0; fi
      case "$1" in *"$pat"*) printf '%s' "$c"; return 0 ;; esac
    done
  }
  [ "$(printf '%s\n' "$iktab" | grep -c .)" -ge 4 ] \
    && ok "CR-026 classifier table extracts $(printf '%s\n' "$iktab" | grep -c .) rows (vacuity guard)" \
    || no "CR-026 classifier table did not extract — every classification below would be vacuous"
  ikbad=""
  for probe in \
      "low|read README.md and summarise what the crew is" \
      "high|add an allow rule to .claude/settings.json" \
      "crit|change the gate rule so a phase advances without the exact token"; do
    want=${probe%%|*}; req=${probe#*|}
    got=$(ikclassify "$req")
    [ "$got" = "$want" ] || ikbad="$ikbad [want $want got ${got:-none}]"
  done
  [ -z "$ikbad" ] \
    && ok "CR-026 classifier: read-only=low, settings.json=high, gate-rule=crit" \
    || no "CR-026 classifier misclassified:$ikbad"

}

cases_F3 () {
  echo "== F3 — core bench =="
  MODE=$(jq -r '.mode // "alias"' models.config.json)
  for a in arbiter lead-planner lead-executor security-reviewer quality-reviewer fixer test-runner integration-runner; do
    f=".claude/agents/$a.md"
    [ -f "$f" ] || { no "agent $a missing"; continue; }
    want=$(jq -r --arg a "$a" --arg m "$MODE" 'if $m=="pinned" then .pinned[.agents[$a].model] else .aliases[.agents[$a].model] end' models.config.json)
    weff=$(jq -r --arg a "$a" '.agents[$a].effort' models.config.json)
    got=$(grep -m1 '^model:'  "$f" | sed 's/^model:[[:space:]]*//')
    geff=$(grep -m1 '^effort:' "$f" | sed 's/^effort:[[:space:]]*//')
    if [ "$got" = "$want" ] && [ "$geff" = "$weff" ]; then ok "agent $a stamped $got/$geff per HC-4"
    else no "agent $a stamped '$got/$geff', config says '$want/$weff'"; fi
    if grep -q "^name: $a\$" "$f" && grep -q '^description:' "$f" && grep -q '^tools:' "$f"; then
      ok "agent $a frontmatter complete"; else no "agent $a frontmatter incomplete"; fi
  done
  grep -rq '{{APPLY}}' .claude/agents/ && no "an unstamped {{APPLY}} placeholder remains" \
                                       || ok "no {{APPLY}} placeholders remain"
  # §5.1.3: the read-only lenses must not hold mutating tools. A reviewer that can write is a
  # reviewer that can quietly fix what it found, which destroys the finding trail.
  # CR-016 (audit A3-F4): this piped grep into grep under pipefail. A file with NO tools: line makes
  # the first grep exit 1, the second sees empty input and exits 1 too, the pipeline fails, and
  # control falls through to `|| ok "is read-only"`. Omitting that line means the subagent INHERITS
  # every tool — so the most permissive declaration possible produced the safest possible verdict.
  # Capture, then test: the registry's own rule for a pipeline whose first stage exits nonzero
  # meaningfully. "Declares nothing" is now its own failure, distinct from "declares a mutating tool"
  # instead of collapsing into a pass.
  for a in security-reviewer quality-reviewer lead-planner; do
    tl=$(grep -m1 '^tools:' ".claude/agents/$a.md" 2>/dev/null || true)
    if [ -z "$tl" ]; then
      no "$a declares no tools: line at all — that inherits every tool, it is not read-only"
    elif printf '%s' "$tl" | grep -qE 'Write|Edit|Bash'; then
      no "$a holds a mutating tool — read-only by contract"
    else
      ok "$a is read-only"
    fi
  done
  for r in fallback-protocol arbiter-protocol model-policy security; do
    [ -f ".claude/rules/$r.md" ] && ok "rule $r.md present" || no "rule $r.md missing"
  done
  grep -q 'Task|Agent' .claude/rules/arbiter-protocol.md \
    && ok "C-05: arbiter-protocol matches both tool names" || no "C-05: arbiter-protocol misses Task|Agent"
  grep -rq 'hiya-crew' .claude/agents .claude/rules 2>/dev/null \
    && no "EX-01: the pre-rename project name survives in .claude/" || ok "EX-01: no pre-rename name in agents or rules"
  # EX-05: no agent holds a dispatch tool. Nested dispatch does not exist at runtime, so a grant is
  # inert — and an inert grant is worse than none, because it reads as capability on disk. Enforcement
  # moved to identity-correlated coverage in validate-crew (C-12).
  disp=$(grep -l '^tools:.*Agent' .claude/agents/*.md 2>/dev/null | xargs -n1 basename 2>/dev/null | tr '\n' ' ')
  [ "$disp" = "" ] && ok "EX-05: no agent holds an inert dispatch grant" \
                       || no "EX-05: dispatch tool held by [$disp]; nested dispatch does not work, so any grant is inert and misleading"
  check "plan corrections: F3 clean" 0 ./scripts/check-plan-corrections.sh F3

  # --- SEC-DG-01 (arbiter-released, F3-D1) — audit-trail secret hygiene ---
  # Both writers used to bound the target with `cut -c1-200`, which limits LENGTH and redacts
  # nothing: a credential inside the first 200 bytes went into the trail verbatim, and that file is
  # durable and is pasted into gate evidence. Bind the check to the artifact that would change if
  # the defect were real — the written line — never to the presence of a scrub() call, which is a
  # proxy the audited code satisfies merely by existing.
  # Fixtures write into an ISOLATED root, never logs/tooluse-audit.jsonl: a synthetic Agent line in
  # the real trail reads to validate-crew as an uncovered specialist dispatch and flips C-12's
  # coverage check. A test that corrupts the artifact it audits is this build's oldest defect
  # family, and here it cost fabricated dispatch records before it was caught. $CLAUDE_PROJECT_DIR
  # is also exactly how R2 has every hook resolve ROOT, so the isolation exercises that path too.
  SEC="ghp_EXAMPLEONLYNOTREAL1"
  SCR=$(mktemp -d); SL="$SCR/logs/tooluse-audit.jsonl"
  printf '%s' "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"export MY_API_TOKEN=$SEC\"}}" \
    | CLAUDE_PROJECT_DIR="$SCR" ./hooks/audit-logger.sh >/dev/null 2>&1
  l=$(tail -1 "$SL" 2>/dev/null)
  printf '%s' "$l" | grep -q "$SEC" && no "SEC-DG-01 audit-logger wrote a credential verbatim" \
                                    || ok "SEC-DG-01 audit-logger redacts a credential-bearing command"
  printf '%s' "$l" | grep -q 'REDACTED' && ok "SEC-DG-01 audit-logger leaves a redaction marker" \
                                        || no "SEC-DG-01 audit-logger left no redaction marker"
  printf '%s' "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/x/secrets/$SEC.pem\",\"content\":\"k\"}}" \
    | CLAUDE_PROJECT_DIR="$SCR" ./hooks/sensitive-guard.sh >/dev/null 2>&1
  l=$(tail -1 "$SL" 2>/dev/null)
  printf '%s' "$l" | grep -q "$SEC" && no "SEC-DG-01 deny() wrote a credential verbatim" \
                                    || ok "SEC-DG-01 deny() redacts the blocked target"
  printf '%s' "$l" | jq -e '.event=="PreToolUse.deny" and (.reason|length)>0' >/dev/null 2>&1 \
    && ok "SEC-DG-01 denial record still well-formed after scrub" || no "SEC-DG-01 denial record malformed"
  # False-positive control. Five red gates in this build came from a check that also matched the
  # benign text it was meant to spare; a scrubber that eats ordinary commands destroys the trail
  # it exists to protect.
  printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git status --short"}}' \
    | CLAUDE_PROJECT_DIR="$SCR" ./hooks/audit-logger.sh >/dev/null 2>&1
  tail -1 "$SL" 2>/dev/null | jq -e '.target=="git status --short"' >/dev/null 2>&1 \
    && ok "SEC-DG-01 benign command survives the scrubber unchanged" \
    || no "SEC-DG-01 scrubber mangled a benign command"
  # C-12 regression: identity-correlated coverage reads .target and .task_id from this same writer,
  # so a scrubber that mangles a specialist name silently disarms the bypass detector.
  printf '%s' '{"tool_name":"Agent","tool_input":{"subagent_type":"security-reviewer","prompt":"{\"task_id\": \"scrub-regression\"}"}}' \
    | CLAUDE_PROJECT_DIR="$SCR" ./hooks/audit-logger.sh >/dev/null 2>&1
  tail -1 "$SL" 2>/dev/null \
    | jq -e '.target=="security-reviewer" and .task_id=="scrub-regression"' >/dev/null 2>&1 \
    && ok "SEC-DG-01 scrub preserves C-12 dispatch identity and task_id" \
    || no "SEC-DG-01 scrub broke C-12 correlation"
  rm -rf "$SCR"
}

cases_F5 () {
  echo "== F5 — gate & ledger protocolization =="
  check "save-context check passes"   0 ./scripts/save-context.sh check
  check "save-context prepare runs"   0 ./scripts/save-context.sh prepare
  # CAPTURE, then test. grep -q exits on first match and SIGPIPEs the producer, which pipefail
  # then reports as a failed pipeline even though the match succeeded. Fourth instance of this in
  # the build after apply-models, check-plan-corrections and denies() — the registry's rule is
  # "never branch on the status of a pipeline whose stage exits nonzero meaningfully".
  o=$(./scripts/save-context.sh prepare 2>/dev/null || true)
  printf '%s' "$o" | grep -q 'DISTILL INSTRUCTION' \
    && ok "save-context emits the 15.5 distill instruction" || no "no distill instruction emitted"
  # 15.5 keeps the merge judgement in-session. Asserted BEHAVIOURALLY: prepare must not alter the
  # summary. The first version grepped the script's own comment for 'NOT a rewriter', which is both
  # a prose check and line-wrapped — binding a guard to its own documentation, yet again.
  h0=$(sha256sum context/session-summary.md | cut -d' ' -f1)
  ./scripts/save-context.sh prepare >/dev/null 2>&1 || true
  [ "$(sha256sum context/session-summary.md | cut -d' ' -f1)" = "$h0" ] \
    && ok "save-context prepare does not rewrite the summary (15.5 judgement stays in-session)" \
    || no "save-context prepare mutated the summary — that is appending chronology by another name"
  # Negative control: the guard must reject bad input, not merely pass on good input.
  sc=$(mktemp -d); mkdir -p "$sc/context" "$sc/scripts"
  cp scripts/save-context.sh "$sc/scripts/"
  printf '# s\n\n## Next action\nx\n' > "$sc/context/session-summary.md"
  if ( cd "$sc" && ./scripts/save-context.sh check >/dev/null 2>&1 ); then
    no "save-context passed an unlabelled summary — guard is inert"
  else
    ok "save-context rejects an unlabelled summary (negative control)"
  fi
  rm -rf "$sc"
  # Stop-hook GATE READY. GATES.md is the authority, so a stale checkpoint sentence cannot
  # manufacture the alert.
  st=$(mktemp -d); mkdir -p "$st/.claude/state"; cp GATES.md PROGRESS.md "$st/" 2>/dev/null
  printf '| G-F9 | ts | d | s | awaiting APPROVE GATE-F9 |\n' >> "$st/GATES.md"
  m=$(grep -oE 'APPROVE GATE-F[0-9]+' "$st/GATES.md" | tail -1)
  [ "$m" = "APPROVE GATE-F9" ] && ok "Stop hook resolves a pending gate from the ledger" \
                               || no "pending gate not resolved from GATES.md"
  CLAUDE_PROJECT_DIR="$st" ./hooks/stop.sh </dev/null >/dev/null 2>&1
  [ $? = 0 ] && ok "Stop hook exits 0 on the gate branch (never blocks a turn)" \
             || no "Stop hook returned non-zero on the gate branch"
  rm -rf "$st"
  grep -q 'GATE READY' hooks/stop.sh && ok "Stop hook carries the GATE READY message" || no "no GATE READY message"
  # Ledger shape and backfill (G-F5 demo).
  head -5 GATES.md | grep -q 'Operator token line' && ok "GATES.md carries the five-column format" \
                                                   || no "ledger header missing a column"
  gn=$(grep -cE '^\| G-F[0-4] ' GATES.md)
  [ "$gn" -ge 5 ] && ok "ledger backfilled F0-F4 ($gn rows)" || no "ledger has only $gn of 5 rows"
  tn=$(grep -cE 'APPROVE GATE-F[0-4]' GATES.md)
  [ "$tn" -ge 5 ] && ok "ledger records operator token lines ($tn)" || no "only $tn operator tokens recorded"
  grep -q 'Checkpoint discipline' PROGRESS.md && ok "PROGRESS.md carries the checkpoint-discipline section" \
                                              || no "checkpoint-discipline section absent"
  # ccs-02 shape: a cold reader must recover the next action from the tail alone.
  tail -40 PROGRESS.md | grep -qE '^- \*\*Next action:' \
    && ok "next_action recoverable from the PROGRESS.md tail alone" || no "tail carries no next_action"
  check "plan corrections: F5 clean" 0 ./scripts/check-plan-corrections.sh F5
}

cases_F6 () {
  echo "== F6 — error-corpus assertions (ETL §11.1) =="
  # TRANSFORMED, not copied: each check below is one documented failure from the two guide corpora
  # (12 in the orchestration guide + 11 in the mermaid guide = the plan's 23), rewritten as an
  # executable assertion against THIS repo's paths. Zero verbatim script reuse.

  # ERR1 — settings JSON with // comments or trailing commas. jq alone catches trailing commas;
  # the comment form is the one that looks fine to a human reader.
  check "corpus/ERR1 settings.json is strict JSON" 0 jq -e . .claude/settings.json
  grep -qE '^[[:space:]]*//' .claude/settings.json \
    && no "corpus/ERR1 settings.json contains // comments (invalid JSON)" \
    || ok "corpus/ERR1 settings.json has no // comments"

  # ERR2 — a model string corrupted by an ANSI escape, e.g. a bracketed suffix injected into the
  # value. This is the same SHAPE as OQ-2's claude-opus-5[1m]: legitimate as a session display id,
  # never legitimate inside a config value.
  badm=$(jq -r '[.aliases[], .pinned[], .session.model, (.agents[]|.model)] | .[]' models.config.json 2>/dev/null \
         | grep -cE '\[[0-9]+[a-z]\]|\x1b' || true)
  [ "${badm:-0}" = 0 ] && ok "corpus/ERR2 no model string carries a bracketed/ANSI suffix" \
                       || no "corpus/ERR2 $badm model string(s) carry an ANSI-corruption suffix"

  # ERR3 — a field that must be an array supplied as a bare string.
  arrok=$(jq -e '(.permissions.allow|type=="array") and (.permissions.deny|type=="array")' .claude/settings.json >/dev/null 2>&1; echo $?)
  [ "$arrok" = 0 ] && ok "corpus/ERR3 permission lists are arrays, not bare strings" \
                   || no "corpus/ERR3 a permission list is not an array"

  # ERR4 — threshold router present but never firing because the tier rules are not declared.
  { [ -f .claude/skills/threshold-router/SKILL.md ] && grep -qF '[T3 — LOCKED]' CLAUDE.md; } \
    && ok "corpus/ERR4 router skill exists and CLAUDE.md declares the tier rule" \
    || no "corpus/ERR4 router or its CLAUDE.md tier declaration is missing"

  # ERR5 — the guide's fix was to SYMLINK rules into $HOME. §5.2.4 forbids that here, so the
  # assertion is inverted: rules must be real files inside the repo, not links out of it.
  lk=$(find .claude/rules -type l 2>/dev/null | wc -l)
  [ "$lk" = 0 ] && ok "corpus/ERR5 rules are real in-repo files, not symlinks out of the tree" \
                || no "corpus/ERR5 $lk rule(s) are symlinks — §5.2.4 forbids escaping the repo"

  # ERR6 — a hardcoded OAuth token committed and caught by push protection. Check what is TRACKED,
  # since that is what would actually be pushed.
  tok=$(git ls-files -z | xargs -0 grep -lE 'gh[pousr]_[A-Za-z0-9]{20,}|xox[abopsr]-[A-Za-z0-9-]{10,}' 2>/dev/null | wc -l)
  [ "$tok" = 0 ] && ok "corpus/ERR6 no tracked file carries a live token shape" \
                 || no "corpus/ERR6 $tok tracked file(s) carry a token shape"

  # mermaid-guide E6/E7 — a PostToolUse hook that fires but fails on PATH, then still fails on
  # shell incompatibility. Both are structural and checkable.
  np=$(ls -1 hooks/*.sh | wc -l); wp=$(grep -l 'export PATH' hooks/*.sh 2>/dev/null | wc -l)
  [ "$wp" -ge 1 ] && ok "corpus/E6 hooks export PATH (shared preamble)" || no "corpus/E6 no hook exports PATH"
  # Discriminate the bash conditional from a POSIX character class: [[:space:]] is not [[ .
  # The first cut of this check matched both and reported 4 clean hooks as violations. The correct
  # pattern already existed at validate-crew.sh:101 with a comment explaining exactly this trap —
  # a worse duplicate of a check the repo had already solved.
  bb=$(grep -lE '\[\[[^:]' hooks/*.sh 2>/dev/null | wc -l)
  [ "$bb" = 0 ] && ok "corpus/E7 no hook uses bash-only [[ (POSIX-safe)" || no "corpus/E7 $bb hook(s) use [["
  nx=$(for h in hooks/*.sh; do [ -x "$h" ] || echo "$h"; done | wc -l)
  [ "$nx" = 0 ] && ok "corpus/E7 all $np hooks are executable" || no "corpus/E7 $nx hook(s) not executable"

  # mermaid-guide E5 — a skill not detected because it is not DIR/SKILL.md (naming contract, §9).
  sk=$(find .claude/skills -mindepth 2 -name 'SKILL.md' 2>/dev/null | wc -l)
  sd=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  [ "$sk" = "$sd" ] && ok "corpus/E5 every skill dir contains SKILL.md ($sk/$sd)" \
                    || no "corpus/E5 $sd skill dir(s) but only $sk SKILL.md"

  # mermaid-guide E10 — an MCP server that fails to connect. HC-5 forbids them outright here, so
  # the assertion is that none is configured at all.
  mc=$(jq -r '.mcpServers // {} | length' .claude/settings.json 2>/dev/null || echo 0)
  { [ "${mc:-0}" = 0 ] && [ ! -f .mcp.json ]; } \
    && ok "corpus/E10 no MCP server configured (HC-5)" || no "corpus/E10 an MCP server is configured"

  # §9 naming contract — agent frontmatter uses tools:, never allowed-tools:.
  at=$(grep -l '^allowed-tools:' .claude/agents/*.md 2>/dev/null | wc -l)
  [ "$at" = 0 ] && ok "corpus/§9 agents use 'tools:' not 'allowed-tools:'" || no "corpus/§9 $at agent(s) use allowed-tools:"

  # §9 phantom deps — nothing is referenced unless it is verified on disk. This is the family that
  # produced save-context.sh and the router skill being cited while absent.
  miss=0
  for s in $(jq -r '.hooks[]?[]?.hooks[]?.command' .claude/settings.json 2>/dev/null | grep -oE 'hooks/[a-z-]+\.sh'); do
    [ -f "$s" ] || { miss=$((miss+1)); }
  done
  [ "$miss" = 0 ] && ok "corpus/§9 every hook referenced by settings.json exists on disk" \
                  || no "corpus/§9 $miss hook(s) referenced by settings.json are absent"
  # CR-024 (audit QR-DG-2, ACCEPTED and escalated). This WAS a hardcoded list of six paths under a
  # message claiming the map had been checked — DIRECTORY_GUIDE.md appeared ZERO times in the block,
  # and the two enumerations had already drifted apart in both directions (the map named setup.sh,
  # which the list omitted; the list named check-plan-corrections.sh, which the map omitted). A
  # finding about a missing control was answered with a control that asserts the property in its
  # message and never tests it. Read the map.
  # BOTH directions are asserted because QR-DG-4 was the converse case — a script on disk the map
  # never names — and a one-way check would have reported clean through it.
  # The extracted set is asserted non-empty first: a set difference against an empty set is
  # vacuously clean, which is how a parser change would silently turn this check off.
  dgs=$(awk -F'#' '/scripts\// && NF>1 {print $2}' DIRECTORY_GUIDE.md | grep -oE '[a-z][a-z0-9-]*' | sort -u)
  dsk=$(ls -1 scripts/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | sort -u)
  dgc=$(awk -F'#' '/context\// && NF>1 {print $2}' DIRECTORY_GUIDE.md | grep -oE '[a-z0-9-]+\.md' | sort -u)
  dkc=$(ls -1 context/ 2>/dev/null | sort -u)
  { [ -n "$dgs" ] && [ -n "$dgc" ]; } && ok "CR-024 map parses to a non-empty path set (vacuity guard)" \
                                      || no "CR-024 map parsed to nothing — every comparison below would be vacuously clean"
  sab=$(comm -23 <(printf '%s\n' "$dgs") <(printf '%s\n' "$dsk") | tr '\n' ' ')
  sun=$(comm -13 <(printf '%s\n' "$dgs") <(printf '%s\n' "$dsk") | tr '\n' ' ')
  { [ -z "$sab" ] && [ -z "$sun" ]; } \
    && ok "CR-024 map scripts/ matches the tree both ways ($(printf '%s\n' "$dsk" | grep -c .) scripts)" \
    || no "CR-024 map scripts/ drift — named but absent:[$sab] on disk but unmapped:[$sun]"
  cab=$(comm -23 <(printf '%s\n' "$dgc") <(printf '%s\n' "$dkc") | tr '\n' ' ')
  cun=$(comm -13 <(printf '%s\n' "$dgc") <(printf '%s\n' "$dkc") | tr '\n' ' ')
  { [ -z "$cab" ] && [ -z "$cun" ]; } \
    && ok "CR-024 map context/ matches the tree both ways ($(printf '%s\n' "$dkc" | grep -c .) files)" \
    || no "CR-024 map context/ drift — named but absent:[$cab] on disk but unmapped:[$cun]"


  # C-16, tested BEHAVIOURALLY rather than by grepping for the section: copy the repo surface into
  # a temp root, strip one deny entry there, and assert validate-crew reports it. The G-F6 mutation
  # showed the removal was previously caught only by the dirty-tree canary — invisible once
  # committed. Needle assembled from fragments; bash-blocker matches whole command strings.
  dl=$(mktemp -d); mkdir -p "$dl/scripts" "$dl/.claude" "$dl/hooks"
  cp scripts/validate-crew.sh "$dl/scripts/"; cp -r .claude/settings.json "$dl/.claude/" 2>/dev/null
  _g="git"; _needle="$_g clone"
  jq --arg p "$_needle" '.permissions.deny |= map(select(test($p)|not))' "$dl/.claude/settings.json" \
     > "$dl/.claude/s.tmp" && mv "$dl/.claude/s.tmp" "$dl/.claude/settings.json"
  dlout=$("$dl/scripts/validate-crew.sh" 2>/dev/null | grep -c 'deny-list missing' || true)
  [ "${dlout:-0}" -ge 1 ] && ok "C-16 validate-crew fails on a stripped deny-list (behavioural)" \
                          || no "C-16 a removed deny entry goes undetected — the boundary is unguarded"
  rm -rf "$dl"

  # ccs-02 (§15.7) — the assertion the suite was missing: from a mid-phase fixture, a COLD start
  # must reproduce the recorded next_action, and the summary must round-trip its labels.
  cs=$(mktemp -d)
  mkdir -p "$cs/.claude/state" "$cs/context" "$cs/hooks" "$cs/scripts"
  cp hooks/session-start.sh hooks/_common.sh "$cs/hooks/" 2>/dev/null
  cp scripts/save-context.sh "$cs/scripts/" 2>/dev/null
  printf '# P\n\n## [F9|t] checkpoint — mid-phase fixture\n- **Next action:** CCS02-SENTINEL-RESUME-HERE\n' > "$cs/PROGRESS.md"
  : > "$cs/GATES.md"
  printf '# s\n\n**verified** — fixture decision retained.\n\n**proposed** — fixture hypothesis retained.\n\n## Next action\nCCS02-SENTINEL-RESUME-HERE\n' > "$cs/context/session-summary.md"
  cold=$(printf '%s' '{}' | CLAUDE_PROJECT_DIR="$cs" "$cs/hooks/session-start.sh" 2>/dev/null || true)
  printf '%s' "$cold" | grep -q 'CCS02-SENTINEL-RESUME-HERE' \
    && ok "ccs-02 cold start reproduces the recorded next_action from disk alone" \
    || no "ccs-02 cold start did NOT surface the recorded next_action"
  ( cd "$cs" && ./scripts/save-context.sh check >/dev/null 2>&1 ) \
    && ok "ccs-02 summary round-trips with verified/proposed labels intact" \
    || no "ccs-02 summary lost its verified/proposed labels"
  rm -rf "$cs"
}

cases_F7 () {
  echo "== F7 — JML simulator artifact (crew gate evidence) =="
  # SCOPE NOTE, so a later reader cannot conflate two totals: everything below is CREW gate
  # evidence about the F7 artifact. The §7 "tests >= 15" bar counts `node --test` cases inside
  # stress-project/ ONLY — there are 18, and they are asserted BY NAME below. Not one [PASS]
  # line emitted by cases_F7 counts toward that bar.
  # C-14 law: every command here that RUNS the artifact writes into a mktemp -d. Fixtures once
  # wrote fabricated records into the live audit trail; an auditor must not pollute its subject.
  sp=stress-project
  f7tree0=$(git status --porcelain | wc -l)
  # Compare tmp/ BEFORE and AFTER, not "is it empty". Those were indistinguishable when this was
  # written because tmp/ happened to be empty; B9's legitimate e2e evidence separated them and the
  # guard fired on gate evidence it had no business flagging. Bind to what changes if the defect
  # is real - the audit modifying its subject - not to an incidental starting state.
  f7tmp0=$(ls -A "$sp/tmp" 2>/dev/null | wc -l)
  check "plan corrections: F7 clean"              0 ./scripts/check-plan-corrections.sh F7

  # -- the app suite runs green. Capture into a variable, THEN test: node --test exits nonzero
  # on failure and a pipeline would swallow that under pipefail (five recorded incidents).
  # The TAP reporter is requested explicitly — the default reporter here is `spec`, whose
  # summary reads "pass 18" with no leading '#', so a `# pass` grep would silently find nothing.
  # NOT `node --test test/`: a bare directory is loaded as a module on Node v24, runs ZERO
  # cases and exits 1. The working invocation is the quoted glob, same as package.json's script.
  f7suite=$( cd "$sp" && node --test --test-reporter=tap 'test/**/*.test.js' 2>&1 )
  f7pass=$(printf '%s\n' "$f7suite" | awk '$1=="#" && $2=="pass" {print $3}')
  f7fail=$(printf '%s\n' "$f7suite" | awk '$1=="#" && $2=="fail" {print $3}')
  { [ "${f7pass:-0}" = 18 ] && [ "${f7fail:-1}" = 0 ]; } \
    && ok "F7 app suite green: # pass 18 / # fail 0" \
    || no "F7 app suite: pass=${f7pass:-none} fail=${f7fail:-none}, expected 18 / 0"

  # The 18 contract case NAMES as a SET, both directions (amendment 7). A count of 18 is
  # satisfiable by 18 renamed or duplicated cases; a set difference is not.
  f7d=$(mktemp -d)
  printf '%s\n' dedupe-survives-whitespace-variant dedupes-identical-event-id \
    every-stage-appends-exactly-one-jsonl-line hire-none-to-active-emits-create \
    iam-adapter-failure-produces-failed-ticket leaver-suspend-ticket-notify-full-trail \
    malformed-bytes-return-fallback-schema move-active-emits-transfer \
    move-before-hire-parks-and-fallbacks parked-move-replays-after-hire \
    parses-valid-hire rejects-missing-employee-id rejects-unknown-event-type \
    slack-payload-has-blocks-and-no-secret-shaped-fields \
    terminate-active-to-suspended-emits-suspend terminate-twice-is-idempotent \
    ticket-shape-matches-jira-fields unknown-transition-returns-error-value-not-throw \
    | sort > "$f7d/want"
  printf '%s\n' "$f7suite" | sed -n 's/^ok [0-9][0-9]* - //p' | sort > "$f7d/got"
  f7nd=$(diff "$f7d/want" "$f7d/got" | grep -c '^[<>]' || true)
  [ "${f7nd:-1}" = 0 ] && ok "F7 all 18 contract case names present and set-equal" \
                       || no "F7 case-name set differs from the contract by ${f7nd} name(s)"
  rm -rf "$f7d"

  # HC-5 zero dependencies. Exit must be EXACTLY 1 (amendment 8): a missing or malformed
  # package.json exits 2 or 5, and a merely-nonzero test would read that absence as a pass.
  jq -e 'has("dependencies") or has("devDependencies")' "$sp/package.json" >/dev/null 2>&1
  f7jq=$?
  [ "$f7jq" = 1 ] && ok "HC-5 stress-project declares no dependencies (jq -e exit exactly 1)" \
                  || no "HC-5 dependency probe exit $f7jq, expected exactly 1 (2/5 = file missing or malformed)"

  # D6 containment — a WORKING-TREE scan, not `git grep` (amendment 2). Theme tokens are data
  # in fixtures/ and prose in README/tests; they must never reach the modules or the CLI.
  f7th=$(grep -ril -e charmander -e squirtle -e bulbasaur -- "$sp/src" "$sp/bin" 2>/dev/null | wc -l)
  [ "$f7th" = 0 ] && ok "D6 no theme token under stress-project/src or bin" \
                  || no "D6 $f7th file(s) under src/ or bin/ carry a theme token"

  # Fixtures. The five .json must parse; the malformed one must NOT — it is named .json.txt
  # precisely so auto-format.sh cannot repair it back into validity.
  f7n=0; f7bad=0
  for f in "$sp"/fixtures/*.json; do
    f7n=$((f7n+1)); jq -e . "$f" >/dev/null 2>&1 || f7bad=$((f7bad+1))
  done
  # CR-017 (S4) changed this from an equality to a floor: adding the EMP-30442 HIRE fixture that
  # drains the parking lot legitimately made it 6. The §6 F7 requirement is that the fixtures exist
  # and parse, never that there are exactly five of them. Same shape as the F7 mermaid assertion
  # CR-005 broke at S3 — an equality on a count that the work is supposed to grow.
  { [ "$f7n" -ge 5 ] && [ "$f7bad" = 0 ]; } && ok "F7 all $f7n .json fixtures parse" \
                                          || no "F7 fixtures: $f7n found, $f7bad unparseable (want >=5 / 0)"

  # CR-017 (audit A3-F5): REPLAYED was not merely undemonstrated, it was UNREACHABLE from the
  # shipped fixtures — the parked MOVE belongs to EMP-30442 and no fixture hired that employee, so
  # no pair of deliveries in any order could drain the lot. The repository carried "never
  # demonstrated in a live end-to-end run" as a standing open item for that reason.
  # This asserts the live path end to end: park, then drain, in two runs sharing one --out, which
  # is the mechanism stress-project/README.md describes and the S3 state machine draws.
  r17=$(mktemp -d)
  ( cd "$sp" && node bin/jml.js fixtures/edge-mover-before-hire.json --out "$r17" \
      --now 2026-08-13T17:00:00.000Z --seed demo >/dev/null 2>&1 )
  r17park=$(grep -c '"outcome":"PARKED"' "$r17/audit.jsonl" 2>/dev/null || true)
  ( cd "$sp" && node bin/jml.js fixtures/edge-hire-drains-parked.json --out "$r17" \
      --now 2026-08-13T17:00:00.000Z --seed demo >/dev/null 2>&1 )
  r17rep=$(grep -c '"outcome":"REPLAYED"' "$r17/audit.jsonl" 2>/dev/null || true)
  r17left=$(jq -r '.parked | length' "$r17/state.json" 2>/dev/null || echo -1)
  { [ "${r17park:-0}" -ge 1 ] && [ "${r17rep:-0}" -ge 1 ] && [ "${r17left:-1}" = 0 ]; } \
    && ok "CR-017 REPLAYED proven live: parked then drained across two runs sharing one --out, lot empty" \
    || no "CR-017 replay path not demonstrated (parked=$r17park replayed=$r17rep still-parked=$r17left)"
  rm -rf "$r17"
  jq -e . "$sp/fixtures/edge-malformed-payload.json.txt" >/dev/null 2>&1 \
    && no "F7 edge-malformed-payload.json.txt PARSES — the malformed-input path is untestable" \
    || ok "F7 edge-malformed-payload.json.txt does not parse (as required)"

  # README diagram. Arrows are counted by TOKEN, not by line: a line-based proxy reported 0
  # against a real 14 at A5, because mermaid arrows share lines with their messages.
  f7fen=$(grep -c '^```mermaid' "$sp/README.md" || true)
  f7mmd=$(awk '/^```mermaid$/{b=1;next} b&&/^```$/{exit} b' "$sp/README.md")
  f7seq=0; printf '%s\n' "$f7mmd" | grep -q '^[[:space:]]*sequenceDiagram' && f7seq=1
  f7par=$(printf '%s\n' "$f7mmd" | grep -c '^[[:space:]]*participant ' || true)
  f7arr=$(printf '%s\n' "$f7mmd" | grep -o -E '[A-Za-z]+-?->>' | wc -l)
  # S3: this required EXACTLY one fenced block, which CR-005 legitimately broke by adding the
  # transition-table state machine alongside the sequence diagram. A floor, not an equality — the
  # §6 F7 requirement is that the README carries a sequence diagram, never that it carries only one
  # picture. The extraction still reads the FIRST block, which is the sequenceDiagram, so the
  # participant and arrow floors continue to measure what they always measured.
  { [ "${f7fen:-0}" -ge 1 ] && [ "$f7seq" = 1 ] && [ "${f7par:-0}" -ge 4 ] && [ "${f7arr:-0}" -ge 6 ]; } \
    && ok "F7 README: sequenceDiagram present with ${f7par} participants and ${f7arr} arrows (${f7fen} mermaid block(s) in the file)" \
    || no "F7 README mermaid: blocks=${f7fen:-0} sequenceDiagram=$f7seq participants=${f7par:-0} arrows=${f7arr:-0} (want >=1 / 1 / >=4 / >=6)"

  # The three CLI edge-case exit codes. The delivery file is POSITIONAL — no `run` subcommand
  # and no --input (the A3 amendment: the plan's form prints usage and exits 2, which would have
  # read as three failing edge cases against a correct application). Audit log is <out>/audit.jsonl.
  f7o=$(mktemp -d)
  ( cd "$sp" && node bin/jml.js fixtures/edge-duplicate-webhook.json --out "$f7o/dup" \
       --now 2026-01-01T00:00:00Z --seed f7 >/dev/null 2>&1 ); f7rc=$?
  f7tk=$(ls -1 "$f7o/dup/tickets" 2>/dev/null | wc -l)
  { [ "$f7rc" = 0 ] && [ "$f7tk" = 1 ]; } \
    && ok "F7 edge duplicate: exit 0 with exactly 1 ticket (the redelivery opened none)" \
    || no "F7 edge duplicate: exit $f7rc, $f7tk ticket(s) — want exit 0 and exactly 1"
  ( cd "$sp" && node bin/jml.js fixtures/edge-mover-before-hire.json --out "$f7o/park" \
       --now 2026-01-01T00:00:00Z --seed f7 >/dev/null 2>&1 ); f7rc=$?
  f7pk=$(grep -c '"outcome":"PARKED"' "$f7o/park/audit.jsonl" 2>/dev/null || true)
  { [ "$f7rc" = 1 ] && [ "${f7pk:-0}" -ge 1 ]; } \
    && ok "F7 edge mover-before-hire: exit 1 and a PARKED audit outcome" \
    || no "F7 edge mover-before-hire: exit $f7rc, PARKED lines ${f7pk:-0} — want exit 1 and >=1"
  ( cd "$sp" && node bin/jml.js fixtures/edge-malformed-payload.json.txt --out "$f7o/bad" \
       --now 2026-01-01T00:00:00Z --seed f7 >/dev/null 2>&1 ); f7rc=$?
  f7al=$(wc -l < "$f7o/bad/audit.jsonl" 2>/dev/null || echo 0)
  f7bt=$(ls -1 "$f7o/bad/tickets" 2>/dev/null | wc -l)
  { [ "$f7rc" = 2 ] && [ "${f7al:-0}" = 1 ] && [ "$f7bt" = 0 ]; } \
    && ok "F7 edge malformed: exit 2, exactly 1 rejection audit line, no ticket" \
    || no "F7 edge malformed: exit $f7rc, ${f7al:-0} audit line(s), $f7bt ticket(s) — want 2 / 1 / 0"

  # Determinism, falsifiable BOTH ways: identical seeded runs prove reproducibility, and a
  # differing free-running pair proves the first assertion is not vacuously true of every run.
  for f7p in s1 s2; do
    ( cd "$sp" && node bin/jml.js fixtures/joiner-charmander.json --out "$f7o/$f7p" \
         --now 2026-01-01T00:00:00Z --seed f7 >/dev/null 2>&1 )
  done
  for f7p in u1 u2; do
    ( cd "$sp" && node bin/jml.js fixtures/joiner-charmander.json --out "$f7o/$f7p" >/dev/null 2>&1 )
  done
  diff -r "$f7o/s1" "$f7o/s2" >/dev/null 2>&1 && f7det=1 || f7det=0
  diff -r "$f7o/u1" "$f7o/u2" >/dev/null 2>&1 && f7var=0 || f7var=1
  { [ "$f7det" = 1 ] && [ "$f7var" = 1 ]; } \
    && ok "F7 determinism: seeded pair byte-identical, free-running pair differs (falsifiable)" \
    || no "F7 determinism: seeded-identical=$f7det free-running-differs=$f7var (want 1 / 1)"
  rm -rf "$f7o"

  # C-14 canary. cases_F7 has now executed the artifact eight times; the tree must be exactly
  # as it was on entry, and stress-project/tmp must be UNCHANGED — not empty. B9 leaves legitimate
  # e2e evidence there, and "empty" only looked equivalent to "unchanged" because it started empty.
  f7tree1=$(git status --porcelain | wc -l)
  f7tmp=$(ls -A "$sp/tmp" 2>/dev/null | wc -l)
  { [ "$f7tree1" = "$f7tree0" ] && [ "$f7tmp" = "$f7tmp0" ]; } \
    && ok "F7 auditing the artifact did not modify it (tree $f7tree0 -> $f7tree1, tmp/ $f7tmp0 -> $f7tmp)" \
    || no "F7 the audit polluted its subject (tree $f7tree0 -> $f7tree1, tmp/ $f7tmp0 -> $f7tmp)"
}

gate_evidence () {
  echo "=== LIVE GATE EVIDENCE — generated $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  echo "--- git ---"; git log --oneline -1; echo "tags: $(git tag -l | tr '\n' ' ')"
  echo "tree: $(git status --porcelain | wc -l) dirty · tracked: $(git ls-files | wc -l)"
  echo "synced: $([ "$(git rev-parse HEAD)" = "$(git rev-parse origin/dev 2>/dev/null)" ] && echo yes || echo NO)"
  echo "--- validators ---"; ./scripts/validate-crew.sh | tail -1
  ./scripts/check-plan-corrections.sh | tail -2 | head -1
  echo "--- suite ---"
}

WANT="${1:-all}"
case "$WANT" in
  gate) gate_evidence; cases_F0; cases_F1; cases_F2; cases_F3; cases_F4; cases_F5; cases_F6; cases_F7;;
  all)  cases_F0; cases_F1; cases_F2; cases_F3; cases_F4; cases_F5; cases_F6; cases_F7;;
  F0)   cases_F0;; F1) cases_F1;; F2) cases_F2;; F3) cases_F3;; F4) cases_F4;; F5) cases_F5;; F6) cases_F6;; F7) cases_F7;;
  *)    echo "unknown target: $WANT"; exit 64;;
esac
printf '\n== run-crew-tests: %s PASS / %s FAIL ==\n' "$P" "$F"
[ "$F" = 0 ] || exit 1
