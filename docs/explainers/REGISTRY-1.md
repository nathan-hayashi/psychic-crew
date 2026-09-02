# REGISTRY-1, explained plainly

## What changed

The suites got a table of contents that cannot rot: `docs/RELIABILITY-REGISTRY.md` maps every
suite SECTION across the five parent scripts — 44 rows at birth — to what it protects
(invariant), how it's judged (oracle), where its proof lives (file + header needle), and how
mature it is. Maturity is MECHANICAL, never archaeology: a section whose span carries a
firing-control line is `proven` (14 at birth), everything else is `experimental` (30) — the
split is measured, not flattered. The suite binds the registry both directions: every row's
needle must grep in its file, and every live section must have a row — so a future gate that
adds a section without adding its row goes red the same run.

## Why

The orca study's largest TAKE: the missing layer between "we have suites" and "a claim is
provably covered." The reverse arm is also a standing tax, stated on purpose: gates 6–8 of
this program each add a section and will prove the maintenance discipline live.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A6 'REGISTRY-1'
awk '/# RELIABILITY-REGISTRY v1/{f=1} f' docs/RELIABILITY-REGISTRY.md | head -8
```

## What could break, and what catches it

A new section without a row → the reverse count. A row pointing at nothing → the forward
needle grep, proven able to fire by a phantom row whose needle deliberately targets a file
that cannot contain it (the first probe targeted the suite file itself, which had just
learned the needle's text — scanner-contains-prey inside a fire-probe, caught and retargeted).
A planted header in a script copy → the orphan control. Per-assertion granularity is v2, wake
named: a section implicated in a real defect splits at the fixing gate.
