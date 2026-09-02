#!/usr/bin/env bash
# route-tier.sh — TEI-1: the Escalation Router's deterministic core. A written policy
# (docs/POLICY-RULES.md) compiled to typed JSON rules (config/escalation-rules.json) is
# evaluated FIRST-MATCH-WINS by this engine, which NEVER calls a model. A model may pass a
# `recommendation` in the descriptor; it is copied into the verdict record BESIDE the
# deterministic result and never consulted — the suite proves that behaviorally.
#
# stdin : {"surface": "...", "action_class": "...", "recommendation": "..."?}
# stdout: {"ts","tier","rule_id","why_allowed","recommendation"}   (also appended to the trail)
# Unmatched requests fall to ENGINE-DEFAULT-DENY even if the compiled catch-all is deleted —
# two independent layers, both deny: a router with no policy fails CLOSED (§C row 4 semantics).
# Rule changes require a gate: the suite byte-pins the compiled file (hash + row count).
set -uo pipefail
cd "$(dirname "$0")/.."
RULES="config/escalation-rules.json"
IN=$(cat 2>/dev/null || true)
SUR=$(printf '%s' "$IN" | jq -r '.surface // ""' 2>/dev/null || true)
ACT=$(printf '%s' "$IN" | jq -r '.action_class // ""' 2>/dev/null || true)
REC=$(printf '%s' "$IN" | jq -r '.recommendation // ""' 2>/dev/null || true)
VER=$(jq -cn --arg sur "$SUR" --arg act "$ACT" --slurpfile r "$RULES" '
  [ $r[0][] | . as $rule
    | select(
        ((($rule.if.surface // null) == null) or ($sur | test($rule.if.surface)))
        and ((($rule.if.action_class // null) == null) or ($act | test($rule.if.action_class)))
      )
  ] | first // {"id":"ENGINE-DEFAULT-DENY","tier":"deny","why":"no rule covers this request class; policy must gain a row at a gate before it can be tiered"}
' 2>/dev/null)
[ -n "${VER:-}" ] || VER='{"id":"ENGINE-DEFAULT-DENY","tier":"deny","why":"rules unreadable — failing closed"}'
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT=$(printf '%s' "$VER" | jq -c --arg ts "$TS" --arg rec "$REC" \
  '{ts:$ts,tier:.tier,rule_id:.id,why_allowed:.why,recommendation:$rec}')
mkdir -p logs/audit
printf '%s\n' "$OUT" >> logs/audit/route-verdicts.jsonl
rb=$(tail -1 logs/audit/route-verdicts.jsonl 2>/dev/null)
[ "$rb" = "$OUT" ] || { echo "route-tier: verdict READ-BACK FAILED" >&2; exit 1; }
printf '%s\n' "$OUT"
