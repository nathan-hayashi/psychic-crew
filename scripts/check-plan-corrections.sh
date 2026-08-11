#!/usr/bin/env bash
# check-plan-corrections.sh — machine-check the plan-vs-reality registry in
# context/plan-corrections.md. The execution authority is never edited, so these
# corrections must be enforced here or they get silently rebuilt from the plan.
#
# Usage: check-plan-corrections.sh [all|F0|F2|F3]
#   no args / all : report every correction, exit 0 (informational)
#   F<n>          : exit 1 if any correction owned by F<n> is still PENDING
set -uo pipefail
cd "$(dirname "$0")/.."
WANT="${1:-all}"
PEND=0; APPL=0; NA=0

report () { # id owner status detail
  case "$3" in
    APPLIED) APPL=$((APPL+1));;
    PENDING) PEND=$((PEND+1)); case "$WANT" in "$2") GATE=1;; esac;;
    *)       NA=$((NA+1));;
  esac
  printf '  %-6s %-3s %-9s %s\n' "$1" "$2" "$3" "$4"
}
GATE=0
S=".claude/settings.json"

echo "== plan corrections (source: context/plan-corrections.md) =="

n=$(jq '[.hooks[]?[]? | select(has("hook"))] | length' "$S" 2>/dev/null || echo -1)
if [ "$n" = 0 ]; then report C-01 F2 APPLIED "no hook entry uses the non-existent 'hook' string key"
else                 report C-01 F2 PENDING "$n hook entries still use \"hook\":<string>; need \"hooks\":[{type,command}]"; fi

if [ "$(jq -r '.hooks | has("PostToolUseFail")' "$S" 2>/dev/null)" = "false" ]; then
  report C-02 F2 APPLIED "no PostToolUseFail event"
else
  report C-02 F2 PENDING "event PostToolUseFail present; real name is PostToolUseFailure"; fi

