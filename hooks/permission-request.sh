#!/usr/bin/env bash
# PermissionRequest — the ask-side of the denial trail (CORPUS-SDKPY candidate #3): the blocker
# logs denials, this logs ASKS, agent-attributed. OBSERVATION ONLY: always exit 0 and never
# emit a decision object — answering asks is a behavior change no observation gate may smuggle.
# The asked-for target is the worst case for credentials, so it passes through scrub().
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)
  AID=$(printf '%s' "$INPUT" | jq -r '.agent_id // ""' 2>/dev/null || true)
  ATY=$(printf '%s' "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null || true)
  TNM=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
  TGT=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.command // ""' 2>/dev/null || true)
  jq -cn --arg ts "$(now)" --arg s "$SID" --arg a "$AID" --arg t "$ATY" \
         --arg n "$TNM" --arg g "$(scrub "$TGT")" --arg p "$PHASE" \
     '{ts:$ts,session_id:$s,agent_id:$a,agent_type:$t,tool_name:$n,target:$g,phase:$p}' \
     >> "$ROOT/logs/permission-requests.jsonl"
} 2>/dev/null
exit 0
