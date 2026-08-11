#!/usr/bin/env bash
# PostToolUse[*] — SOC2-style evidence trail. MUST never fail the pipeline: always exit 0.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  T=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
  G=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.command // ""' 2>/dev/null || true)
  jq -cn --arg ts "$(now)" --arg t "$T" --arg g "$(printf '%s' "$G" | cut -c1-200)" --arg p "$PHASE" \
     '{ts:$ts,event:"PostToolUse",tool:$t,target:$g,phase:$p}' >> "$ROOT/logs/tooluse-audit.jsonl"
} 2>/dev/null
exit 0
