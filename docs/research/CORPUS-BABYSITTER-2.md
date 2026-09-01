# CORPUS-BABYSITTER-2 — the dive, intervention half; the ladder closes

**The question (named at CORPUS-0, split by design):** part 2 — what babysitter INTERVENES
with, and which halves transfer under our human-gate law. (Part 1, detection, is
CORPUS-BABYSITTER-1; this gate discharges the row and the question.)

## Read manifest (M4: targeted)

`quality-convergence.md` — the loop example, prioritized-gap feedback, and the progressive-
target strategy, read directly · `breakpoints.md` — the plain-English contract, the
BreakpointResult flow, and the Advanced features list (durability, backends, signing), read
directly.

## Findings — what it intervenes with

1. **Rejection is LOOP INPUT, not a crash.** A failed quality check re-tasks the agent WITH
   the measured feedback ("Tests run: 3/10… AI sees: missing password validation"); a
   breakpoint returns `BreakpointResult { approved, feedback }`, and `!approved` routes to a
   fix path carrying the reviewer's words. Bounded by attempt caps.
2. **Targets ESCALATE progressively.** For hard targets the bar itself rises by iteration
   (70 → 80 → 85 → 90), with gap feedback prioritized by weighted contribution — early
   iterations intervene gently, late ones demand production-ready.
3. **The human intervention is DURABLE and PORTABLE.** A pending approval "survives session
   timeouts, restarts, and handoffs" (journal + configured backend, not the live chat), and
   can route to where reviewers already work — a GitHub Issues backend (approve by
   commenting) or a server backend. In-session, Claude Code breakpoints use AskUserQuestion.
4. **Approvals are CRYPTOGRAPHICALLY SIGNED.** Verbatim: "an audit trail of who approved
   what can be verified rather than merely trusted."

## The answer, part 2 — which halves transfer under our human-gate law

- **Feedback-carrying rejection: already held.** The arbiter→fixer FINDINGS flow is exactly
  this (findings released, steelmanned, applied, re-verified); reject-with-feedback is our
  native loop.
- **Progressive targets: REJECTED with reason.** A rising bar legitimizes shipping below the
  final bar at every iteration before the last. This estate's bar is fixed (a red suite
  blocks close, full stop); iteration is unbounded until green. Recorded as a decision.
- **Durable out-of-chat approvals: the network-full sibling of our remote lane, recorded.**
  Babysitter routes the question to a backend; SIDE-R1 routes the PACK through the human.
  Same problem, inverse transport; their design independently validates the lane's shape.
  Zero-network law keeps ours as is.
- **Signed approvals: BLOCKED BY R-SEC-1, honestly.** Signing needs a key, and rule 1 of the
  secrets contract is that no key exists anywhere in this estate until a gate grants one —
  tamper-evidence cannot be bought at the price of the zero-credential law. The
  R-SEC-1-compatible route is RECORDED for the operator: git commit signing with the
  OPERATOR'S OWN key (operator-held, never repo-resident) would make every APPROVED row's
  commit verifiable without the estate holding anything — an operator option, not a build
  item, and only the operator's word opens it.

## The ladder, closed

With this gate all EIGHT full dives are discharged (zeroshot, OpenHands, conductor, sdkpy,
takt, langgraph, agent-framework, babysitter×2). The census row flips, the last question
leaves the table (the questions arm reads 0 == 0, empty-legal by the dynamic form), and the
arc's remaining gate is CORPUS-DELTA — the four ETL-BUILD refresh docs, one gate, per the
coverage table's arithmetic.
