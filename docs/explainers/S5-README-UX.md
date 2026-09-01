# S5-README-UX, explained plainly

## What changed

Arc 1's finale, across all six repos: every sibling README got a count badge whose number rides
the SAME suite binding as the prose (extractors read badge URLs now), first-occurrence count
bindings became every-occurrence with planted-conflict controls BEFORE any badge landed,
quickstarts lost their machine-local assumptions, honesty sections state what each suite does
NOT assert, repurpose's requires-graph is rendered and derived-checked, lite drew its topology,
and sidekick got a hand-authored SVG screenshot. After all six pushes verified, the GitHub
metadata landed: descriptions for the four siblings, topics and homepages estate-wide.

## Why

READMEs are the estate's front doors, and the one thing this program refuses is a front door
that decorates instead of binds. Every number a visitor sees is asserted; every gap is stated;
every diagram is derived from the artifact it depicts or bound against it.

## Verify it yourself

```
for r in templates sidekick repurpose plugins; do (cd ../psychic-$r && ./scripts/validate-*.sh | tail -1); done
gh repo view nathan-hayashi/psychic-templates --json description,homepageUrl
```

## What could break, and what catches it

A badge edited without its prose (or vice versa) → that repo's every-occurrence arm names both
values. A redrawn repurpose graph → C4 set-inequality. The parent and lite carry NO badges —
declined with reasons in their rows, because an unbound badge is the exact hole this gate
existed to close.
