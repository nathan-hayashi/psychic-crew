# CORPUS-BABYSITTER-1 — the dive, detection half of the split question

**The question (named at CORPUS-0, split by design):** What supervision loop does babysitter
run over child agents — **part 1 (this gate): what it watches and how it detects**; part 2
(next gate): what it intervenes with — and which halves transfer under our human-gate law?

## Identity

Babysitter (a5c-ai) — "Enforce obedience on agentic workforces… deterministic,
hallucination-free self-orchestration." A process written in real JavaScript is the AUTHORITY;
an enforcement engine drives any of 12 harnesses through it (Adapters, v6), with breakpoints
as human gates, quality gates as code, and an immutable event-sourced journal. The convergence
with this estate's premises is the closest of the whole corpus. Sidecars excluded.

## Read manifest (M4: targeted)

README (What-is + the How-It-Works diagram) · `docs/user-guide/features/` listing ·
`two-loops-architecture.md` (the TL;DR + product triad, read directly) ·
`quality-convergence.md` head (scoping only — its loop mechanics belong to part 2) · targeted
grep over `journal-system.md`.

## Findings — what it watches, how it detects

1. **It watches EVERY STEP BOUNDARY, mandatorily.** The triad's third leg, verbatim: "a
   mandatory stop after every step, a process check, and a permit/halt decision. Enforcement,
   not assistance — gates block progression until satisfied; they're not suggestions." The
   boss loop is real code; "the orchestrator can ONLY do what this code permits."
2. **The detection substrate is an EVENT-SOURCED JOURNAL.** Every decision recorded immutably;
   "state is event-sourced for deterministic replay" — the same events replay to the same
   verdicts, so detection itself is reproducible.
3. **It watches QUALITY AS A NUMBER against a declared target.** The process code compares
   measured scores to thresholds (`if (score < 80) refine`) with bounded attempts ("max 10
   attempts") — detection of not-good-enough is code logic over measurements, not sentiment.
4. **Breakpoints are watched as gates, not offered as options** — "human gates (enforced, not
   optional)."

## The answer, part 1

Babysitter watches step completions, an immutable event stream, measured quality, and human
breakpoints; it detects by running deterministic process code over that substrate at a
MANDATORY stop after every step. The estate holds most of this in different clothing —
breakpoints ARE our exact tokens, the journal IS our append-only ledgers, quality-gates-block
IS our red-suite-blocks-close, process-as-authority IS the plan-as-contract. The one
structural difference: their per-step permit/halt is ENFORCED BY MECHANISM, while our
per-step discipline (commit per step, suite after every change) is law the executor obeys —
held by discipline, not by machinery. That is precisely the shape of C-05, the hook-enforced
bypass detection already named in ROADMAP.md as this estate's largest available upgrade: this
dive is its strongest external corroboration yet.

## The transfer, part 1 — a corroboration RECORDED where its owner already lives

No new arm and no new candidate queue: C-05 already exists as the named owner. This dive's
record strengthens its case file (mandatory-per-step permit/halt as practiced art, event-
sourced detection as its substrate). The intervention half — what babysitter DOES on a failed
check, the convergence loop, halts and attempt caps — is DELIBERATELY left to part 2, per the
split this arc declared before any reading.

## Bookkeeping, stated

The census row does NOT flip at this gate: the split discharges the row at CORPUS-BABYSITTER-2
(the coverage table binds the row to BOTH gate ids). The question row likewise remains in
CORPUS-QUESTIONS until part 2 — the questions arm stays 1==1 through this gate by design.
