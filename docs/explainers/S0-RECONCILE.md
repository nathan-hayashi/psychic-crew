# S0-RECONCILE, explained plainly

## What changed

Every repo in the estate now has a real LICENSE (MIT, copyright Nathan Lim) — five of them were
already public with no license at all, which legally meant nobody could reuse anything. Three
sibling repos' docs stopped claiming to be private (they'd been flipped public at some unrecorded
moment); instead of rewriting history, each got a dated ledger row saying exactly what happened
and when it was ratified. The explainer discipline you're reading now was also installed in all
four siblings, and the health-rubric baseline for the future self-audit lane was measured and
recorded before later gates could skew it.

## Why

A public repo with no license is "look but don't touch" — the opposite of a reference estate.
And docs that say "private" on a public repo are the kind of small falsehood that erodes trust in
everything else the docs say. The fix is honesty in both directions: license what's shared,
record what happened.

## Verify it yourself

```
head -3 LICENSE                                  # MIT / Copyright (c) 2026 Nathan Lim
for r in psychic-templates psychic-sidekick psychic-repurpose psychic-plugins; do
  head -3 ../$r/LICENSE; tail -2 ../$r/GATES.md; done
grep -rn 'PRIVATE at creation' ../psychic-sidekick/README.md   # gone — superseded honestly
```

## What could break, and what catches it

Each sibling's validator now fails if a future gate there ships without its explainer (and a
planted-row probe proves the check actually sees new ledger rows). The parent's own explainer
binding covers this gate the same way.
