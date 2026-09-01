# ARC4-RECAL, explained plainly

## What changed

The audit bands were recalibrated from the birth baseline to the post-program plateau — the
program's growth landed (every repo grew, none shrank), so the floors now guard TODAY's
reality: parent 183 tracked / 254 assertions, lite 62/67, templates 21/44, sidekick 22/64,
repurpose 28/78, plugins 18/36, ceilings at 3x. The birth values stay durable in the ledger;
the rubric's history says exactly when and why the bands moved; the next recalibration is on
the operator's word.

## Why this was the program's last named gate

Bands set before growth would strangle it; bands set during growth would chase it. The plan
named the recalibration from birth so the bands could be provisional without being forgotten
— and the ratification evidence is a live audit run against the NEW bands reading clean.

## Verify it yourself

```
grep -A8 'ARC4-BANDS v1' docs/AUDIT-RUBRIC.md
./scripts/self-audit.sh --measure-only && tail -1 logs/audit/runs.jsonl | jq .
```

## What could break, and what catches it

Any repo shrinking below its plateau floor → a high-severity finding on the next audit run.
The bands block still parses to exactly six numeric rows or the suite fails.
