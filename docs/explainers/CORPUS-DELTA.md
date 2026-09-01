# CORPUS-DELTA, explained plainly

## What changed

The last four coverage rows discharged in one gate, at their declared tier: refresh, not dive.
Each ETL-BUILD corpus (turbo, open-code-review, neatcontext-plugins, mermaid-hybrid-stack-
guide) got a section stating its identity, what the build consumed from it, and a delta
verdict — all four read NO ACTION, each with its reason (already mirrored, deliberately
declined, stricter here, or fully transformed at F6). Arc 2's coverage arithmetic now closes
18 of 18.

## Why the light touch is the honest touch

The tier was declared at CORPUS-0, before any reading: delta rows owe a refresh verdict, not a
question-driven dive. Under HC-5 nothing can be fetched anyway — the delta is snapshot-vs-
consumed. Depth by declaration beats depth by mood.

## Verify it yourself

```
grep -c 'NO ACTION' docs/research/CORPUS-DELTA.md      # 4
./scripts/check-decision-matrices.sh | tail -1          # the bindings that hold the 18
```

## What could break, and what catches it

A future corpus drop is caught unclassified-by-name; a census/coverage drift is caught by
set-inequality. The arc's remaining work is no longer coverage — BASE-1 opens arc 3.
