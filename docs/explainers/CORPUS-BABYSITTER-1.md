# CORPUS-BABYSITTER-1, explained plainly

## What changed

The ladder's declared two-gate finale opened. Part 1 answered the detection half: babysitter
watches every step boundary with a MANDATORY stop, detects by running deterministic process
code over an immutable event-sourced journal, measures quality as numbers against declared
targets, and treats human breakpoints as enforced gates. Almost all of it is this estate in
different clothing — except one structural line: their per-step check is mechanical, ours is
disciplined. That is exactly C-05 (hook-enforced bypass detection), already named in ROADMAP
as the largest available upgrade — so the finding was filed with its existing owner instead
of a new queue.

## Why the census did not flip

The coverage table binds the babysitter row to BOTH split gates; the row and its question
discharge at part 2. Stated here so nobody reads the unchanged census as an oversight.

## Verify it yourself

```
grep -A6 'The answer' docs/research/CORPUS-BABYSITTER-1.md
grep -n 'C-05' ROADMAP.md
./scripts/check-decision-matrices.sh | grep 'QUEUED row'   # still 1 == 1, by design
```

## What could break, and what catches it

Nothing mechanical moved; the CORPUS-0 bindings hold unchanged. Part 2 owes the intervention
half and the census flip — the coverage table will not let the arc close without it.
