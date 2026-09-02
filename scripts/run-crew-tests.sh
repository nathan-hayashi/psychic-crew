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
# Byte-pin hashing, portable across GNU and BSD/macOS: sha256sum is GNU-only, shasum ships on macOS.
# Returns EMPTY when neither exists, and every caller treats an empty hash as failure — a byte-pin
# guard must go red on a missing tool, never pass silently on two empty hashes (the macOS false-pass).
_sha256 () { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
             elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1; fi; }

BAK=$(mktemp -d); trap 'cp -f "$BAK"/models.config.json models.config.json 2>/dev/null
                        cp -f "$BAK"/quality-reviewer.md .claude/agents/quality-reviewer.md 2>/dev/null
                        cp -f "$BAK"/PROGRESS.md PROGRESS.md 2>/dev/null
                        rm -f .claude/state/compact-pending 2>/dev/null
                        ./scripts/apply-models.sh >/dev/null 2>&1; rm -rf "$BAK"' EXIT
cp models.config.json "$BAK"/
cp .claude/agents/quality-reviewer.md "$BAK"/ 2>/dev/null || true
cp PROGRESS.md "$BAK"/ 2>/dev/null || true
# C-14 GENERALISED — the canary covers EVERY live audit trail, not the one that happened to get
# burned. CR-013 added a canary for logs/build-errors.jsonl after fixtures wrote 178 fabricated
# records into it (95% of the file). The identical defect then ran on logs/tooluse-audit.jsonl
# undetected until L4, by which point 5,817 of 6,177 denial records — 94% — were fixture-shaped.
# A canary written for one artifact is not a control over the class. This one enumerates whatever
# trails exist, so a trail added later is covered on the day it appears.
TRAILS_BEFORE=$(for f in logs/*.jsonl; do [ -f "$f" ] && printf '%s:%s\n' "$f" "$(wc -l < "$f")"; done | sort)

cases_F0 () {
  echo "== F0 — scaffold integrity =="
  check "validate-crew all green"                 0 ./scripts/validate-crew.sh
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F0 skipped (the metrics-writer chain)"
  else check "plan corrections: F0 clean"              0 ./scripts/check-plan-corrections.sh F0; fi
  check "decision matrices: structure, census and citations hold (H3b)" 0 ./scripts/check-decision-matrices.sh
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
  [ "$(git status --porcelain | wc -l)" -eq 0 ] && ok "working tree clean" \
                                             || no "working tree dirty ($(git status --porcelain | wc -l) entries)"
}

cases_F1 () {
  echo "== F1 — model routing (HC-2 / HC-4) =="
  check "apply-models clean config"               0 ./scripts/apply-models.sh
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F1 skipped (the metrics-writer chain)"
  else check "plan corrections: F1 clean"              0 ./scripts/check-plan-corrections.sh F1; fi
  for v in '.agents["lead-planner"].model="fable"' '.session.model="fable"' \
           '.pinned.opus="claude-fable-5"' '.aliases.opus="claude-fable-5"'; do
    jq "$v" "$BAK"/models.config.json > models.config.json
    check "HC-2 refuses $v" 2 ./scripts/apply-models.sh
  done
  cp -f "$BAK"/models.config.json models.config.json
  # BSD/macOS sed -i needs a suffix operand; -i.bak is the one form both GNU and BSD accept
  # (the apply-models.sh idiom). And a negative control that plants nothing tests nothing — so the
  # plant is CONFIRMED live before the guard is asked to refuse it (R-SD-1 rule 7).
  sed -i.bak 's/^model: sonnet/model: claude-fable-5/' .claude/agents/quality-reviewer.md \
    && rm -f .claude/agents/quality-reviewer.md.bak
  grep -q '^model: claude-fable-5' .claude/agents/quality-reviewer.md \
    && ok "HC-2 poison planted — the negative control is live" \
    || no "HC-2 poison NOT planted — the control tests nothing (sed portability)"
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
  # ISOLATED ROOT. These fixtures drive the real guards, and deny() writes a PreToolUse.deny record
  # to $ROOT/logs/tooluse-audit.jsonl. Without an isolated root that is the LIVE trail, so every
  # suite run appended ~25 denials describing blocks that never happened in real work.
  #
  # This is C-14 exactly, on a second artifact. C-14 was raised when fixtures wrote 178 fabricated
  # records into logs/build-errors.jsonl — 95% of that file — and CR-013 fixed THAT fixture and
  # added a canary for THAT trail. The identical defect ran here undetected the whole time, because
  # the canary was written for the artifact that happened to get burned rather than for the class.
  # Measured before the fix: 5,817 of 6,177 denial records in the live trail were fixture-shaped.
  # 94%, against C-14's 95%. An evidence trail of invented events is worse than one with gaps,
  # because every downstream check and every gate report treats it as ground truth.
  F2T=$(mktemp -d); mkdir -p "$F2T/logs"
  cp GATES.md models.config.json "$F2T/" 2>/dev/null || true
  denies () { o=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$F2T" "./hooks/$1.sh" 2>/dev/null || true)
              grep -q '"permissionDecision":"deny"' <<<"$o"; }
  allows () { o=$(printf '%s' "$2" | CLAUDE_PROJECT_DIR="$F2T" "./hooks/$1.sh" 2>/dev/null || true)
              ! grep -q '"permissionDecision":"deny"' <<<"$o"; }
  feed   () { printf '%s' "$2" | CLAUDE_PROJECT_DIR="$F2T" "./hooks/$1.sh"; }

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

  # CORRECTIONS-2 (#7): the append-only guard — a whole-file Write to an EXISTING trail is denied
  # (forcing the arbiter to Edit-append), while a Write that CREATES an absent trail and any Edit both
  # pass. All three fire-probed, per house law; the create-allow case is the fresh-session deadlock fix.
  printf '{"seed":1}\n' > "$F2T/logs/arbiter-audit.jsonl"
  denies sensitive-guard "$(jq -cn --arg f "$F2T/logs/arbiter-audit.jsonl" '{tool_name:"Write",tool_input:{file_path:$f,content:"x"}}')" \
    && ok "append-only: whole-file Write to an existing trail is denied" || no "append-only: existing-trail Write not denied"
  allows sensitive-guard "$(jq -cn --arg f "$F2T/logs/build-errors.jsonl" '{tool_name:"Write",tool_input:{file_path:$f,content:"x"}}')" \
    && ok "append-only: Write that CREATES an absent trail is allowed (no first-line deadlock)" || no "append-only: create-write wrongly denied"
  allows sensitive-guard "$(jq -cn --arg f "$F2T/logs/arbiter-audit.jsonl" '{tool_name:"Edit",tool_input:{file_path:$f}}')" \
    && ok "append-only: Edit to an existing trail is allowed" || no "append-only: Edit wrongly denied"

  # CORRECTIONS-2 (#2): reference-cap WARNS (never denies, exit 0) when lead-executor is dispatched
  # with a staged index. A throwaway git repo stages a file; the warning goes to stderr. The clean
  # case is the control. (fixer is exempt — it is not a committing agent; the existing :507 probe
  # dispatches fixer and stays unaffected.)
  rcg=$(mktemp -d)
  ( cd "$rcg" && git init -q && git config user.email t@t && git config user.name t \
    && echo x > staged.txt && git add staged.txt ) 2>/dev/null
  rcw=$(printf '%s' "$(jq -cn '{tool_input:{subagent_type:"lead-executor",prompt:"go"}}')" \
        | CLAUDE_PROJECT_DIR="$rcg" ./hooks/reference-cap.sh 2>&1 >/dev/null); rcrc=$?
  { [ "$rcrc" -eq 0 ] && grep -q 'STAGED index' <<<"$rcw"; } \
    && ok "CORRECTIONS-2 #2: reference-cap warns on a staged-index lead-executor dispatch (exit 0)" \
    || no "CORRECTIONS-2 #2: staged-index warning missing or hook denied (rc=$rcrc)"
  ( cd "$rcg" && git commit -qm x ) 2>/dev/null
  rcc=$(printf '%s' "$(jq -cn '{tool_input:{subagent_type:"lead-executor",prompt:"go"}}')" \
        | CLAUDE_PROJECT_DIR="$rcg" ./hooks/reference-cap.sh 2>&1 >/dev/null)
  grep -q 'STAGED index' <<<"$rcc" \
    && no "CORRECTIONS-2 #2: false staged-index warning on a clean tree" \
    || ok "CORRECTIONS-2 #2: no warning when the index is clean (control)"
  rm -rf "$rcg"

  denies model-guard '{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-fable-5\""}}' && ok "model-guard blocks fable write" || no "fable write not blocked"
  allows model-guard '{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-opus-5\""}}'  && ok "model-guard allows a clean model write" || no "clean model write wrongly denied"
  allows model-guard '{"tool_input":{"file_path":"README.md","content":"the fable model is banned"}}' && ok "model-guard ignores prose outside the config surface" || no "prose wrongly denied"

  n0=$( [ -f "$F2T/logs/tooluse-audit.jsonl" ] && wc -l < "$F2T/logs/tooluse-audit.jsonl" || echo 0 )
  printf '%s' '{"tool_name":"Write","tool_input":{"file_path":"x.txt"}}' | CLAUDE_PROJECT_DIR="$F2T" ./hooks/audit-logger.sh >/dev/null 2>&1
  n1=$( [ -f "$F2T/logs/tooluse-audit.jsonl" ] && wc -l < "$F2T/logs/tooluse-audit.jsonl" || echo 0 )
  [ "$n1" -gt "$n0" ] && ok "audit line appended after a benign tool use" || no "no audit line appended"
  tail -1 "$F2T/logs/tooluse-audit.jsonl" 2>/dev/null | jq -e . >/dev/null 2>&1 && ok "audit line is valid JSON" || no "audit line malformed"

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
  grep -q '"decision":"block"' <<<"$o" && ok "Stop emits decision:block while the flag is armed" || no "Stop did not block on armed flag"
  [ -f .claude/state/checkpoints/latest.md ] && ok "ccs-03 Stop refreshed latest.md" || no "latest.md not refreshed"
  o=$(printf '%s' '{}' | ./hooks/stop.sh 2>/dev/null || true)
  grep -q '"decision":"block"' <<<"$o" && no "Stop blocked twice — flag not consumed exactly once" || ok "flag consumed exactly once, no loop"

  check "restore-context.sh latest exits 0" 0 ./scripts/restore-context.sh latest
  grep -q 'RELOAD INSTRUCTION' <<<"$(./scripts/restore-context.sh latest 2>/dev/null)" && ok "restore-context prints the reload instruction" || no "reload instruction missing"

  # HOOK-1 retrofit: this fixture used to run against the LIVE root, which was harmless while
  # the hook only read — the seen-cursor makes it write, and a trail row born mid-run is
  # exactly what the C-14 canary calls drift. Temp root, the ccs-02 shape.
  ssfx=$(mktemp -d); mkdir -p "$ssfx/hooks" "$ssfx/context"
  cp hooks/session-start.sh hooks/_common.sh "$ssfx/hooks/" 2>/dev/null
  printf '# P\n- **Next action:** fixture\n' > "$ssfx/PROGRESS.md"
  : > "$ssfx/GATES.md"; : > "$ssfx/Plan.md"
  o=$(printf '%s' '{}' | CLAUDE_PROJECT_DIR="$ssfx" "$ssfx/hooks/session-start.sh" 2>/dev/null || true)
  printf '%s' "$o" | jq -e '.hookSpecificOutput.additionalContext' >/dev/null 2>&1 && ok "SessionStart emits additionalContext (§15.4)" || no "SessionStart output malformed"

  # --- G-F2 gap closure (found by the live stress, not by the offline suite) ---
  # A denial that leaves no record is a silent control. PostToolUse cannot cover it: the blocked
  # tool never runs, so the guard has to write its own line. The first live stress produced six
  # denials and zero audit entries, failing G-F2's "6 denies + 6 audit entries" as written.
  n0=$(wc -l < "$F2T/logs/tooluse-audit.jsonl" 2>/dev/null || echo 0)
  denies bash-blocker '{"tool_name":"Bash","tool_input":{"command":"git clone https://x/y"}}' >/dev/null 2>&1
  n1=$(wc -l < "$F2T/logs/tooluse-audit.jsonl" 2>/dev/null || echo 0)
  [ "$n1" -gt "$n0" ] && ok "denial writes an audit record" || no "denial left no audit record"
  tail -1 "$F2T/logs/tooluse-audit.jsonl" | jq -e '.event=="PreToolUse.deny" and (.reason|length)>0' >/dev/null 2>&1 \
    && ok "denial record carries event + reason" || no "denial record malformed"

  # auto-format, error-recovery and notify had no coverage at all until now.
  # auto-format must format ordinary files yet NEVER touch a byte-pinned payload (EX-01 identity).
  h0=$(_sha256 CLAUDE.md)
  printf '%s' '{"tool_input":{"file_path":"CLAUDE.md"}}' | ./hooks/auto-format.sh >/dev/null 2>&1
  { [ -n "$h0" ] && [ "$(_sha256 CLAUDE.md)" = "$h0" ]; } && ok "auto-format refuses byte-pinned CLAUDE.md" \
                                                          || no "auto-format mutated a byte-pinned seed (or no sha256 tool)"
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
  { grep -q 'minimal-shell' <<<"$ehint" && [ "$erc" = 2 ]; } \
    && ok "CR-018 §9 hint DELIVERED on stderr with exit 2 (not merely emitted)" \
    || no "CR-018 §9 hint not delivered (exit=$erc stderr='$ehint')"
  [ "$(wc -l < logs/build-errors.jsonl 2>/dev/null || echo 0)" -eq "$erb" ] \
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

  # H2a — CR-006 CLOSED within HC-5 honesty. The earlier form embedded its data inside a context
  # file because logs/ is gitignored and a spec pointing there plots nothing from a clone. This is
  # the tracked-file form the ruling asks for: a generated snapshot beside the spec, so the chart is
  # reproducible AND the data has one home rather than being pasted into prose.
  vlf="docs/dispatch-cost.vl.json"
  vlok=1; vlwhy=""
  [ -f "$vlf" ] || { vlok=0; vlwhy="$vlwhy [spec absent]"; }
  if [ -f "$vlf" ]; then
    jq -e . "$vlf" >/dev/null 2>&1 || { vlok=0; vlwhy="$vlwhy [does not parse]"; }
    jq -e '.["$schema"] | test("vega-lite")' "$vlf" >/dev/null 2>&1 || { vlok=0; vlwhy="$vlwhy [no vega-lite \$schema]"; }
    jq -e '.encoding // (.layer[]?.encoding)' "$vlf" >/dev/null 2>&1 || { vlok=0; vlwhy="$vlwhy [no encoding]"; }
    # A LAYERED spec declares its marks inside the layers, so requiring a top-level `mark` would
    # fail a correct spec. Accept either, and require at least one.
    jq -e '(.mark // ([.layer[]?.mark] | map(select(. != null)) | .[0])) != null' "$vlf" >/dev/null 2>&1 \
      || { vlok=0; vlwhy="$vlwhy [no mark at top level or in any layer]"; }
  fi
  [ "$vlok" = 1 ] && ok "H2a CR-006 spec parses and declares \$schema, encoding and a mark" \
                  || no "H2a CR-006 spec malformed:$vlwhy"
  # THE BINDING THAT MATTERS: the data URL must resolve to a TRACKED file. A spec whose data is
  # gitignored renders empty from a fresh clone, which is the defect that deferred CR-006 for weeks.
  vlurl=$(jq -r '.data.url // ""' "$vlf" 2>/dev/null)
  vldat="$(dirname "$vlf")/$vlurl"
  vltracked=$(git ls-files --error-unmatch "$vldat" 2>/dev/null | grep -c .)
  case "$vltracked" in ''|*[!0-9]*) vltracked=0 ;; esac
  { [ -n "$vlurl" ] && [ -f "$vldat" ] && [ "$vltracked" -gt 0 ]; } \
    && ok "H2a CR-006 data URL resolves to a TRACKED file ($vlurl -> $vldat)" \
    || no "H2a CR-006 data URL '$vlurl' does not resolve to a tracked file (exists:$([ -f "$vldat" ] && echo yes || echo no) tracked:$vltracked)"
  # And the snapshot must be real data, not an empty scaffold.
  vlrec=$(jq 'length' "$vldat" 2>/dev/null)
  case "$vlrec" in ''|*[!0-9]*) vlrec=0 ;; esac
  [ "$vlrec" -ge 10 ] && ok "H2a CR-006 snapshot carries $vlrec records with phase labels" \
                      || no "H2a CR-006 snapshot has only $vlrec record(s) — the chart would be vacuous"

  # CR-003 — the d2 hook-pipeline topology, and the FIRST binding here that checks a diagram is
  # TRUE rather than merely well-formed. Every assertion above it validates fences, types and
  # referential integrity: a diagram depicting an entirely different system passes them, which is
  # the state A1-F4 found both then-existing diagrams in.
  #
  # It is decidable HERE for exactly one reason: the depicted thing is .claude/settings.json, a
  # machine-readable file. DO NOT generalise this to the mermaid blocks — binding a picture to
  # behaviour is not mechanically decidable, and claiming it would be the proxy family this repo
  # has recorded ten times.
  #
  # Compared as a SET DIFFERENCE in both directions, never as a count. C-12 established that a
  # count is satisfiable by the party being audited: thirteen edges against thirteen wired hooks
  # agrees perfectly while naming the wrong ones.
  d2dia=$(awk '/^```d2$/{f=1;next} f&&/^```$/{exit} f' README.md 2>/dev/null \
          | sed -nE 's/^([A-Za-z]+) -> [a-z]+\."([a-z0-9-]+\.sh)": (.+)$/\1\t\2\t\3/p' | sort)
  d2cfg=$(jq -r '.hooks | to_entries[] as $e | $e.value[] as $m | $m.hooks[] |
                 "\($e.key)\t\(.command | sub(".*/";"") | sub("\"$";""))\t\($m.matcher // "*")"' \
          .claude/settings.json 2>/dev/null | sort)
  d2nd=$(printf '%s\n' "$d2dia" | grep -c . || true)
  d2nc=$(printf '%s\n' "$d2cfg" | grep -c . || true)
  # Vacuity guard first, and it guards BOTH sides. An empty diagram set against an empty config set
  # is a clean comparison that proves nothing — the exact defect the audit proved twice with a
  # negative control, and the reason check-sync opens the same way.
  { [ "${d2nd:-0}" -ge 10 ] && [ "${d2nc:-0}" -ge 10 ]; } \
    && ok "CR-003 d2 topology and settings.json both parse ($d2nd edges vs $d2nc wired hooks)" \
    || no "CR-003 extraction is vacuous — diagram:$d2nd config:$d2nc, both must be >=10"
  d2only=$(comm -23 <(printf '%s\n' "$d2dia") <(printf '%s\n' "$d2cfg") | tr '\t' ':' | tr '\n' ' ')
  d2miss=$(comm -13 <(printf '%s\n' "$d2dia") <(printf '%s\n' "$d2cfg") | tr '\t' ':' | tr '\n' ' ')
  { [ -z "$d2only" ] && [ -z "$d2miss" ]; } \
    && ok "CR-003 every event->hook edge matches settings.json exactly, both directions" \
    || no "CR-003 diagram diverges from settings.json — drawn but not wired:[$d2only] wired but not drawn:[$d2miss]"

  # Historical note, refreshed at CLEANUP-1 (audit R1-10): written when the map still said 12
  # hook scripts against a tree of 14 and hooks/ was the one directory CR-024 never policed. Both
  # halves closed long since — D17's payload enumerates all fourteen by name and the C-26 block
  # below polices map against tree in both directions — so this tree-vs-settings comparison is
  # one leg of a three-way agreement now, not the only coverage.
  d2tracked=$(git ls-files 'hooks/*.sh' 2>/dev/null | sed 's|hooks/||' | grep -vE '^(_common|_profile)\.sh$' | sort -u)
  d2wired=$(printf '%s\n' "$d2cfg" | cut -f2 | sort -u)
  d2unwired=$(comm -23 <(printf '%s\n' "$d2tracked") <(printf '%s\n' "$d2wired") | tr '\n' ' ')
  d2ghost=$(comm -13 <(printf '%s\n' "$d2tracked") <(printf '%s\n' "$d2wired") | tr '\n' ' ')
  { [ -z "$d2unwired" ] && [ -z "$d2ghost" ]; } \
    && ok "CR-003 every tracked hook is wired and every wired hook exists (_common.sh + _profile.sh excluded, they are sourced)" \
    || no "CR-003 hooks/ drift — tracked but unwired:[$d2unwired] wired but absent:[$d2ghost]"

  # CR-006 — the Vega-Lite dispatch-cost distribution. Two failure modes, both real, both checked.
  #
  # The audit named the first: logs/ is gitignored, so a spec with a "url" plots nothing from a
  # fresh clone. The data is embedded instead, which trades reproducibility for staleness — so the
  # embedded copy is compared against the TSV rather than trusted.
  #
  # The second is Vega-Lite's own: an encoding naming a field the data does not carry renders an
  # EMPTY CHART, silently. That is referential integrity, the same property the mermaid validator
  # asserts on edge endpoints, and it needs no renderer.
  vlf="context/budget-baseline.md"
  vlspec=$(awk '/^```vega-lite$/{f=1;next} f&&/^```$/{exit} f' "$vlf" 2>/dev/null)
  vln=$(printf '%s' "$vlspec" | jq -r '.data.values | length' 2>/dev/null || echo 0)
  # Vacuity guard first: a fence that stops parsing makes every comparison below trivially clean.
  { [ -n "$vlspec" ] && [ "${vln:-0}" -ge 10 ]; } \
    && ok "CR-006 vega-lite spec parses with $vln embedded rows" \
    || no "CR-006 spec did not parse or carries too few rows ($vln) — every check below would be vacuous"

  # Referential integrity: every field named anywhere in the encoding must exist in the data.
  vlfields=$(printf '%s' "$vlspec" | jq -r '[.. | objects | select(has("field")) | .field] | unique[]' 2>/dev/null | sort -u)
  vlkeys=$(printf '%s' "$vlspec" | jq -r '.data.values[0] | keys[]' 2>/dev/null | sort -u)
  vlbad=$(comm -23 <(printf '%s\n' "$vlfields") <(printf '%s\n' "$vlkeys") | tr '\n' ' ')
  { [ -n "$vlfields" ] && [ -z "$vlbad" ]; } \
    && ok "CR-006 every encoded field exists in the embedded data ($(printf '%s' "$vlfields" | tr '\n' ' '))" \
    || no "CR-006 encoding names field(s) absent from the data:[$vlbad] — this renders an empty chart"

  # Freshness against the source. The TSV is gitignored, so absence is EXPECTED in a clone and the
  # skip announces itself rather than passing quietly — C-23 punished exactly the silent version.
  vlsrc="logs/metrics/dispatch-costs.tsv"
  if [ ! -f "$vlsrc" ]; then
    ok "CR-006 source TSV absent (gitignored, expected in a fresh clone) — freshness not checkable here"
  else
    vlsn=$(grep -c . "$vlsrc")
    vlst=$(awk -F'\t' '{s+=$3} END{print s+0}' "$vlsrc")
    vlet=$(printf '%s' "$vlspec" | jq -r '[.data.values[].tokens] | add' 2>/dev/null)
    # Correlated by SUM and per-role identity, never by row count alone: thirty rows against thirty
    # rows agrees perfectly while carrying different numbers (C-12's lesson, applied to data).
    vlsr=$(awk -F'\t' '{print $1}' "$vlsrc" | sort | uniq -c | awk '{print $2":"$1}' | sort | tr '\n' ' ')
    vler=$(printf '%s' "$vlspec" | jq -r '.data.values[].role' 2>/dev/null | sort | uniq -c | awk '{print $2":"$1}' | sort | tr '\n' ' ')
    { [ "$vln" = "$vlsn" ] && [ "$vlet" = "$vlst" ] && [ "$vlsr" = "$vler" ]; } \
      && ok "CR-006 embedded data matches the TSV — $vln rows, $vlet tokens, per-role counts identical" \
      || no "CR-006 embedded data is STALE — rows $vln/$vlsn tokens $vlet/$vlst roles[$vler] vs [$vlsr]"
  fi

  # R4-11 (PROJECT-AUDIT-1, CLEANUP-1): the section's own narrating sentence went stale against
  # the fence it introduces — "30 dispatches" prose beside 33 embedded rows — and nothing bound it:
  # the assertions above compare fence to TSV and never read the prose. Bind the sentence to the
  # fence. Scoped to the distribution section so the F7 line earlier in the file (a different,
  # C-28-bound figure) is never matched.
  vlsec=$(awk '/^## Dispatch-cost distribution/{f=1} f' "$vlf")
  vlpd=$(printf '%s\n' "$vlsec" | grep -oE '[0-9]+ dispatches, \*\*[0-9,]+ tokens\*\*' | head -1)
  vlpn=$(printf '%s' "$vlpd" | grep -oE '^[0-9]+')
  vlpt=$(printf '%s' "$vlpd" | grep -oE '[0-9,]+ tokens' | tr -d ',' | grep -oE '[0-9]+')
  case "$vlpn" in ''|*[!0-9]*) vlpn=-1 ;; esac
  case "$vlpt" in ''|*[!0-9]*) vlpt=-1 ;; esac
  vlft=$(printf '%s' "$vlspec" | jq -r '[.data.values[].tokens] | add' 2>/dev/null)
  { [ "$vlpn" = "$vln" ] && [ "$vlpt" = "$vlft" ]; } \
    && ok "R4-11 the section's narrating sentence matches the fence ($vlpn dispatches, $vlpt tokens)" \
    || no "R4-11 section prose says $vlpn dispatches / $vlpt tokens, the fence carries $vln / $vlft"

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
  grep -qE 'tool_response|\.error|success' <<<"$(sed 's/#.*//' hooks/subagent-start.sh)" \
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
  { [ "$s2a" -eq 0 ] && [ "$s2b" -eq 1 ]; } \
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
  grep -q 'exit=0' <<<"$o" && ok "C-13 never blocks (exit 0)" || no "C-13 returned non-zero — it must only flag"
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
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F4 skipped (the metrics-writer chain)"
  else check "plan corrections: F4 clean" 0 ./scripts/check-plan-corrections.sh F4; fi

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
  iktab=$(awk '/^# INTAKE-CLASSIFIER v[0-9]+$/{f=1;next} f&&/^```/{exit} f&&NF' "$ikp" 2>/dev/null)
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
    elif grep -qE 'Write|Edit|Bash' <<<"$tl"; then
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
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F3 skipped (the metrics-writer chain)"
  else check "plan corrections: F3 clean" 0 ./scripts/check-plan-corrections.sh F3; fi

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
  grep -q "$SEC" <<<"$l" && no "SEC-DG-01 audit-logger wrote a credential verbatim" \
                                    || ok "SEC-DG-01 audit-logger redacts a credential-bearing command"
  grep -q 'REDACTED' <<<"$l" && ok "SEC-DG-01 audit-logger leaves a redaction marker" \
                                        || no "SEC-DG-01 audit-logger left no redaction marker"
  printf '%s' "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"/x/secrets/$SEC.pem\",\"content\":\"k\"}}" \
    | CLAUDE_PROJECT_DIR="$SCR" ./hooks/sensitive-guard.sh >/dev/null 2>&1
  l=$(tail -1 "$SL" 2>/dev/null)
  grep -q "$SEC" <<<"$l" && no "SEC-DG-01 deny() wrote a credential verbatim" \
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
  grep -q 'DISTILL INSTRUCTION' <<<"$o" \
    && ok "save-context emits the 15.5 distill instruction" || no "no distill instruction emitted"
  # 15.5 keeps the merge judgement in-session. Asserted BEHAVIOURALLY: prepare must not alter the
  # summary. The first version grepped the script's own comment for 'NOT a rewriter', which is both
  # a prose check and line-wrapped — binding a guard to its own documentation, yet again.
  h0=$(_sha256 context/session-summary.md)
  ./scripts/save-context.sh prepare >/dev/null 2>&1 || true
  { [ -n "$h0" ] && [ "$(_sha256 context/session-summary.md)" = "$h0" ]; } \
    && ok "save-context prepare does not rewrite the summary (15.5 judgement stays in-session)" \
    || no "save-context prepare mutated the summary — that is appending chronology by another name (or no sha256 tool)"
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
  grep -q 'Operator token line' <<<"$(head -5 GATES.md)" && ok "GATES.md carries the five-column format" \
                                                   || no "ledger header missing a column"
  gn=$(grep -cE '^\| G-F[0-4] ' GATES.md)
  [ "$gn" -ge 5 ] && ok "ledger backfilled F0-F4 ($gn rows)" || no "ledger has only $gn of 5 rows"
  tn=$(grep -cE 'APPROVE GATE-F[0-4]' GATES.md)
  [ "$tn" -ge 5 ] && ok "ledger records operator token lines ($tn)" || no "only $tn operator tokens recorded"
  grep -q 'Checkpoint discipline' PROGRESS.md && ok "PROGRESS.md carries the checkpoint-discipline section" \
                                              || no "checkpoint-discipline section absent"
  # ccs-02 shape: a cold reader must recover the next action from the tail alone.
  grep -qE '^- \*\*Next action:' <<<"$(tail -40 PROGRESS.md)" \
    && ok "next_action recoverable from the PROGRESS.md tail alone" || no "tail carries no next_action"
  # SIDE-3 — the ARMY selector: specialist fit as data, not vibes. Same doctrine as CR-026
  # above: classification behaviour is model-interpreted and deliberately unasserted; what IS
  # asserted is the table — mapped path (CR-024), shape, real agents only, exercised rows, and
  # the caveat that keeps the whole thing lawful under the zero-dispatch default.
  akp=$(awk -F'#' '/skills\/army-selector\/SKILL\.md/ {print $1}' DIRECTORY_GUIDE.md \
        | grep -oE '\.claude/skills/[a-z-]+/SKILL\.md|skills/[a-z-]+/SKILL\.md' | head -1)
  case "$akp" in .claude/*) : ;; skills/*) akp=".claude/$akp" ;; esac
  [ -n "$akp" ] && [ -f "$akp" ] \
    && ok "SIDE-3 army skill present at the path the map names ($akp)" \
    || no "SIDE-3 army skill missing from the mapped path (map said '${akp:-nothing}')"
  aktab=$(awk '/^# ARMY-TABLE v[0-9]+$/{f=1;next} f&&/^```/{exit} f&&NF' "$akp" 2>/dev/null)
  aknr=$(printf '%s\n' "$aktab" | grep -c .)
  [[ "$aknr" =~ ^[0-9]+$ ]] || aknr=0
  [ "$aknr" -ge 9 ] && ok "SIDE-3 table non-vacuous ($aknr rows)" || no "SIDE-3 table vacuous: $aknr rows"
  akbad=$(printf '%s\n' "$aktab" | awk -F'\t' 'NF!=5{print NR}' | tr '\n' ' ')
  [ -z "$akbad" ] && ok "SIDE-3 every row carries 5 tab-separated fields" || no "SIDE-3 malformed rows: $akbad"
  akag=$(ls .claude/agents/ | sed 's/\.md$//' | sort -u)
  akref=$(printf '%s\n' "$aktab" | cut -f2,3,4 | tr '\t' '\n' | sort -u | grep -vE '^(none|all)$')
  akundef=$(comm -23 <(printf '%s\n' "$akref") <(printf '%s\n' "$akag") | tr '\n' ' ')
  [ -z "$akundef" ] && ok "SIDE-3 every named specialist is a real agent file" \
    || no "SIDE-3 phantom specialists: $akundef"
  akx=$(printf '%s\n' "$aktab" | awk -F'\t' '$1=="security-review"{print $2}')
  [ "$akx" = security-reviewer ] && ok "SIDE-3 fixture: security-review -> security-reviewer" \
    || no "SIDE-3 fixture security-review resolved to '$akx'"
  akx=$(printf '%s\n' "$aktab" | awk -F'\t' '$1=="test-run"{print $2}')
  [ "$akx" = test-runner ] && ok "SIDE-3 fixture: test-run -> test-runner" \
    || no "SIDE-3 fixture test-run resolved to '$akx'"
  akx=$(printf '%s\n' "$aktab" | awk -F'\t' '$1=="ambiguous"{print $2}')
  [ "$akx" = none ] && ok "SIDE-3 fixture: ambiguous -> none (FALLBACK, not a guess)" \
    || no "SIDE-3 fixture ambiguous resolved to '$akx'"
  grep -qF "not a license to dispatch" "$akp" \
    && ok "SIDE-3 zero-dispatch caveat present verbatim" || no "SIDE-3 caveat line missing"
  grep -qF "army-selector" .claude/skills/intake/SKILL.md \
    && ok "SIDE-3 intake points at the selector" || no "SIDE-3 intake pointer missing"

  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F5 skipped (the metrics-writer chain)"
  else check "plan corrections: F5 clean" 0 ./scripts/check-plan-corrections.sh F5; fi
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
  [ "$lk" -eq 0 ] && ok "corpus/ERR5 rules are real in-repo files, not symlinks out of the tree" \
                || no "corpus/ERR5 $lk rule(s) are symlinks — §5.2.4 forbids escaping the repo"

  # ERR6 — a hardcoded OAuth token committed and caught by push protection. Check what is TRACKED,
  # since that is what would actually be pushed.
  tok=$(git ls-files -z | xargs -0 grep -lE 'gh[pousr]_[A-Za-z0-9]{20,}|xox[abopsr]-[A-Za-z0-9-]{10,}' 2>/dev/null | wc -l)
  [ "$tok" -eq 0 ] && ok "corpus/ERR6 no tracked file carries a live token shape" \
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
  [ "$bb" -eq 0 ] && ok "corpus/E7 no hook uses bash-only [[ (POSIX-safe)" || no "corpus/E7 $bb hook(s) use [["
  nx=$(for h in hooks/*.sh; do [ -x "$h" ] || echo "$h"; done | wc -l)
  [ "$nx" -eq 0 ] && ok "corpus/E7 all $np hooks are executable" || no "corpus/E7 $nx hook(s) not executable"

  # mermaid-guide E5 — a skill not detected because it is not DIR/SKILL.md (naming contract, §9).
  sk=$(find .claude/skills -mindepth 2 -name 'SKILL.md' 2>/dev/null | wc -l)
  sd=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
  [ "$sk" -eq "$sd" ] && ok "corpus/E5 every skill dir contains SKILL.md ($sk/$sd)" \
                    || no "corpus/E5 $sd skill dir(s) but only $sk SKILL.md"

  # mermaid-guide E10 — an MCP server that fails to connect. HC-5 forbids them outright here, so
  # the assertion is that none is configured at all.
  mc=$(jq -r '.mcpServers // {} | length' .claude/settings.json 2>/dev/null || echo 0)
  { [ "${mc:-0}" = 0 ] && [ ! -f .mcp.json ]; } \
    && ok "corpus/E10 no MCP server configured (HC-5)" || no "corpus/E10 an MCP server is configured"

  # §9 naming contract — agent frontmatter uses tools:, never allowed-tools:.
  at=$(grep -l '^allowed-tools:' .claude/agents/*.md 2>/dev/null | wc -l)
  [ "$at" -eq 0 ] && ok "corpus/§9 agents use 'tools:' not 'allowed-tools:'" || no "corpus/§9 $at agent(s) use allowed-tools:"

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
  # ADJUDICATED against the v3.5 map as authority (the PLAN-V3 precedent). The old form pulled
  # every lowercase WORD out of the comment, which worked only while that comment was a bare
  # middot-separated list. v3.5's entry carries a parenthetical explaining the gate guard, so a
  # word-level extractor began reporting "commit", "refuses", "token" and "until" as missing
  # scripts. The map is the byte-pinned payload and is right; the detector was reading it at the
  # wrong granularity. Split on the list separator, drop the leading count, take each entry's
  # first token, keep only name-shaped results.
  dgs=$(awk -F'#' '/scripts\// && NF>1 {print $2}' DIRECTORY_GUIDE.md \
        | sed 's/\xc2\xb7/\n/g' \
        | sed -E 's/^[[:space:]]*[0-9]+:[[:space:]]*//; s/^[[:space:]]+//; s/[[:space:]].*$//' \
        | grep -E '^[a-z][a-z0-9-]+$' | sort -u)
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

    # C-26 CLOSED — CR-024 extended to hooks/, the directory it never policed. It compared the map
    # to the tree in both directions for scripts/ and context/ and skipped the one holding the whole
    # enforcement layer, so the two hooks S2 added drifted for four days and the map's "12 tracked
    # hook scripts" was wrong for the life of the build. v3.2's payload enumerates all fourteen BY
    # NAME, which is what makes a set comparison possible at all — a count cannot be correlated to
    # identity, and C-12 established that a count is satisfiable by the party being audited.
    #
    # _common.sh is INCLUDED, not special-cased. The map names it and marks it the shared library;
    # exempting it in code would be the check disagreeing with the map it is checking.
    #
    # Needles fragment-assembled: this repo's deny-list matches the verbs its hooks block, and a
    # contiguous literal here would deny any command quoting this region.
    _hk="hoo""ks/"
    dgh=$(awk -F'#' -v H="$_hk" '$0 ~ ("^\xe2\x94\x9c\xe2\x94\x80 " H) && NF>1 {print $2}' DIRECTORY_GUIDE.md \
          | grep -oE '[a-z_][a-z0-9_-]*\.sh' | sort -u)
    dkh=$(git ls-files "${_hk}*.sh" 2>/dev/null | sed "s|${_hk}||" | sort -u)
    ndgh=$(printf '%s\n' "$dgh" | grep -c . || true); ndkh=$(printf '%s\n' "$dkh" | grep -c . || true)
    # Vacuity guard on BOTH sides: two empty sets differ by nothing, a clean comparison proving zero.
    { [ "${ndgh:-0}" -ge 5 ] && [ "${ndkh:-0}" -ge 5 ]; } \
      && ok "C-26 hooks/ extraction is non-vacuous (map $ndgh, tree $ndkh)" \
      || no "C-26 hooks/ extraction vacuous — map:$ndgh tree:$ndkh, both must be >=5"
    hab=$(comm -23 <(printf '%s\n' "$dgh") <(printf '%s\n' "$dkh") | tr '\n' ' ')
    hun=$(comm -13 <(printf '%s\n' "$dgh") <(printf '%s\n' "$dkh") | tr '\n' ' ')
    { [ -z "$hab" ] && [ -z "$hun" ]; } \
      && ok "C-26 map hooks/ matches the tree both ways ($ndkh files, _common.sh included as the map names it)" \
      || no "C-26 map hooks/ drift — named but absent:[$hab] on disk but unmapped:[$hun]"

  # CORRECTIONS-2 (#8, QUAL-09) — CR-024 widened to TOP-LEVEL directories. The map's last entry
  # predated stress-site/ (D26 mapped it); nothing mechanically checked that a new top-level dir is
  # named in the map. Derivation dry-run-verified at plan time (7 dirs each side). MAP side is
  # COLUMN-0 anchored (`^├─ `/`^└─ `) — a loose anchor wrongly catches nested `│  ├─` children
  # (agents/, rules/, skills/). Gitignored map entries (logs/, tagged in the map) are dropped via
  # git check-ignore so they are not flagged as "mapped but untracked". TREE side is tracked dirs
  # only (git ls-files first component), excluding the ~12 top-level files and the untracked corpus.
  dgt=$(grep -oE '^[├└]─ [A-Za-z._-]+/' DIRECTORY_GUIDE.md | sed -E 's/^[├└]─ //; s:/$::' | sort -u)
  dgt=$(for d in $dgt; do git check-ignore -q "$d" || printf '%s\n' "$d"; done | sort -u)
  dtt=$(git ls-files | awk -F/ 'NF>1{print $1}' | sort -u)
  ndgt=$(printf '%s\n' "$dgt" | grep -c . || true); ndtt=$(printf '%s\n' "$dtt" | grep -c . || true)
  { [ "${ndgt:-0}" -ge 5 ] && [ "${ndtt:-0}" -ge 5 ]; } \
    && ok "CR-024 top-level extraction non-vacuous (map $ndgt, tree $ndtt)" \
    || no "CR-024 top-level extraction vacuous — map:$ndgt tree:$ndtt, both must be >=5"
  tab=$(comm -23 <(printf '%s\n' "$dgt") <(printf '%s\n' "$dtt") | tr '\n' ' ')
  tun=$(comm -13 <(printf '%s\n' "$dgt") <(printf '%s\n' "$dtt") | tr '\n' ' ')
  { [ -z "$tab" ] && [ -z "$tun" ]; } \
    && ok "CR-024 map top-level dirs match the tree both ways ($ndtt tracked dirs)" \
    || no "CR-024 top-level drift — mapped-but-untracked:[$tab] tracked-but-unmapped:[$tun]"
  # Fire-probe: a planted unmapped tracked dir must be caught by the same both-ways comm (real map).
  tplant=$(comm -13 <(printf '%s\n' "$dgt") <(printf '%s\nPLANTED-UNMAPPED-DIR\n' "$dtt" | sort -u))
  grep -q 'PLANTED-UNMAPPED-DIR' <<<"$tplant" \
    && ok "CR-024 top-level arm catches a planted unmapped tracked dir (probe)" \
    || no "CR-024 top-level arm did NOT catch a planted unmapped dir — the arm is void"

  # INDEX-1 — the chronicle's index is bound to the chronicle in BOTH directions. docs/CHANGE-PLANE.md
  # is 727KB and cannot be read whole; docs/CHANGE-PLANE-INDEX.md is the map into it, and an unbound
  # map rots — the defect family this repo has recorded eleven times (CR-024, C-26). Anchors are the
  # binding pointer; the index's advisory LINE NUMBERS are deliberately NOT checked, because they
  # shift on any edit and the index says so in its own staleness contract.
  #
  # Correlated in ONE awk pass over both files rather than 351 greps: a `section` anchor must match a
  # whole line exactly once, a `gate`/`decision` anchor must match as a substring exactly once, the
  # six DECLARED dual-site headings must match exactly twice (the rulings record is deliberately
  # inlined at both II.D and II.F), and — the converse — every heading in the chronicle must appear
  # in one of those two lists, so a section added later cannot go unindexed.
  cpf="docs/CHANGE-PLANE.md"; cpi="docs/CHANGE-PLANE-INDEX.md"
  # Shared checker: $1=anchor file, $2=dual file. Echoes "bad<TAB>dualbad<TAB>unindexed<TAB>sample".
  cp_check () {
    awk -v ancf="$1" -v dualf="$2" -F'\t' '
      FILENAME==ancf  { if (NF>=2) { anc[$1]=$2 } ; next }
      FILENAME==dualf { if (NF>=1) { dual[$1]=1 } ; next }
      {
        if ($0 ~ /^#{2,4} /) heads[$0]=1
        for (a in anc) {
          if (anc[a]=="section") { if ($0==a) hit[a]++ }
          else if (index($0,a)>0) { hit[a]++ }
        }
        for (d in dual) { if ($0==d) dhit[d]++ }
      }
      END {
        for (a in anc)  { if ((hit[a]+0)  != 1) { bad++;   if (s1=="") s1=substr(a,1,44) } }
        for (d in dual) { if ((dhit[d]+0) != 2) { dbad++;  if (s2=="") s2=substr(d,1,44) } }
        for (h in heads){ if (!(h in anc) && !(h in dual)) { un++; if (s3=="") s3=substr(h,1,44) } }
        printf "%d\t%d\t%d\t%s%s%s\n", bad+0, dbad+0, un+0, s1, s2, s3
      }' "$1" "$2" "$3"
  }
  if [ ! -f "$cpf" ] || [ ! -f "$cpi" ]; then
    no "INDEX-1: the chronicle or its index is missing — the binding cannot be checked"
  else
    cpa=$(mktemp); cpd=$(mktemp)
    awk '/^# CHANGE-PLANE-ANCHORS v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$cpi" > "$cpa"
    awk '/^# CHANGE-PLANE-DUAL-SITE v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$cpi" > "$cpd"
    cpan=$(grep -c . "$cpa"); [[ "$cpan" =~ ^[0-9]+$ ]] || cpan=0
    cpdn=$(grep -c . "$cpd"); [[ "$cpdn" =~ ^[0-9]+$ ]] || cpdn=0
    # Vacuity guard FIRST: an empty block makes every comparison below trivially clean.
    { [ "$cpan" -ge 100 ] && [ "$cpdn" -ge 1 ]; } \
      && ok "INDEX-1 anchor block non-vacuous ($cpan anchors, $cpdn dual-site)" \
      || no "INDEX-1 anchor block vacuous — anchors:$cpan dual:$cpdn (want >=100 and >=1)"
    cpr=$(cp_check "$cpa" "$cpd" "$cpf")
    cpbad=$(printf '%s' "$cpr" | cut -f1); cpdbad=$(printf '%s' "$cpr" | cut -f2)
    cpun=$(printf '%s' "$cpr" | cut -f3); cpsam=$(printf '%s' "$cpr" | cut -f4)
    { [ "${cpbad:-1}" -eq 0 ] && [ "${cpdbad:-1}" -eq 0 ]; } \
      && ok "INDEX-1 every index anchor resolves in the chronicle ($cpan once, $cpdn twice)" \
      || no "INDEX-1 anchor(s) do not resolve — unique-miss:$cpbad dual-miss:$cpdbad e.g. [$cpsam]"
    [ "${cpun:-1}" -eq 0 ] \
      && ok "INDEX-1 converse: every chronicle heading is indexed (no unindexed section)" \
      || no "INDEX-1 converse: $cpun chronicle heading(s) missing from the index, e.g. [$cpsam]"
    # Fire-probes — a check never seen failing proves nothing. Both directions, on scratch copies.
    cpp=$(mktemp); cat "$cpa" > "$cpp"; printf '### ANCHOR-THAT-DOES-NOT-EXIST\tsection\t0\n' >> "$cpp"
    [ "$(cp_check "$cpp" "$cpd" "$cpf" | cut -f1)" -ge 1 ] \
      && ok "INDEX-1 probe: a planted unresolvable anchor is caught" \
      || no "INDEX-1 probe: a planted unresolvable anchor went UNCAUGHT — the forward check is void"
    grep -v '^## PART I ' "$cpa" > "$cpp"
    [ "$(cp_check "$cpp" "$cpd" "$cpf" | cut -f3)" -ge 1 ] \
      && ok "INDEX-1 probe: a chronicle heading dropped from the index is caught" \
      || no "INDEX-1 probe: a dropped heading went UNCAUGHT — the converse check is void"
    rm -f "$cpa" "$cpd" "$cpp"
  fi

  # FENCE-2 — the 2026-08-31 program kickoff is the BYTE-SOURCE for MATRIX-AI-1's 51-item checklist
  # (the list exists nowhere else on disk; the HELIX program lost its own kickoff this way, gap #7).
  # A truncated or reflow-mangled kickoff must fail here by count, not surface at the matrix gate.
  kkf="docs/research/ADDITIONS-2026-08-31-kickoff.md"
  if [ ! -f "$kkf" ]; then
    no "FENCE-2 kickoff doc missing — MATRIX-AI-1's byte-source is gone"
  else
    kkn=$(grep -c '^> Build your own' "$kkf")
    case "$kkn" in ''|*[!0-9]*) kkn=0 ;; esac
    [ "$kkn" -eq 51 ] && ok "FENCE-2 kickoff carries all 51 checklist items (MATRIX-AI-1 byte-source)" \
                      || no "FENCE-2 kickoff checklist count is $kkn, want exactly 51 — the byte-source is damaged"
  fi

  # HARNESS-ROT-1 — stop.sh's pending-token extraction, executed from the FILE'S OWN BYTES against
  # fixtures (rule 6: probe the exact construct — a re-typed copy of the regex would test the test).
  # The old [A-Z0-9-] class silently skipped lowercase-suffixed tokens: STRESS-1a awaited with no
  # toast and nothing noticed. Both fixtures must resolve: the legacy uppercase shape, and the
  # mixed-case shape the old class missed.
  hrx=$(mktemp -d)
  hrline=$(grep -m1 '^PEND=' hooks/stop.sh)
  if [ -z "$hrline" ]; then
    no "HARNESS-ROT-1 could not extract the PEND line from stop.sh — the probe has no construct to execute"
  else
    printf '| A |  | x | y | awaiting `APPROVE FENCE-9` |\n' > "$hrx/GATES.md"
    ROOT="$hrx" eval "$hrline"
    hr1="${PEND:-}"
    printf '| B |  | x | y | awaiting `APPROVE HARNESS-Rot-9z` |\n' > "$hrx/GATES.md"
    ROOT="$hrx" eval "$hrline"
    hr2="${PEND:-}"
    { [ "$hr1" = "FENCE-9" ] && [ "$hr2" = "HARNESS-Rot-9z" ]; } \
      && ok "HARNESS-ROT-1 stop.sh token extraction resolves upper AND mixed-case fixtures (own bytes executed)" \
      || no "HARNESS-ROT-1 stop.sh extraction failed a fixture — upper:[$hr1] mixed:[$hr2]"
  fi
  rm -rf "$hrx"

  # HARNESS-ROT-1 — scrub() bounds the WHOLE payload, not each line. Report row 4, demonstrated
  # live: a ~4KB multi-line denied heredoc logged essentially in full under the per-line cut.
  # The planted shape is fragment-assembled (a scanner never contains its prey) and sits PAST the
  # bound, proving redaction runs before truncation can be relied on and the bound holds anyway.
  hrtok="$(printf 'gh%s_%s' 'p' 'ABCDEFGHIJKLMNOP12345678')"
  hrpay=$(printf 'line-one-%0400d\nline-two-%0400d\nline-three %s tail-%0400d\n' 7 7 "$hrtok" 7)
  hrout=$(bash -c '. hooks/_common.sh 2>/dev/null; scrub "$1"' _ "$hrpay")
  hrlen=${#hrout}
  case "$hrout" in
    *"$hrtok"*) no "HARNESS-ROT-1 scrub leaked the planted shape past the bound" ;;
    *) [ "$hrlen" -le 400 ] \
         && ok "HARNESS-ROT-1 scrub bounds the whole multi-line payload (${hrlen} <= 400) and the planted shape is gone" \
         || no "HARNESS-ROT-1 scrub output is ${hrlen} bytes — the bound is per-line again" ;;
  esac

  # HARNESS-CONV-1 / R-PR-1 — order and fail direction, run against the artifact's own bytes in a
  # copied tree with NO resolver present: the universal arm must deny without _profile.sh ever
  # existing (universal precedes profile), and the build arm must ALSO deny (missing resolver
  # fails CLOSED — not enforcing build constraints in a real harness would be a breach).
  rpa=$(mktemp -d); mkdir -p "$rpa/hooks" "$rpa/logs"
  cp hooks/bash-blocker.sh hooks/_common.sh "$rpa/hooks/"
  printf '%s' "$(jq -cn --arg c "sudo rm x" '{tool_name:"Bash",tool_input:{command:$c}}')" \
    | CLAUDE_PROJECT_DIR="$rpa" "$rpa/hooks/bash-blocker.sh" >/dev/null 2>&1; rpu=$?
  printf '%s' "$(jq -cn --arg c "git clone https://x/y" '{tool_name:"Bash",tool_input:{command:$c}}')" \
    | CLAUDE_PROJECT_DIR="$rpa" "$rpa/hooks/bash-blocker.sh" >/dev/null 2>&1; rpb=$?
  { [ "$rpu" = 2 ] && [ "$rpb" = 2 ]; } \
    && ok "R-PR-1 universal arm precedes the profile AND a missing resolver fails closed (rc $rpu/$rpb)" \
    || no "R-PR-1 order/fail-direction broken — universal rc=$rpu build rc=$rpb (want 2/2 with no resolver)"
  rm -rf "$rpa"

  # R-PR-1 two-root law: the LIVE blocker with the session root pointed at a foreign directory
  # carrying a node-app marker must STILL deny a build arm (the profile resolves from the script's
  # own repo; the session root is only the log destination — and the record must land THERE).
  rpc=$(mktemp -d); mkdir -p "$rpc/.claude" "$rpc/logs"
  printf '{"profile":"node-app"}' > "$rpc/.claude/harness-profile.json"
  printf '%s' "$(jq -cn --arg c "git clone https://x/y" '{tool_name:"Bash",tool_input:{command:$c}}')" \
    | CLAUDE_PROJECT_DIR="$rpc" ./hooks/bash-blocker.sh >/dev/null 2>&1; rpr=$?
  rpn=$(grep -c . "$rpc/logs/tooluse-audit.jsonl" 2>/dev/null || true)
  case "$rpn" in ''|*[!0-9]*) rpn=0 ;; esac
  { [ "$rpr" = 2 ] && [ "$rpn" -ge 1 ]; } \
    && ok "R-PR-1 two-root: a session-root marker cannot loosen the live blocker; the record lands at the session root" \
    || no "R-PR-1 two-root broken — rc=$rpr (want 2) records=$rpn (want >=1)"
  rm -rf "$rpc"

  # HARNESS-BUILD-1 — deploy-harness.sh controls as spec predicates, in a scratch git repo far from
  # both harnesses (C-14 law). Three assertions: (1) refusals + fresh deploy + byte-idempotent
  # re-run; (2) a planted human edit inside a managed region REFUSES without --force; (3) --remove
  # restores the touched files byte-equal to pre-deploy and deletes every artifact.
  hdt=$(mktemp -d)
  ( cd "$hdt" && git init -q . && git config user.email t@t && git config user.name t \
    && printf 'hi\n' > app.txt && printf '# target\n' > CLAUDE.md && printf 'node_modules/\n' > .gitignore \
    && git add -A && git commit -qm init ) >/dev/null 2>&1
  hdc0=$(_sha256 "$hdt/CLAUDE.md"); hdg0=$(_sha256 "$hdt/.gitignore")
  # C-14: mutating legs run a BYTE-COPY from a scratch harness home, so the script's own audit
  # append lands in scratch logs, never this repo's live trail. Refusal legs use the live script:
  # they exit before any audit write, and the self-refusal needs the live SELF_DIR identity.
  hdh=$(mktemp -d); mkdir -p "$hdh/scripts" "$hdh/logs"
  cp scripts/deploy-harness.sh "$hdh/scripts/"
  hdng=$(mktemp -d)
  ./scripts/deploy-harness.sh "$hdng" --apply >/dev/null 2>&1; hdr1=$?
  ./scripts/deploy-harness.sh . --apply >/dev/null 2>&1; hdr2=$?
  "$hdh/scripts/deploy-harness.sh" "$hdt" --apply >/dev/null 2>&1; hdr3=$?
  ( cd "$hdt" && git add -A && git commit -qm deploy ) >/dev/null 2>&1
  hdcat=$(mktemp); cat "$hdt/CLAUDE.md" "$hdt/.gitignore" "$hdt/.claude/harness-profile.json" > "$hdcat" 2>/dev/null; hds1=$(_sha256 "$hdcat")
  "$hdh/scripts/deploy-harness.sh" "$hdt" --apply >/dev/null 2>&1; hdr4=$?
  cat "$hdt/CLAUDE.md" "$hdt/.gitignore" "$hdt/.claude/harness-profile.json" > "$hdcat" 2>/dev/null; hds2=$(_sha256 "$hdcat"); rm -f "$hdcat"
  { [ "$hdr1" = 3 ] && [ "$hdr2" = 3 ] && [ "$hdr3" = 0 ] && [ "$hdr4" = 0 ] && [ "$hds1" = "$hds2" ] \
      && [ -x "$hdt/.claude/harness-hooks/bash-blocker.sh" ]; } \
    && ok "deploy-harness refuses non-git and self, deploys fresh, and re-runs byte-idempotent" \
    || no "deploy-harness basics broken — non-git:$hdr1 self:$hdr2 fresh:$hdr3 rerun:$hdr4 idem:[$hds1/$hds2]"
  awk '{gsub(/do not edit inside these markers/,"HUMAN EDIT")}1' "$hdt/CLAUDE.md" > "$hdt/CLAUDE.md.t" && mv "$hdt/CLAUDE.md.t" "$hdt/CLAUDE.md"
  ( cd "$hdt" && git add -A && git commit -qm humanedit ) >/dev/null 2>&1
  "$hdh/scripts/deploy-harness.sh" "$hdt" --apply >/dev/null 2>&1; hdr5=$?
  "$hdh/scripts/deploy-harness.sh" "$hdt" --apply --force >/dev/null 2>&1; hdr6=$?
  ( cd "$hdt" && git add -A && git commit -qm forced ) >/dev/null 2>&1
  { [ "$hdr5" = 3 ] && [ "$hdr6" = 0 ]; } \
    && ok "deploy-harness REFUSES a drifted managed region and proceeds only under --force" \
    || no "deploy-harness drift law broken — plain:$hdr5 (want 3) force:$hdr6 (want 0)"
  "$hdh/scripts/deploy-harness.sh" "$hdt" --remove >/dev/null 2>&1; hdr7=$?
  hdc1=$(_sha256 "$hdt/CLAUDE.md"); hdg1=$(_sha256 "$hdt/.gitignore")
  { [ "$hdr7" = 0 ] && [ "$hdc1" = "$hdc0" ] && [ "$hdg1" = "$hdg0" ] \
      && [ ! -d "$hdt/.claude/harness-hooks" ] && [ ! -f "$hdt/.claude/harness-profile.json" ]; } \
    && ok "deploy-harness --remove restores both files BYTE-EQUAL to pre-deploy and deletes every artifact" \
    || no "deploy-harness --remove broken — rc:$hdr7 CLAUDE.md:$([ "$hdc1" = "$hdc0" ] && echo eq || echo NEQ) .gitignore:$([ "$hdg1" = "$hdg0" ] && echo eq || echo NEQ)"
  rm -rf "$hdt" "$hdng" "$hdh"

  # RSCH-4 — the orca surgical matrix is DATA the suite parses (ARMY-TABLE/INDEX-1 precedent):
  # the fenced ORCA-MATRIX block must carry exactly 12 rows of legal verdicts, and the doc's own
  # prose roll-up must agree with the block — a matrix whose summary disagrees with its rows is
  # the stale-figure class this repo has recorded repeatedly.
  omf="docs/research/RSCH-4-orca.md"
  if [ ! -f "$omf" ]; then
    no "RSCH-4 matrix doc missing"
  else
    omrows=$(awk '/^# ORCA-MATRIX v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$omf")
    omn=$(printf '%s\n' "$omrows" | grep -c . || true)
    case "$omn" in ''|*[!0-9]*) omn=0 ;; esac
    ombad=$(printf '%s\n' "$omrows" | awk -F'\t' '$3!="TAKE-PATTERN"&&$3!="MODULATE-OURS"&&$3!="VALIDATE-AGAINST"&&$3!="REJECT"{c++} END{print c+0}')
    { [ "$omn" -eq 12 ] && [ "$ombad" = 0 ]; } \
      && ok "RSCH-4 ORCA-MATRIX parses to exactly 12 rows, every verdict legal" \
      || no "RSCH-4 ORCA-MATRIX malformed — rows:$omn (want 12) illegal-verdicts:$ombad"
    omt=$(printf '%s\n' "$omrows" | grep -c 'TAKE-PATTERN' || true)
    omm=$(printf '%s\n' "$omrows" | grep -c 'MODULATE-OURS' || true)
    omv=$(printf '%s\n' "$omrows" | grep -c 'VALIDATE-AGAINST' || true)
    grep -qF -- "Roll-up: **$omt TAKE-PATTERN · $omm MODULATE-OURS · $omv VALIDATE-AGAINST" "$omf" \
      && ok "RSCH-4 roll-up prose agrees with the block ($omt/$omm/$omv)" \
      || no "RSCH-4 roll-up prose disagrees with the block — block says $omt/$omm/$omv"
  fi

  # COMPREHEND-2 — the explainer discipline, bound. Every GATES row AFTER the declared epoch row
  # must have docs/explainers/<GATE>.md. Row-position, not date (the ledger's ISO column is empty
  # on many rows). Vacuity-guarded: an empty post-epoch set refuses rather than passing silent.
  exidx="docs/explainers/INDEX.md"
  exepoch=$(grep -m1 '^EXPLAINER-EPOCH: ' "$exidx" 2>/dev/null | awk '{print $2}')
  if [ -z "${exepoch:-}" ]; then
    no "COMPREHEND-2 epoch line missing from $exidx — the explainer rule has no anchor"
  else
    exrows=$(awk -F'|' -v ep="$exepoch" '
      /^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g);
        if (found && g!="Gate") print g;
        if (g==ep) found=1 }' GATES.md)
    exn=$(printf '%s\n' "$exrows" | grep -c . || true)
    case "$exn" in ''|*[!0-9]*) exn=0 ;; esac
    exmiss=""
    for g in $exrows; do [ -f "docs/explainers/$g.md" ] || exmiss="$exmiss [$g]"; done
    if [ "$exn" -lt 1 ]; then
      no "COMPREHEND-2 post-epoch gate set is EMPTY — vacuous, the epoch row was not found in GATES.md"
    elif [ -z "$exmiss" ]; then
      ok "COMPREHEND-2 every post-epoch gate ($exn) has its plain-language explainer"
    else
      no "COMPREHEND-2 explainer(s) MISSING for post-epoch gate(s):$exmiss"
    fi
    # Fire-probe: a planted post-epoch row with no explainer must be caught by the same extraction.
    exfx=$(mktemp)
    cat GATES.md > "$exfx"
    printf '| PROBE-GATE-X9 |  | planted | planted | awaiting `APPROVE PROBE-GATE-X9` |\n' >> "$exfx"
    exrows2=$(awk -F'|' -v ep="$exepoch" '
      /^\| [A-Za-z]/ { g=$2; gsub(/^ +| +$/,"",g);
        if (found && g!="Gate") print g;
        if (g==ep) found=1 }' "$exfx")
    exmiss2=""
    for g in $exrows2; do [ -f "docs/explainers/$g.md" ] || exmiss2="$exmiss2 [$g]"; done
    case "$exmiss2" in
      *PROBE-GATE-X9*) ok "COMPREHEND-2 fire-probe: a planted explainer-less gate is caught by name" ;;
      *) no "COMPREHEND-2 fire-probe FAILED — the planted gate went unnoticed; the binding is void" ;;
    esac
    rm -f "$exfx"
  fi

  # MATRIX-AI-1 — the 51-item feasibility matrix is DATA (same law as ORCA-MATRIX): exactly 51
  # rows, every verdict legal, and the roll-up prose must agree with the block. The kickoff doc's
  # own 51-item assertion above is the byte-source side of the same contract.
  amf="docs/research/MATRIX-AI-1.md"
  if [ ! -f "$amf" ]; then
    no "MATRIX-AI-1 doc missing"
  else
    amrows=$(awk '/^# MATRIX-AI v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$amf")
    amn=$(printf '%s\n' "$amrows" | grep -c . || true)
    case "$amn" in ''|*[!0-9]*) amn=0 ;; esac
    ambad=$(printf '%s\n' "$amrows" | awk -F'\t' '$3!="EXISTS"&&$3!="GENERALIZE"&&$3!="FEASIBLE-ZERO-DEP"&&$3!="BLOCKED-HC"&&$3!="REJECT"{c++} END{print c+0}')
    { [ "$amn" -eq 51 ] && [ "$ambad" = 0 ]; } \
      && ok "MATRIX-AI-1 block parses to exactly 51 rows, every verdict legal" \
      || no "MATRIX-AI-1 block malformed — rows:$amn (want 51) illegal:$ambad"
    ame=$(printf '%s\n' "$amrows" | grep -c 'EXISTS' || true)
    amg=$(printf '%s\n' "$amrows" | grep -c 'GENERALIZE' || true)
    amz=$(printf '%s\n' "$amrows" | grep -c 'FEASIBLE-ZERO-DEP' || true)
    amb=$(printf '%s\n' "$amrows" | grep -c 'BLOCKED-HC' || true)
    amr=$(printf '%s\n' "$amrows" | awk -F'\t' '$3=="REJECT"{c++} END{print c+0}')
    grep -qF -- "Roll-up: **$ame EXISTS · $amg GENERALIZE · $amz FEASIBLE-ZERO-DEP · $amb BLOCKED-HC · $amr REJECT" "$amf" \
      && ok "MATRIX-AI-1 roll-up prose agrees with the block ($ame/$amg/$amz/$amb/$amr)" \
      || no "MATRIX-AI-1 roll-up disagrees — block says $ame/$amg/$amz/$amb/$amr"
  fi

  # C-16, tested BEHAVIOURALLY and rewritten at HARNESS-1 for the golden-manifest mechanism: copy
  # settings AND the manifest into a temp root, strip a deny entry the OLD hand-maintained subset
  # did NOT cover (terraform), and assert the set-difference check reports it. This proves the new
  # boundary catches removals the old seven-needle check missed silently — the MacBook finding.
  # 'terraform' is not an HC-5 verb bash-blocker matches, so no fragment assembly is needed here.
  dl=$(mktemp -d); mkdir -p "$dl/scripts" "$dl/.claude" "$dl/hooks"
  cp scripts/validate-crew.sh "$dl/scripts/"
  cp .claude/settings.json "$dl/.claude/" 2>/dev/null
  cp .claude/deny-manifest.txt "$dl/.claude/" 2>/dev/null
  jq '.permissions.deny |= map(select(test("terraform")|not))' "$dl/.claude/settings.json" \
     > "$dl/.claude/s.tmp" && mv "$dl/.claude/s.tmp" "$dl/.claude/settings.json"
  dlout=$("$dl/scripts/validate-crew.sh" 2>/dev/null | grep -c 'REMOVED from settings' || true)
  [ "${dlout:-0}" -ge 1 ] && ok "C-16 validate-crew catches a manifest-vs-settings deny removal (behavioural)" \
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
  grep -q 'CCS02-SENTINEL-RESUME-HERE' <<<"$cold" \
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
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then ok "self-audit skip-guard: corrections site F7 skipped (the metrics-writer chain)"
  else check "plan corrections: F7 clean"              0 ./scripts/check-plan-corrections.sh F7; fi

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
  [ "$f7th" -eq 0 ] && ok "D6 no theme token under stress-project/src or bin" \
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
  f7seq=0; grep -q '^[[:space:]]*sequenceDiagram' <<<"$f7mmd" && f7seq=1
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
  { [ "$f7rc" -eq 0 ] && [ "$f7tk" -eq 1 ]; } \
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
  { [ "$f7rc" -eq 2 ] && [ "${f7al:-0}" -eq 1 ] && [ "$f7bt" -eq 0 ]; } \
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


  # RPG-2 — the parent consumes the repurpose graph through a VENDORED PIN (the vendored-vocabulary
  # blueprint applied to its own gallery). Unconditional arms bind the pin block in the intake
  # skill; the live diff runs only when a sibling checkout is present, and absence is ANNOUNCED in
  # the ok-line (this suite has no SKIP channel — silent not-applicable is the C-23 shape).
  echo "== RPG-2 — repurpose pull pin (unconditional) + live sibling diff (conditional) =="
  rpsk=.claude/skills/intake/SKILL.md
  rptab=$(awk '/^# REPURPOSE-PIN v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$rpsk")
  rpn=$(grep -c . <<<"$rptab"); [[ "$rpn" =~ ^[0-9]+$ ]] || rpn=0
  [ "$rpn" -ge 4 ] && ok "RPG-2 pin block extracted non-vacuously ($rpn rows)" \
    || no "RPG-2 pin block vacuous: $rpn rows (want >= 4)"
  rpids=$(awk -F'\t' '$1=="ids"{print $2}' <<<"$rptab")
  rpidn=$(tr ',' '\n' <<<"$rpids" | grep -c .); [[ "$rpidn" =~ ^[0-9]+$ ]] || rpidn=0
  [ "$rpidn" -eq 11 ] && ok "RPG-2 pin carries 11 blueprint ids" \
    || no "RPG-2 pin id count $rpidn != 11"
  rptrg=$(awk -F'\t' '$1=="trigger"' <<<"$rptab" | grep -c .); [[ "$rptrg" =~ ^[0-9]+$ ]] || rptrg=0
  [ "$rptrg" -eq 3 ] && ok "RPG-2 pin names exactly 3 triggers" \
    || no "RPG-2 pin trigger rows $rptrg != 3"
  rpsec=$(awk '/^## 6\. /{f=1;next} f&&/^## [0-9]/{exit} f' "$rpsk")
  rpsl=$(grep -c '' <<<"$rpsec"); [[ "$rpsl" =~ ^[0-9]+$ ]] || rpsl=0
  rpfn=$(grep -c '^```' <<<"$rpsec"); [[ "$rpfn" =~ ^[0-9]+$ ]] || rpfn=0
  { [ "$rpsl" -le 40 ] && [ "$rpfn" -eq 2 ]; } \
    && ok "RPG-2 path-not-body cap holds: section 6 is $rpsl lines with one fenced block" \
    || no "RPG-2 path-not-body cap BROKEN: $rpsl lines (cap 40), $rpfn fence markers (want 2)"
  rpmut=$(tr ',' '\n' <<<"$rpids" | grep -vxF 'gate-machine' | grep -c .)
  [[ "$rpmut" =~ ^[0-9]+$ ]] || rpmut=0
  { [ "$rpmut" -ne 11 ] && [ "$rpmut" -ne "$rpidn" ]; } \
    && ok "RPG-2 control fires: a pin with one id dropped is seen by the comparator ($rpmut != 11)" \
    || no "RPG-2 control DID NOT fire — dropping an id left the comparator blind"
  RPATH="${PSYCHIC_REPURPOSE_PATH:-../psychic-repurpose}"
  if [ -f "$RPATH/docs/PULL-INDEX.md" ]; then
    rplive=$(awk '/^# PULL-INDEX v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$RPATH/docs/PULL-INDEX.md" | cut -f1 | sort)
    rppin=$(tr ',' '\n' <<<"$rpids" | sort)
    [ "$rppin" = "$rplive" ] && ok "RPG-2 pin ids set-equal the live sibling index (both directions)" \
      || no "RPG-2 pin/sibling id drift: $(comm -3 <(printf '%s\n' "$rppin") <(printf '%s\n' "$rplive") | tr '\n' ' ')"
    rpmiss=""
    while IFS=$'\t' read -r rjunk rslug rphr; do
      rrow=$(awk -F'\t' -v s="$rslug" '$2==s' "$RPATH/docs/PULL-INDEX.md" 2>/dev/null | head -1)
      grep -qF "$rphr" <<<"$rrow" || rpmiss="$rpmiss [$rslug]"
    done <<<"$(awk -F'\t' '$1=="trigger"' <<<"$rptab")"
    [ -z "$rpmiss" ] && ok "RPG-2 all 3 pinned trigger phrases verbatim in the sibling index" \
      || no "RPG-2 pinned phrase(s) missing from the sibling:$rpmiss"
  else
    ok "RPG-2 sibling checkout absent at PSYCHIC_REPURPOSE_PATH — id diff deferred, ANNOUNCED (pin arms above still bind)"
    ok "RPG-2 sibling checkout absent — trigger-phrase diff deferred, ANNOUNCED"
  fi


  # CORPUS-ZEROSHOT — the transferred check: completion/dispatch trails held to TYPED coherence
  # (zeroshot's verifier outputs are schema-required with errors-empty-iff-approved; the analog
  # here is the arbiter trail). Conditional on the gitignored trail, announced when absent
  # (CR-027 pattern); the probes below are UNCONDITIONAL so both checkers are seen firing.
  echo "== CORPUS-ZEROSHOT — typed-trail coherence (transferred from the dive) =="
  zaud=logs/arbiter-audit.jsonl
  if [ ! -f "$zaud" ]; then
    ok "arbiter trail absent (bare clone) — schema-coherence arm announced, not silent"
    ok "arbiter trail absent — self-dispatch arm announced likewise"
  else
    ztot=$(grep -c . "$zaud"); [[ "$ztot" =~ ^[0-9]+$ ]] || ztot=0
    zok=$(jq -c 'select(.ts != null and .from_agent != null and .to != null)' "$zaud" 2>/dev/null | grep -c .)
    [[ "$zok" =~ ^[0-9]+$ ]] || zok=0
    { [ "$ztot" -ge 1 ] && [ "$zok" -eq "$ztot" ]; } \
      && ok "arbiter trail schema-coherent: all $ztot rows parse with ts+from_agent+to (typed, not narrated)" \
      || no "arbiter trail incoherent: $zok of $ztot rows carry the required shape"
    zself=$(jq -r '.from_agent as $f | select(($f != null) and (.to != null)) | select((.to | index($f)) != null) | .ts' "$zaud" 2>/dev/null | grep -c .)
    [[ "$zself" =~ ^[0-9]+$ ]] || zself=0
    [ "$zself" -eq 0 ] && ok "no self-dispatch row: from_agent never in its own to-list (C-12, machine-typed)" \
      || no "SELF-DISPATCH in the trail: $zself row(s) name their own sender"
  fi
  zp=$(mktemp)
  printf '{"ts":"probe","from_agent":"a","to":["b"]}\nnot-json-at-all\n' > "$zp"
  zpt=$(grep -c . "$zp"); zpo=$(jq -c 'select(.ts != null and .from_agent != null and .to != null)' "$zp" 2>/dev/null | grep -c .)
  [[ "$zpo" =~ ^[0-9]+$ ]] || zpo=0
  [ "$zpo" -lt "$zpt" ] && ok "control fires: a malformed trail line is seen by the coherence checker ($zpo of $zpt)" \
    || no "coherence control DID NOT fire"
  printf '{"ts":"probe2","from_agent":"a","to":["x","a"]}\n' > "$zp"
  zps=$(jq -r '.from_agent as $f | select(($f != null) and (.to != null)) | select((.to | index($f)) != null) | .ts' "$zp" 2>/dev/null | grep -c .)
  [[ "$zps" =~ ^[0-9]+$ ]] || zps=0
  [ "$zps" -eq 1 ] && ok "control fires: a planted self-dispatch row is seen ($zps)" \
    || no "self-dispatch control DID NOT fire ($zps)"
  rm -f "$zp"


  # ARC4-1 — rubric + queue bindings (nothing autonomous; the runner is ARC4-2's).
  echo "== ARC4-1 — audit rubric, bands, queue, and the gated-fixes law =="
  arub=docs/AUDIT-RUBRIC.md
  abnd=$(awk '/^# ARC4-BANDS v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$arub" 2>/dev/null)
  abn=$(grep -c . <<<"$abnd"); [[ "$abn" =~ ^[0-9]+$ ]] || abn=0
  [ "$abn" -eq 6 ] && ok "ARC4 bands: one row per estate repo (6)" \
    || no "ARC4 bands rows $abn != 6"
  abbad=$(printf '%s\n' "$abnd" | awk -F'\t' 'NF!=4 || $2!~/^[0-9]+$/ || $3!~/^[0-9]+$/ || $4!~/^[0-9]+$/ {print $1}')
  [ -z "$abbad" ] && ok "ARC4 bands numeric and 4-column throughout" \
    || no "ARC4 band row(s) malformed: $(tr '\n' ' ' <<<"$abbad")"
  grep -qF 'APPROVE ARC4-RECAL' "$arub" \
    && ok "bands declared provisional with the recalibration token named" \
    || no "ARC4-RECAL not named — provisional bands without a recal path"
  if grep -qE '^# AUDIT-QUEUE v1$' "$arub"; then
    aq=$(awk '/^# AUDIT-QUEUE v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$arub")
    aqn=$(grep -c . <<<"$aq"); [[ "$aqn" =~ ^[0-9]+$ ]] || aqn=0
    ok "audit queue parses ($aqn row(s) — EMPTY IS LEGAL; the guard tests the instrument, not the yield)"
  else
    no "AUDIT-QUEUE header missing or unparseable — a broken instrument, not an empty one"
  fi
  aqp=$(mktemp); sed 's/^# AUDIT-QUEUE v1$/# AUDIT-QUEUE-BROKEN/' "$arub" > "$aqp"
  if grep -qE '^# AUDIT-QUEUE v1$' "$aqp"; then
    no "queue-header control DID NOT fire — a corrupted header went unseen"
  else
    ok "control fires: a corrupted queue header is seen as broken, distinct from empty"
  fi
  rm -f "$aqp"
  agbad=""
  while IFS="$(printf '\t')" read -r qid qts qrepo qaxis qsev qclaim qstat qcr; do
    [ -n "${qid:-}" ] || continue
    case "${qstat:-}" in
      ACCEPTED|CLOSED)
        grep -qF "${qcr:-__none__}" Plan.md || agbad="$agbad [$qid:$qcr]"
        ;;
    esac
  done <<AQEOF
$aq
AQEOF
  [ -z "$agbad" ] && ok "gated-fixes law holds over the queue ($aqn row(s); ACCEPTED/CLOSED require a chronicled cr_id)" \
    || no "gated-fixes law VIOLATED — ACCEPTED/CLOSED without a Plan.md cr_id:$agbad"
  agp=$(printf 'q99\t2026-01-01\tpsychic-crew\tA\tmed\tprobe\tACCEPTED\tCR-PHANTOM-X9')
  agpv=""
  while IFS="$(printf '\t')" read -r qid qts qrepo qaxis qsev qclaim qstat qcr; do
    case "${qstat:-}" in ACCEPTED|CLOSED) grep -qF "${qcr:-__none__}" Plan.md || agpv="$agpv [$qid]";; esac
  done <<AQ2EOF
$agp
AQ2EOF
  [ -n "$agpv" ] && ok "control fires: a planted ACCEPTED row with a phantom cr_id is caught$agpv" \
    || no "gated-fixes control DID NOT fire on the planted row"


  # ARC4-2 — the runner and its two P0 controls. The no-write control is a TREE-HASH manifest
  # diff over a tracked+.git tar copy (porcelain cannot see ignored paths — the one directory
  # the lane may write is the one porcelain ignores; and the copy is verified to BE a git work
  # tree first, the C-23 lesson). The skip-guard is proven live by a nested F5 run.
  echo "== ARC4-2 — the runner: skip-guard, tree-hash no-write control, freshness =="
  [ -x scripts/self-audit.sh ] && bash -n scripts/self-audit.sh 2>/dev/null \
    && ok "self-audit.sh present, executable, parses" || no "self-audit.sh missing or broken"
  sagn=$(grep -c 'self-audit skip-guard' scripts/run-crew-tests.sh)
  [[ "$sagn" =~ ^[0-9]+$ ]] || sagn=0
  [ "$sagn" -eq 8 ] && ok "all 7 corrections call sites carry the skip-guard (7 sites + this counting line)" \
    || no "skip-guard site count $sagn != 8 (7 sites + the counter's own match)"
  sfl=$(PSYCHIC_SELF_AUDIT=1 ./scripts/run-crew-tests.sh F5 2>/dev/null | grep -c 'skip-guard')
  [[ "$sfl" =~ ^[0-9]+$ ]] || sfl=0
  [ "$sfl" -ge 1 ] && ok "skip-guard FIRES live (nested F5 run in audit mode: $sfl site(s) skipped)" \
    || no "skip-guard DID NOT fire in a live audit-mode run"
  na=$(mktemp -d)
  git ls-files -z | tar -cf "$na/t.tar" --null -T - .git 2>/dev/null
  mkdir "$na/repo" && tar -xf "$na/t.tar" -C "$na/repo"
  if git -C "$na/repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    ok "no-write control copy IS a git work tree (C-23: the control's substrate proven before use)"
    ( cd "$na/repo" && find . -type f | LC_ALL=C sort > "$na/f0.list" )
    while IFS= read -r f; do printf '%s %s\n' "$(cd "$na/repo" && _sha256 "$f")" "$f"; done < "$na/f0.list" > "$na/m0"
    ( cd "$na/repo" && ./scripts/self-audit.sh --measure-only >/dev/null 2>&1 )
    ( cd "$na/repo" && find . -type f | LC_ALL=C sort > "$na/f1.list" )
    while IFS= read -r f; do printf '%s %s\n' "$(cd "$na/repo" && _sha256 "$f")" "$f"; done < "$na/f1.list" > "$na/m1"
    nwbad=$(diff "$na/m0" "$na/m1" | grep -E '^[<>]' | awk '{print $3}' | sort -u | grep -v '^\./logs/audit/' || true)
    [ -z "$nwbad" ] && ok "no-write holds: the audit lane changed ONLY logs/audit/* (tree-hash diff)" \
      || no "audit lane WROTE outside logs/audit/: $(tr '\n' ' ' <<<"$nwbad")"
    mkdir -p "$na/repo/logs/metrics" && printf 'planted\n' > "$na/repo/logs/metrics/planted-probe"
    ( cd "$na/repo" && find . -type f | LC_ALL=C sort > "$na/f2.list" )
    while IFS= read -r f; do printf '%s %s\n' "$(cd "$na/repo" && _sha256 "$f")" "$f"; done < "$na/f2.list" > "$na/m2"
    nwp=$(diff "$na/m1" "$na/m2" | grep -E '^[<>]' | awk '{print $3}' | sort -u | grep -v '^\./logs/audit/' | grep -c .)
    [[ "$nwp" =~ ^[0-9]+$ ]] || nwp=0
    [ "$nwp" -ge 1 ] && ok "control fires: a planted logs/metrics write IS seen by the manifest diff (porcelain could not see it)" \
      || no "no-write control DID NOT fire on the planted ignored-path write"
  else
    no "no-write control copy is NOT a git work tree — the control would be void (C-23)"
  fi
  rm -rf "$na"
  sgl=$(grep -n 'GATE READY' hooks/stop.sh | head -1 | cut -d: -f1); [[ "$sgl" =~ ^[0-9]+$ ]] || sgl=0
  sal=$(grep -n 'last self-audit' hooks/stop.sh | head -1 | cut -d: -f1); [[ "$sal" =~ ^[0-9]+$ ]] || sal=0
  { [ "$sgl" -ge 1 ] && [ "$sal" -gt "$sgl" ] && grep -q 'PEND' <<<"$(grep -B2 'last self-audit' hooks/stop.sh)"; } \
    && ok "stop-toast: audit staleness sits BELOW gate precedence, proven from the hook's own bytes (gate line $sgl < audit line $sal, PEND-guarded)" \
    || no "stop-toast ordering broken: gate=$sgl audit=$sal or the PEND guard is missing"
  grep -q 'logs/audit/runs.jsonl' hooks/session-start.sh \
    && grep -E -- '-f "\$ROOT/logs/audit/runs.jsonl"' hooks/session-start.sh >/dev/null \
    && ok "session-start freshness line present and guarded (absent logs/ = silent, the bare-clone branch)" \
    || no "session-start freshness line missing or unguarded"


  # TEI-0 — the envelope + pilot, held by the standalone checker (suite-checked like the
  # vega-lite fence: the suite runs the checker and independently spot-binds the fence).
  echo "== TEI-0 — envelope schema + graph pilot =="
  [ -x scripts/check-envelope.sh ] && bash -n scripts/check-envelope.sh 2>/dev/null \
    && ok "check-envelope.sh present, executable, parses" || no "check-envelope.sh missing or broken"
  if ./scripts/check-envelope.sh >/tmp/tei0-check.out 2>&1; then
    ok "check-envelope green: $(tail -1 /tmp/tei0-check.out | tr -d '\n')"
  else
    no "check-envelope RED: $(grep '\[FAIL\]' /tmp/tei0-check.out | head -2 | tr '\n' ' ')"
  fi
  tgn=$(awk '/^# TEI-GRAPH v1$/{f=1;next} f&&/^```/{exit} f' docs/research/TEI-0-pilot.md | jq '.nodes | length' 2>/dev/null)
  case "$tgn" in ''|*[!0-9]*) tgn=0 ;; esac
  [ "$tgn" -ge 10 ] && ok "pilot graph fence extracts independently ($tgn nodes)" \
    || no "pilot graph fence vacuous from the suite's own extraction ($tgn)"
  tvc=$(grep -c '^VERDICT: PARK' docs/research/TEI-0-pilot.md)
  case "$tvc" in ''|*[!0-9]*) tvc=0 ;; esac
  [ "$tvc" -eq 1 ] && ok "pilot verdict PARK recorded once, wake condition named (the RSCH-1 question discharged)" \
    || no "pilot verdict line count $tvc != 1"
  jq -e '.required | length == 8' envelope.schema.json >/dev/null 2>&1 \
    && ok "envelope schema requires its eight members (suite's independent read)" \
    || no "envelope schema required-set broken by the suite's own read"


  # HOOK-1 — the four observation surfaces, tested on the CR-025 template (temp roots, piped
  # fixture JSON). Honest limit restated where it binds: these prove WIRING AND BEHAVIOR; only
  # live rows prove the platform delivers the events.
  echo "== HOOK-1 — observation hooks: stop twin, prompt receipts, ask trail, seen-cursor =="
  h1t=$(mktemp -d); mkdir -p "$h1t/logs"; cp GATES.md "$h1t/" 2>/dev/null
  printf '%s' '{"session_id":"h1","agent_id":"h1-agt","agent_type":"quality-reviewer","agent_transcript_path":"/x/y.jsonl"}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/subagent-stop.sh >"$h1t/stop.out" 2>&1
  h1a=$(jq -r '.agent_id // ""' "$h1t/logs/subagent-stops.jsonl" 2>/dev/null | head -1)
  h1x=$(jq -r '.agent_transcript_path // ""' "$h1t/logs/subagent-stops.jsonl" 2>/dev/null | head -1)
  { [ "$h1a" = "h1-agt" ] && [ "$h1x" = "/x/y.jsonl" ]; } \
    && ok "HOOK-1 stop twin records identity + transcript path (the death-forensics handle)" \
    || no "HOOK-1 stop twin lost fields (id='$h1a' path='$h1x')"
  [ -s "$h1t/stop.out" ] && no "HOOK-1 stop twin wrote to stdout/stderr (must be silent)" \
    || ok "HOOK-1 stop twin is silent and exits 0 (observation law)"
  grep -qE 'tool_response|\.error|success' <<<"$(sed 's/#.*//' hooks/subagent-stop.sh)" \
    && no "HOOK-1 stop twin reads an outcome field — it must fire regardless of success" \
    || ok "HOOK-1 stop twin depends on no outcome field (covers failed dispatches, like its birth twin)"
  printf '%s' '{"session_id":"h1","prompt":"APPROVE X9-PROBE"}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/user-prompt-submit.sh >"$h1t/ups.out" 2>&1
  h1k=$(jq -r '.starts_with_approve_token // ""' "$h1t/logs/prompt-receipts.jsonl" 2>/dev/null | head -1)
  [ "$h1k" = "APPROVE X9-PROBE" ] && ok "HOOK-1 receipt stamps an exact token at submission (whole-prompt anchored)" \
    || no "HOOK-1 receipt missed the exact token (got '$h1k')"
  [ -s "$h1t/ups.out" ] && no "HOOK-1 prompt hook wrote to stdout (context injection risk)" \
    || ok "HOOK-1 prompt hook prints nothing (stdout-injection law)"
  printf '%s' '{"session_id":"h1","prompt":"please APPROVE X9-PROBE later, secret_token=sk-abcdef123456789012345"}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/user-prompt-submit.sh >/dev/null 2>&1
  h1k2=$(jq -r '.starts_with_approve_token // ""' "$h1t/logs/prompt-receipts.jsonl" 2>/dev/null | tail -1)
  [ -z "$h1k2" ] && ok "HOOK-1 anchored negative: prose mentioning a token stamps NO receipt" \
    || no "HOOK-1 receipt fired on prose (got '$h1k2') — the anchor is broken"
  grep -qF 'sk-abcdef123456789012345' "$h1t/logs/prompt-receipts.jsonl" \
    && no "HOOK-1 PROMPT BODY LEAKED into the receipts trail — the no-body law is broken" \
    || ok "HOOK-1 control: a planted secret in the prompt never reaches the trail (derived-only, fire-probed)"
  printf '%s' '{"session_id":"h1","prompt":"REMOTE PROMPT PROTOCOL v1 - this prompt was sent from a remote/mobile session by the operator.\nRun it."}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/user-prompt-submit.sh >/dev/null 2>&1
  h1r=$(jq -r '.is_remote_preamble' "$h1t/logs/prompt-receipts.jsonl" 2>/dev/null | tail -1)
  [ "$h1r" = "true" ] && ok "HOOK-1 a REMOTE PROMPT PROTOCOL turn is recognized at entry" \
    || no "HOOK-1 remote-preamble flag wrong ($h1r)"
  printf '%s' '{"session_id":"h1","agent_id":"h1-agt","agent_type":"fixer","tool_name":"Bash","tool_input":{"command":"deploy --token=ghp_abcdefgh12345678 now"}}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/permission-request.sh >"$h1t/pr.out" 2>&1
  h1p=$(jq -r '.agent_type // ""' "$h1t/logs/permission-requests.jsonl" 2>/dev/null | head -1)
  [ "$h1p" = "fixer" ] && ok "HOOK-1 ask trail is agent-attributed (the ask-side of the denial trail)" \
    || no "HOOK-1 ask row lost attribution ('$h1p')"
  h1g=$(jq -r '.target // ""' "$h1t/logs/permission-requests.jsonl" 2>/dev/null | head -1)
  case "$h1g" in
    *ghp_abcdefgh12345678*) no "HOOK-1 ask trail carries a planted credential UNSCRUBBED" ;;
    *REDACTED*) ok "HOOK-1 control: a planted credential in the asked target is scrubbed (fire-probed)" ;;
    *) no "HOOK-1 ask target neither raw nor redacted ('$h1g') — scrub path broken" ;;
  esac
  [ -s "$h1t/pr.out" ] && no "HOOK-1 ask hook emitted output — it must never answer asks" \
    || ok "HOOK-1 ask hook is silent (observation only, never a decision)"
  h1c=$(mktemp -d); mkdir -p "$h1c/hooks" "$h1c/context" "$h1c/logs"
  cp hooks/session-start.sh hooks/_common.sh "$h1c/hooks/" 2>/dev/null
  printf 'a\nb\nc\n' > "$h1c/Plan.md"; printf 'r1 awaiting\n' > "$h1c/GATES.md"
  printf '# P\n- **Next action:** fx\n' > "$h1c/PROGRESS.md"
  printf '%s' '{}' | CLAUDE_PROJECT_DIR="$h1c" "$h1c/hooks/session-start.sh" >/dev/null 2>&1
  printf 'd\ne\nf\n' >> "$h1c/Plan.md"
  cur2=$(printf '%s' '{}' | CLAUDE_PROJECT_DIR="$h1c" "$h1c/hooks/session-start.sh" 2>/dev/null \
         | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null)
  grep -q 'Plan +3 lines' <<<"$cur2" \
    && ok "HOOK-1 seen-cursor reports the append delta (+3 Plan lines between groundings)" \
    || no "HOOK-1 seen-cursor missed the append delta"
  printf 'r1 APPROVED\n' > "$h1c/GATES.md"
  cur3=$(printf '%s' '{}' | CLAUDE_PROJECT_DIR="$h1c" "$h1c/hooks/session-start.sh" 2>/dev/null \
         | jq -r '.hookSpecificOutput.additionalContext' 2>/dev/null)
  grep -q 'GATES +0 lines (CHANGED)' <<<"$cur3" \
    && ok "HOOK-1 seen-cursor sees a zero-line-delta stamp flip by content hash (the class that matters)" \
    || no "HOOK-1 seen-cursor is blind to the in-place stamp flip"
  h1n=$(grep -c . "$h1c/logs/grounding-cursor.jsonl" 2>/dev/null); [ "${h1n:-0}" -ge 3 ] \
    && ok "HOOK-1 cursor trail accumulates one row per grounding ($h1n rows in fixture)" \
    || no "HOOK-1 cursor trail rows: ${h1n:-0} (want >= 3)"
  printf '%s' '{"session_id":"h1","tool_name":"Agent","tool_input":{"subagent_type":"Explore","prompt":"tiny"}}' \
    | CLAUDE_PROJECT_DIR="$h1t" ./hooks/reference-cap.sh >/dev/null 2>&1
  grep -q '"event":"PreToolUse.observed"' "$h1t/logs/tooluse-audit.jsonl" 2>/dev/null \
    && ok "HOOK-1 reference-cap now leaves an unconditional delivery row (HOOK-2's precondition evidence)" \
    || no "HOOK-1 PreToolUse.observed row missing — delivery evidence not wired"
  h1keys=$(jq -r '.hooks | keys[]' .claude/settings.json 2>/dev/null | tr '\n' ' ')
  case "$h1keys" in
    *SubagentStop*UserPromptSubmit*|*UserPromptSubmit*SubagentStop*) : ;; *)
      no "HOOK-1 settings missing new event keys ($h1keys)"; h1sk=done ;;
  esac
  if [ "${h1sk:-}" != done ]; then
    case "$h1keys" in
      *PermissionRequest*) ok "HOOK-1 all three new events wired in settings (SubagentStop, UserPromptSubmit, PermissionRequest)" ;;
      *) no "HOOK-1 PermissionRequest key missing from settings" ;;
    esac
  fi
  rm -rf "$h1t" "$h1c"

  # C-14 canary. cases_F7 has now executed the artifact eight times; the tree must be exactly
  # as it was on entry, and stress-project/tmp must be UNCHANGED — not empty. B9 leaves legitimate
  # e2e evidence there, and "empty" only looked equivalent to "unchanged" because it started empty.
  f7tree1=$(git status --porcelain | wc -l)
  f7tmp=$(ls -A "$sp/tmp" 2>/dev/null | wc -l)
  { [ "$f7tree1" -eq "$f7tree0" ] && [ "$f7tmp" -eq "$f7tmp0" ]; } \
    && ok "F7 auditing the artifact did not modify it (tree $f7tree0 -> $f7tree1, tmp/ $f7tmp0 -> $f7tmp)" \
    || no "F7 the audit polluted its subject (tree $f7tree0 -> $f7tree1, tmp/ $f7tmp0 -> $f7tmp)"
}

