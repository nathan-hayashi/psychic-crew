# TEI-1, explained plainly

## What changed

The Assurance Layer got its risk-rating brain, and it is deliberately not an AI. A written
policy (the ratified five-tier table) is compiled into six typed rules; a small script reads a
request descriptor and answers "how risky is this" by first-match-wins over that file — no
model, no network, ever. A model may attach a recommendation; it is logged BESIDE the verdict
and never consulted, and the suite proves that behaviorally: a critical-surface request
carrying recommendation:"low" must still verdict crit. Unmatched requests deny twice over —
the compiled catch-all, and the engine's own default beneath it, so even a deleted catch-all
cannot fail open. Every verdict lands read-back-confirmed in an append-only trail with
who/what/why-allowed. Changing a rule requires a gate: the compiled file is byte-pinned.

## The bug the smoke caught before any arm existed

The first compilation ordered action rules before surface rules, so a reversible-looking
action on a FINANCE surface routed med — fail-open by ordering. The order IS the policy now:
most-restrictive first (deny, crit, high, med, low, catch-all), stated in the policy prose
with the incident named.

## Verify it yourself

```
printf '%s' '{"surface":"finance","action_class":"edit-internal","recommendation":"low"}' | ./scripts/route-tier.sh
./scripts/run-crew-tests.sh F7 | grep -A11 'TEI-1'
jq -r '.[].id' config/escalation-rules.json
```

## What could break, and what catches it

Any byte of the rules changing → the pin arm goes red until a gate updates it. The catch-all
vanishing → the two-layer control. The recommendation ever being consulted → the behavioral
control. Prose and compiled ids drifting → the both-ways id arm.
