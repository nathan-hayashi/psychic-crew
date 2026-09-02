# TICK-1, explained plainly

## What changed

Approval stamps can no longer quietly vanish, and awaiting gates are re-refused on every suite
run — not just once at their STOP. Three layers: (1) the live re-block derives every awaiting
token from the ledger and runs gate-guard against each, expecting refusal — honest about being
a straddle-time control (between gates the set is empty and says so), with an always-run
backstop that plants an awaiting row in a scratch root and proves the refusal machinery fires
regardless; (2) a tracked high-water floor: the APPROVED-row count must never read below
`.claude/gates-floor.txt`, which advances in close-record commits — a separate commit from the
stamp by existing ritual, so one revert cannot move both sides; (3) the working tree's
APPROVED count must be ≥ HEAD's (direction explicit — the straddle's tree=HEAD+1 is legal),
catching an uncommitted stamp deletion, announced-not-silent in archive extracts.

## Why

The motivating incident class is the rebase-dropped-APPROVED-row the push protocol names —
this makes the loss visible from inside the suite, not only at push time. And this gate paid
the registry tax live: its new section's row landed in the same gate, proving REGISTRY-1's
reverse arm does what it was built for.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A6 'TICK-1'
cat .claude/gates-floor.txt
```

## What could break, and what catches it

A committed stamp-drop → the floor. An uncommitted one → tree-vs-HEAD. The refusal machinery
itself rotting → the scratch backstop, every run. The deleted-stamp arithmetic is proven able
to fire by a scratch count minus one.
