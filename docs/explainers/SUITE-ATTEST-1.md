# SUITE-ATTEST-1, explained plainly

## What changed

The estate can now answer two questions it never could: when did each control last prove
itself, and on what platform — and when did a section stop holding, to which window of
commits. One tracked, append-only record (docs/ATTEST-HISTORY.md) written ONLY by the
deliberate act `scripts/attest.sh run`, which executes all five suites and refuses on any
red. Queries ride the same script: list, summary, a per-section timeline that exposes
flapping needles, and a regressions view that names drops and vanishes with their bisect
windows. Growth is drift (gates add arms legitimately); shrink is the alarm — orca's split.
The twin got its half first: check-witness --timeline over the history it has carried since
birth. And the closure arm in section J evolved to check fulfilled predictions: a row the
synthesis said would be consumed by this gate must have been resolved BY this gate.

## Why appends are manual

Because the suite writing tracked state is the registered H2a defect class — verification
must not mutate what it measures. Attestation is an act, like save-context: the lite law
("re-verification is deliberate") applied estate-wide.

## Verify it yourself

```
./scripts/attest.sh list
./scripts/attest.sh regressions
./scripts/run-crew-tests.sh all | grep -A12 'SUITE-ATTEST-1'
```

## What could break, and what catches it

A red battery attempting to attest — refused with teeth (proven every run in a scratch tree
with stubbed-red suites). A vanished or shrunken section — named with its window by the
regressions query, control-fired on fixtures each run. A hand-append out of order — the
monotone-timestamp arm. The empty fence before the first attest — announced as the declared
straddle, resolved at this gate's own close.
