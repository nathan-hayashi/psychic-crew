# CORPUS-0, explained plainly

## What changed

Arc 2 opened with its accounting before its reading. The corpus census went four-value —
`BARRED` retired because it blurred "no question named yet" (now QUEUED) with the absolute
prohibition (now PROHIBITED, a row whose ABSENCE from disk is the assertion). A coverage table
now maps all 18 rows to a discharging gate or the one exemption, suite-bound both directions, so
the arc cannot quietly close at 13 of 17. The eight dive questions are NAMED here, before any
corpus is opened — reading follows questions, never the reverse. And the three dives that lived
only as ledger prose (gastown, ruflo, oh-my-claudecode) are promoted to standing documents,
quoted verbatim from the dated entries.

## Why

M4's own law: a dive without a named question is general reading, and general reading of this
corpus was measured to underperform targeted questions every time it was tried. The prohibition
row exists so the one absolute bar is machine-visible instead of living only in memory files.

## Verify it yourself

```
./scripts/check-decision-matrices.sh | tail -1     # 23/0; C2 = the coverage bindings
grep -A10 'CORPUS-QUESTIONS v1' docs/research/CORPUS-0-coverage.md
ls docs/research/S6-*.md
```

## What could break, and what catches it

A new corpus drop → unclassified-by-name FAIL. A census/coverage drift → set-inequality names
it. A QUEUED row without a question (or a question without a row) → the both-directions arm. The
prohibited directory ever appearing on disk → a named FAIL the same run.