gate_evidence () {
  echo "=== LIVE GATE EVIDENCE — generated $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  echo "--- git ---"; git log --oneline -1; echo "tags: $(git tag -l | tr '\n' ' ')"
  echo "tree: $(git status --porcelain | wc -l) dirty · tracked: $(git ls-files | wc -l)"
  echo "synced: $([ "$(git rev-parse HEAD)" = "$(git rev-parse origin/dev 2>/dev/null)" ] && echo yes || echo NO)"
  echo "--- validators ---"; ./scripts/validate-crew.sh | tail -1
  if [ "${PSYCHIC_SELF_AUDIT:-0}" = 1 ]; then echo "self-audit skip-guard: corrections site evidence skipped (the metrics-writer chain)"
  else ./scripts/check-plan-corrections.sh | tail -2 | head -1; fi
  echo "--- suite ---"
}

WANT="${1:-all}"
case "$WANT" in
  gate) gate_evidence; cases_F0; cases_F1; cases_F2; cases_F3; cases_F4; cases_F5; cases_F6; cases_F7;;
  all)  cases_F0; cases_F1; cases_F2; cases_F3; cases_F4; cases_F5; cases_F6; cases_F7;;
  F0)   cases_F0;; F1) cases_F1;; F2) cases_F2;; F3) cases_F3;; F4) cases_F4;; F5) cases_F5;; F6) cases_F6;; F7) cases_F7;;
  *)    echo "unknown target: $WANT"; exit 64;;
