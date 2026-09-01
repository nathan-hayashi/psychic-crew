# CORPUS-SDKPY, explained plainly

## What changed

Dive 4 diffed the SDK's ten-event hook vocabulary against the eight this repo wires and found
three events our layer never sees: the turn's entry point (UserPromptSubmit), the subagent's
death (SubagentStop — we log births only), and the permission-ask moment (PermissionRequest).
Each is priced as the assertion it would enable; SubagentStop is flagged strongest because it
would close a standing SKIP (identity coverage sees starts, never stops).

## Why nothing was wired

Wiring a hook edits `.claude/settings.json` — HIGH class in this repo's own intake classifier.
A research gate that quietly widens the permission surface would be the exact defect this
estate exists to prevent. The three candidates are recorded, named, and wait for an operator-
declared gate.

## Verify it yourself

```
jq -r '.hooks | keys[]' .claude/settings.json          # the eight
grep -A6 'The answer' docs/research/CORPUS-SDKPY.md    # the three, priced
```

## What could break, and what catches it

Nothing changed mechanically beyond the census flip — the CORPUS-0 bindings verify it (4==4).
The record itself is the deliverable: a future hook gate can be held to these three names.
