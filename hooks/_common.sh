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
  # A denial is the single event a SOC2 reader most wants to see, and PostToolUse never fires for
  # a tool that was blocked — so the guard must write its own record or the block leaves no trace.
  # G-F2's stress requires six denials AND six audit entries; without this it yielded six and zero.
  # Must not touch stdout: the deny JSON below is the only thing the dispatcher may read.
  { mkdir -p "$ROOT/logs"
    dt=$(printf '%s' "${INPUT:-}" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
    dg=$(printf '%s' "${INPUT:-}" | jq -r '.tool_input.file_path // .tool_input.command // ""' 2>/dev/null || true)
    jq -cn --arg ts "$(now)" --arg t "$dt" --arg g "$(printf '%s' "$dg" | cut -c1-200)" \
           --arg r "$1" --arg p "$PHASE" \
       '{ts:$ts,event:"PreToolUse.deny",tool:$t,target:$g,reason:$r,phase:$p}' \
       >> "$ROOT/logs/tooluse-audit.jsonl"
  } >/dev/null 2>&1
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
  exit 2
}
