# CORPUS-CONDUCTOR, explained plainly

## What changed

Dive 3 answered its question: yes, conductor names failure states our arbiter protocol lacks —
a typed line between "we chose to stop" and "we crashed" (`is_explicit`), and a declared trio
of parallel-group failure modes (fail_fast / continue_on_error / all_or_nothing) with keyed
errors. No suite arm lands, deliberately: the arbiter trail is append-only history whose rows
narrate failure in prose, and an arm demanding types would indict the past. Instead both
adoptions are recorded with NAMED owners — the termination vocabulary joins ARC4-1's findings
schema, the trio waits for the next gate that dispatches parallel specialists.

## Why

A failure state that exists only in prose cannot be queried, counted, or asserted. Conductor's
lesson is that the vocabulary itself is the control — and the right place to adopt vocabulary
is the schema being designed (ARC4-1), not a retrofit over history.

## Verify it yourself

```
grep -A8 'The transfer' docs/research/CORPUS-CONDUCTOR.md
./scripts/check-decision-matrices.sh | grep 'QUEUED row'    # 5 == 5
```

## What could break, and what catches it

The census/coverage/questions bindings verify the flip; ARC4-1's gate text now owes two adopted
shapes (coherence + termination vocabulary) — a reviewer of that gate can hold it to both, by
name, from this record.
