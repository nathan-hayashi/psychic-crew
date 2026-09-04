# CALIB-1, explained plainly

## What changed

The estate's predictions now have a home where they meet their outcomes. The standing
ledger seeds with the wave's six graded calls (recomputed mechanically against the source
map every run — nothing recalled), declares its intake lanes (research-yield predictions;
FALLBACK confidences with their task-resolution oracle; any gate's pre-declared
expectation), and states the point plainly: the 0.6 threshold every agent carries has zero
graded entries yet, and from today that absence is measurable instead of invisible. The
last of the vector program's three motivating holes closes whole.

## Verify it yourself

```
./scripts/run-crew-tests.sh all | grep -A7 'CALIB-1'
awk '/^# CALIBRATION v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/CALIBRATION.md
```

## What could break, and what catches it

A seed row drifting from its source, a wrong band verdict, a malformed or off-vocabulary
row — the recompute arm and its planted-wrong-verdict probe, every run. An abandoned task
never grading — visible as a '-' outcome, never silent.
