#!/usr/bin/env bash
# PreToolUse[Write|Edit] — HC-2: block any write ASSIGNING a forbidden model into the config surface.
# EX-03: assignment positions only. A substring scan would block this repo's own rule file and
# would make this very script unwriteable, since it must contain the string to match it.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
C=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || true)
[ -n "$F" ] || exit 0
case "$F" in
  */.claude/*|*/models.config.json|*models.config.json) ;;
  *) exit 0 ;;
esac
BAD=$(jq -r '.forbidden_substrings[]' "$ROOT/models.config.json" 2>/dev/null || echo fable)
for b in $BAD; do
  if printf '%s' "$C" | grep -qiE "^[[:space:]]*\"?model\"?[[:space:]]*:[[:space:]]*\"?[^\",}]*${b}"; then
    deny "HC-2: write assigns a forbidden ($b) model into the config surface"
  fi
done
exit 0
