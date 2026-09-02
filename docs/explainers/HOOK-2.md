# HOOK-2, explained plainly

## What changed

Specialist dispatch got its ordering lock. A new PreToolUse guard on the Agent tool denies any
dispatch of the five specialist types unless a FRESH arbiter-written arm marker exists for the
same (task_id, agent_type) — one marker file per pair so parallel reviewer rounds never race,
consumed on use so a retry needs a deliberate re-arm, stale after ten minutes, failing CLOSED
on anything unreadable. Planning agents (Explore, Plan, general-purpose) pass untouched. The
arbiter's contract gained the one line licensing it to write the markers as its brokering act.

## The limit, on the label

This enforces ORDERING AND ATTRIBUTION — it defeats forgetting and out-of-order dispatch, not
deliberate forgery (a session bent on bypass could write its own marker; the hook header, the
gate row, and the ROADMAP supersession all say so, the same way gate-guard states its own
limit). The C-25/C-05 detection correlations remain the net underneath.

## The precondition, discharged with live evidence

A deny hook must not ship on unproven delivery. Before this guard landed, a real dispatch
produced the first live `PreToolUse.observed` row — and the same hour delivered live
SubagentStop rows and the estate's first machine-stamped token receipt (the operator's own
`APPROVE HOOK-1`, 14 chars, body never stored). Delivery is a recorded fact, not an assumption.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A13 'HOOK-2'
grep 'PreToolUse.observed' logs/tooluse-audit.jsonl | head -1
jq -r '.hooks.PreToolUse[].hooks[0].command' .claude/settings.json | tail -1
```

## What could break, and what catches it

Every refusal class is fire-probed every run: no-marker, stale-TTL, wrong-type, path-carried
prompt, unparseable marker — plus the allow leg's consumption and its audit record. A denial
leaves a trail row; so does an allow. The break-glass is named, not armed: if `.claude/state/`
is unwritable or jq is absent, recovery is an operator hand-edit of settings under the
operator's word.
