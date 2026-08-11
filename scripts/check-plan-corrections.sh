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

h=$(ls -1 hooks/*.sh 2>/dev/null | wc -l)
if [ "$h" = 0 ]; then report C-03 F2 PENDING "hooks/ empty — F2 must emit hookSpecificOutput.permissionDecision, not bare exit 2"
else
  miss=""
  for f in hooks/bash-blocker.sh hooks/model-guard.sh; do
    [ -f "$f" ] || continue
    grep -q 'permissionDecision' "$f" || miss="$miss $f"
  done
  [ -z "$miss" ] && report C-03 F2 APPLIED "PreToolUse guards emit permissionDecision" \
                 || report C-03 F2 PENDING "missing permissionDecision in:$miss"; fi

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

for id in C-06:'HC-2 scan matches lines not filenames':'grep -v .\"forbidden_substrings\"' \
          C-07:'session-model jq uses if/then/else':'if \$m=="pinned"' \
          C-08:'agent loop avoids the pipeline subshell':'for a in \$\(jq'; do
  i=${id%%:*}; rest=${id#*:}; desc=${rest%%:*}; pat=${rest##*:}
  if grep -qE "$pat" scripts/apply-models.sh 2>/dev/null; then report "$i" F0 APPLIED "$desc"
  else report "$i" F0 PENDING "$desc — EX-02 fix missing from apply-models.sh"; fi
done

printf '\n== %s APPLIED / %s PENDING ==\n' "$APPL" "$PEND"
case "$WANT" in
  all) echo "(informational; run with a phase id, e.g. 'F2', to gate on it)"; exit 0;;
  *)   if [ "$GATE" = 1 ]; then echo "GATE $WANT: FAIL — corrections owned by $WANT are still pending"; exit 1
       else echo "GATE $WANT: PASS — all $WANT-owned corrections applied"; exit 0; fi;;
esac
