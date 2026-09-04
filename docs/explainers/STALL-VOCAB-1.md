# STALL-VOCAB-1, explained plainly

## What changed

The estate finally has words — and one working check — for a hung agent. Two planes: agents
report their own state, and the observer makes exactly one inference (is the last trail
event fresh). Five typed classifications name detection REASONS, never lifecycle states,
each with its response beside it — self-reported stuck ESCALATES (never restarts), absent
signals get grace, stale signals fall through, TOCTOU re-checks precede any action, and
no-auto-action is stated as design: this estate runs no daemon, the operator is the
watchdog. The first mechanical form is an announce-plane sweep in validate-crew over the
trails HOOK-1 already writes — a stall candidate is a NOTE, never a FAIL, until PROMOTE-1
reads its evidence.

## Verify it yourself

```
./scripts/run-crew-tests.sh all | grep -A10 'STALL-VOCAB-1'
./scripts/validate-crew.sh | grep 'stall announce'
```

## What could break, and what catches it

A vocabulary edit without a gate — the exactly-five arm and the ratified-set arm. A
regression in the announce logic — three fixture controls every run: an old unpaired start
must flag, a stopped agent must not, a fresh start must ride its grace.
