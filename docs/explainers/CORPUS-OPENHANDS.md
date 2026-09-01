# CORPUS-OPENHANDS, explained plainly

## What changed

Dive 2 answered its pre-named question and, unusually, landed NO new suite arm — and says so
loudly instead of quietly. The corpus (Agent Canvas, OpenHands' control plane) bounds agent
actions with one confirmation boolean, a fail-open OSS permission hook, a genuinely good
home-anchored path resolver, and per-session capability negotiation. The census row flipped and
the question moved into the dive document.

## Why no transfer

Three of the four bounds are already held here, or held more strongly (per-action-class hooks
beat a boolean; our layer never fail-opens; the only-sanctioned-resolver rule is our two-root
law, already asserted). The fourth — runtime capability negotiation — is rejected with reason:
a negotiable guard is a guard an agent can talk its way out of. A dive that finds nothing to
take must say "nothing transfers" on the record, or every no-arm dive after it becomes a
silent cap.

## Verify it yourself

```
grep -A4 'The transfer' docs/research/CORPUS-OPENHANDS.md
./scripts/check-decision-matrices.sh | grep 'QUEUED row'    # 6 == 6 now
```

## What could break, and what catches it

The census/coverage/questions bindings (CORPUS-0) verify the flip mechanically — a discharged
question that lingered, or a flipped row that didn't, is a named FAIL in the same run.
