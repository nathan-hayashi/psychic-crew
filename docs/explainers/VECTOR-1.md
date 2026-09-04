# VECTOR-1, explained plainly

## What changed

The register got its router. A small deterministic engine — ten typed rules, first match wins,
no AI anywhere in the loop — reads every OPEN row of the gap register and assigns it a vector:
dive into research, verify on the web, ask the operator, build a fix, wait for a named wake, or
accept forever. Anything no rule covers escalates to the operator twice over (the compiled
catch-all, and the engine's own default beneath it). The output is a committed, readable queue
ordered by priority — and the suite re-derives it from scratch every run and byte-compares:
a hand-edited queue, a register change that skipped re-routing, or an ungated rules tweak all
go red the same run. The queue is a pure function; it cannot rot into a lying cache.

## Why the queue is tracked at all

Because it is the program's product — the operator reads their vectors from it, and the
successor program consumes it by commit reference. The derived-artifact tension is resolved by
the derivation arm, not by untracking.

## Verify it yourself

```
./scripts/check-decision-matrices.sh | grep -A10 'H. VECTOR'
bash scripts/route-vector.sh --all | cmp - docs/research/VECTOR-QUEUE.md && echo pure
printf 'GR-900\tparked-wake\ts\te:1\tOPEN\tno\tunread-source\tCENSUS\tX' | bash scripts/route-vector.sh
```

## What could break, and what catches it

A rules edit without a gate — the byte-pin. A queue drift — the derivation diff. A routing
change of meaning — six fixture routings plus the first-match and engine-default controls, all
firing every run. A mislabeled register row routing confidently to the wrong process — stated
weakest claim; the calibration roll-up at SYNTH-1 is where that class surfaces.
