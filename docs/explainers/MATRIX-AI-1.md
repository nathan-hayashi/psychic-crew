# MATRIX-AI-1, explained plainly

## What changed

Your 51-item "Build your own X" checklist now has a verdict for every single item, in one tracked
table the test suite checks — so the answer to "what can this platform actually do, at the highest
honest fidelity?" is written down, not vibes.

## Why

You asked to double-check the projected final state of psychic-crew against the whole AI-engineering
landscape. The honest way to do that is item by item, with the reason attached, and with the
constitution applied consistently: this project never installs anything, never uses GPUs or
training compute, and only ever talks to Claude — so some items are barred by LAW (changeable by
you), a different thing from being too hard.

## The pieces

- One table, 51 rows, five verdicts: **7 you already have** (the agent loop, the eval harness, the
  guardrails, the router, the reasoner, synthetic data, adversarial probing — these are the build's
  own core); **10 that extend something real** (retrieval, graphs, SQL checking, caching
  verification…); **9 buildable from scratch here** (tokenizer, autograd, vector index, dedup —
  the classics, honestly at teaching scale); **22 blocked by your own rules** (GPU kernels, model
  training, weight access — each one ruling away from reconsideration); **3 that don't fit the
  mission** (multi-vendor gateways contradict the Claude-only law; recommenders and feature stores
  serve products this isn't).
- Two automated checks: the table must hold exactly 51 legal rows, and the summary line must agree
  with the table (a summary that disagrees with its own rows is how numbers rot).

## Verify it yourself

````
cd ~/projects/psychic-crew
grep -c '^> Build your own' docs/research/ADDITIONS-2026-08-31-kickoff.md   # 51 — your original list
awk '/^# MATRIX-AI v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/research/MATRIX-AI-1.md | wc -l   # 51 — the verdicts
./scripts/run-crew-tests.sh 2>&1 | grep 'MATRIX-AI'                          # both checks: PASS
````

## What could break, and what catches it

Edit the table to 50 rows or a made-up verdict, and the suite fails naming the count. Change the
table without the summary (or vice versa) and the agreement check fails. Nothing here builds any of
the 51 — each build would be its own gated decision, and the matrix is the standing answer sheet.
