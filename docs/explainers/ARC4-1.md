# ARC4-1, explained plainly

## What changed

The auto-audit got its constitution before its engine: a rubric document defining the three
axes (tracked-count bands per repo from the EARLY S0 baseline, doc-staleness as advisory-only
because the parent's old docs are frozen history, suite-total floors with the environment
caveat), a durable AUDIT-QUEUE whose empty state is legal but whose broken state fails, the
findings schemas that discharge all three dive-filed obligations by name (errors-empty-iff-
completed from zeroshot, is_explicit from conductor, part-timeout from takt), the
runtime→durable bridge (findings are machine-local; promotion is a human act under a token),
and the gated-fixes law (ACCEPTED/CLOSED requires a chronicled cr_id and a gated fix). Seven
suite arms bind it, including both fire-probes.

## Why nothing runs yet

"Autonomous" means unattended analysis, never unattended scheduling — and not even analysis
until ARC4-2 ships the runner with its tree-hash no-write control. Rubric first, engine
second, so the engine is born into law.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A9 'ARC4-1'
grep -A8 'The findings schemas' docs/AUDIT-RUBRIC.md
```

## What could break, and what catches it

A malformed band row, a corrupted queue header, or an ACCEPTED row whose cr_id is not in
Plan.md — each is a named FAIL; both controls are proven to fire on planted defects every run.
