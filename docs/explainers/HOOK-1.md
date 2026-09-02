# HOOK-1, explained plainly

## What changed

The project gained four new senses. It now records when a helper agent FINISHES (not just when
it starts — including the transcript path, the only forensic handle a death leaves), stamps a
machine receipt the moment a prompt arrives (derived facts only — an exact gate token, a
remote-protocol turn, a byte count and hash — NEVER the prompt body, because prompts are where
secrets arrive and not-storing is the only redaction that cannot miss), logs every
permission ASK with the asking agent's identity (the blocker already logged denials; now the
asks have a trail too, scrubbed), and keeps a grounding cursor: every session start writes
what ledger state it saw — line counts AND content hashes — and prints what changed since the
last grounding, catching even a zero-line stamp flip. One more line matters: the existing
Agent-dispatch hook now leaves an unconditional delivery row, turning "does this event even
fire live?" from an assumption into a readable fact — the next gate's deny hook has a hard
precondition on it.

## Why

The corpus dives priced these four absences one by one (CORPUS-SDKPY, CORPUS-LANGGRAPH) and
classifier law forbade wiring them under a research token. This is the operator-declared gate
those dives queued. The coverage arms ship ANNOUNCE-ONLY behind a pinned cutover — append-only
trails cannot be repaired, so promotion to FAIL is a named wake, not a default.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A17 'HOOK-1'
jq -r '.hooks | keys[]' .claude/settings.json          # eleven events now
printf '%s' '{"prompt":"APPROVE TEST-X"}' | CLAUDE_PROJECT_DIR=$(mktemp -d) ./hooks/user-prompt-submit.sh; echo $?
```

## What could break, and what catches it

A prompt body leaking into the receipts trail → the planted-secret control fails by name. A
credential in an ask target → the scrub control. The cursor going blind to stamp flips → the
zero-line-delta hash case. And the honest limit is stated where it binds: fixtures prove
wiring and behavior; only live rows prove the platform delivers the three new events — every
trail-reading arm announces absence instead of failing on it.
