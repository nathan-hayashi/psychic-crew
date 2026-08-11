# shellcheck shell=bash
# Shared hook preamble. R2: never depend on $CLAUDE_PROJECT_DIR alone — it is unset in some
# contexts, and a hook resolving to an empty path fails silently, which is the worst outcome
# for an enforcement layer. Derive from the script's own location as the fallback.
export PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
PHASE=$(grep -oE '^## \[F[0-9]' "$ROOT/PROGRESS.md" 2>/dev/null | tail -1 | grep -oE 'F[0-9]' || true)
[ -n "${PHASE:-}" ] || PHASE="F?"
now () { date -u +%Y-%m-%dT%H:%M:%SZ; }
# C-03: PreToolUse denial is JSON on stdout. A bare exit 2 does NOT block. Emit both — the JSON
# denies, the exit code is belt-and-braces and matches the working local hook.
deny () {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
  exit 2
}
