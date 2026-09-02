#!/usr/bin/env bash
# PreToolUse[Agent] — HOOK-2: ORDERING AND ATTRIBUTION for specialist dispatch, scoped to EX-05.
#
# What this enforces: a dispatch of one of the FIVE specialist types must be PRECEDED by an
# arbiter-written arm marker naming the same (task_id, agent_type). What this does NOT enforce,
# stated as the gate-guard states its own limit: a session determined to bypass could write the
# marker itself — this defeats ORDERING MISTAKES and forgetting, never deliberate forgery, and
# the C-25/C-05 detection correlations remain the net underneath.
#
# Marker: .claude/state/armed/<task_id>.<agent_type> — one file per pair (parallel multi-
# specialist rounds are the norm; a global slot would race), written by the ARBITER as its
# brokering act, consumed (rm) here on the allow leg. A failed dispatch's retry needs a re-arm.
# TTL 600s. FAIL CLOSED: an unreadable or unparseable marker denies.
#
# Non-specialist dispatches (Explore, Plan, general-purpose, claude, …) pass silently: planning
# and research workflows are not this hook's business.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
INPUT=$(cat 2>/dev/null || true)
STY=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null || true)
case "$STY" in
  security-reviewer|quality-reviewer|fixer|test-runner|integration-runner) : ;;
  *) exit 0 ;;
esac
PRM=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null || true)
# Unconditional task_id extraction (reference-cap's regex SHAPE, but always-on — its own run is
# conditional and there is deliberately no shared code path). Accepted shape is PINNED: the
# literal inline JSON form "task_id": "<value>". A DISPATCH carried by path without the inline
# form is DENIED — §14.3 mechanized as a stated decision, not a surprise.
TID=$(printf '%s' "$PRM" | grep -oE '"task_id"[[:space:]]*:[[:space:]]*"[A-Za-z0-9._-]+"' | head -1 \
      | sed 's/.*"\([A-Za-z0-9._-]*\)"$/\1/' || true)
[ -n "${TID:-}" ] || deny "HOOK-2: specialist dispatch ($STY) carries no inline \"task_id\" — the arbiter's DISPATCH block must be in the prompt (path-carried contracts are refused by design)"
MARK="$ROOT/.claude/state/armed/$TID.$STY"
[ -f "$MARK" ] || deny "HOOK-2: specialist dispatch ($STY, task $TID) has NO arbiter arm marker — order is arbiter-brokers-then-orchestrator-dispatches (EX-05)"
MTS=$(jq -r '.ts // ""' "$MARK" 2>/dev/null || true)
MTY=$(jq -r '.agent_type // ""' "$MARK" 2>/dev/null || true)
{ [ -n "$MTS" ] && [ -n "$MTY" ]; } || deny "HOOK-2: arm marker unreadable or unparseable — failing CLOSED (task $TID, $STY)"
[ "$MTY" = "$STY" ] || deny "HOOK-2: arm marker names agent_type '$MTY' but the dispatch is '$STY' — wrong-type arms do not transfer"
MEP=$(date -u -d "$MTS" +%s 2>/dev/null || date -u -j -f %Y-%m-%dT%H:%M:%SZ "$MTS" +%s 2>/dev/null || echo 0)
NOW=$(date -u +%s)
AGE=$((NOW - MEP))
{ [ "$MEP" -gt 0 ] && [ "$AGE" -ge 0 ] && [ "$AGE" -le 600 ]; } \
  || deny "HOOK-2: arm marker stale or clock-invalid (age ${AGE}s, TTL 600) — re-arm and retry"
rm -f "$MARK"
{ mkdir -p "$ROOT/logs"
  jq -cn --arg ts "$(now)" --arg t "$STY" --arg i "$TID" --arg p "$PHASE" \
     '{ts:$ts,event:"PreToolUse.arm-consumed",tool:"Agent",agent_type:$t,task_id:$i,phase:$p}' \
     >> "$ROOT/logs/tooluse-audit.jsonl"
} >/dev/null 2>&1
exit 0
