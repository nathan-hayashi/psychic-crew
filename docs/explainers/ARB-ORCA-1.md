# ARB-ORCA-1, explained plainly

## What changed

The arbiter's rulebook absorbed four proven ideas from the orca study, as one coherent
amendment. Verdicts now carry an observability field — live, unverifiable, or exited — with
the collapse forbidden in words: unverifiable may never be recorded as live. The DISPATCH
example gained three authoring rules placed BESIDE it (exactly one completion declaration per
packet; rules beside examples; over-budget sections omitted, never softened) and a
failure_budget whose exhaustion escalates to the operator — never a silent replan. Releases
now require three independent ownership proofs (the task exists in the dispatch trail, the
DISPATCH named this agent type, the sender's id matches a start row). And the lifecycle
vocabulary gained its honest third outcome: dispatched-unobserved.

## Why the snapshot matters

Docs-as-data arms are only as good as their anchor. The DISPATCH example fence is now a TESTED
artifact — byte-compared against a golden every run, with a mutated-copy control — and the
formatter exemption landed BEFORE the golden was captured, because Prettier rewrites json
fences and a pin on formatter output pins the wrong author.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A11 'ARB-ORCA-1'
grep -A2 'Verdict observability' .claude/rules/arbiter-protocol.md
```

## What could break, and what catches it

Any byte of the example fence → the snapshot arm. The trio, the collapse sentence, the
three checks, the third outcome, the ordering sentence — each has a named arm. The authoring
rules drifting away from the fence they annotate → the adjacency arm. Zero-dispatch default:
untouched, and the amendment says so.
