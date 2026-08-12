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