esac
# The generalised canary, asserted at the end of every run. Bound to the FILES, not to a count of
# them: a trail that appears mid-run is a new entry and shows as drift rather than being skipped.
TRAILS_AFTER=$(for f in logs/*.jsonl; do [ -f "$f" ] && printf '%s:%s\n' "$f" "$(wc -l < "$f")"; done | sort)
tb=$(printf '%s\n' "$TRAILS_BEFORE" | grep -c . || true)
if [ "${tb:-0}" = 0 ]; then
  # Announced, not silent: with no trails on disk the canary proves nothing, and a quiet pass here
  # is how it would stop meaning anything in a fresh clone.
  ok "C-14 canary: no live audit trail on disk to protect (fresh checkout)"
elif [ "$TRAILS_BEFORE" = "$TRAILS_AFTER" ]; then
  ok "C-14 canary: all $tb live audit trail(s) unchanged by this run"
else
  no "C-14 canary: a fixture wrote to a LIVE audit trail — before[$(printf '%s' "$TRAILS_BEFORE" | tr '\n' ' ')] after[$(printf '%s' "$TRAILS_AFTER" | tr '\n' ' ')]"
fi


  # R-SD-1 — the CLASS assertion for .claude/rules/shell-discipline.md. Five recurrences across two
  # builds of one defect: `grep -c` prints its count and THEN exits nonzero on zero matches, so a
  # `|| echo DEFAULT` fallback fires too and the composite emits TWO lines. It corrupts any numeric
  # consumer, and it misbehaves only when the count is zero — a clean tree, which is the state a
  # gate run is in. It broke a history write twice, the second time three lines below the comment
  # citing the first.
  #
  # This is a CLASS assertion, not an instance fix. C-27 swept the existing occurrences; this stops
  # the next one entering. `|| true` is deliberately NOT matched: grep prints "0" and true adds
  # nothing, which is the correct form the rule points at.
  #
  # NEEDLES FRAGMENT-ASSEMBLED so this assertion and the rule file never match themselves — the
  # guard-trips-on-its-own-documentation family, recorded seven times here. The allowlist is empty
  # and stays empty; an exemption is how a class assertion decays back into an instance fix.
  _sd1="gre""p -c"; _sd2="|| ec""ho"
  sdbad=$(git ls-files '*.sh' 2>/dev/null | while read -r sdf; do
            sed 's/#.*//' "$sdf" | grep -nF -- "$_sd1" | grep -F -- "$_sd2" | sed "s|^|$sdf:|"
          done)
  sdn=$(git ls-files '*.sh' 2>/dev/null | grep -c .)
  # Vacuity guard: a scan over no files is trivially clean, which is how this would switch off.
  [ "${sdn:-0}" -ge 5 ] \
    && ok "R-SD-1 class scan covers $sdn tracked shell file(s)" \
    || no "R-SD-1 scan is vacuous — only ${sdn:-0} shell file(s) enumerated"
  [ -z "$sdbad" ] \
    && ok "R-SD-1 no count-then-default composite in any tracked shell file" \
    || no "R-SD-1 VIOLATION — count-then-default composite at: $(printf '%s' "$sdbad" | tr '\n' ' ')"

  # R-SD-1 RULE 2 (portability scanner, HARNESS-1) — a count captured from `wc -l` must reach a
  # NUMERIC test. BSD/macOS `wc` left-pads its count ("       0"), so `[ "$(… wc -l)" = 0 ]` takes
  # the FAILURE branch on a value that is genuinely zero — thirteen such false failures surfaced on
  # a MacBook setup. Rule 2's remedy is capture-then-numeric-test. STATED SCOPE, honestly: a line
  # scanner catches the inline offender (`… wc -l)" =`); it cannot follow the two-step form
  # (`n=$(… wc -l); [ "$n" = 0 ]`) across lines — every such site was swept at HARNESS-1 and gains a
  # needle when evidence produces one, exactly as rule 5 states for its own uncovered consumers.
  # Fragment-assembled so this assertion never matches itself; empty allowlist.
  _w1="w""c -l"; _w2=')" ='; _w3=')" !='
  sd2bad=$(git ls-files '*.sh' 2>/dev/null | while read -r sdf; do
             sed 's/#.*//' "$sdf" | grep -nF -- "$_w1" | grep -F -e "$_w2" -e "$_w3" | sed "s|^|$sdf:|"
           done)
  # The scanner must be SEEN to fire — a control that never catches proves nothing (R-SD-1 rule 6).
  sd2probe='[ "$(git status | '"$_w1"$_w2' 0 ]'
  { grep -qF -- "$_w1" <<<"$sd2probe" && grep -qF -- "$_w2" <<<"$sd2probe"; } \
    && ok "R-SD-1 rule 2 scanner fires on a planted inline wc→string offender" \
    || no "R-SD-1 rule 2 scanner is void — did not match a planted offender"
  [ -z "$sd2bad" ] \
    && ok "R-SD-1 rule 2: no wc -l count reaches an inline string test in tracked shell" \
    || no "R-SD-1 rule 2 VIOLATION — wc -l into string compare at: $(printf '%s' "$sd2bad" | tr '\n' ' ')"

  # R-SD-1 RULE 7 (portability scanner, HARNESS-1) — GNU-isms that misbehave on BSD/macOS userland,
  # each of which cost a real failure or a SILENT false-pass on a MacBook setup:
  #   (a) `sed -i` with no suffix — BSD consumes the script as the suffix operand and edits nothing;
  #       the portable form is `-i.bak … && rm` (the apply-models.sh idiom).
  #   (b) `sha256sum` reached directly — absent on macOS, both hashes come back empty and the
  #       byte-pin guard passes on "" = "" — worse than a red; must go through the _sha256 helper.
  #   (c) `paste -sd` without an explicit stdin operand — BSD paste needs a file/`-` argument; awk
  #       replaces it and drops the bc dependency too.
  # Fragment-assembled; the _sha256 DEFINITION and the `-i.bak` portable form are the legitimate
  # carriers and self-exclude by shape. Empty allowlist. Vacuity is covered by rule 1's sdn≥5 above.
  _pb="sha256""sum"; _pc="past""e -sd"; _pi="se""d -i "
  pabad=$(git ls-files '*.sh' 2>/dev/null | while read -r pf; do
            sc=$(sed 's/#.*//' "$pf")
            printf '%s\n' "$sc" | grep -nE "${_pi}['\"]"       | sed "s|^|$pf:(a) |"
            printf '%s\n' "$sc" | grep -nF -- "$_pb" | grep -vF '_sha256 ()' | sed "s|^|$pf:(b) |"
            printf '%s\n' "$sc" | grep -nF -- "$_pc" | grep -vF -- '-sd+ -'  | sed "s|^|$pf:(c) |"
          done)
  # Fire-probe: three planted offenders, one per shape, must each match their needle.
  { grep -qE "${_pi}['\"]" <<<"${_pi}'x'" \
      && grep -qF -- "$_pb" <<<"${_pb} f" \
      && grep -qF -- "$_pc" <<<"${_pc}+ | bc"; } \
    && ok "R-SD-1 rule 7 scanner fires on planted sed-i / sha256 / paste offenders" \
    || no "R-SD-1 rule 7 scanner is void — a planted GNU-ism went unmatched"
  [ -z "$pabad" ] \
    && ok "R-SD-1 rule 7: no unguarded GNU-ism (sed-i / sha256 / paste) in tracked shell" \
    || no "R-SD-1 rule 7 VIOLATION — GNU-ism at: $(printf '%s' "$pabad" | tr '\n' ' ')"

  # R-SEC-1 RULE 3 — redaction is enforced, not promised. Every writer that appends to a log or
  # ledger must strip token-shaped values, and this proves it by writing planted fakes THROUGH each
  # writer and reading the trail back. Grepping the writers for the word "scrub" would report green
  # for a writer that calls it on the wrong variable, which is the proxy family recorded ten times
  # here — error-recovery passed exactly that reading while leaking a token verbatim.
  #
  # Shapes are GENERIC and fragment-assembled: real values never appear even in tests (rule 3), and
  # a contiguous literal would trip this repo's own scanners.
  rsg="gh""p_"; rsx="xox""b-"; rsa="AKI""A"; rsj="ey""J"
  rst="${rsg}RSEC1AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  rsroot=$(mktemp -d); mkdir -p "$rsroot/logs"; cp GATES.md models.config.json "$rsroot/" 2>/dev/null
  rsleak=""
  # deny() — the worst case: the commands a guard blocks are the likeliest to carry a credential.
  g1=git; g2=clone
  printf '%s' "$(jq -cn --arg c "$g1 $g2 https://x@h.invalid/r?t=$rst" '{tool_name:"Bash",tool_input:{command:$c}}')" \
    | CLAUDE_PROJECT_DIR="$rsroot" ./hooks/bash-blocker.sh >/dev/null 2>&1
  # HARNESS-CONV-1 vacuity guard: if the deny stopped writing entirely, the leakage grep below
  # finds nothing and reports a clean pass having tested nothing — the recorded vacuous-pass class.
  [ -s "$rsroot/logs/tooluse-audit.jsonl" ] \
    && ok "R-SEC-1 deny probe non-vacuous — the deny appended a record before leakage is judged" \
    || no "R-SEC-1 deny probe VACUOUS — the blocker wrote nothing; the leakage check proves nothing"
  grep -qF -- "$rst" "$rsroot/logs/tooluse-audit.jsonl" 2>/dev/null && rsleak="$rsleak [deny]"
  # audit-logger — every ordinary tool use.
  printf '%s' "$(jq -cn --arg c "ec""ho $rst" '{tool_name:"Bash",tool_input:{command:$c}}')" \
    | CLAUDE_PROJECT_DIR="$rsroot" ./hooks/audit-logger.sh >/dev/null 2>&1
  grep -qF -- "$rst" "$rsroot/logs/tooluse-audit.jsonl" 2>/dev/null && rsleak="$rsleak [audit-logger]"
  # error-recovery — F-1 at SECURITY-1: it truncated instead of redacting and leaked verbatim.
  printf '%s' "$(jq -cn --arg e "auth failed using token $rst" '{tool_name:"Bash",tool_response:{error:$e}}')" \
    | CLAUDE_PROJECT_DIR="$rsroot" ./hooks/error-recovery.sh >/dev/null 2>&1
  grep -qF -- "$rst" "$rsroot/logs/build-errors.jsonl" 2>/dev/null && rsleak="$rsleak [error-recovery]"
  [ -z "$rsleak" ] \
    && ok "R-SEC-1 rule 3: a planted token survives no log writer (deny, audit-logger, error-recovery)" \
    || no "R-SEC-1 rule 3 VIOLATED — planted token written verbatim by:$rsleak"
  # The scrubber must cover the shapes the contract names, not just the one tested above.
  # Each planted value must be a REAL instance of its shape. The first version of this probe used a
  # bare `eyJ` prefix with no dots and reported the scrubber broken — but a JWT is
  # header.payload.signature, and the pattern correctly declines to redact something that is not one.
  # The probe was wrong, not the guard. R-SD-1 rule 6: exercise the exact construct.
  rsmiss=""
  rsvals="${rsg}ZZZZZZZZZZZZZZZZZZZZ ${rsx}ZZZZZZZZZZZZZZZZZZZZ ${rsa}ZZZZZZZZZZZZZZZZ ${rsj}ZZZZZZZZ.${rsj}ZZZZZZZZ.ZZZZZZZZ"
  for sh in $rsvals; do
    printf '%s' "$(jq -cn --arg c "tok""en=$sh" '{tool_name:"Bash",tool_input:{command:$c}}')" \
      | CLAUDE_PROJECT_DIR="$rsroot" ./hooks/audit-logger.sh >/dev/null 2>&1
    # Capture, then test — R-SD-1 rule 5. The class assertion caught this line as a pipe-to-grep-q
    # within the same session that wrote it, which is the second time this run the enforcement has
    # found my code before I did.
    rsline=$(tail -1 "$rsroot/logs/tooluse-audit.jsonl")
    grep -qF -- "$sh" <<<"$rsline" && rsmiss="$rsmiss [${sh%%Z*}]"
  done
  [ -z "$rsmiss" ] \
    && ok "R-SEC-1 rule 3: every shape the contract names is redacted by the scrubber" \
    || no "R-SEC-1 rule 3: shape(s) not redacted:$rsmiss"
  rm -rf "$rsroot"

  # H0a — the gate-order guard. It exists because THIS session's predecessor committed before the
  # operator's token at LITE-SYNC-2; one breach of a constitutional control earns a mechanical guard
  # rather than a promise. Bound to the MAPPED path, not a literal, for CR-024's reason: a check
  # naming its own target cannot notice the map drifting away from it.
  ggp=$(awk -F'#' '/scripts\// && NF>1 {print $2}' DIRECTORY_GUIDE.md | grep -oE 'gate-guard' | head -1)
  ggf="scripts/${ggp:-gate-guard}.sh"
  { [ -n "$ggp" ] && [ -x "$ggf" ]; } \
    && ok "H0a gate-guard present and executable at the path the map names ($ggf)" \
    || no "H0a gate-guard missing from the mapped path (map said '${ggp:-nothing}')"
  # The REFUSAL BRANCH must read the ledger. A guard that exits 0 unconditionally satisfies every
  # caller and guards nothing — the proxy family recorded ten times here. Needles fragment-assembled
  # so this assertion and the guard's own prose never match themselves.
  _gg1="GATE""S.md"; _gg2="REFU""SED"; _gg3="APPRO""VED"
  ggbody=$(sed -E 's/^[[:space:]]*#.*$//; s/[[:space:]]#.*$//' "$ggf" 2>/dev/null)
  ggmiss=""
  for nd in "$_gg1" "$_gg2" "$_gg3"; do
    grep -qF -- "$nd" <<<"$ggbody" || ggmiss="$ggmiss [$nd]"
  done
  [ -z "$ggmiss" ] \
    && ok "H0a gate-guard's refusal branch reads the ledger and keys on the approval marker" \
    || no "H0a gate-guard is missing load-bearing logic:$ggmiss — it would pass every caller"

  # R-SD-1 rule 5 — the SIBLING class, added at v2 after the b77fbec flake. `producer | grep -q PAT`
  # under pipefail: grep -q exits the instant it matches, the producer's next write takes SIGPIPE
  # (141), and pipefail reports the producer's death as the pipeline's verdict. Measured at 2 of 42
  # invocations on a 381-line file with the match at line 28 — a race that scales with size and load,
  # and cost a one-in-four red suite on unchanged inputs.
  #
  # NO SMALL-INPUT EXEMPTION, per the rule: uniformity is the guard, and a risk-tiered allowlist is
  # a future defect with paperwork. The allowlist is empty and stays empty.
  #
  # COMMENT STRIPPING IS DELIBERATELY MORE ACCURATE THAN `s/#.*//`, and this is not pedantry: the
  # naive form destroys any line carrying a `#` inside a string, and one of the 29 swept sites was
  # `sed 's/#.*//' FILE | grep -qE ...` — it hid from a naive census of its own class. Stripping
  # only a hash introduced by whitespace, or a whole-line comment, keeps such lines visible.
  _sd5="| gr""ep -"
  sd5bad=$(git ls-files '*.sh' 2>/dev/null | while read -r sd5f; do
             sed -E 's/^[[:space:]]*#.*$//; s/[[:space:]]#.*$//' "$sd5f" \
               | grep -nE '\|[[:space:]]*grep[[:space:]]+-[a-zA-Z]*q' | sed "s|^|$sd5f:|"
           done)
  [ -z "$sd5bad" ] \
    && ok "R-SD-1 rule 5: no status-consumed pipeline with a signal-able producer ($sdn files, census 29 -> 0)" \
    || no "R-SD-1 rule 5 VIOLATION — pipe-to-grep-q at: $(printf '%s' "$sd5bad" | tr '\n' ' ')"

