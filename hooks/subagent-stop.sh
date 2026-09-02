#!/usr/bin/env bash
# SubagentStop[*] — the death half of the lifecycle whose birth half subagent-start.sh records.
# MUST never interfere: always exit 0, never write a decision object to stdout.
#
# HOOK-1 (CORPUS-SDKPY candidate #1). Pairs on agent_id with logs/subagent-starts.jsonl so the
# paired-lifecycle arm can see orphans (a start with no stop = the hung-agent case the gastown
# watchdog chain exists for; the liveness axis budget-baseline.md names as unowned gets its
# death half here). agent_transcript_path is recorded because it is the only forensic handle a
# death leaves; any line quoted into a tracked doc must strip it (absolute-path law).
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  AID=$(printf '%s' "$INPUT" | jq -r '.agent_id // ""' 2>/dev/null || true)
  ATY=$(printf '%s' "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null || true)
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)
  ATP=$(printf '%s' "$INPUT" | jq -r '.agent_transcript_path // ""' 2>/dev/null || true)
  jq -cn --arg ts "$(now)" --arg a "$AID" --arg t "$ATY" --arg s "$SID" --arg p "$PHASE" --arg x "$ATP" \
     '{ts:$ts,agent_id:$a,agent_type:$t,session_id:$s,phase:$p,agent_transcript_path:$x}' \
     >> "$ROOT/logs/subagent-stops.jsonl"
} 2>/dev/null
exit 0
