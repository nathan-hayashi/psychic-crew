# CORPUS-LANGGRAPH, explained plainly

## What changed

Dive 6 compared checkpointing philosophies. Langgraph checkpoints typed, versioned state with
lineage and a replayable crash window, and its resume is pure computation — `versions_seen`
mechanically decides what runs next. Our HC-8 checkpoints narrative and resumes by judgment.
Most differences dissolve into "held by other means" (git SHAs are our monotonic ids; commit
parentage is our lineage; writing every decision immediately is our crash-window closure). One
primitive has no equivalent: a seen-cursor recording which ledger state a session has already
consumed. It joins the queued hook gate as candidate four.

## Why nothing was wired

Same classifier law as the SDK dive: grounding machinery lives in hooks/, HIGH class, and a
research token must not smuggle a permission-surface change. The candidate is recorded where a
future gate can be held to it.

## Verify it yourself

```
grep -A6 'The answer' docs/research/CORPUS-LANGGRAPH.md
./scripts/check-decision-matrices.sh | grep 'QUEUED row'    # 2 == 2
```

## What could break, and what catches it

The CORPUS-0 bindings verify the flip mechanically. The hook-gate queue now carries four named
candidates — a single future gate can discharge all four or explain each refusal.
