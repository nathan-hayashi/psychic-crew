#!/usr/bin/env bash
# SessionStart — §15.4 re-grounding. The event was confirmed to exist at F0 step 6, so this is
# hook-enforced rather than relying only on the CLAUDE.md continuity bullet.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
CTX=$( {
  printf 'HC-8 re-grounding. Disk is canonical; this window is a cache.\n'
  printf 'Recorded next action: %s\n' "$(grep -E '^- \*\*Next action:' "$ROOT/PROGRESS.md" 2>/dev/null | tail -1)"
  printf 'Read before acting: PROGRESS.md tail, GATES.md, context/session-summary.md, context/plan-corrections.md.\n'
  [ -f "$ROOT/.claude/state/checkpoints/latest.md" ] && printf 'A rolling snapshot exists at .claude/state/checkpoints/latest.md\n'
  [ -f "$ROOT/logs/audit/runs.jsonl" ] && printf 'Last self-audit: %s\n' "$(tail -1 "$ROOT/logs/audit/runs.jsonl" 2>/dev/null | jq -r '.ts // "unreadable"' 2>/dev/null)"
  printf 'Proceed strictly forward under 0.2b: never regress, never re-run an artifact that exists.\n'
} 2>/dev/null )
jq -cn --arg c "$CTX" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
exit 0
