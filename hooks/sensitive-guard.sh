#!/usr/bin/env bash
# PreToolUse[Write|Edit] — protect .env / secrets, and block REMOVAL of protected .gitignore
# entries. Appends are permitted: C-04 itself was a .gitignore append.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
C=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null || true)
[ -n "$F" ] || exit 0
case "$F" in
  *.env|*.env.*|*/secrets/*|*/.ssh/*) deny "secrets guard: writes to .env/secrets are blocked" ;;
esac
case "$F" in
  */.gitignore)
    # Only a full-content Write can be checked for removals; an Edit supplies a fragment.
    [ -n "$C" ] || exit 0
    for e in ".env" "logs/" ".claude/state/"; do
      grep -qxF "$e" <<<"$C" || deny "sensitive guard: write removes protected .gitignore entry '$e'"
    done ;;
esac
exit 0
