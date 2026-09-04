# TM-FENCE-1, explained plainly

## What changed

The threat model — the one register that lived as prose alone — now carries a machine
mirror: its twelve residual rows as a dated fenced appendix, bound three ways every run
(prose table numbers == mirror fence == gap-register TM tags), without one word of the
canonical prose changing. And the three hallucination specimens logged at the register's
birth got their dated corrections, appends only: the envelope enum divergence is
ADJUDICATED intentional where the checker lives (V? is a prose staleness marker, never an
evidence class a claim may carry); the registry 44-to-48 ledger figure has its correction
line beside the append-only original ("the meter was right, the ledger lied"); and the two
research docs still reading awaiting-a-gate carry pointers to the gate that discharged them.

## Verify it yourself

```
./scripts/run-crew-tests.sh all | grep -A8 'TM-FENCE-1'
awk '/^# THREAT-RESIDUALS v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/security/threat-model.md
```

## What could break, and what catches it

A mirror row added or dropped — the three-way equality, phantom-probed every run. A
correction quietly deleted — needle arms on all four sites.
