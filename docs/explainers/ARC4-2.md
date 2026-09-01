# ARC4-2, explained plainly

## What changed

The audit got its engine, fenced. `scripts/self-audit.sh` measures the estate against the
rubric's bands and writes ONLY under `logs/audit/` — and that claim is not a promise: every
suite run copies the tracked tree plus .git, verifies the copy is a real work tree, hashes
every file before and after a live audit run, and fails if anything outside `logs/audit/`
changed. Porcelain could never have seen that (the one directory the lane may write is
ignored), which is why the control is a tree-hash diff — and a planted `logs/metrics/` write
is proven caught every run. The parent suite gained skip-guards on all seven
check-plan-corrections call sites (`PSYCHIC_SELF_AUDIT=1`), because that chain writes a
tracked metrics file and an audit that dirties its subject is the observer-fence defect — the
guard is proven firing by a nested run. Freshness: session-start prints the last audit
timestamp (silent in bare clones — exercised in the portability drill's clone leg), and the
stop toast carries staleness only when no gate is pending, proven from the hook's own bytes.

## Why invocation stays human

"Autonomous" was defined at ARC4-1 as unattended analysis, never unattended scheduling. The
runner runs when the operator or a session acting on the staleness line invokes it. Proposals
stay prose-only; drafting is a future gate.

## Verify it yourself

```
./scripts/self-audit.sh --measure-only     # writes only logs/audit/, says so, reads back
./scripts/run-crew-tests.sh F7 | grep -A9 'ARC4-2'
tail -1 logs/audit/runs.jsonl | jq .
```

## What could break, and what catches it

The lane writing anywhere else → the tree-hash arm names the path. The skip-guard rotting →
the nested live-fire arm. The toast outranking a gate → the byte-order arm. And this build's
own two catches are on the record: the rule-5 scanner caught the new arm's pipe-to-grep-q the
moment it existed, and the runner's first live run scanned six repos and found the estate
inside every band.
