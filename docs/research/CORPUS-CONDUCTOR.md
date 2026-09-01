# CORPUS-CONDUCTOR — the dive, against its named question

**The question (named at CORPUS-0):** How does conductor express multi-agent hand-off ordering,
and does its scheme name failure states our arbiter protocol lacks?

## Identity

Conductor (Microsoft) — a CLI for multi-agent workflows over the Copilot SDK and Claude, whose
core claim is DETERMINISM: routing is YAML + Jinja2 expressions, first matching condition wins,
and — verbatim — "No LLM in the orchestration loop, no tokens spent deciding what runs next."
Workflows are source-controlled files. Nested extract at `conductor-main/`; sidecars excluded.

## Read manifest (M4: targeted)

README (identity + features) · `docs/workflow-syntax.md` (routing, terminate, dialog, hook
sections) · `docs/parallel-execution.md` (failure_mode section) · `docs/dynamic-parallel.md`
(keyed-error greps) · `docs/` listing. Five surfaces; everything below cites one.

## Findings

1. **Hand-off ordering is data.** Routes are conditional expressions evaluated first-match-wins
   toward named agents, parallel groups, or `$end`; sub-workflows compose with templated
   input mappings. Ordering disputes cannot arise at run time because ordering is not decided
   at run time.
2. **Parallel failure is a TYPED TRIO.** `failure_mode: fail_fast | continue_on_error |
   all_or_nothing` per group, with errors KEYED by the same extracted keys as results — group
   failure semantics are declared, not improvised.
3. **Deliberate termination is DISTINGUISHABLE from a crash.** Terminate steps carry
   `status: success|failed` + a structured `reason`; the event payload carries
   `is_explicit: true`, the CLI exit code is deterministic, and explicit terminations SKIP the
   on-failure checkpoint — a typed line between "we chose to stop" and "we died."
4. **Failure TRANSLATES at composition boundaries.** A failed terminate inside a sub-workflow is
   DOWNGRADED at the parent to `SubworkflowTerminatedError`; `is_explicit` does NOT inherit,
   while the child's `terminated_output/reason/by` are preserved on the wrapper. Cross-boundary
   failure semantics are named, not accidental.
5. **Uncertainty pauses into a human.** Dialog mode: an evaluator inspects output against
   criteria and may open a conversation; human-in-the-loop steps pause on decisions.

## The answer

Yes — conductor names failure states our arbiter protocol does not. The arbiter law has
FALLBACK (uncertainty), findings packets, custody and release separation, and its trail records
dispatch failures — but as PROSE in a mutation field, not as type. Conductor draws two lines we
have never drawn: explicit-stop vs crash (`is_explicit`), and per-group failure semantics
(the trio). Its ordering scheme itself adds nothing here — plan-driven numbered steps under a
human gate are already a stronger form of "no LLM decides what runs next."

## The transfer — recorded with NAMED OWNERS, no arm this gate

No suite arm lands: the arbiter trail is append-only history and its existing rows narrate
failure in prose — an arm demanding typed status would indict the past instead of binding the
future. Two adoptions are recorded where they will bind:

1. **ARC4-1's findings schema** (already earmarked for errors-empty-iff-approved at
   CORPUS-ZEROSHOT) additionally adopts the termination vocabulary: a finding-run record
   carries `status` + `is_explicit`-style provenance so a deliberate stop is never confused
   with a crash.
2. **The failure_mode trio** is named for the next gate that dispatches parallel specialists
   (the security+quality pair is a live all_or_nothing today, implicitly) — declaring the mode
   per dispatch group belongs to that gate's arbiter-protocol amendment, not to a dive.

## Disposition

- **Already held:** deterministic ordering (plan-driven numbered steps + gates); dialog-on-
  uncertainty (fallback rule 3); source-controlled workflow (the plan IS the file).
- **Adopted, owner named:** typed termination vocabulary -> ARC4-1; failure_mode trio -> the
  next parallel-dispatch gate.
- **Rejected:** nothing required rejection — the schemes are compatible, ours is the stricter
  special case (every hand-off crosses a human gate).

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)