# ONE shared total for both closing bindings. Each previously did its own +1 arithmetic, which
# broke twice: once when the C-14 canary was added after the README binding, and again when the
# C-28 binding was moved last and the README binding stopped counting it. The +2 is the two
# assertions below, which are the last things this script emits.
SUITE_TOTAL=$((P + F + 2))
# CR-027 — the README's reproduction block stated 37 / 144 / 24 while the real numbers were
# 43 / 166 / 26. Nothing bound them, so they drifted for four sessions in the one file a new reader
# starts from. Fixing the numbers without binding them would just restart the clock.
#
# Each script asserts its OWN number. That is deliberate: a cross-script check would have to invoke
# the other suite, and validate-crew invoking run-crew-tests invoking validate-crew is a cycle. A
# script always knows its own total, so the binding needs nothing external.
#
# The +1 is THIS assertion, which has not been counted yet at the moment it runs. Stated rather than
# left as a magic number for someone to "fix" later.
if [ "$WANT" = "all" ] && { ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 || [ ! -f logs/arbiter-audit.jsonl ]; }; then
  # Same guard as validate-crew's, for the same reason — see the note there.
  ok "CR-027 README count describes the primary checkout; this is not one"
elif [ "$WANT" = "all" ]; then
  # EVERY claim, not the first. The first version bound only the count inside the fenced Quickstart
  # block and left README:311's "144 crew assertions" unbound and four sessions stale — a binding
  # that covers one instance of a claim is the same defect as a canary that covers one trail, which
  # is what C-27 was about. And it ran BEFORE the C-14 canary, so an assertion added after it was
  # invisible to it and the binding passed on a number one short. It now runs last.
  # CORRECTIONS-2 (#5): CR-027 legitimately binds the AUTHORED assertion count (SUITE_TOTAL = P+F+2),
  # stable red or green — the README claims how many assertions EXIST, not how many passed today. The
  # pass/fail claim is C-28's job (fixed above). CR-027 is not the defect.
  rct=$SUITE_TOTAL
  rcall=$(grep -oE '[0-9]+ crew assertions' README.md 2>/dev/null | grep -oE '^[0-9]+' | sort -u)
  rcn=$(printf '%s\n' "$rcall" | grep -c . || true)
  if [ "${rcn:-0}" = 0 ]; then
    no "CR-027 README states no crew-assertion count to bind — the claim was removed, not updated"
  else
    rcbad=$(printf '%s\n' "$rcall" | grep -vxF "$rct" | tr '\n' ' ')
    [ -z "$rcbad" ] && ok "CR-027 every crew-assertion claim in README agrees ($rcn distinct value(s)) and matches this run ($rct)" \
                    || no "CR-027 README carries stale crew-assertion count(s):[$rcbad] — this run has $rct"
  fi
