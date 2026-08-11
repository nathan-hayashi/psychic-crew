# PROGRESS.md — Compaction-Safe Checkpoints
Disk is canonical; context windows are caches (HC-8 §15.1). Every checkpoint answers: task · workflow status · active artifact · open decisions · in-flight changes · closed avenues · next action.

## [F0|2026-08-11T03:54:36Z] checkpoint — step 3 complete
- **Task:** F0 — Verify, Question, Scaffold. Budget 12K tokens (§6) / 45 min wall (Q5).
- **Workflow status:** steps 1, 2, 3 of 7 complete. Gate G-F0 not reached.
- **Active artifact:** `Plan.md` — baseline, Q0 answers, EX-01, OQ-1..OQ-7.
- **Open decisions:** OQ-2 model-id variant (→ F1) · OQ-3 idempotency measurement point (→ G-F0 stress) · OQ-6 apply-models HC-2 check self-triggers (**blocks step 7**) · OQ-7 .gitignore misses .claude/state/ (→ F2).
- **In-flight changes:** none unrecorded. Git not yet initialized — step 4 owns `git init`.
- **Closed avenues:** editing MASTER_FIFO_PLAN_CLAUDE.md (standing operator decision: report-only) · full §14.5 byte-identity (superseded by EX-01 after the psychic-crew rename).
- **Next action:** F0 step 4 — `git init`, branch `dev`, first commit.

## [F0|2026-08-11T04:03:24Z] checkpoint — F0 COMPLETE, gate G-F0 ready
- **Task:** F0 — Verify, Question, Scaffold. Complete.
- **Workflow status:** steps 1–7 of 7 done. validate-crew 7 PASS / 3 SKIP / 0 FAIL. Idempotency stress zero-diff across 12 files. Awaiting `APPROVE GATE-F0`.
- **Active artifact:** `Plan.md` (114L) · `GATES.md` G-F0 row · `context/session-summary.md` seeded.
- **Open decisions carried forward:** OQ-2 model-id variant (F1) · OQ-7 .claude/state/ ungitignored (F2) · OQ-8 hook schema invalid (F2, blocking) · OQ-9 PreToolUse deny mechanism (F2, blocking) · OQ-10 Task→Agent rename defeats bypass detection (F3, blocking).
- **In-flight changes:** none. Everything committed and tagged.
- **Closed avenues:** editing the execution authority · §14.5 literal byte-identity (EX-01) · §5.5 verbatim apply-models logic (EX-02, three defects corrected).
- **Next action:** STOP. On `APPROVE GATE-F0` → F1 Model Routing Layer; F1's per-agent-effort probe is already resolved (supported) by step 6.

## [F0|2026-08-11T04:18:21Z] checkpoint — plan-corrections registry added (gate-adjacent; does NOT advance to F1)
- **Task:** operator-directed — make the four open plan defects mechanically fixable rather than prose-only.
- **Workflow status:** F0 still complete and still gated. **G-F0 remains open; F1 has NOT started.**
- **READ FIRST when implementing any phase:** `context/plan-corrections.md` — the authoritative plan-vs-reality registry. The execution authority is never edited, so a phase that trusts §4.6/§5.6/§5.2.2 verbatim will rebuild the known defects. Machine-checked by `scripts/check-plan-corrections.sh`.
- **Current registry state:** 3 APPLIED (C-06/07/08, the EX-02 apply-models fixes) / 5 PENDING (C-01..C-04 owned by F2, C-05 by F3).
- **Enforcement:** `./scripts/check-plan-corrections.sh F2` exits 1 today and will keep failing F2's gate until C-01..C-04 are applied; `F0` exits 0. Verified both.
- **Next action:** unchanged — await `APPROVE GATE-F0`.
