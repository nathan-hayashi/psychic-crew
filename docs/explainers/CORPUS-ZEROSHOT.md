# CORPUS-ZEROSHOT, explained plainly

## What changed

The first dive of arc 2 ran against its pre-named question and produced three things: the dive
document (what zeroshot's executor–verifier harness asserts about completion that our gate
machine does not — typed schemas, errors-empty-iff-approved, computed consensus, structural
verifier separation), a census flip (zeroshot QUEUED → DIVED, its question discharged into the
dive doc, the questions arm now dynamic — one per remaining QUEUED row), and a TRANSFERRED
CHECK: four new suite arms holding our own arbiter trail to typed coherence — every row must
parse with its required keys, and no row may name its own sender in its recipient list.

## Why

The dive question asked "does any check transfer?" and the honest answer was to land it, not
name it. The self-dispatch arm is C-12 turned from procedure into a machine-checked property.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A6 ZEROSHOT     # the four arms + both firing controls
grep -A3 'The answer' docs/research/CORPUS-ZEROSHOT.md
```

## What could break, and what catches it

A malformed or key-missing trail row → the coherence arm names the count. A future dispatch that
lists its own sender → the self-dispatch arm. Both controls are UNCONDITIONAL (planted rows in a
scratch file) — and the self-dispatch control earned its keep on first fire: the arm's original
jq expression was scoped wrong and vacuous, the planted row exposed it before it ever shipped,
and the fix landed with the probe as witness.
