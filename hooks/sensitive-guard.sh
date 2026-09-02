#!/usr/bin/env bash
# PreToolUse[Write|Edit] — protect .env / secrets, and block REMOVAL of protected .gitignore
# entries. Appends are permitted: C-04 itself was a .gitignore append.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
T=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
C=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null || true)
[ -n "$F" ] || exit 0
case "$F" in
  *.env|*.env.*|*/secrets/*|*/.ssh/*) deny "secrets guard: writes to .env/secrets are blocked" ;;
esac
# CORRECTIONS-2 (#7): audit/ledger trails are append-only. A whole-file Write to an EXISTING
# non-empty trail truncates concurrent hook appends and loses coverage — deny it and force an Edit
# append. Write-to-CREATE (absent or empty file) is permitted so a session's first line is not blocked;
# Edit is never affected (this branch is Write-only).
if [ "$T" = "Write" ]; then
  case "$F" in
    *logs/*)
      case "${F##*/}" in
        arbiter-audit.jsonl|tooluse-audit.jsonl|subagent-starts.jsonl|build-errors.jsonl|intake-contracts.jsonl|subagent-stops.jsonl|prompt-receipts.jsonl|permission-requests.jsonl|grounding-cursor.jsonl)
          [ -s "$F" ] && deny "append-only guard: '$F' is an append-only audit trail — append via Edit, not a whole-file Write" ;;
      esac ;;
  esac
fi
case "$F" in
  */.gitignore)
    # Only a full-content Write can be checked for removals; an Edit supplies a fragment.
    [ -n "$C" ] || exit 0
    for e in ".env" "logs/" ".claude/state/"; do
      grep -qxF "$e" <<<"$C" || deny "sensitive guard: write removes protected .gitignore entry '$e'"
    done ;;
esac
exit 0
