# CORPUS-AGENTFW, explained plainly

## What changed

Dive 7 compared Microsoft Agent Framework's planner/executor contract and human-gate placement
with ours. Their planner literally keeps ledgers (task + progress, typed), counts stalls, and
answers a stall by clearing context and re-planning autonomously. Their human gate is declared
per tool, by the tool's author. Ours differs on both axes that matter: custody (our ledgers
are operator-witnessed law, not model working-state) and authority (the operator's layer
declares what needs a human — a capability that can mark itself exempt can unmark itself).

## Why the one rejection matters

Stall-then-autonomous-replan is the third stall mechanism this arc has met, and the first
with a response semantic. Under gate law the correct response is escalation to the operator,
never a silent context reset — so the rejection is recorded as a decision with its reason,
and the detection half still strengthens the queued hook gate's case.

## Verify it yourself

```
grep -A8 'The answer' docs/research/CORPUS-AGENTFW.md
./scripts/check-decision-matrices.sh | grep 'QUEUED row'    # 1 == 1 (babysitter remains)
```

## What could break, and what catches it

The CORPUS-0 bindings verify the flip. One QUEUED row remains — the babysitter split closes
the ladder next, in two gates.
