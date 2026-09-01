# RPG-2, explained plainly

## What changed

This repo (and its Lite twin, under the same token) became consumers of the repurpose blueprint
gallery. The intake skill gained §6: a vendored PIN — the full 11-blueprint id list plus three
named trigger phrases — inside a fenced block, plus the rule that a matching request pulls the
blueprint BY PATH with its requires closure, never by pasting the body. The army-selector gained
one line pointing at that pin. Seven new suite assertions bind it; Lite gained its consumer doc,
a sync-map row, and an orchestrator law line.

## Why

RPG-1 built the graph and honestly declared two gaps: trigger matching is judgment, and nothing
proved path-not-body. This gate lands the one mechanical bound the protocol promised — §6 is
CAPPED at 40 lines and one fenced block, so a pasted blueprint body cannot fit — and vendors the
pin so the estate's bind runs UNCONDITIONALLY, sibling checkout or not (the vendored-vocabulary
blueprint applied to its own gallery).

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep RPG-2        # 7 arms; pin, cap, control, live diff
PSYCHIC_REPURPOSE_PATH=/nonexistent ./scripts/run-crew-tests.sh F7 | grep RPG-2   # the announced absent leg
grep -A6 'REPURPOSE-PIN v1' .claude/skills/intake/SKILL.md
```

## What could break, and what catches it

Sibling adds or renames a blueprint → the live-diff arm names the drifted id the next time a
checkout is present, and the pin update is a visible, reviewable edit. Someone pastes a
blueprint body into §6 → the length/fence cap fails. The comparator itself is proven able to
see a drifted pin by an in-memory mutation control (one id dropped, must read 10 != 11). What
is still unasserted: whether a live request matches a trigger — judgment, stated in the
gallery's protocol and again here.
