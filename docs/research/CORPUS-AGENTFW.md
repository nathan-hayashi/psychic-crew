# CORPUS-AGENTFW — the dive, against its named question

**The question (named at CORPUS-0):** What contract does agent-framework enforce between
planner and executor roles, and where does it place the human gate relative to ours?

## Identity

Microsoft Agent Framework (MAF) — open, multi-language (.NET + Python) framework for
production agent systems: graph workflows with sequential/concurrent/handoff/group patterns,
checkpointing, streaming, human-in-the-loop, time-travel. The planner/executor contract lives
in its Magentic orchestration; the human gate lives at the tool decorator and in
request-info workflow steps. Sidecars excluded; top-level extract (no doubled nesting).

## Read manifest (M4: targeted)

README (identity + workflow feature list) · `_magentic.py` — task/progress ledger structures,
stall_count/max_stall_count/replan, read at the named lines · `tool-approval` samples
(approval_mode declarations) · `_workflows/` module listing (approval lifecycle/state,
checkpoint, request-info surfaces located by name).

## Findings

1. **The planner's state is LEDGERS — their own word.** Magentic maintains a TASK LEDGER
   (facts + plan, dedicated prompts) and a typed PROGRESS LEDGER evaluated as the loop runs.
   The planner/executor contract: orchestrator holds the ledgers, executors act, progress is
   judged per turn into a structured object.
2. **Stall is counted and answered by REPLANNING.** `stall_count` with `max_stall_count = 3`;
   on threshold, `replan()` — which "will clear the chat history and reset the stall count."
   Stall detection, third corpus in a row (gastown's watchdogs, takt's inactivity deadline,
   now MAF's counted stalls) — but MAF adds a RESPONSE semantic: reset context and re-plan,
   autonomously.
3. **The human gate is declared AT THE TOOL, by the tool's AUTHOR.**
   `@tool(approval_mode="always_require")` vs `"never_require"` — sensitivity is a property
   the capability declares about itself; approvals then flow as request-info events with a
   full approval lifecycle/state machine behind them.
4. **Workflow-level human-in-the-loop exists as steps** (request-info executors, samples), so
   a graph can pause into a person mid-flow.

## The answer

The planner/executor contract is convergent with ours in shape — ledgers, typed progress,
bounded stalls — and divergent in CUSTODY: Magentic's ledgers are model-maintained working
state; ours (GATES/Plan/PROGRESS) are operator-witnessed law. The human gate placement is the
sharp difference, on two axes. GRANULARITY: MAF gates per tool call and per workflow step;
this estate gates per PHASE with an exact pre-declared token — MAF has no phase-token
equivalent, we additionally get per-tool interception from the platform layer, so ours is
two-tier. AUTHORITY: MAF's `approval_mode` is declared by the TOOL AUTHOR in code — a
capability that can mark itself `never_require` is a capability that can unmark itself; in
this estate the OPERATOR's layer decides (the harness law that a marker can tighten but never
mint), and content never grants authority.

## The transfer — NONE mechanical; one response-semantic REJECTED with reason, one record

- **Rejected with reason:** stall → autonomous replan-with-context-reset. Under gate law the
  correct stall response is ESCALATION (FALLBACK to the operator), not an agent quietly
  resetting its own context and trying again — replan-without-a-human contradicts the
  program's premise. Recorded so the rejection is a decision, not an oversight.
- **Recorded:** the third stall-detection corroboration strengthens the queued hook gate's
  case (four candidates there; detection is prerequisite to ANY response semantic).
- **Already held:** ledger-driven planning (operator-witnessed form); two-tier human gating;
  authority-side sensitivity declaration.

## Disposition

- **Already held / held stronger:** ledgers as law; phase tokens above per-tool gates;
  operator-declared authority (marker-tightens-never-mints).
- **Rejected:** author-declared sensitivity; autonomous stall-replan.
- **Recorded:** stall corroboration #3 for the hook-gate queue.

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)
