#!/usr/bin/env bash
# run-crew-tests.sh — crew test harness (§5.5). Wraps the validators and adds per-phase cases.
#
# Usage:  run-crew-tests.sh [all|gate|F0|F1|F2|F3]
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
  # EX-01: seeds equal their payloads modulo the recorded rename delta (0 / 1 / 1)
  for pair in "CLAUDE.md 4.1 1" "CLAUDE_DESIGN.md 4.2 0" "DIRECTORY_GUIDE.md 4.3 1"; do
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
  check "error-recovery exits 0"                 0 feed error-recovery '{"tool_name":"Bash","tool_response":{"error":"bash: foo: command not found"}}'
  [ -f logs/build-errors.jsonl ] && ok "error-recovery wrote build-errors.jsonl" || no "no build-errors record"
  printf '%s' '{"tool_name":"Bash","tool_response":{"error":"bash: foo: command not found"}}' \
    | ./hooks/error-recovery.sh 2>/dev/null | grep -q 'minimal-shell' \
    && ok "error-recovery emits the §9 corpus hint" || no "§9 hint missing"
  check "notify exits 0 and is never fatal"      0 feed notify '{"message":"run-crew-tests probe"}'
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
  for a in security-reviewer quality-reviewer lead-planner; do
    grep -m1 '^tools:' ".claude/agents/$a.md" | grep -qE 'Write|Edit|Bash' \
      && no "$a holds a mutating tool — read-only by contract" || ok "$a is read-only"
  done
  for r in fallback-protocol arbiter-protocol model-policy security; do
    [ -f ".claude/rules/$r.md" ] && ok "rule $r.md present" || no "rule $r.md missing"
  done
  grep -q 'Task|Agent' .claude/rules/arbiter-protocol.md \
    && ok "C-05: arbiter-protocol matches both tool names" || no "C-05: arbiter-protocol misses Task|Agent"
  grep -rq 'hiya-crew' .claude/agents .claude/rules 2>/dev/null \
    && no "EX-01: the pre-rename project name survives in .claude/" || ok "EX-01: no pre-rename name in agents or rules"
  # EX-04: the arbiter is the ONLY component permitted a dispatch tool. Exclusivity is what turns
  # §5.2.2 from a rule a lead could break into one it physically cannot, so assert exclusivity and
  # not mere presence — a second grant silently re-opens the bypass this build's design rests on.
  disp=$(grep -l '^tools:.*Agent' .claude/agents/*.md 2>/dev/null | xargs -n1 basename 2>/dev/null | tr '\n' ' ')
  [ "$disp" = "arbiter.md " ] && ok "EX-04: arbiter holds the only dispatch tool" \
                              || no "EX-04: dispatch tool held by [$disp], expected arbiter.md alone"
  check "plan corrections: F3 clean" 0 ./scripts/check-plan-corrections.sh F3
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
  gate) gate_evidence; cases_F0; cases_F1; cases_F2; cases_F3;;
  all)  cases_F0; cases_F1; cases_F2; cases_F3;;
  F0)   cases_F0;; F1) cases_F1;; F2) cases_F2;; F3) cases_F3;;
  *)    echo "unknown target: $WANT"; exit 64;;
esac
printf '\n== run-crew-tests: %s PASS / %s FAIL ==\n' "$P" "$F"
[ "$F" = 0 ] || exit 1
