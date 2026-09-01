# CORPUS-LANGGRAPH — the dive, against its named question

**The question (named at CORPUS-0):** What does langgraph checkpoint per graph node, and how do
its resume semantics compare to our disk-canonical continuity law (HC-8)?

## Identity

LangGraph — graph-structured agent orchestration whose durability layer is a first-class
library family: `libs/checkpoint` (the base contract), sqlite/postgres backends, and —
notably — `libs/checkpoint-conformance`, a suite that exists solely to verify ANY backend
against the contract. Nested extract; sidecars excluded.

## Read manifest (M4: targeted)

`libs/` listing · `libs/checkpoint/.../base/__init__.py` — the `Checkpoint` TypedDict,
`CheckpointTuple`, `PendingWrite`, and the delta-snapshot walk docstrings, read directly ·
`libs/checkpoint-conformance` structure (capabilities detection, conformance entry points).

## Findings

1. **What is checkpointed is TYPED STATE WITH LINEAGE.** `Checkpoint`: a format version `v`;
   an `id` that is unique AND monotonically increasing (sortable by construction); ISO `ts`;
   `channel_values` (the state itself); `channel_versions` (monotonic per-channel version
   strings); and `versions_seen` — per-NODE, which version of each channel that node has
   consumed, "used to determine which nodes to execute next." `CheckpointTuple` adds
   `parent_config` (lineage) and `pending_writes` (deltas recorded AFTER the checkpoint,
   replayable across a crash).
2. **History is delta-compressed with a defined walk.** Non-snapshot steps store a sentinel;
   reconstruction walks to the nearest ancestor holding a `_DeltaSnapshot` — storage-efficient
   history with the reconstruction rule in the contract, not in folklore.
3. **Resume is COMPUTED, not re-read.** On resume, `versions_seen` against `channel_versions`
   mechanically decides which nodes run next; `pending_writes` replays the crash window. No
   judgment participates.
4. **The contract has its own conformance suite.** Backends prove themselves against
   `checkpoint-conformance` (capability detection + tests) — N implementations, one law.

## The answer

HC-8 and langgraph agree on the axiom — durable state outranks the process's memory — and part
on everything after it. We checkpoint NARRATIVE (ledger tails, distilled summaries, a rolling
snapshot); resume is JUDGMENT (a session re-reads and re-grounds per §15.4). Langgraph
checkpoints TYPED VERSIONED STATE; resume is COMPUTATION. Three of its primitives we hold by
other means: monotonic sortable ids (git SHAs + dated stamps), lineage (commit parentage), the
crash window (closed by writing every decision the moment it is made, rather than replaying).
ONE primitive has no equivalent here: **versions_seen** — nothing records which ledger state a
session (or subagent) has already consumed, so every re-grounding re-reads everything and every
post-compaction turn trusts a summary it cannot diff. A seen-cursor would let a resumed session
know exactly what is NEW since its last grounding.

## The transfer — one candidate RECORDED, classifier law again

A seen-cursor lands in session-start/grounding machinery — `hooks/` territory, HIGH class in
the intake classifier; a dive token does not smuggle it. RECORDED as the FOURTH candidate for
the operator-declared hook gate already queued by CORPUS-SDKPY (SubagentStop, UserPromptSubmit,
PermissionRequest — the grounding cursor composes with them into one lifecycle gate). The
conformance-suite idea is noted as already practiced in miniature (every estate repo carries
its own validate-* against shared laws); no arm lands.

## Disposition

- **Already held:** disk-canonical axiom; sortable checkpoint identity (SHAs); lineage
  (parentage); crash-window closure (write-the-moment-decided, HC-8); per-repo law suites.
- **Recorded, operator's word required:** the seen-cursor (hook-gate candidate #4).
- **Rejected:** nothing — computed resume is right for graphs; judgmental resume is right for
  a build whose every phase crosses a human gate.

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)
