#!/usr/bin/env bash
# PreCompact[auto|manual] — §15.3 emergency checkpoint + arm flag, and §15.9(a) numbered snapshot.
# Fires mid-flight. MUST never block or fail compaction: always exit 0, <=10s, no prompts.
# ccs-01 requires exit 0 even when PROGRESS.md is unwritable.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  TS=$(now)
  # Filesystem-safe stamp: the §15.9(a) name is <UTCISO>, but colons are hostile in filenames.
  STAMP=$(date -u +%Y%m%dT%H%M%SZ)
  ST="$ROOT/.claude/state"; CK="$ST/checkpoints"
  mkdir -p "$CK" 2>/dev/null || true

  # 15.3 — emergency checkpoint appended to PROGRESS.md (best effort; never fatal)
  {
    printf '\n## [%s|%s] EMERGENCY CHECKPOINT (PreCompact)\n' "$PHASE" "$TS"
    printf -- '- **In-flight:** %s file(s) uncommitted\n' "$(cd "$ROOT" && git status --porcelain 2>/dev/null | wc -l)"
    printf -- '- **HEAD:** %s\n' "$(cd "$ROOT" && git rev-parse --short HEAD 2>/dev/null || echo none)"
    printf -- '- **Next action:** see the tail of Plan.md and the newest snapshot in .claude/state/checkpoints/\n'
  } >> "$ROOT/PROGRESS.md" 2>/dev/null || true

  # 15.3 — arm the flag for the next Stop to consume exactly once
  : > "$ST/compact-pending" 2>/dev/null || true

  # 15.9(a) — numbered snapshot, all five fields
  SNAP="$CK/ckpt-$STAMP-${PHASE}.md"
  {
    printf '# checkpoint %s (%s)\n\n## PROGRESS.md (tail 40)\n' "$STAMP" "$PHASE"
    tail -40 "$ROOT/PROGRESS.md" 2>/dev/null
    printf '\n## GATES.md (tail)\n'; tail -8 "$ROOT/GATES.md" 2>/dev/null
    printf '\n## Plan.md open items\n'; grep -E '^- \*\*OQ-' "$ROOT/Plan.md" 2>/dev/null | tail -12
    printf '\n## git\n'; (cd "$ROOT" && git status --short 2>/dev/null; echo "HEAD $(git rev-parse HEAD 2>/dev/null)")
    printf '\n## declared next_action\n'; grep -E '^- \*\*Next action:' "$ROOT/PROGRESS.md" 2>/dev/null | tail -1
  } > "$SNAP" 2>/dev/null || true

  # 15.9(c) — retention: keep the newest 10
  ls -1t "$CK"/ckpt-*.md 2>/dev/null | tail -n +11 | while read -r old; do rm -f "$old" 2>/dev/null || true; done
} 2>/dev/null
exit 0
