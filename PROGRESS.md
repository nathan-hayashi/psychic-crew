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

## [F0|2026-08-11T04:19:39Z] checkpoint — validator self-match fixed
- **Task:** repair `validate-crew.sh` flagging itself on §5.2.4.
- **Workflow status:** validate-crew back to 7 PASS / 3 SKIP / 0 FAIL, exit 0, verified with a negative control. **G-F0 still open; F1 has NOT started.**
- **Note:** G-F0's "no absolute paths" evidence was measured against an untracked `scripts/`; now genuinely covered. Recorded in Plan.md.
- **Next action:** unchanged — await `APPROVE GATE-F0`.

## [F0|2026-08-11T04:41:35Z] GATE G-F0 APPROVED — F1 opened
- **Task:** F0 closed on exact token `APPROVE GATE-F0`. F1 — Model Routing Layer [10K] now active.
- **F1 steps:** (1) finalize apply-models.sh; (2) probe per-agent effort in an agent frontmatter, record verdict; (3) write model-policy rule.
- **Scoping decision:** F1 step 2 requires an agent frontmatter to exist and G-F1's demo names `quality-reviewer`, but `.claude/agents/` is F3's tree. F1 therefore creates `quality-reviewer.md` **frontmatter-only, body stubbed and marked F3-owned** — the routing layer needs a target to stamp; F3 still writes the behavioural body to its §5.1.3 contract.
- **Compaction defense:** no PreCompact parachute until F2 (OQ-8), so §0.3's 70% rule + these checkpoints are it.
- **Next action:** F1 step 1.

## [F1|2026-08-11T04:48:25Z] checkpoint — F1 COMPLETE, gate G-F1 ready
- **Task:** F1 — Model Routing Layer. Steps 1–3 complete.
- **Workflow status:** validate-crew 8 PASS / 3 SKIP / 0 FAIL. Corrections 3 APPLIED / 5 PENDING / 1 SUPERSEDED. Gate sims F0→0 F1→0 F2→1 F3→1. Awaiting `APPROVE GATE-F1`.
- **Active artifact:** scripts/apply-models.sh · scripts/validate-crew.sh · scripts/check-plan-corrections.sh · .claude/rules/model-policy.md · .claude/agents/quality-reviewer.md (frontmatter only).
- **Open decisions:** OQ-2 closed by the effort probe for effort; the `claude-opus-5[1m]` pinned-mode gap remains open. C-01..C-04 (F2) and C-05 (F3) still pending and now gate-enforced.
- **In-flight changes:** none.
- **Next action:** STOP. On `APPROVE GATE-F1` → F2 Enforcement Layer, which must start by applying C-01..C-04.

## [F1|2026-08-11T04:57:23Z] checkpoint — F2 readiness package (gate-adjacent; F2 NOT started)
- **Task:** operator-directed readiness. F2's rebuild deliberately not performed — it requires `APPROVE GATE-F1`.
- **Delivered:** `scripts/run-crew-tests.sh` (18 cases, `gate` mode for live evidence) · `context/f2-readiness.md` (acceptance spec + risk register).
- **New hazards recorded:** sensitive-guard/C-04 install-order deadlock; `$CLAUDE_PROJECT_DIR` unset in this shell, which would silently no-op all nine hooks.
- **Next action:** STOP. On `APPROVE GATE-F1` → F2, starting at f2-readiness.md §0 step 1 (C-04 before sensitive-guard).

## [F2|2026-08-11T05:10:43Z] checkpoint — F2 implemented, offline-verified; live proof pending a relaunch
- **Task:** F2 Enforcement Layer. All §6 steps done: hooks implemented, `bash -n` clean, wired per settings, cases registered, §15.3 flag mechanics, §15.4 session-start re-grounding, §15.9 snapshot pair + restore-context.sh.
- **Workflow status:** validate-crew 19 PASS / 2 SKIP / 0 FAIL · run-crew-tests F2 27 PASS / 0 FAIL · corrections F0/F1/F2 all exit 0, F3 exit 1.
- **BLOCKER for G-F2:** project hooks do not load in this session (bound to the pre-rename path). The live-trigger demo requires relaunching from `~/projects/psychic-crew`.
- **Next action:** relaunch, then G-F2 demo (live trigger each hook) + stress (6 forbidden ops → 6 denies + 6 audit entries; kill-switch).
