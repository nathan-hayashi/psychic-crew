# CORPUS-ZEROSHOT — the dive, against its named question

**The question (named at CORPUS-0, before any reading):** What does zeroshot's harness assert
about task completion that our gate machine does not, and does any check transfer as a suite arm?

## Identity

zeroshot (The Open Engine, "Layer 01 · Verification") — independent executor–verifier
orchestration for software changes. Thesis, verbatim from its README: **"The agent that wrote
the code shouldn't be the one that says it works."** Node ≥ 22 CLI orchestrating provider CLIs;
crash-safe SQLite ledger; worktree isolation by default. Corpus snapshot on disk at
`zeroshot-main/` (nested extract; Zone.Identifier sidecars EXCLUDED from all counts per the
CORPUS-0 rule).

## Read manifest (M4: targeted, never general)

README.md (architecture + classification sections) · `cluster-templates/base-templates/`
listing · `worker-validator.json` (schema-walked) · `heavy-validation.json` (schema-walked).
Four surfaces against a repo of thousands of files; everything below cites one of them.

## Findings

1. **Completion is TYPED, not narrated.** The validator's output is a JSON schema with
   `approved` REQUIRED and an `errors` field documented "empty if approved" — an
   errors-empty-iff-approved coherence rule. The executor's own status carries a required
   `percentComplete`. Prose summaries are actively forbidden ("NO preambles… ONLY the required
   JSON schema fields").
2. **The verifier is separated by construction.** Validators run READ-ONLY, never share the
   executor's session or reasoning context, and (README) "must reproduce reported failures."
   The rejection loop is mechanical: a ledger query fires the executor again when
   `approved === false`.
3. **Consensus is COMPUTED from typed rows.** heavy-validation runs validator-security +
   validator-tester + a consensus-coordinator whose only job is `allApproved` over ledger
   queries, with per-validator `errors` aggregated into the verdict row.
4. **Rigor is tiered BEFORE work.** A conductor scores complexity (TRIVIAL/SIMPLE/STANDARD/
   CRITICAL) and type first; the score picks the workflow. TRIVIAL deliberately has NO verifier
   — a declared exemption, not a silent skip. A junior model that cannot call it answers
   UNCERTAIN and a senior decides.
5. **The ledger IS the control flow.** Triggers are queries over a crash-safe SQLite event log;
   agents subscribe/publish; the graph is that wiring.
6. **Non-interactive law.** Every agent is told it cannot ask questions and must take the SAFER
   choice when unsure — the inverse of our fallback-protocol (we block below 0.6 confidence;
   they proceed-safer because there is no user). Same fork our remote lane declared at SIDE-R1.

## The answer

Our gate machine asserts WHO may declare completion (the operator, exact token) and that the
declaration is on the record. Zeroshot additionally asserts WHAT a completion claim must look
like — typed, schema-required, coherence-checked (errors empty iff approved), computed into
consensus — and its verifier separation is structural where our C-12 is procedural (release
lines + arbiter custody). The transferable check is exactly that: our own audit trail can be
held to typed coherence.

## The transfer — landed as suite arms, this gate

Four crew arms (cases_F7): the arbiter trail's rows must PARSE with required keys
(ts/from_agent/to — the typed-completion lesson), and NO row may name its own `from_agent` in
its `to` list (self-dispatch: C-12, now machine-typed). Both conditional on the gitignored trail
existing (announced when absent, the CR-027 pattern) — and both proven able to fire by
UNCONDITIONAL probes on planted rows (a malformed line; a self-dispatch row).

## Disposition

- **Adopted:** typed-trail coherence (the arms above). The errors-empty-iff-approved shape is
  recorded for ARC4-1's findings schema (findings.jsonl should carry the same coherence rule).
- **Rejected with reason:** TRIVIAL-skips-the-verifier — every phase here gets its human gate;
  tiering rigor below the gate is the army-selector's job, not a gate bypass. Computed consensus
  over model validators — HC-7/zero-dispatch posture stands; consensus here is the operator.
- **Already held:** UNCERTAIN-escalates = fallback-protocol rule 3; worktree isolation = our
  scratch-copy discipline; ledger-as-control-flow = GATES.md is precisely this, human-stepped.

**Question discharged.** (It leaves CORPUS-QUESTIONS with this gate; the census row flips
QUEUED → DIVED; this document is the standing record.)
