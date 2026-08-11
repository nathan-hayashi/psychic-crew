#!/usr/bin/env bash
# PostToolUse[*] — SOC2-style evidence trail. MUST never fail the pipeline: always exit 0.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  T=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
  # C-12: record WHO was dispatched and under WHICH task_id. Coverage that compares counts is
  # satisfiable by the audited party writing lines; coverage that correlates identity is not.
  # subagent_type first, so an Agent call names its specialist rather than dumping the prompt.
  G=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // .tool_input.file_path // .tool_input.command // ""' 2>/dev/null || true)
  ID=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null \
       | grep -oE '"task_id"[[:space:]]*:[[:space:]]*"[A-Za-z0-9._-]+"' | head -1 \
       | sed 's/.*"\([A-Za-z0-9._-]*\)"$/\1/' || true)
  jq -cn --arg ts "$(now)" --arg t "$T" --arg g "$(printf '%s' "$G" | cut -c1-200)" \
         --arg i "${ID:-}" --arg p "$PHASE" \
     '{ts:$ts,event:"PostToolUse",tool:$t,target:$g,task_id:$i,phase:$p}' >> "$ROOT/logs/tooluse-audit.jsonl"
} 2>/dev/null
exit 0