# C-03 is checked BEHAVIOURALLY: the deny contract lives in the shared hooks/_common.sh, so
# grepping each guard for the string misses a correct implementation. Feed each guard a real
# denial input and assert the JSON contract actually comes out.
h=$(ls -1 hooks/*.sh 2>/dev/null | wc -l)
if [ "$h" = 0 ]; then
  report C-03 F2 PENDING "hooks/ empty — F2 must emit hookSpecificOutput.permissionDecision, not bare exit 2"
else
  # Payloads are passed as printf ARGUMENTS, never as the format string: printf interprets
  # backslash escapes in the format, which silently corrupts JSON containing \" and makes a
  # working guard look broken. That is exactly what happened on the first attempt here.
  c3=1; c3why=""
  j1='{"tool_input":{"command":"git clone https://example/x"}}'
  j2='{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-fable-5\""}}'
  j3='{"tool_input":{"file_path":"/x/.env","content":"K=v"}}'
  for pair in "bash-blocker:$j1" "model-guard:$j2" "sensitive-guard:$j3"; do
    g=${pair%%:*}; j=${pair#*:}
    o=$(printf '%s' "$j" | "./hooks/$g.sh" 2>/dev/null || true)
    printf '%s' "$o" | grep -q '"permissionDecision":"deny"' || { c3=0; c3why="$c3why $g"; }
  done
  if [ "$c3" = 1 ]; then report C-03 F2 APPLIED "all three PreToolUse guards emit permissionDecision:deny on a real trigger"
  else report C-03 F2 PENDING "guards not denying via the JSON contract:$c3why"; fi
fi

if git check-ignore -q .claude/state/compact-pending 2>/dev/null; then
  report C-04 F2 APPLIED ".claude/state/ is gitignored"
else
  report C-04 F2 PENDING ".claude/state/ tracked; DIRECTORY_GUIDE says it must be ignored"; fi

v=0
grep -q 'Task|Agent' scripts/validate-crew.sh 2>/dev/null || v=1
if [ -f .claude/rules/arbiter-protocol.md ]; then
  grep -q 'Agent' .claude/rules/arbiter-protocol.md || v=1
  [ "$v" = 0 ] && report C-05 F3 APPLIED "both Task and Agent matched in detection and rule" \
               || report C-05 F3 PENDING "dispatch detection does not match the current tool name 'Agent'"
else
  [ "$v" = 0 ] && report C-05 F3 PENDING "validate-crew ok; .claude/rules/arbiter-protocol.md not written yet (F3)" \
               || report C-05 F3 PENDING "detection incomplete and rule not yet written"; fi

# C-06 was EX-02's fix to the filename-vs-line bug inside the old `grep -ril` form. EX-03 replaced
# that form entirely with assignment-position matching, under which the bug cannot occur — so its
# detection pattern legitimately no longer exists. Superseded, not unfixed.
CODE_AM=$(sed 's/#.*//' scripts/apply-models.sh 2>/dev/null)
if printf '%s' "$CODE_AM" | grep -q 'grep -ril'; then
  report C-06 F0 PENDING "HC-2 still uses grep -ril (filenames); the -v filter can never suppress"
elif printf '%s' "$CODE_AM" | grep -q 'ascii_downcase | contains'; then
  report C-06 F0 SUPERSEDED "subsumed by C-09; the grep -ril form no longer exists"
else
  report C-06 F0 PENDING "HC-2 implementation unrecognised — re-verify by hand"
fi

for id in \
          C-07:'session-model jq uses if/then/else':'if \$m=="pinned"' \
          C-08:'agent loop avoids the pipeline subshell':'for a in \$\(jq'; do
  i=${id%%:*}; rest=${id#*:}; desc=${rest%%:*}; pat=${rest##*:}
  if grep -qE "$pat" scripts/apply-models.sh 2>/dev/null; then report "$i" F0 APPLIED "$desc"
  else report "$i" F0 PENDING "$desc — EX-02 fix missing from apply-models.sh"; fi
done

if sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null | grep -q 'ascii_downcase | contains' \
   && printf '%s' "$CODE_AM" | grep -q 'ascii_downcase | contains'; then
  if grep -q 'HITS=' scripts/apply-models.sh 2>/dev/null; then
    report C-09 F1 APPLIED "HC-2 matches assignment positions; guard captures hits (pipefail-safe)"
  else
    report C-09 F1 PENDING "HC-2 narrowed but the guard still tests pipeline status — silently skippable under pipefail"
  fi
else
  report C-09 F1 PENDING "HC-2 is still a bare substring scan; F2 model-guard.sh cannot pass validation"
fi

# C-10: CLAUDE.md binds every agent to .claude/rules/fallback-protocol.md, but no §6 phase step
# writes it — F3 is assigned rules 5.2.2-5.2.4 only, and §5.2.1 sits in the F0 payload section that
# F0's step list never reaches. A binding rule absent from disk is a dangling contract: agents are
# instructed to obey a file they cannot read, and every FALLBACK path silently loses its definition.
if [ -f .claude/rules/fallback-protocol.md ] && grep -q 'FALLBACK' .claude/rules/fallback-protocol.md; then
  report C-10 F3 APPLIED "fallback-protocol.md present; CLAUDE.md's binding reference resolves"
else
  report C-10 F3 PENDING "CLAUDE.md binds all agents to .claude/rules/fallback-protocol.md, which is absent"
fi

printf '\n== %s APPLIED / %s PENDING / %s SUPERSEDED ==\n' "$APPL" "$PEND" "$NA"
case "$WANT" in
  all) echo "(informational; run with a phase id, e.g. 'F2', to gate on it)"; exit 0;;
  *)   if [ "$GATE" = 1 ]; then echo "GATE $WANT: FAIL — corrections owned by $WANT are still pending"; exit 1
       else echo "GATE $WANT: PASS — all $WANT-owned corrections applied"; exit 0; fi;;
esac
