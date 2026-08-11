#!/usr/bin/env bash
# restore-context.sh [latest|<n>|<file>] — §15.9(d). Prints the chosen snapshot and the fixed
# reload instruction. Read-only.
set -uo pipefail
cd "$(dirname "$0")/.."
CK=".claude/state/checkpoints"
A="${1:-latest}"
case "$A" in
  latest) F="$CK/latest.md" ;;
  ''|*[!0-9]*) F="$A" ;;
  *) F=$(ls -1t "$CK"/ckpt-*.md 2>/dev/null | sed -n "${A}p") ;;
esac
if [ -z "${F:-}" ] || [ ! -f "$F" ]; then
  echo "[FAIL] no snapshot for '$A'. Available:"; ls -1t "$CK" 2>/dev/null | sed 's/^/  /'; exit 1
fi
echo "===== $F ====="; cat "$F"
cat <<'MSG'

===== RELOAD INSTRUCTION (paste after any compaction, /clear, or new session) =====
Restore per §15.9: read .claude/state/checkpoints/latest.md (or the named snapshot) plus
PROGRESS.md tail and context/session-summary.md, state the recorded next_action, then continue
strictly forward under 0.2b — no regression, no re-runs.
MSG
