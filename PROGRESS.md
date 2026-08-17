# PROGRESS.md — compaction-safe checkpoints

## Checkpoint discipline (§6 F5, binding)

Disk is canonical; a context window is a disposable cache (§15.1). Every checkpoint is written at
the moment a decision is made, never deferred to the end of a turn.

**Read order at every session start and every post-compaction turn (§15.4):** the tail of this
file, then `GATES.md`, then `context/session-summary.md`, then `context/plan-corrections.md`.
Then proceed strictly forward under §0.2b — never regress to a completed step, never re-run a step
whose artifact exists. If recorded state and disk disagree, ESCALATE; do not guess which to trust.

**Every checkpoint carries these fields**, so a cold reader can resume without the transcript:

| Field | Why it is required |
|---|---|
| Task | what this phase/step is actually for |
| Workflow status | validator, suite and correction counts — numbers, not adjectives |
| Active artifact | the files currently being changed |
| Open decisions | what is unresolved, and who owns it |
| In-flight changes | uncommitted work, or explicitly "none" |
| Closed avenues | what was tried and rejected, so it is not retried |
| Next action | one concrete next step, in the imperative |

A checkpoint that says "done" without numbers is not a checkpoint. Gate-readiness is recorded in
`GATES.md`, which is the authority the Stop hook reads for its GATE READY toast — a checkpoint
sentence alone cannot manufacture that alert.


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

## [F2|2026-08-11T05:11:41Z] checkpoint — kill-switch closed; G-F2 offline stress green
- **Stress:** 6/6 denials · 6/6 audit entries · kill-switch removes hooks → validate-crew exit 1 (11 FAIL).
- **Still required for G-F2:** live trigger of each hook, which needs a relaunch from `~/projects/psychic-crew`.
- **Next action:** relaunch; the SessionStart hook will re-ground automatically, then run the live demo.

## [F2|2026-08-11T05:39:31Z] checkpoint — G-F2 live demo + stress COMPLETE, gate ready
- **Task:** G-F2 live evidence. The relaunch from the renamed path cleared F2's blocker; all ten hooks are confirmed dispatching through the platform, not just the harness.
- **Workflow status:** validate-crew 19 PASS / 2 SKIP / 0 FAIL (both SKIPs correctly F3-owned) · run-crew-tests F2 35 PASS / 0 FAIL (was 27) · corrections F0/F1/F2 exit 0, F3 exit 1.
- **Demo:** session-start, audit-logger and stop proved themselves unprompted during re-grounding; bash-blocker (6 ops), model-guard, sensitive-guard, error-recovery, auto-format and notify were triggered deliberately. PreCompact is not on-demand triggerable — covered by ccs-01 plus the existing numbered snapshots.
- **Stress:** 6 forbidden ops → 6/6 denials with correct HC reasons → 6/6 audit records. Every probe was inert-if-unguarded by construction. Kill-switch closed earlier at 6591b34.
- **Defect found and fixed:** denials were silent. `deny()` wrote no record and PostToolUse cannot fire for a blocked tool, so the first live stress produced 6 denials / 0 audit entries — failing G-F2's stress as written.
- **Coverage gap closed:** auto-format, error-recovery and notify had zero harness cases; 8 new checks added.
- **Docs corrected:** R2 closed with live evidence (engineered around at two layers, not a false alarm) plus new R7; `context/session-summary.md` was stale by two gates and is redistilled per §15.5.
- **In-flight changes:** none.
- **Next action:** STOP. Await `APPROVE GATE-F2`. On approval → F3 Core Bench, starting with C-05.

## [F2|2026-08-11T06:00:49Z] GATE G-F2 APPROVED — F3 opened
- **Task:** F2 closed on the exact token `APPROVE GATE-F2`; operator confirmed the desktop toast, closing notify's live proof. F3 — Core Bench [45K] now active.
- **F3 steps (§6):** write arbiter.md + lead-planner.md verbatim (§5.1.1/§5.1.2); build the remaining six agents to their §5.1.3 contracts; write rules §5.2.2–§5.2.4; apply-models; register agent-presence assertions in cases_F3.
- **MUST DO FIRST — C-05:** bypass detection greps `Task`, renamed `Agent` in v2.1.63. `scripts/validate-crew.sh` already matches both; `.claude/rules/arbiter-protocol.md` does not exist yet and must carry both names. `./scripts/check-plan-corrections.sh F3` exits 1 until it does — the F3 gate is hard-blocked on this.
- **Rename trap:** §5.1.1's verbatim arbiter.md payload (plan L187) reads "the hiya-crew pipeline". Writing it verbatim reintroduces the old name; the EX-01 substitution must be applied and recorded.
- **Compaction posture:** unlike F1/F2, the §15.9 parachute is now live — PreCompact snapshots, rolling latest.md, and SessionStart re-grounding are all proven, so a mid-phase compaction is survivable.
- **Next action:** F3 step 1 — write `.claude/rules/arbiter-protocol.md` applying C-05, then the agent definitions.

