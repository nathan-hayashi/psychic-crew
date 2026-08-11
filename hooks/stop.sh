#!/usr/bin/env bash
# Stop[*] — §15.9(b) rolling latest.md, and §15.3 one-shot consumption of the compact flag.
# Blocking uses a TOP-LEVEL decision: {"decision":"block","reason":"..."} (verified F0 step 6).
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
ST="$ROOT/.claude/state"; CK="$ST/checkpoints"
{
  mkdir -p "$CK" 2>/dev/null || true
  {
    printf '# latest (rolling, refreshed every turn) — %s (%s)\n\n## PROGRESS.md (tail 40)\n' "$(now)" "$PHASE"
    tail -40 "$ROOT/PROGRESS.md" 2>/dev/null
    printf '\n## git\n'; (cd "$ROOT" && git status --short 2>/dev/null; echo "HEAD $(git rev-parse HEAD 2>/dev/null)")
    printf '\n## declared next_action\n'; grep -E '^- \*\*Next action:' "$ROOT/PROGRESS.md" 2>/dev/null | tail -1
  } > "$CK/latest.md" 2>/dev/null || true
} 2>/dev/null

# One consumption per flag, no loops: remove it BEFORE emitting the block.
if [ -f "$ST/compact-pending" ]; then
  rm -f "$ST/compact-pending" 2>/dev/null || true
  printf '{"decision":"block","reason":"post-compaction: refresh the PROGRESS.md checkpoint and distill the delta into context/ before ending this turn (§15.3)"}'
  exit 0
fi
command -v wsl-notify-send.exe >/dev/null 2>&1 && wsl-notify-send.exe "psychic-crew" "turn complete" >/dev/null 2>&1 || true
exit 0
