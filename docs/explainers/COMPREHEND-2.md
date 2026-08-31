# COMPREHEND-2, explained plainly

## What changed

The repo gained this folder (`docs/explainers/`), an index declaring the rule, and two automated
checks that enforce it. From now on, every approved gate must ship a file like this one — a short,
plain-language explanation of what that gate did.

## Why

You said the hard part is reviewing what gets engineered: the build logs are complete but written
for an auditor, dense with internal codes. This layer is the same truth at reading altitude — and
its trust move is that every explainer ends with commands **you** run, so you never have to take
the summary on faith.

## The pieces

- `docs/explainers/INDEX.md` — the rule and the list. One line in it (`EXPLAINER-EPOCH:`) tells the
  checker where the rule starts applying, by gate name, so history before the rule is not
  retroactively judged.
- `docs/explainers/<GATE>.md` — one per gate after the epoch, this file being the first.
- Two checks inside the main test suite: one fails the build if any post-epoch gate lacks its
  explainer (and refuses to pass vacuously if it finds no gates at all); the other deliberately
  plants a fake gate row in a scratch copy and proves the first check would catch it — a check that
  has never been seen failing proves nothing.

## Verify it yourself

```
cd ~/projects/psychic-crew
./scripts/run-crew-tests.sh 2>&1 | grep -i explainer     # both explainer checks: PASS
grep 'EXPLAINER-EPOCH' docs/explainers/INDEX.md          # the epoch line the checker reads
ls docs/explainers/                                      # one file per post-epoch gate + INDEX
```

If you delete this file and re-run the first command, the suite goes red and names the missing
gate — that is the discipline enforcing itself.

## What could break, and what catches it

If a future gate closes without its explainer, the suite fails by gate name (the first check). If
someone edits the ledger's gate names, the same check fails because the filenames no longer match.
If the index's epoch line is deleted, the checker refuses to pass empty rather than passing silent
(the vacuity guard).
