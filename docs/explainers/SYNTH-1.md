# SYNTH-1, explained plainly

## What changed

The program's terminal synthesis: six successor gates with their exact tokens pre-declared
(SUITE-ATTEST-1 the headline — the convergent orca+ruflo record that answers when-did-a-
control-last-prove-itself and when-did-it-break in one platform-keyed artifact), and a
closure fence accounting EVERY open register row into exactly one of consumed / parked /
declined / accepted — 131 rows, suite-bound both ways against the live register, so
"nothing pulled out of a rabbit hole was dropped" is an arm, not a promise. The calibration
table ships 6-for-6 at the pre-locked bands, recomputed from the map by the suite, with its
honest caveat: coarse bands are calibration's floor, and the corpus-vs-web yield split is
the real learned prior.

## Verify it yourself

```
./scripts/check-decision-matrices.sh | grep -A14 'J. SYNTH'
awk '/^# SYNTH-CLOSURE v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/research/SYNTH-1-incorporation-program.md | wc -l
```

## What could break, and what catches it

A dropped open row (set-equality both ways), a phantom consuming gate, a token colliding
with the ledger, a calibration cell disagreeing with the map, an out-of-order program row —
each a named FAIL, with the phantom-gate control shown firing every run.
