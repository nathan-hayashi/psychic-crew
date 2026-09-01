# CORPUS-TAKT, explained plainly

## What changed

Dive 5 found that takt budgets a different quantity than we do: not how much a run spends, but
whether it is still ALIVE — inactivity deadlines that reset on every observable event,
cumulative time deliberately uncapped, and a typed PART_TIMEOUT when even the signal channel
stales. Our budget baseline measures spend only, so it gained a dated section saying exactly
that: a phase can be under budget and hung forever, the second axis is unowned here, and the
SubagentStop candidate from the previous dive is its future death-half. PART_TIMEOUT joined the
ARC4-1 termination-vocabulary earmark — that gate now owes three adopted shapes by name.

## Why

A baseline that states what it does NOT measure is the same honesty its unit section already
practices (context-total vs output). The two-axis lesson cost nothing to land and closes a
comprehension gap: nobody reading the baseline will again mistake under-budget for healthy.

## Verify it yourself

```
tail -15 context/budget-baseline.md
grep -A5 'The transfer' docs/research/CORPUS-TAKT.md
```

## What could break, and what catches it

The census/coverage/questions bindings verify the flip (3==3). The ARC4-1 obligations are now
three, each named in a dive record a reviewer can hold that gate to.