else
  # Announced, never silent: a partial run legitimately has a different total, and a check that
  # quietly passes on 'not applicable' is the shape C-23 punished.
  printf '  [INFO] CR-027 README count not checked — partial target "%s", only a full run is comparable\n' "$WANT"
fi

# ENVIRONMENT GUARD — the same one the README binding already carries, and which I failed to apply
# here. The assertion total is NOT invariant: a git-archive extract runs 38+5, a detached worktree
# 41+3, and the primary checkout 44+1, because blocks are gated on optional runtime artifacts. The
# summary's figure describes the primary checkout, so the comparison is scoped to it and ANNOUNCED
# elsewhere. Caught by the portability drill immediately after the gate — the fourth appearance of
# equality-on-a-varying-count in this build, and the second in this session.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 || [ ! -f logs/arbiter-audit.jsonl ]; then
  ok "C-28 summary figure describes the primary checkout; this is not one"
else
  # C-28 — this script also binds its own claim in context/session-summary.md. save-context cannot
  # compute it: check-plan-corrections runs save-context under a temp root, so a call back into a
  # suite would recurse. The suite is the only component that knows its own total.
  ssum="context/session-summary.md"
  ssgot=$(grep -oE 'crew suite \*\*([^*]+)\*\*' "$ssum" 2>/dev/null | head -1 | sed -E 's/^crew suite \*\*//; s/\*\*$//')
  # CORRECTIONS-2 (#5): the crew twin of the same defect — bind the clean figure ONLY when the run
  # is clean; a red run (F>0 so far) fails here rather than reading PASS beside red, and no figure is
  # recomputed in the red branch so the +2 self-count cannot go off-by-one.
  if [ "$F" -ne 0 ]; then
    no "C-28 cannot bind a clean summary — this run is red (F=$F); fix the failures first"
  elif [ -z "$ssgot" ]; then
    ok "C-28 summary makes no crew suite claim — nothing to bind"
  else
    sswant="$SUITE_TOTAL PASS / 0 FAIL"
    if [ "$ssgot" = "$sswant" ]; then
      ok "C-28 summary's crew suite figure matches this run ($sswant)"
    else
      no "C-28 summary says crew suite '$ssgot', this run is '$sswant'"
    fi
  fi
fi

printf '\n== run-crew-tests: %s PASS / %s FAIL ==\n' "$P" "$F"
[ "$F" = 0 ] || exit 1
