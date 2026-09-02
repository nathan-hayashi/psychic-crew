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
  # HOOK-1 seen-cursor (the CORPUS-LANGGRAPH versions_seen adoption): record what ledger state
  # this grounding SAW, and say what changed since the last one. Content hashes, not just line
  # counts — the change that matters most (an in-place awaiting->APPROVED stamp flip) moves ZERO
  # lines. Silent no-op wherever the pieces are missing (bare clones, archive extracts).
  {
    cpl=$(wc -l < "$ROOT/Plan.md" 2>/dev/null | tr -d ' '); case "$cpl" in ''|*[!0-9]*) cpl=0 ;; esac
    cgl=$(wc -l < "$ROOT/GATES.md" 2>/dev/null | tr -d ' '); case "$cgl" in ''|*[!0-9]*) cgl=0 ;; esac
    crl=$(wc -l < "$ROOT/PROGRESS.md" 2>/dev/null | tr -d ' '); case "$crl" in ''|*[!0-9]*) crl=0 ;; esac
    cps=$([ -f "$ROOT/Plan.md" ] && _sha256 "$ROOT/Plan.md" 2>/dev/null || true)
    cgs=$([ -f "$ROOT/GATES.md" ] && _sha256 "$ROOT/GATES.md" 2>/dev/null || true)
    crs=$([ -f "$ROOT/PROGRESS.md" ] && _sha256 "$ROOT/PROGRESS.md" 2>/dev/null || true)
    chd=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || true)
    prev=$(tail -1 "$ROOT/logs/grounding-cursor.jsonl" 2>/dev/null || true)
    if [ -n "$prev" ]; then
      ppl=$(printf '%s' "$prev" | jq -r '.plan_lines // 0' 2>/dev/null); case "$ppl" in ''|*[!0-9]*) ppl=0 ;; esac
      pgl=$(printf '%s' "$prev" | jq -r '.gates_lines // 0' 2>/dev/null); case "$pgl" in ''|*[!0-9]*) pgl=0 ;; esac
      prl=$(printf '%s' "$prev" | jq -r '.progress_lines // 0' 2>/dev/null); case "$prl" in ''|*[!0-9]*) prl=0 ;; esac
      pgs=$(printf '%s' "$prev" | jq -r '.gates_sha // ""' 2>/dev/null || true)
      gch="unchanged"; [ -n "$pgs" ] && [ "$pgs" != "${cgs:-}" ] && gch="CHANGED"
      printf 'Since last grounding: Plan %+d lines, GATES %+d lines (%s), PROGRESS %+d lines.\n' \
        "$((cpl-ppl))" "$((cgl-pgl))" "$gch" "$((crl-prl))"
    else
      printf 'No previous grounding cursor — first recorded grounding.\n'
    fi
    mkdir -p "$ROOT/logs"
    jq -cn --arg ts "$(now)" --argjson pl "$cpl" --argjson gl "$cgl" --argjson rl "$crl" \
           --arg ps "${cps:-}" --arg gs "${cgs:-}" --arg rs "${crs:-}" --arg h "${chd:-}" \
       '{ts:$ts,plan_lines:$pl,gates_lines:$gl,progress_lines:$rl,plan_sha:$ps,gates_sha:$gs,progress_sha:$rs,head_sha:$h}' \
       >> "$ROOT/logs/grounding-cursor.jsonl" 2>/dev/null
  } 2>/dev/null
} 2>/dev/null )
jq -cn --arg c "$CTX" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
exit 0