## [F3|2026-08-11T06:05:46Z] checkpoint — F3 step 1: rules layer + the two verbatim agents
- **Task:** F3 Core Bench, opened after `APPROVE GATE-F2`. C-05 applied first as mandated, then the rules layer, then the two verbatim agent payloads.
- **Workflow status:** validate-crew 21 PASS / 2 SKIP / 0 FAIL · corrections 9 APPLIED / 0 PENDING / 1 SUPERSEDED · GATE F3 PASS · suite 53 PASS / 0 FAIL.
- **Delivered:** `.claude/rules/arbiter-protocol.md` (C-05 — matches Task|Agent, `expected_output` required, reference-passing, weakness stated) · `.claude/rules/security.md` (§5.2.4 severity table + standing prohibitions) · `.claude/rules/fallback-protocol.md` (§5.2.1 verbatim, C-10) · `.claude/agents/arbiter.md` + `lead-planner.md` (verbatim, EX-01 rename applied) · apply-models stamped both (opus/high, opus/max).
- **New defect registered — C-10:** CLAUDE.md binds every agent to fallback-protocol.md, but no §6 step ever writes it. Absent through F0/F1/F2; now written and machine-checked.
- **Remaining for F3:** six agent bodies (lead-executor, security-reviewer, fixer, test-runner, integration-runner, plus quality-reviewer's F3-owned body) · cases_F3 agent-presence assertions · G-F3 demo + stress.
- **In-flight changes:** none.
- **Next action:** write the six agent bodies to their §5.1.3 contracts, then register cases_F3.

## [F3|2026-08-11T06:09:36Z] checkpoint — F3 IMPLEMENTATION COMPLETE, G-F3 demo not yet run
- **Task:** F3 Core Bench. All five §6 steps done.
- **Workflow status:** validate-crew 26 PASS / 1 SKIP / 0 FAIL (the last SKIP is arbiter dispatch coverage, which needs a real dispatch — G-F3 owns it) · cases_F3 27 PASS / 0 FAIL · corrections 9 APPLIED / 0 PENDING / 1 SUPERSEDED · GATE F3 PASS.
- **Delivered:** all 8 agents present and stamped from models.config.json — opus/max lead-planner · opus/high lead-executor, arbiter, fixer · sonnet/high security-reviewer · sonnet/medium quality-reviewer, test-runner, integration-runner (HC-3 exactly). Four rules complete. cases_F3 registers 27 assertions incl. stamp-vs-config drift, no surviving {{APPLY}}, read-only lenses holding no mutating tool, and EX-01 name hygiene.
- **BLOCKED on operator authorisation:** G-F3's demo requires dispatching real subagents (lead → arbiter → both reviewers → arbiter merge → fixer verdict, then showing logs/arbiter-audit.jsonl). This session's operating instructions forbid invoking the Agent tool unless the operator asks. Not a technical blocker — an authorisation one.
- **In-flight changes:** none.
- **Next action:** obtain authorisation to spawn subagents, then run the G-F3 demo + stress (malformed packet quarantine; direct lead→specialist probe caught by coverage check), then tag crew-f3.

## [F3|2026-08-11T06:21:10Z] checkpoint — G-F3 HALTED at a P0: the broker cannot dispatch
- **Task:** G-F3 demo, authorised by the operator. Ran lead-planner → arbiter for real.
- **Result:** demo BLOCKED. Verdict **ESCALATE** (§0.2c) — a gate cannot PASS with an open P0.
- **C-11 (P0):** 0 of 8 agents hold Agent or Task. §5.1.1 grants the arbiter Read/Grep/Glob/Write; §5.2.2 makes it the sole permitted dispatcher. lead→arbiter→specialist has zero dispatch capability at every hop, so the broker pattern — this build's central design bet — is unexecutable as specified.
- **Agent behaviour was correct:** lead-planner produced a rigorous DISPATCH and confirmed it holds no dispatch tool. The arbiter passed ORDER CHECK, refused to fabricate specialist packets, returned a FALLBACK at confidence 0.97, and wrote `original_sha256: UNAVAILABLE(no-hash-tool…)` rather than invent a digest. The contract is broken; the implementation of it is sound.
- **Gates now blocking, both correctly:** `check-plan-corrections.sh F3` FAIL (C-11 pending) · `validate-crew.sh` 26 PASS / 0 SKIP / 1 FAIL (arbiter coverage: 2 dispatches, 1 arbiter line — a true positive against the orchestrator, which had to bypass the arbiter *because* of C-11). That FAIL also satisfies G-F3's stress requirement that a direct lead→specialist call be flagged at validate.
- **NOT tagged:** crew-f3 is deliberately not created. The phase is not gate-ready.
- **In-flight changes:** none.
- **Next action:** operator decision on C-11 — Option A (grant the arbiter `Agent`, making it the only component able to dispatch and converting the dispatch law into a structural guarantee, under a logged exception) or Option B (orchestrator fans out, arbiter normalises; partial G-F3 evidence only). Then re-run the G-F3 demo.

## [F3|2026-08-11T06:36:54Z] checkpoint — G-F3 re-run BLOCKED by a platform limit; two new P0s
- **Task:** G-F3 demo re-run under EX-04.
- **Result:** still blocked. Verdict remains **ESCALATE**. crew-f3 NOT tagged.
- **C-11 reopened:** EX-04 is INERT. Runtime says "Agent is disabled for this session, in subagents as well as here" — the orchestrator can dispatch, a subagent cannot, at any depth. A frontmatter grant is a declaration, not a capability, and disk inspection cannot tell them apart. **Option A is not implementable in this environment**; no exception can lift a platform constraint.
- **C-12 (new P0):** the bypass detector is satisfiable by the party it audits. validate-crew compares COUNTS of Agent calls vs arbiter audit lines without correlating identity. The arbiter's two failed dispatches logged nothing (PostToolUse cannot fire for a tool that never ran), its two truthful lines took c 1→3 against d=3, and a true-positive FAIL flipped to PASS with nothing remediated. validate-crew now reads 27 PASS / 0 FAIL and that green is NOT trustworthy.
- **Self-inflicted, caught and fixed:** my first C-11 detector matched "RELEASE replaced by FALLBACK" and reported APPLIED for a failed fan-out. Now tests the mutation field via jq instead of grepping the file.
- **Arbiter conduct:** two dispatches, two correct FALLBACKs, zero fabrication under direct pressure to produce a packet; it surfaced C-12 against its own interest rather than banking the clean result.
- **Unresolved:** the global-vs-project shadowing of security-reviewer / quality-reviewer / fixer. Only a live dispatch settles it; for quality-reviewer the tool lists are identical, so vocabulary and effort are the only discriminators.
- **In-flight changes:** none.
- **Next action:** operator decision — Option A is off the table, so choose between Option B (orchestrator dispatches, arbiter normalises post-hoc) and a redesign; then fix C-12's correlation.

## [F3|2026-08-11T07:27:26Z] checkpoint — F3 COMPLETE, G-F3 gate-ready
- **Task:** F3 Core Bench. All five §6 steps plus the G-F3 demo and stress.
- **Workflow status:** validate-crew 27 PASS / 0 SKIP / 0 FAIL · run-crew-tests 87 total · corrections 11 APPLIED / 1 PENDING (C-13, F4-owned) / 2 SUPERSEDED · gate sims F0-F3 exit 0, F4 exit 1.
- **Demo:** lead-planner → orchestrator fan-out (EX-05) → security-reviewer ∥ quality-reviewer → arbiter normalise/recalibrate/quarantine/audit/release → fixer verdicts. 9 arbiter audit lines, 6 carrying the dispatch task_id.
- **Stress:** malformed packet quarantined with a precise FALLBACK and nothing silently dropped; direct uncovered dispatch flagged by the identity-correlated coverage check (twice — once against the orchestrator, once against fabricated fixture records).
- **Closed:** the global-vs-project shadowing question. Both reviewers reported PROJECT vocabularies via SELFCHECK. The same-named global agents do NOT shadow.
- **Open, all logged:** C-13 (F4) · branch B's 4 verified-sound findings await round 2 re-emission · DIRECTORY_GUIDE drift needs an operator routing decision because EX-01 pins it · the arbiter holds Write but not Edit, so appending to an append-only log means rewriting it whole (transcription risk in the arbiter contract itself).
- **In-flight changes:** none.
- **Next action:** STOP. Await `APPROVE GATE-F3`.

## [F3|2026-08-11T14:02:22Z] GATE G-F3 APPROVED — F4 opened
- **Task:** F3 closed on the exact token `APPROVE GATE-F3`. Tag `crew-f3`. **F4 — Router + Tier Lock [8K] now active.**
- **F4 steps (§6):** (1) write `.claude/skills/threshold-router/SKILL.md` per §5.3 — note QR-DG-3 found the map already lists this file while it is absent from disk, so F4 closes a live docs-drift finding as a side effect; (2) confirm the tier announcement across three probe prompts; (3) add a tier-announcement check to validate-crew (transcript sampling is manual-eyes at the gate).
- **MUST ALSO RESOLVE — C-13 (F4-owned, gate-enforced):** no hook inspects content bound for Plan.md/PROGRESS.md/context/*, while the Navigation rule says append anomaly text there then act. `./scripts/check-plan-corrections.sh F4` exits 1 until it lands. **Two operator decisions are required before it can be implemented:** block-vs-flag (a denying check aimed at Plan.md would block the Fix Ledger entries that quote findings verbatim), and provenance-vs-keywords (a keyword list would trip on C-13's own registry entry and on the §0.2d rule text).
- **Distilled:** `context/session-summary.md` refreshed per §15.6 — merged, superseded claims deleted, verified/proposed labels intact.
- **Budget note:** F3 ran ~87 min against the 45-min Q5 ceiling, driven by three unplanned P0s (C-11, C-12, C-14). F4 is budgeted 8K and should be comfortably inside it.
- **In-flight changes:** none.
- **Next action:** F4 step 1 — write the threshold-router SKILL.md. Per §0.3 (one phase = one session) a fresh session is preferred; the SessionStart hook re-grounds automatically.

## [F4|2026-08-12T02:30:51Z] checkpoint — F4 COMPLETE, G-F4 gate-ready
- **Task:** F4 — Router + Tier Lock. All three §6 steps plus C-13 (carried in from F3's deferral).
- **Workflow status:** validate-crew 34 PASS / 0 SKIP / 0 FAIL · run-crew-tests 99 total · corrections 12 APPLIED / 0 PENDING / 2 SUPERSEDED · gate sims F0-F4 all exit 0.
- **Delivered:** `.claude/skills/threshold-router/SKILL.md` (§5.3 verbatim, 0-line delta) · validate-crew tier-lock section (6 checks) · cases_F4 (12 checks: 5 provenance + 7 router/stress) · C-13 resolved as a provenance-based flag-only guard.
- **Closed by side effect:** QR-DG-3 — the map listed the router skill while it was absent; the claim is now true without editing a byte-pinned seed.
- **Demo evidence:** transcript — every response this session opened with the exact token, covering well over three consecutive operator prompts. Machine-checked separately: the token is present verbatim in the skill and in CLAUDE.md.
- **Stress evidence:** executable half green (lock clears in a scratch shell without touching project env; both router branches reachable; project env restored to T3). Residual is stated below.
- **In-flight changes:** none.
- **Next action:** STOP. Await `APPROVE GATE-F4`. On approval → F5 Gate & Ledger Protocolization, which owns `scripts/save-context.sh` — currently referenced by the map and by session-summary.md while absent from disk.

## [F4|2026-08-12T03:07:06Z] GATE G-F4 APPROVED — F5 opened
- **Task:** F4 closed on the exact token `APPROVE GATE-F4`. Tag `crew-f4`. **F5 — Gate & Ledger Protocolization [6K] now active.**
- **F5 steps (§6):** GATES.md ledger format {gate, iso, demo_result, stress_result, operator_token_line} · PROGRESS.md checkpoint-discipline section · wire the Stop-hook "GATE READY" message · create context/ with a seeded session-summary.md and `scripts/save-context.sh` implementing §15.5 distill-merge · from G-F5 onward distillation is a MANDATORY pre-gate-report step.
- **Already satisfied by earlier phases (0.2b — do not re-create):** GATES.md exists and already carries the five-column format with F0-F4 populated · PROGRESS.md checkpoints have been in continuous use since F0 · context/session-summary.md exists and has been distilled at each gate.
- **The real F5 gap:** `scripts/save-context.sh` does not exist, while DIRECTORY_GUIDE.md line 17 and context/session-summary.md both reference it. Same drift class as QR-DG-1/3/4. F5 owns closing it.
- **Also owed:** the Stop hook currently emits the gate-ledger decision-block but no "GATE READY" toast per §6 F5.
- **In-flight changes:** none.
- **Next action:** F5 step 1 — write `scripts/save-context.sh` (§15.5 distill-merge semantics), then the Stop-hook message, then the checkpoint-discipline section.

## [F4|2026-08-12T03:15:59Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 6 file(s) uncommitted
- **HEAD:** 9a8ce77
- **Next action:** see the tail of Plan.md and the newest snapshot in .claude/state/checkpoints/

## [F4|2026-08-12T03:17:30Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 8 file(s) uncommitted
- **HEAD:** 9a8ce77
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** see the tail of Plan.md and the newest snapshot in .claude/state/checkpoints/

## [F5|2026-08-12T03:18:24Z] checkpoint — F5 COMPLETE, G-F5 gate-ready
- **Task:** F5 — Gate & Ledger Protocolization. All §6 steps done; the pre-existing ledger/checkpoint machinery was NOT re-created per §0.2b.
- **Workflow status:** validate-crew 34 PASS / 0 SKIP / 0 FAIL · run-crew-tests 113 total · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · gate sims F0-F5 all exit 0 · save-context check 11 PASS / 0 FAIL.
- **Active artifact:** scripts/save-context.sh · hooks/stop.sh · hooks/pre-compact-checkpoint.sh · PROGRESS.md discipline section · cases_F5.
- **Open decisions:** DIRECTORY_GUIDE drift still needs an operator routing decision (byte-pinned under EX-01); G-F3 round-2 re-emission of the quarantined branch is still owed.
- **In-flight changes:** none.
- **Closed avenues:** rewriting session-summary.md from a script — rejected, §15.5 requires the merge judgement stay in-session.
- **Next action:** STOP. Await `APPROVE GATE-F5`. On approval → F6 Test Suite Consolidation (ETL lane §11.1; suite floor 28 incl. ccs-01/02/03).

## [F6|2026-08-12T06:39:34Z] checkpoint — F6 COMPLETE, G-F6 gate-ready
- **Task:** F6 — Test Suite Consolidation. ETL lane §11.1 corpus transform, ccs-02, mutation stress.
- **Workflow status:** validate-crew 36 PASS / 0 SKIP / 0 FAIL · run-crew-tests 131 total · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED (C-16 is enforced by a behavioural case in cases_F6, not a registry detector — the registry count is 13, not 14) · gate sims F0-F6 all exit 0.
- **Corpus:** the plan's "23-error corpus" reconciles as 12 (orchestration guide) + 11 (mermaid guide TROUBLESHOOTING). 17 assertions transformed against this repo's paths, zero verbatim reuse.
- **ccs-02 added** — it was a comment, not an assertion, though §6 F6 requires all three continuity checks. Now a real cold-start test against a mid-phase fixture.
- **Mutation stress 3/3 caught**, but M3 was initially caught only by the dirty-tree canary; C-16 closes that so it now fails by name.
- **In-flight changes:** none.
- **Next action:** STOP. Await `APPROVE GATE-F6`. On approval → F7 FINAL ORCHESTRATION STRESS TEST [200K, may span 2 sessions with mid-gate G-F7a].

## [F6|2026-08-13T05:42:38Z] GATE G-F6 APPROVED — F7 opened and immediately HELD (session-model conflict)
- **Task:** F6 closed on the exact token `APPROVE GATE-F6`. **F7 — FINAL ORCHESTRATION STRESS TEST [200K, may span 2 sessions, mid-gate G-F7a] is the active phase**, held before any work.
- **HOLD (HC-2 / CLAUDE.md non-negotiable):** the orchestrator session is running claude-fable-5 as of this turn — an interactive model override supersedes the settings pin until restart, and this repo forbids any fable model for any session. No F7 work was executed under the override.
- **Verified intact:** .claude/settings.json pins model opus / effort max / CREW_TIER_LOCK T3; agent stamps unchanged (4 opus / 4 sonnet); tree was clean at b655ad7 before this turn's ledger writes.
- **Workflow status:** suite 131 PASS / 0 FAIL · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED — all unchanged this turn (docs-only writes).
- **In-flight changes:** none.
- **Closed avenues:** running F7 from this session regardless — rejected, it would place the build's largest phase in breach of a hard constraint; §0.3's one-phase-one-session preference points at a fresh session anyway.
- **Next action:** operator relaunches Claude Code from the repo root — the pin restores Opus automatically and SessionStart re-grounds. Then F7 step 1: dispatch lead-planner for the JML-simulator plan (Pokémon overlay per Q4) and STOP at mid-gate G-F7a for plan approval.

## [F7|2026-08-13T05:48:36Z] HOLD LIFTED — F7 started
- **Task:** the HC-2 session-model conflict is resolved; the session is on Opus per the harness switch confirmation (HC-2 compliant, no forbidden substring). G-F6's approval was NOT re-recorded — the artifact exists (@ 2026-08-13T05:42:38Z) and §0.2b forbids re-running it.
- **Pre-flight verified:** pin opus/max/T3 · stamps 4 opus / 4 sonnet · validate-crew 36 PASS / 0 SKIP / 0 FAIL · suite 131 PASS / 0 FAIL · corrections 13 APPLIED / 0 PENDING · tree clean at 66fa12e.
- **stress-project/ is present but EMPTY** — an F0 mkdir scaffold declared at DIRECTORY_GUIDE.md:20, 0 tracked files, none of the F7 modules present. Nothing of F7 has executed.
- **Evidentiary limit, stated:** a session cannot introspect its own model. The basis is the harness switch confirmation plus the settings pin, not self-report — the same limit recorded for the tier announcement at G-F4.
- **In-flight changes:** none.
- **Next action:** F7 step 1 — dispatch lead-planner for the JML-simulator plan, then STOP at mid-gate G-F7a for operator plan approval. No build work before that token.

## [F7|2026-08-13T14:17:51Z] checkpoint — G-F7a READY (plan complete, build NOT started)
- **Task:** F7 step 1 done. lead-planner produced the JML Simulator plan; nothing has been built.
- **Workflow status:** validate-crew 36 PASS / 0 SKIP / 0 FAIL · suite 131 PASS / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · tree clean.
- **Active artifact:** the plan (in-session, released to the operator at this gate; arbiter release is step A0 and happens AFTER approval).
- **Open decisions:** C-17 — the mid-gate token is undefined by the plan and must be issued by the operator; recommended `APPROVE GATE-F7a`. C-18 RESOLVED pre-run: wall 45 min per session (breach → early gate), token denominator 207K.
- **In-flight changes:** none. stress-project/ still empty.
- **Closed avenues:** trimming A3/B5 to fit 200K — rejected by the operator in favour of the 7K overrun, because the trim would compress module build and round-2 discourse, the two places lead-planner flagged as least safe to squeeze.
- **Next action:** STOP. Await the operator's mid-gate token. On receipt → A0 (arbiter releases the plan under task_id F7-P1-jml-simulator-plan), then A1-A7 build.

## [F7|2026-08-13T14:50:30Z] checkpoint — A0 + A1 complete, Stage A released, A2 next
- **Task:** F7 Stage A. G-F7a approved @ 2026-08-13T14:39:23Z; arbiter released the plan at A0; A1 absorbed the release flags and re-measured Gate 0.
- **Workflow status (re-measured, not recalled):** validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · suite green once this step's edits are committed · stress-project/ still empty (0 entries).
- **Active artifact:** `context/f7-plan.md` — the approved plan plus an appended "A0 arbiter release — accepted amendments" section. The approved text is preserved as approved; amendments are visible as amendments.
- **Binding amendments carried into A2-B10:** F7 rounds go to `logs/rounds/f7-round-1|2/`, NEVER `round-1/` (two live detectors read that fixture and logs/ is gitignored) · D6 containment uses a working-tree scan, not `git grep` (0 tracked files pre-A7 makes it vacuous) · B2's seed check captures into a variable (`git grep -c` exits 1 on zero matches, so `= 0` fails on the success case) · A2's jq test must be exit **exactly 1** · A4 asserts the 18 case NAMES, not just a count · every A2-A6 dispatch carries `expected_output`.
- **Open decisions:** none blocking. C-17/C-18 resolved at the gate.
- **In-flight changes:** none after this commit.
- **Closed avenues:** routing F7 rounds into the existing `logs/rounds/round-1/` — rejected, it would clobber C-13's and F4's fixture with no git safety net.
- **Next action:** A2 — dispatch lead-executor (`task_id F7-A2-fixtures`, WITH expected_output) to scaffold `stress-project/`, write `package.json` and the six fixtures via Bash heredoc.

## [F7|2026-08-13T15:02:39Z] checkpoint — A2 COMPLETE, A3 next (session boundary recommended)
- **Task:** F7 Stage A. A0 release, A1 gate-0 + amendments, A2 scaffold/fixtures all complete.
- **Workflow status:** validate-crew 36 PASS / 0 SKIP / 0 FAIL · suite 131 PASS / 0 FAIL after this commit · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · gate sims F0-F6 exit 0.
- **Active artifact:** stress-project/ — package.json + 6 fixtures, 7 tracked files. src/, bin/, test/, README.md correctly absent.
- **Open decisions:** none blocking A3.
- **In-flight changes:** none.
- **Closed avenues:** C-14's word-matching pattern — replaced by an enumerated fixture-id set after it failed the F3 gate on the legitimate dispatch F7-A2-fixtures.
- **Carry into A3:** the amendments section of context/f7-plan.md is binding — D6 containment needs a WORKING-TREE scan (git grep sees 0 tracked files pre-A7 and passes vacuously); every dispatch carries expected_output; F7 rounds go to logs/rounds/f7-round-1|2/, never round-1/.
- **Next action:** A3 — dispatch lead-executor (`task_id F7-A3-modules`, with expected_output) to build the six src/ modules, two adapters and bin/jml.js. Budget 35K; if it exceeds 45K, checkpoint and split rather than compressing A4.

## [F7|2026-08-13T15:35:57Z] checkpoint — A3 COMPLETE, A4 next
- **Task:** F7 Stage A. A0-A3 done. 15 tracked files under stress-project/ (7 fixtures+config, 8 modules).
- **Workflow status:** validate-crew 36 PASS / 0 SKIP / 0 FAIL · suite 131 PASS / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · tree clean at a1e26b2.
- **Verified independently:** all three edge-case exit codes and artifact counts, both valid fixtures, determinism (falsifiable both ways), HC-5, D6 containment.
- **Open decisions:** two carried to B3 discourse — the unused OUTCOMES import in bin/jml.js, and the NONE-row asymmetry (MOVE parks, TERMINATE suspends anyway).
- **In-flight changes:** none.
- **Closed avenues:** the plan's `run --input` CLI form — corrected in context/f7-plan.md to the positional contract the CLI actually implements, before B9 could report three false edge-case failures.
- **Next action:** A4 — dispatch lead-executor (`task_id F7-A4-tests`, with expected_output) for the 18-case suite. Assert the 18 case NAMES, not just a count (amendment 7), and capture `node --test` output into a variable before testing it (amendment 3).

## [F7|2026-08-13T16:12:23Z] checkpoint — A4 COMPLETE, A5 next
- **Task:** F7 Stage A. A0-A4 done. 21 tracked files under stress-project/ (7 fixtures+config, 8 modules, 6 tests).
- **Workflow status:** app suite 18 PASS / 0 FAIL (`# pass 18` / `# fail 0`, TAP) · crew suite and validate-crew unchanged this step (test-only + one package.json line) · tree clean after this commit.
- **Verified independently:** the 18 case names set-diffed against the contract (empty both directions, not a count) · two consecutive runs identical · tmp/ empty before and after · no ignored artifacts anywhere · HC-5 14 import specifiers all node:/relative.
- **Defect fixed:** `node --test test/` does not run on Node v24.14.0 — --test positionals are globs and a bare directory is loaded as a module (MODULE_NOT_FOUND, 0 cases executed). package.json's test script is now `node --test 'test/**/*.test.js'`; `npm test` exits 0 with 18/0. A6 must not revert to the directory form.
- **A3 limit closed:** dedupe independence is now bound by mutation, not by reading — disabling the fingerprint branch fails exactly one case by name; src/intake.js restored byte-identical to HEAD.
- **In-flight changes:** none.
- **Open decisions:** unchanged — the unused OUTCOMES import in bin/jml.js and the NONE-row asymmetry both still carried to B3 discourse. No test constrains the NONE+TERMINATE verdict either way.
- **Next action:** A5 — dispatch lead-executor (`task_id F7-A5-readme`, with expected_output) for stress-project/README.md. Tests are done; do NOT let A5 or A6 revert the runner invocation to `node --test test/`.

## [F7|2026-08-13T16:17:54Z] checkpoint — A4 COMPLETE, A5 next
- **Task:** F7 Stage A. A0-A4 done. 21 tracked files under stress-project/.
- **Workflow status:** app suite 18 PASS / 0 FAIL (TAP-verified, names set-diffed) · crew suite 131 PASS / 0 FAIL after this commit · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 0 PENDING.
- **Active artifact:** stress-project/test/ — six files, 18 named cases, 9 failure paths.
- **Open decisions:** two still carried to B3 — the unused OUTCOMES import in bin/jml.js, and the NONE-row asymmetry (MOVE parks, TERMINATE suspends anyway).
- **In-flight changes:** none.
- **Closed avenues:** `node --test test/` as the test command — it runs zero cases on Node v24 and exits 1; the working form is `node --test 'test/**/*.test.js'`, quoted. Do not revert it. Also closed: storing a token-shaped literal in a tracked test file, on a public repo.
- **Next action:** A5 — dispatch lead-executor (`task_id F7-A5-readme`, with expected_output) for README.md plus the GitHub-native mermaid sequence diagram. Assert: even fence count, block contains sequenceDiagram with >=4 participant and >=6 arrows, and NO local renderer binary is invoked anywhere (HC-5).

## [F7|2026-08-13T17:06:23Z] checkpoint — STAGE A COMPLETE, split point, Stage B next
- **Task:** F7 Stage A (A0-A7) complete. The JML Simulator is built, tested, documented and bound to the crew harness.
- **Workflow status:** crew suite 144 PASS / 0 FAIL · app suite 18 PASS / 0 FAIL · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED · 22 tracked files under stress-project/.
- **Active artifact:** stress-project/ — 8 modules, 6 fixtures, 6 test files with 18 named cases, README with a GitHub-native mermaid sequenceDiagram (8 participants, 14 arrows), package.json with zero dependencies.
- **Open decisions:** OUTCOMES dead import in bin/jml.js · the NONE-row asymmetry (MOVE parks, TERMINATE suspends) · mover-squirtle has no HIRE so no runnable replay demo exists. All three are B3 discourse material, deliberately not fixed silently.
- **In-flight changes:** none.
- **Closed avenues:** `node --test test/` (runs zero cases on Node v24) · storing a token-shaped literal in a tracked file on a public repo · routing F7 rounds into logs/rounds/round-1/ where two live detectors read their fixture.
- **Next action:** B1 — re-ground per §15.4, then B2: seed three bugs with the manifest written to the SCRATCHPAD, never the repo. Full step table in context/f7-plan.md, whose amendment sections supersede the tables above them.

## [F7|2026-08-13T18:02:16Z] checkpoint — B1 + B2 complete, discourse next (TREE DELIBERATELY DIRTY)
- **Task:** B1 re-grounded from disk (all four §15.4 reads agree). B2 seeded three defects.
- **Seed state, no locations recorded here by design:** 3 seeds live as UNCOMMITTED working-tree edits. 1 is test-visible (the control, proving the suite is load-bearing); 2 are invisible to all 18 app cases AND to cases_F7, so Robustness depends on the discourse finding them rather than passing for free. Manifest is in the session scratchpad, OUTSIDE the repo — if reviewers could read it, Robustness would measure nothing.
- **Seeds are NOT committed**, deliberately: committing puts the answer key in git history on a public repo, where `git show` on that commit reveals exactly what to find.
- **EXPECTED RED, do not treat as regression:** while seeds are live, cases_F0's clean-tree check fails (tree is intentionally dirty) and the F7 app-suite + case-name assertions fail (seed A breaks terminate-twice-is-idempotent). Recorded in advance so the red is explained rather than mysterious. Baseline before seeding was 144 PASS / 0 FAIL, 18/18 app, clean tree at fbcbc1f — so every red is attributable.
- **First seed set was DISCARDED:** all three landed on covered paths and were caught by tests. The plan requires at least one invisible seed or the discourse is never exercised — "re-seed rather than accept". Root cause: invisibility was judged from test NAMES rather than test BODIES.
- **In-flight changes:** 3 seeded source files, uncommitted.
- **Next action:** B3 — dispatch security-reviewer and quality-reviewer IN PARALLEL (task_ids F7-B3-sec / F7-B3-qual, each with expected_output). Reviewers are NOT told seeds exist; that is the honest measurement. Artifacts to logs/rounds/f7-round-1/, never round-1/.

## [F7|2026-08-13T18:48:29Z] checkpoint — B5 complete, B6 next (seeds still live, tree deliberately dirty)
- **Task:** F7 Stage B. B1-B5 done. Round 2 discourse complete; exactly two rounds, as §5.4 requires.
- **Workflow status:** round-1 packets 11 findings, round-2 packets 15 entries (7 AGREE / 1 CHALLENGE / 5 CONNECT / 2 SURFACE), all in logs/rounds/f7-round-1|2/. arbiter-audit carries F7-P1, F7-B4-compile1.
- **Open decisions for B6:** the arbiter must rule on a defended CHALLENGE against its OWN P0->P1 downgrade of sec-2, with both branches now agreeing from newly-read adapter source. Two P0s remain open, and §0.2c blocks a gate PASS while they are.
- **BINDING SEQUENCING for B7:** QUAL-01 must not be fixed in isolation ahead of sec-2/QUAL-06 — it is currently the only remaining path back to iam.apply() for a stranded account, so fixing it alone removes the last accidental recovery path. This is the fixer's most important constraint and it came out of round 2, not round 1.
- **In-flight changes:** 3 seeded source files, still uncommitted; 0 seed commits in history.
- **Next action:** B6 — dispatch arbiter (task_id F7-B6-compile2, with expected_output) to compile round 2, apply confidence arithmetic, drop undefended challenges, and RELEASE to the fixer.

## [F7|2026-08-13T21:35:08Z] checkpoint — B6 + B7 complete (closing a stale anchor the arbiter caught)
- **Task:** F7 Stage B. B6 compiled round 2 and released; B7 applied all 11 fixes. This checkpoint also closes a §15.4 staleness the arbiter flagged: PROGRESS.md had not been checkpointed across B6 or B7, so a compaction would have lost two completed steps.
- **Workflow status:** app suite 18 PASS / 0 FAIL · crew suite 143 PASS / 1 FAIL (dirty-tree canary only, cleared by this commit) · validate-crew 36 PASS / 0 SKIP / 0 FAIL incl. dispatch coverage · corrections 13 APPLIED / 1 PENDING (C-19, F8-owned) / 2 SUPERSEDED.
- **Verdicts:** 11 ACCEPT, 0 REJECT, 0 DEFER, nothing reverted. All four open P0s closed by applied fixes.
- **Active artifact:** stress-project/ — src, bin and test all modified by the fixer; seeds gone, leaving no trace.
- **Open decisions:** none blocking. C-19 is F8-owned by design.
- **In-flight changes:** none after this commit.
- **Closed avenues:** repairing the coverage red by writing a line (the fixer refused, correctly); leaving retrospective coverage unlabelled (the arbiter refused, correctly).
- **Next action:** B8 — dispatch test-runner (task_id F7-B8-tests, with expected_output) for OBSERVED suite evidence. The arbiter released B7 without running anything and said so; B8 owns execution.

## [F7|2026-08-13T23:24:01Z] checkpoint — B8 + B9 complete (closing the ledger lag B9 surfaced)
- **Task:** F7 Stage B. B8 independent execution, B9 live e2e. This checkpoint closes the same §15.4 lag the arbiter flagged at B7 and integration-runner flagged again at B9 — my bookkeeping trailing the work by two steps, three times now.
- **B8 OBSERVED (test-runner, not orchestrator numbers):** app suite 18/18 exit 0 with the per-case list · crew suite 144 PASS / 0 FAIL · F7-only 13/13 · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections F0-F7 exit 0, F8 exit 1 (C-19 by design) · save-context 14 PASS / 0 FAIL · tree clean.
- **B9 OBSERVED (integration-runner):** 7/7 scripted runs matched exactly, zero FALLBACKs. DEMO leaver exit 0 with the 4-stage trail and JML-0001 Done. EDGE 1 duplicate exit 0, one DUPLICATE line, exactly one ticket. EDGE 2 park exit 1, PARKED, D5 fallback at confidence 0.25. EDGE 3 malformed exit 2, six D5 keys verified programmatically, one audit line, no ticket or notification directory created at all. RETRY A1 failed suspend exit 1 with state rolled back to employees={} and the failure indexed; A2 redelivery RE-PROCESSED with detail "retry of a failed attempt, matched by event_id", JML-0002 Done, indexes cleared; A3 negative control redelivery-after-success still DUPLICATE with no new ticket.
- **Judgement call it made well:** it used a distinct --seed per retry invocation because clock.js derives ids from sha256(seed:prefix:n) with a per-process counter reset, so one seed across three runs would have collided notification filenames and silently overwritten its own evidence.
- **In-flight changes:** none; runtime output confined to the gitignored stress-project/tmp/.
- **Next action:** arbiter coverage for F7-B8-tests and F7-B9-e2e, then B10 — metrics to logs/metrics/f7.json, the D7 mirror into the GATES.md row, seed disclosure, §12 self-check, and the §10 gate report for G-F7b.

## [F7|2026-08-13T23:39:31Z] checkpoint — B10 COMPLETE, G-F7b gate-ready with one rubric FAIL
- **Task:** F7 Stage B complete. B10 metrics, seed disclosure, §12 self-check, rubric roll-up.
- **Workflow status:** crew suite 144 PASS / 0 FAIL · app suite 18/18 · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 1 PENDING (C-19, F8-owned) / 2 SUPERSEDED · tree clean.
- **§7 rubric: 6 of 7 PASS, 1 FAIL.** PASS — tests 18/18 · seeded 3/3 with two invisible to every test · edges 3/3 · agents 8/8 bound to named artifacts · post-review defects 0 · arbiter lines 19 >= 18 dispatches. FAIL — token spend 1,922,184 subagent tokens against the 207K denominator fixed pre-run, 9.3x over and a strict lower bound since orchestrator spend is unmeasurable from inside the session.
- **§6 axes:** Depth PASS · Breadth PASS · Robustness PASS · **Velocity FAIL**. §6 states any fail goes to a gap register, fix loop and re-gate — that is an operator decision, not mine to waive.
- **Open decisions:** the operator's call on the Velocity FAIL. Zero open P0s, so §0.2c does not independently block.
- **In-flight changes:** none.
- **Next action:** STOP. Await the operator's ruling on G-F7b and the exact token, which the plan does not define (C-17 applies to G-F7b as it did to G-F7a).

## [F7|2026-08-14T00:47:43Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 1 file(s) uncommitted
- **HEAD:** 42364c6
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** STOP. Await the operator's ruling on G-F7b and the exact token, which the plan does not define (C-17 applies to G-F7b as it did to G-F7a).

## CHECKPOINT 2026-08-14T00:50:58Z — F7 Velocity resolved, G-F7b ready
- **Operator ruling (option A)**: Q5's ceiling is a gate TRIGGER, not a pass/fail bar — the same reading the operator applied to the wall-clock limb at G-F7a, now applied consistently to the token limb. Velocity **PASS by trigger**. §7 is 7 of 7; §6 Depth/Breadth/Robustness/Velocity all PASS.
- **Not a waiver**: 1,922,184 subagent tokens at 9.3x the 207K denominator stands recorded, and it is a strict lower bound (excludes one unreported dispatch and all orchestrator tokens).
- **C-20 registered and left PENDING, F8-owned**: the axis was unsatisfiable by construction — 18 mandated dispatches x 46,388 cheapest-observed = 834,984, still 4.0x the denominator at best. Detector added to check-plan-corrections.sh; closes only when context/budget-baseline.md records measured per-dispatch cost. F8 exit=1 until then, by design.
- **Evidence made durable**: logs/ is gitignored, so the rubric roll-up would not have survived a clone. Mirrored to the tracked context/f7-metrics.md, limits and both audit-coverage readings included.
- Suite 144 PASS / 0 FAIL · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 2 PENDING / 2 SUPERSEDED.
- **Next action:** STOP. Present the G-F7b gate report and await the operator's token. The plan defines no G-F7b token (C-17 applies as it did to G-F7a); the ledger is prepared for `APPROVE GATE-F7b`.

## CHECKPOINT 2026-08-14T00:56:07Z — G-F7b APPROVED, F8 OPEN
- Operator token `APPROVE GATE-F7b` received @ 2026-08-14T00:56:07Z (one prior attempt was a typo, `APPROVR`, and was correctly refused — exact-token rule held).
- **F7 CLOSED.** §7 rubric 7/7, §6 all four axes PASS, 0 open P0. Tag `crew-f7`.
- **F8 OPEN — Audit & Handover [plan L311-313].** Steps: gap register closure · final validate+tests · repo README (operator quickstart = clone + scripts/setup.sh + auth note) · tag v1.0.0 · push · ROADMAP.md stub with the Q6 domain order. Gate demo: fresh-clone drill in a temp dir with setup.sh green (portability proof). Stress: no absolute home paths in tracked files. Token `APPROVE GATE-F8` closes the plan.
- **Next action:** F8 step 1 — inventory the gap register (C-19, C-20, G-F3 owed re-emission, DIRECTORY_GUIDE drift) and confirm whether scripts/setup.sh exists, since the gate demo depends on it.

## CHECKPOINT 2026-08-14T01:17:15Z — F8 deliverables written
- **Gap register CLOSED.** C-19 root-caused to the arbiter's audit schema having no timestamp FORMAT (date-only ts, unorderable against full-ISO dispatch records); fixed at writer and validator, F0-F7 grandfathered by enumeration. C-20 closed by the operator's option-A ruling plus a measured baseline. C-21 opened and closed: the per-dispatch measurement underpinning every Velocity number was never persisted to disk. **F7 spend corrected to 2,045,319 across 18 dispatches (9.88x)** — the recovered dispatch was arbiter/F7-P1 at 123,135.
- **C-22** — the plan's G-F8 demo mandates a fresh-clone drill that this build's own HC-5 deny-list blocks. Guard NOT widened; scripts/portability-drill.sh proves the same property by git archive (stricter: tracked bytes only, no .git, no local config) plus a detached worktree (keeps .git so repo-dependent assertions run). Cost two real incidents: a denied Bash call silently discarded a git commit sharing its command line, and the guard fired again on the prose documenting it.
- **C-23** — validate-crew's absolute-path assertion, the exact check the G-F8 stress names, tested [ -d .git ] and therefore SKIPPED silently in a worktree (.git is a file there) while reporting "git not initialized yet". Tenth instance of the proxy-binding family and the worst-shaped: a plausible reason for not checking, in the context where checking mattered most. Now asks git; verified three ways; the drill asserts it ran.
- **New deliverables**: scripts/setup.sh (toolchain, runtime dirs, exec bits, model stamp, validation, app suite — installs nothing, idempotent), scripts/portability-drill.sh, scripts/measure-dispatch-cost.sh, README.md (operator quickstart + honest not-proven section), ROADMAP.md (Q6 order IAM to Compliance to HR-lifecycle to ITSM to rest, dormant lanes, open decisions), context/budget-baseline.md.
- Suite 144 PASS / 0 FAIL · validate-crew 37 PASS / 0 SKIP / 0 FAIL · app suite 18/18 · corrections 18 APPLIED / 0 PENDING · drill PORTABLE.
- **Next action:** final verification sweep, tag v1.0.0, push, then present the G-F8 gate report and await `APPROVE GATE-F8`, which closes the plan.

## CHECKPOINT 2026-08-14T01:19:37Z — F8 COMPLETE, G-F8 READY
- All six F8 steps done: gap register closed (C-19, C-20, C-21, C-22, C-23) · final validate+tests green · README.md operator quickstart · **tag v1.0.0 pushed** · ROADMAP.md with the Q6 order.
- G-F8 demo GREEN by two mechanisms (C-22): git archive extract of all 74 tracked files, and a detached worktree where the absolute-path assertion is confirmed to RUN rather than skip. setup.sh exits 0 in both and leaves the worktree byte-clean.
- G-F8 stress GREEN: no absolute machine paths in tracked files outside the byte-pinned execution authority.
- §12 self-check complete: HC-1 T3 · HC-2 clean (line-based scan; the naive filename-based form reproduces the OQ-6 defect and false-positives on the forbidden_substrings declaration) · HC-3 4 opus / 4 sonnet matching the policy table · HC-4 apply-models re-run leaves 0 dirty · HC-5 zero node_modules, zero declared deps.
- context/session-summary.md distilled to final state per §15.5/§15.6.
- **Next action:** STOP. Await `APPROVE GATE-F8`, which closes the plan. After approval: tag crew-f8. Merging to main requires the approved gate and has NOT been done.

## CHECKPOINT 2026-08-14T01:54:54Z — G-F8 APPROVED · PLAN CLOSED
- Operator token `APPROVE GATE-F8` received @ 2026-08-14T01:54:54Z. **The MASTER_FIFO_PLAN is closed.** All nine phases F0-F8 complete and gated.
- Final state: crew suite 144 PASS / 0 FAIL · validate-crew 37 PASS / 0 SKIP / 0 FAIL · app suite 18/18 · corrections 18 APPLIED / 0 PENDING / 2 SUPERSEDED · portability drill PORTABLE · 74 tracked files.
- Tags: crew-f0..crew-f8, v1.0.0 moved to the final commit per the gate report.
- **main NOT touched.** The project rule permits pushing main only with an approved gate; the gate is now approved, but the plan's F8 text says "push" without specifying a merge, so that remains an operator call.
- **Next action:** none pending. The build is complete. Open items carried past v1.0.0 are listed in ROADMAP.md and context/session-summary.md.

## CHECKPOINT 2026-08-14T01:58:11Z — branch decision settled; project closed
- Operator accepted the recommendation: **leave the branch layout as is.** No `main` branch exists or will be created. `dev` is the remote default; `v1.0.0` marks the release. This is a decision, not an omission — do not create `main` in a later session on the assumption it was forgotten.
- Nothing else outstanding. Final: 144 crew / 37 validate / 18 app · corrections 18 APPLIED / 0 PENDING · 10 gates approved · drill PORTABLE · tree clean, synced.
- **Next action:** none. The build is complete and handed over.

## [F7|2026-08-17T04:01:19Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 1 file(s) uncommitted
- **HEAD:** a7bc87c
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** none. The build is complete and handed over.

## CHECKPOINT 2026-08-17T04:22:31Z — AUDIT A0 baseline measured, awaiting gate
- **Session type:** AUDIT-ONLY. Inspect, measure, adjudicate. No fix, refactor or implementation; every improvement becomes a numbered CR in docs/audit/CHANGE_REQUESTS.md gated for a later session.
- **Baseline (measured, not assumed):** validate-crew 37 PASS / 0 SKIP / 0 FAIL · crew 144 PASS / 0 FAIL · save-context 20 PASS / 0 FAIL · stress 18 declared = 18 ran (set difference non-vacuous, negative-controlled) · corrections 20 rows = 18 APPLIED / 0 PENDING / 2 SUPERSEDED.
- **Deviation from the brief:** corrections expected 23, measured 20. Traced to this repo's own G-F8 closing entry, which counted by highest ID rather than by entry. Recorded as A0-F1.
- **Findings so far:** A0-F1 registry three-way asymmetry (P2) · A0-F2 rebrand guard scans the two directories with zero hits (P2) · A0-F3 distilled entry point conflates two adjacent ledger events, and the distillation checker verifies hygiene not fidelity (P3).
- **Write boundary honoured:** two non-behavioural commits (PreCompact checkpoint; ignore-rule glob so ReportforClaudeWeb_2.txt cannot be staged into a public repo). models.config.json byte-identical before and after every suite. Stage-everything probe stages 0 paths.
- **Next action:** await the exact token `APPROVE AUDIT-GATE-A0`. On approval, A1 (diagram audit) and A2 (decision audit) run back-to-back to the A3 gate.

## CHECKPOINT 2026-08-17T04:46:29Z — AUDIT A3 complete, awaiting gate
- **Findings A3-F1..A3-F9.** Six proven with executed negative controls rather than argued. One (A3-F9, PostToolUseFailure) raised at A2 and REFUTED here by three independent sources.
- **Severity:** five P2 (evidence integrity, stale-phase self-reinforcement, count-bound permission assertion, inverted tools-line failure mode, REPLAYED unreachable) · three P3 · one refuted.
- **Execution:** portability drill PORTABLE at 77 tracked files, both mechanisms, C-23 assertion confirmed running. Stress e2e verified every README claim except the replay path.
- **Suites:** validate-crew 37/0/0 · crew 144/0 after commit · corrections 20 rows unchanged.
- **Next action:** await the exact token `APPROVE AUDIT-GATE-A3`. On approval, A4 (flow + the four owed findings) runs to the A5 gate.
