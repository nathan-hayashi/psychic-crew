---
name: army-selector
description: Typed specialist-selection over the crew — classify the request type, look up primary/support/never-fit specialists from a machine-readable effectiveness table, and return advice that never bypasses the arbiter or the zero-dispatch default. Use when choosing which specialist fits a task, when the user asks who should do the work, or before proposing any dispatch.
---

The crew has eight specialists and a standing temptation: reach for whichever one is nearest.
This skill replaces that reflex with a table. A typing chart, honestly pokémon-shaped: which
specialist is super-effective against which request class, which pairing does no damage, and
which matchup is forbidden outright.

## 1. The table

Columns, tab-separated: request-type · primary · support · never · why. `none` means the slot is
deliberately empty; `all` in the never column means the row resolves to no specialist at all.
First matching row wins; a request matching nothing is `ambiguous` by definition.

```text
# ARMY-TABLE v1
plan	lead-planner	arbiter	lead-executor	multi-step design is plan-only; the executor never plans its own work
execute	lead-executor	arbiter	lead-planner	approved plans run step-numbered; the planner never edits
security-review	security-reviewer	arbiter	fixer	read-only lens; the fixer would pre-grade its own future work
quality-review	quality-reviewer	arbiter	fixer	read-only lens, same separation
test-run	test-runner	arbiter	none	raw PASS/FAIL only; interpretation belongs to the arbiter's release
integration-run	integration-runner	arbiter	none	scripted E2E exactly as written; deviation returns a FALLBACK
finding-adjudication	fixer	arbiter	security-reviewer	steelman-then-fix consumes RELEASED findings; a reviewer never adjudicates its own packet
dispatch-brokering	arbiter	none	none	every specialist path crosses the broker; leads never dispatch directly
ambiguous	none	none	all	below 0.6 confidence the correct output is a FALLBACK block, not a specialist
```

## 2. Selection procedure

1. Classify the request into exactly one request-type above — this classification is judgment,
   and below 0.6 confidence it is a FALLBACK question, never a guess
   (`.claude/rules/fallback-protocol.md` rule 3).
2. Look the row up. Primary is the fit; support is who the path crosses anyway; never is the
   pairing that damages the system's separations even when it looks efficient.
3. Return the row and the why — as advice. Selection is advice about WHO would fit, not a license to dispatch: the zero-dispatch default (CR-006/C-25) stands, every real dispatch still crosses the arbiter (EX-05), and a session that can do the work solo does.
4. If the honest classification is `ambiguous`, say so and return the FALLBACK, because the
   ninth row is the one that keeps the other eight honest.
5. When the fit includes re-instantiating a known pattern, pull it through the intake skill's
   §6 pin — cite the blueprint's path in the sibling gallery; never paste its body.

## 3. What is mechanically checked, and what is not

Asserted by `run-crew-tests.sh`: this file sits at the path the §4.3 map names · the table
parses (nine rows, five fields) · every named specialist resolves to a real file in
`.claude/agents/` · three fixture rows resolve as written · the caveat sentence above is present
verbatim · the intake skill points here. NOT asserted, because it is model-interpreted: whether a
free-text request is classified into the right request-type. That is the same honesty line the
intake skill draws, and it is drawn here on purpose.
