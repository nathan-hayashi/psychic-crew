# ATTEST-HISTORY — dated proof-of-run (2026-09-04T04:58:53Z seed)

**Purpose.** The answer to two questions no suite total can answer: *when did a control last
prove itself, and on what platform/userland* (orca's evidence-run lesson), and *when did a
section stop holding* (ruflo's temporal-history lesson) — one tracked, append-only record,
platform-keyed because hashes and userlands legitimately differ (the BSD story).

**The H2a lesson, honored:** rows are appended ONLY by the deliberate act
`scripts/attest.sh run` — never as a suite side-effect. The suites verify; the operator (or
a gated close) attests. Refusal on any red is mechanical, read-back-confirmed.

**Semantics (orca's split):** counts GROWING between rows is drift — gates legitimately add
arms; a count DROPPING or a section VANISHING is the regression alarm
(`attest.sh regressions` names the bisect window). `timeline --section` exposes flapping —
a flapping count is a brittle needle telling on itself. Bisect granularity equals attest
cadence, stated plainly: this file resolves to the acts performed, not to every commit.

**BSD certification consumes this record:** the first row appended from a Mac (platform
Darwin, userland BSD) IS the certification artifact the portability story has always named.

## The history

```text
# ATTEST-HISTORY v1
```

## Weakest claims, flagged

`[E-limits]` Empty at birth by design — the gate's own close performs the first attest (the
enablement-at-the-token shape); an empty fence is legal exactly until then, and the suite
announces which state it sees. `[I]` Section identity rides the crew suite's own `== X ==`
headers (the registry's extraction); a renamed section reads as vanish+birth — the
regressions query will say so, and the rename's gate owns the explanation.
