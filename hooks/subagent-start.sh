#!/usr/bin/env bash
# SubagentStart[*] — record every subagent creation with the identity the platform supplies.
# MUST never interfere: always exit 0, never write a decision object to stdout.
#
# CR-025 / C-25. The platform supplies agent_id and agent_type directly [V], so caller attribution
# stops being inferred from a prompt body and becomes a fact the runtime handed us.
#
# What this closes, and it is NOT what the repository claimed for two years of documentation:
# SubagentStart CANNOT block subagent creation, so prevention-at-the-call is not on offer here and
# is not claimed. What IS on offer is coverage of dispatches that FAILED. C-12 observed live that
# two failed Agent calls produced zero PostToolUse records — the hook cannot fire for a tool that
# never executed — so the coverage denominator silently shrank and a true-positive FAIL flipped to
# PASS with nothing remediated. This event fires at creation, independently of whether the call
# then succeeds, so the attempt stays visible to the auditor.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  AID=$(printf '%s' "$INPUT" | jq -r '.agent_id // ""' 2>/dev/null || true)
  ATY=$(printf '%s' "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null || true)
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)
  # phase is carried beyond the four fields CR-025 names, for parity with the other two trails and
  # because a record nobody can place in the build's timeline is hard to act on later.
  jq -cn --arg ts "$(now)" --arg a "$AID" --arg t "$ATY" --arg s "$SID" --arg p "$PHASE" \
     '{ts:$ts,agent_id:$a,agent_type:$t,session_id:$s,phase:$p}' >> "$ROOT/logs/subagent-starts.jsonl"
} 2>/dev/null
exit 0
