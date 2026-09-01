# BASE-2, explained plainly

## What changed

The comparison matrix landed under the contract BASE-1 pre-bound: exactly four rows by the
five frozen axes, the four-value vocabulary, and a roll-up the suite now checks against the
cells. Sixteen of twenty cells read NOT-COMPARABLE-DOCUMENTED-ONLY — and that distribution IS
the finding: documentation settles setup stories (THEIRS, all four, same class as CrewAI's
decisive row) and almost nothing else. No verdict was invented to make the table look done.

## Why an honest mostly-empty matrix beats a full fake one

The STRESS-1 comparison earned its 4–1 because the baseline was dived and the run was
measured. These four rows have neither; a matrix that pretended otherwise would be fitting
the ruler to the wish. The open cells are priced: an operator snapshot, a named question, a
dive gate — per row.

## Verify it yourself

```
./scripts/check-decision-matrices.sh | grep -A5 'C5'    # shape, vocabulary, roll-up bound
grep -c 'NOT-COMPARABLE-DOCUMENTED-ONLY' docs/research/BASE-2-comparison.md
```

## What could break, and what catches it

A fifth row, a sixth column, an off-vocabulary cell, or a roll-up that disagrees with the
cells — each is a named FAIL in the matrices suite from this gate on.
