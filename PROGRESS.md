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

**After a gated commit lands (added at CLEANUP-1, closing audit item R2-03):** append a one-line
post-commit checkpoint refreshing **Next action** to the genuinely next step. The close ritual
commits the awaiting-token checkpoint, so without this line the newest recorded next action
describes an already-completed step until the next phase's first checkpoint — and §15.4's cold
reader plus the PreCompact carry-forward (C-15) both faithfully propagate that stale pointer.


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

## CHECKPOINT 2026-08-17T05:41:35Z — AUDIT COMPLETE, awaiting final gate
- **All five phases done.** A0 baseline · A1 diagrams · A2 decisions · A3 code · A4 flow + four owed findings · A5 optimization/gaps/conformance.
- **Findings:** 1 P1 (A2-F2, the C-12 detector satisfied by comments) · 13 P2 · 8 P3 · 1 raised then REFUTED on evidence (PostToolUseFailure is real).
- **Backlog:** CR-001..CR-031 in docs/audit/CHANGE_REQUESTS.md, priced with effort/risk/value and gate flags. Top three by value: CR-009, CR-024, CR-013 — all under an hour, none touching a permission boundary.
- **Owed findings closed:** the four quarantined G-F3 branch-B findings adjudicated after five days. Three ACCEPT, one REJECT, anchors quoted into docs/audit/ because logs/ is gitignored.
- **Conformance:** HC-7 clean · plan byte-pin intact (1 commit ever) · zero deps · deny/allow lists untouched · suites at the A0 baseline.
- **Nothing was fixed.** Six tracked audit documents plus one gitignored distillation. Fixes begin only on approval of specific CRs at a future gate.
- **Next action:** await the exact token `APPROVE AUDIT-GATE-A5`.

## CHECKPOINT 2026-08-17T05:50:43Z — AUDIT-GATE-A5 APPROVED, AUDIT CLOSED
- **Three audit gates approved:** A0, A3, A5. All five phases complete.
- **Product:** 31 findings and 31 priced change requests in docs/audit/. **Nothing was fixed.**
- **Blocked on an operator decision, not on work:** CR-023, the DIRECTORY_GUIDE routing decision. Three accepted findings from G-F3 have waited on it since 2026-08-11.
- **Highest-value work available:** CR-009, CR-024, CR-013 — each restores a control that currently reports green while testing nothing; each under an hour; none touches a permission boundary.
- **Next action:** none. Await operator approval of specific CRs before any fix session begins. Do not implement a CR without that approval — the separation between finding and fixing is what makes the findings trustworthy.

## CHECKPOINT 2026-08-17T06:32:45Z — S1 commit 1a, 5 of 11 complete (early gate, Q5 wall)
- **Applied, each with its negative control demonstrated:** CR-009 · CR-024 · CR-013 · CR-015 · CR-019. Every one shows the control failing under the old predicate and passing under the new.
- **Next CR: CR-016** — scripts/run-crew-tests.sh, the read-only agent check: capture the tools line into a variable so a file with NO tools line fails explicitly instead of reporting "is read-only". Then CR-010, CR-030, CR-021, PR-F2, then commit 1a.
- **Registered, not fixed (2):** the C-14 detector extension to build-errors.jsonl must land in commit 2 after CR-012's redaction or the suite goes red — same ordering shape as CR-032, which the plan already moved. CR-033 (audit line-number citations off by +6) still open.
- **Self-inflicted, caught and fixed in step:** a comment I wrote for CR-015 spelled out the HC-5 verb set as a contiguous literal, which denies any command quoting that region. Rewritten to describe rather than spell. Third live instance of that family in this project's work.
- **Tree is intentionally dirty mid-batch;** the dirty-tree canary fails until commit 1a lands. No commit yet, by design.
- **Next action:** resume at CR-016. Nothing is blocked.

## CHECKPOINT 2026-08-17T07:10:01Z — S1 / CR-BATCH-1 COMPLETE, awaiting gate
- **Three commits:** 39ce1c1 eleven controls restored · c6c4f65 phase derivation isolated · 561013f figures corrected, registry completed, fidelity check added.
- **Nineteen CRs applied**, every one with its negative control executed. CR-009 · 024 · 013 · 015 · 019 · 016 · 010 · 030 · 021 · PR-F2 · 014 · 031 · 018 · 007 · 011 · 032/C-24 · 012 · C-14 extension · PR-F1.
- **Suites:** validate-crew 40/0/0 · run-crew-tests 147/0 · save-context 21/0 · corrections 21 rows / 24 registered IDs · stress 18/18 · drill PORTABLE · probe 0 paths · 82 tracked.
- **Every count delta attributed to a named CR.** No unexplained movement.
- **Registered, not fixed:** CR-033 (the audit's line-number citations, now stale again because this batch moved those lines — the fix is to replace them with content anchors, which is the audit's own lesson applied to its prose).
- **Not pushed.** Commits are local pending the gate token.
- **Next action:** await the exact token `APPROVE CR-BATCH-1`. On approval: push to dev. Then S2 (CR-025 + CR-022, permission boundary, own gate) awaits ruling R1-R3 and the operator's v3.0.1 §5.2.2 wording correction.

## CHECKPOINT 2026-08-19T07:24:40Z — S2 complete, awaiting the enforcement gate
- **Plan v3.0.1 verified before anything else:** diff is exactly the three expected changes; §4 payloads byte-identical; seed deltas 0/0/0.
- **CR-025 rescoped and applied.** Attribution + detection-at-creation + failed-dispatch coverage. **Prevention at the call is not implemented and not claimed** — SubagentStart cannot block. Five premise sites corrected to match.
- **CR-022 applied, flag-only.** Over-cap fenced blocks flag; nothing ever denies.
- **A C-12 hazard was found and closed in the same change:** FLAG lines in the arbiter trail would have let a hook satisfy the arbiter's own coverage obligation. Both correlations now exclude `event:FLAG` by field.
- **Counts:** validate-crew 42 PASS / 1 SKIP (43 total) · run-crew-tests 151 PASS + the dirty-tree canary (152 total) · save-context 21 · corrections 22 rows · stress 18/18. Every delta attributed.
- **The one SKIP is honest:** C-25's correlation has no live trail yet because no subagent has been dispatched this session. Its behavioural detector in the registry does exercise it.
- **Registered, not fixed:** CR-034 — the distilled summary carries pre-S1 numbers and a self-contradicting open-items list.
- **Nothing committed.** The whole session is one gate because it touches the enforcement layer.
- **Next action:** await the exact token `APPROVE CR-025`. On approval: one commit including the v3.0.1 plan, then push to dev.

## CHECKPOINT 2026-08-19T08:14:49Z — ruling R1d recorded, awaiting token
- **R1d supersedes C1b.** Bash-native permanently; Windows via WSL2 only. READ FIRST Additions #1-2 excluded-with-why.
- **Docs-only.** Four files: the rulings register (appended, C1b verbatim), ROADMAP.md, docs/audit/CHANGE_REQUESTS.md (CR-027 facts corrected), Plan.md. **PLATFORM_GAP_POWERSHELL.md untouched by instruction** — it is the evidence.
- **Suites unchanged as predicted:** 42+1SKIP / 152 / 21 / 22 rows / 18-18. Nothing touched a script, hook, settings.json or agent body.
- **Two disclosures:** the ROADMAP item to be marked SUPERSEDED did not exist, so the exclusion was recorded in the correct section with the absence stated; and R2a/R3a were recorded beyond the enumerated five, per HC-8.
- **Registered, not fixed:** two ROADMAP entries are stale in the CR-034 class — the DIRECTORY_GUIDE item still calls the map byte-pinned under EX-01, and the G-F3 item still reads "still owed" though A4 adjudicated all four.
- **Next action:** await the exact token `APPROVE R1D`, then one commit and push to dev.

## CHECKPOINT 2026-08-19T08:40:11Z — S3 complete, awaiting gate
- **Four diagrams delivered per R2a:** CR-001 (dispatch flowchart corrected) · CR-002 (gate FSM) · CR-004 (§15 continuity) · CR-005 (JML state machine). CR-003 and CR-006 deferred as ruled.
- **Plus a structural validator** over every fenced block in tracked markdown, controlled four ways. It checks well-formed, **never true** — accuracy stays a review obligation and the limit is stated in the code.
- **CR-024 caught my own drift:** the validator as a tenth script broke the map-vs-tree assertion, so it moved inline. The map is the §4.3 payload at delta 0 and can only change by operator re-export.
- **The F7 mermaid assertion was corrected** from exactly-one-block to a floor, because CR-005 legitimately broke it. Control: removing the sequenceDiagram still fails.
- **Counts:** run-crew-tests 152 → 153 (+1). Everything else unchanged; no script added, no hook, no settings, no agent body.
- **Next action:** await the exact token `APPROVE CR-DIAGRAMS`, then one commit and push to dev.

## CHECKPOINT 2026-08-19T09:05:58Z — S4 complete, awaiting gate
- **CR-026** intake layer at the mapped path, R3a hybrid. Classifier is a parseable table the suite exercises; behaviour that is model-interpreted is written as four manual drills in the skill and labelled as such.
- **CR-017** REPLAYED **proven live** — was unreachable, not merely undemonstrated. New fixture drains the parked lot; control confirms removing it fails.
- **CR-034** summary repaired, after demonstrating the extended C-24 failing against it (80 claimed vs 84 actual). C-24 now binds three claims instead of one.
- **CR-033** registered and deferred on a reframing: a blanket re-anchor would rewrite three historical audit records. The registration itself closes the §15.1 breach.
- **Counts:** run-crew-tests 153 → 158 · save-context 21 → 23 · tracked 84 → 86. Everything else unchanged, all attributed.
- **Disclosed:** the tree carried a second modified file (DIRECTORY_GUIDE.md) which is the plan's own §4.3 payload at delta 0 — reported, not treated as a stop.
- **Next action:** await the exact token `APPROVE CR-026`, then one commit and push to dev.

## CHECKPOINT 2026-08-19T15:35:23Z — CR backlog frozen until S6
- **Operator decision:** no CR is proposed for action until the S6 planning session completes. No CR gates.
- **Still in force:** discoveries are registered as they are found (§15.1). The freeze is on doing, not on recording.
- **Next action:** S6 — the planning session. gastown deep dive first (D1a), then oh-my-claudecode and ruflo, then the Psychic-Crew-Lite Master FIFO Plan (B1a/B2a/B3a/B4b) with CR-028 seams and CR-029 capability classes folded into its config design.

## CHECKPOINT 2026-08-19T15:39:18Z — S6a complete (gastown), early gate at the Q5 wall
- **gastown read targeted, not whole:** Project-Explorer named six files, so ~30KB was read against a 4.3M-token repo. The map paid for itself.
- **Three mechanisms confirmed** this build lacks: stall detection (with a documented false-escalation incident and the rule "never declare an agent stuck from a single store"), a watchdog chain where something watches the watchdog, and Seance — a successor querying its predecessor's event log instead of inheriting a summary.
- **Two further ideas the map had not extracted:** NDI (nondeterministic idempotence) as a named philosophy, and universal hierarchical attribution — half of which C-25 already landed at S2, and whose git-authorship half is **rejected** against the operator's standing identity rule.
- **One deliberate non-adoption:** GUPP/propulsion is the philosophical opposite of a gated build and stays out, but its enabler — agents discovering their own state rather than being briefed — is §15.4 and belongs in Lite.
- **Next action:** S6b — oh-my-claudecode and ruflo dives, then S6c the Psychic-Crew-Lite FIFO plan. Nothing is blocked.
- **Note for S6c:** Lite's plan output will be **local and gitignored**, like Project-Explorer.md, because DIRECTORY_GUIDE.md is byte-pinned to plan v3.1 and a new tracked file it does not name is the drift QR-DG-4 recorded. Tracking it needs an operator re-export.

## CHECKPOINT 2026-08-20T00:14:40Z — S6b complete (oh-my-claudecode, ruflo)
- **Both read targeted per the map.** OMC: the staged loop is F7's, run per-task on demand rather than per-phase behind a gate. ruflo: the map said read it only for swarm topology and warned off general orchestration — correct, but it misses `verification/` entirely.
- **The find:** ruflo's three-layer regression protection — smoke tests, a cryptographic witness manifest attesting each documented fix's load-bearing code is still present, and a temporal history for bisecting. Motivated by three regressions that passed unit tests and still broke users.
- **Why it lands here:** plan-corrections.md + its checker IS a hand-rolled witness manifest, and the audit found two detectors attesting nothing. This build has layer 1, a weak layer 2, and no layer 3 at all.
- **Registered as a [V?]:** OMC states Claude Code 2.1.178+ removed native team creation and that an experimental flag gives each session one implicit team. Consistent with EX-05 as restated, but the flag's effect on that premise is unverified here.
- **Next action:** S6c — the Psychic-Crew-Lite FIFO plan, folding in B1a/B2a/B3a/B4b, CR-028 seams, CR-029 capability classes, and the verification design this dive surfaced.

## CHECKPOINT 2026-08-20T00:20:59Z — S6 COMPLETE (a, b, c); backlog-freeze condition met
- **S6c:** Psychic-Crew-Lite plan v0.1 drafted — local and gitignored, mirroring how this build's own execution authority lives outside the repo.
- **It opens by correcting the audit.** A5.2e priced Lite as practices-without-controls on the assumption the host was not Claude Code. B2a says the runtime IS the Claude Code CLI, with Zed hosting only the terminal — so the enforcement layer travels and Lite means fewer agents and phases, not fewer controls.
- **Cross-release** resolves the arbiter's absence at four agents without reopening C-12; `released_by` must differ from `from_agent`, asserted mechanically.
- **Known cost recorded, not smoothed:** one discourse pass loses the second uncontaminated lens, which is the branch that found F7's hardest seeded bug.
- **Verification designed from the ruflo find:** suites, a witness manifest binding marker plus content hash, and a temporal history for bisecting.
- **Suites unmoved** by a docs-only session: 42+1 SKIP / 158 / 23 / 22 rows.
- **Next action:** operator answers the five questions in the Lite plan's §8 before `APPROVE GATE-L0`. The backlog freeze's condition is met — lifting it is the operator's call. The decision-matrix suite over the audit's measured data remains the one unstarted S6 item.

## CHECKPOINT 2026-08-20T20:12:41Z — S6 fully complete; operator decisions recorded
- **All operator answers on disk:** freeze amended to CONDITIONAL (per-item, on "blocked for build continuity"), Lite §8 answered, §2.2 revised to two blind adversarial passes, §7.1 sync correlation added.
- **CR-033 implemented** — and measurement changed its shape: the forward-looking set was empty, so all four audit documents were annotated and nothing rewritten. 30 citations verified unchanged.
- **Decision-matrix suite built** at docs/audit/DECISION_MATRICES.md — six matrices, each with a decision column. Two constraints have no mechanical enforcement at all; both are designed into Lite.
- **Next action:** `APPROVE GATE-L0` is unblocked — §8 is answered. The Lite repo and its §7.1 correlation map should be L0's first act, scoped as its own session. ROADMAP.md's staleness awaits a freeze decision.

## [F8|2026-08-21T15:07:54Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 1 file(s) uncommitted
- **HEAD:** 75df75a
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** `APPROVE GATE-L0` is unblocked — §8 is answered. The Lite repo and its §7.1 correlation map should be L0's first act, scoped as its own session. ROADMAP.md's staleness awaits a freeze decision.

## [F8|2026-08-21T15:11:36Z] LITE L0 BUILT — awaiting the closing token
- **Built:** psychic-crew-lite, branch dev, commit 997651f, 18 files. Four agents (22-36 lines), capability classes with three-hop resolution, two rules MIRRORED byte-identical from this repo, release-protocol replacing the arbiter protocol, and the §7.1 sync correlation map with its enforcing check.
- **Verified:** apply-models stamps 4 agents and refuses before stamping on a poisoned config · check-sync 15 PASS / 0 FAIL · all scripts parse · no absolute home prefix, no forbidden vendor names in any tracked file · this repo unchanged at 158 PASS / 0 FAIL.
- **Decided:** Lite gates are recorded in the LITE ledger, not this one. Two reasons, both measured: this repo's pending-gate toast greps `GATE-F[0-9]+` (hooks/stop.sh:27) and its gate-count assertions grep `G-F[0-4]` (scripts/run-crew-tests.sh:570), so an L0 row here would be a pending gate this build's own machinery cannot see; and a verdict written into two ledgers is two records that can disagree. This repo's Plan.md carries the narrative, the Lite ledger carries the verdict.
- **Next action:** await `APPROVE GATE-L0` to CLOSE Lite L0. The token was issued once against an empty repository and read as authorisation to begin, per the grammar correction now in the Lite plan §9; closing needs it against work that exists. L1 is Lite enforcement: hooks, deny-list, model guard, secrets guard, release-audit trail.

## [F8|2026-08-21T15:30:59Z] LITE L0 CLOSED — this repo unchanged
- **Gate:** `APPROVE GATE-L0` received; verdict recorded in the Lite ledger, narrative in this repo's Plan.md, per the separation decided and committed at 13ec397.
- **Published:** github.com/nathan-hayashi/psychic-crew-lite, PUBLIC, default dev, no main — every setting read off this repo rather than assumed.
- **This repo:** untouched by the Lite build beyond ledger prose. Suites re-run at close.
- **Next action:** Lite L1 — enforcement layer (hooks, deny-list, model guard, secrets guard, release-audit trail), opening on plain instruction and closing on `APPROVE GATE-L1`. Still open here: CR-003 (d2, deferred), CR-006 (Vega-Lite), CR-027 (README requirements), and ROADMAP.md's staleness against context/session-summary.md.

## [F8|2026-08-21T15:55:25Z] CR-003 + CR-006 DELIVERED — the two diagram CRs R2a deferred
- **CR-003:** d2 hook topology in README.md, bound to .claude/settings.json by set difference in both directions. No renderer here and that is stated, not engineered around.
- **CR-006:** Vega-Lite distribution in context/budget-baseline.md with all 30 rows embedded so it survives a fresh clone, compared against the TSV by sum and per-role identity.
- **Placement forced by the byte-pin:** both landed inside files the map ALREADY names. A new file in context/ or scripts/ fails CR-024, and the map can only gain a path through an operator re-export — the same constraint that moved the S3 diagram validator inline.
- **Counts:** run-crew-tests 158 -> 164 (+3 CR-003, +3 CR-006). save-context 23 unchanged. Registry 25 -> 26 rows/IDs (+C-26), and the C-24 binding tracked it.
- **Controls:** 3/3 for CR-003, 4/4 for CR-006 — one of which failed on its first attempt because the suite regenerates the file it was hiding.
- **Next action:** Lite L1 — enforcement layer. Hooks, deny-list, model guard, secrets guard, release-audit trail, and Lite's own stop hook for L-series gate tokens.

## [F8|2026-08-21T16:04:37Z] LITE L1 BUILT — this repo unchanged
- **Lite:** b9e1026, 27 tracked files. validate-lite 24 PASS / 1 SKIP / 0 FAIL, check-sync 36 PASS / 0 FAIL. Awaiting `APPROVE GATE-L1` in its own ledger.
- **This repo:** CR-003 and CR-006 landed earlier this session at add7ad9; suites 164 / 42+1SKIP / 23. Untouched by the L1 build beyond ledger prose.
- **Owed here, surfaced by L1:** CR-024 should extend to `hooks/` once a plan re-export lets the map name a correct count (C-26); and this repo's jq detectors should be re-checked for the root-context idiom that made Lite's forbidden-model scan vacuous.
- **Next action:** await `APPROVE GATE-L1`. Then Lite L2 — continuity layer and the release trail. Still open here: CR-027 (README requirements), ROADMAP.md staleness.

## [F8|2026-08-21T21:56:32Z] LITE L1 CLOSED — this repo unchanged and one owed item resolved
- **Gate:** `APPROVE GATE-L1` received; Lite at b89e97b, 27 tracked. Verdict in its own ledger.
- **Owed item CLOSED with a negative result:** this repo does NOT share Lite's root-context jq defect. Every `to_entries` usage here is entry-local; the defect was structural to Lite's three-hop class resolution. Checked, not assumed. No fix owed.
- **Still owed here:** CR-024 should extend to `hooks/` once a plan re-export lets DIRECTORY_GUIDE.md name a correct count (C-26, half-applied).
- **Next action:** Lite L2 — continuity layer and the release trail. Open here: CR-027 (README requirements), ROADMAP.md staleness against context/session-summary.md.

## [F8|2026-08-22T02:05:08Z] CR-027 + ROADMAP STALENESS — both closed before the next gate
- **CR-027:** README requirements section from measured data. Platform per R1d, footprint re-measured (1,020,568 tracked bytes, not the audit draft's 723,222), token economics with the unit caveat.
- **Bound, not just fixed:** the reproduction counts were stale by 7 and 21; each script now asserts its own figure. Controls 3/3 including the removed-claim case.
- **ROADMAP:** two entries corrected in place — the EX-01-era `DIRECTORY_GUIDE.md` drift (resolved, but re-pointed at the different drift C-26 found) and G-F3 round-2 (closed at A4). Neither deleted.
- **Counts:** validate-crew 42+1SKIP -> **43+1SKIP** (+1 self-binding) · run-crew-tests 164 -> **165** (+1 self-binding).
- **Escalation held for a local session:** nothing binds ROADMAP.md to the distilled summary, and making it bindable needs a status vocabulary neither file has. Not improvised from a remote prompt.
- **Next action:** Lite L2 — continuity layer and the release trail. No gate token requested for this work.

## [F8|2026-08-22T21:33:45Z] LITE L2 BUILT — this repo unchanged
- **Lite:** 7df5080, 31 tracked. verify.sh layer1 24/1/0 · sync 41/0 · layer2 17/0/0, no signal. Awaiting `APPROVE GATE-L2` in its own ledger.
- **This repo:** 44 / 165 / 23 / PORTABLE, unchanged since 8cf02af.
- **Owed here, surfaced by L2:** hash-pin and comment-strip this repo's correction markers; this repo has no verification layer 3; and sweep for the `grep -c . || echo 0` idiom that silently emptied an audit write in Lite.
- **Next action:** await `APPROVE GATE-L2`. Then Lite L3 — continuity (§6): ledgers, distillation, checkpoint/restore, stall detection, plus `pre-compact-checkpoint`.

## [F8|2026-08-22T22:11:16Z] LITE L3 BUILT — this repo unchanged
- **Lite:** 5ab130a, 37 tracked. verify.sh layer1 31/1/0 · sync 47/0 · distill 11/0 · layer2 23/0/0, no signal. Awaiting `APPROVE GATE-L3` in its own ledger.
- **This repo:** 165 / 43+1SKIP / 23 / PORTABLE, unchanged since d1d90b8.
- **Owed here:** port Lite's declared-binding distillation. save-context.sh binds 3 claims by hand and leaves every other number unbound — the drift CR-034 recorded. Lite fails on any undeclared claim.
- **Next action:** await `APPROVE GATE-L3`. Then Lite L4 — the stress phase across all four agents and the cross-release law.

## [F8|2026-08-22T22:14:12Z] LITE L3 CLOSED — this repo unchanged
- **Gate:** `APPROVE GATE-L3` received; Lite at 05b6802, 37 tracked, phase L3. Verdict in its own ledger.
- **This repo:** 165 / 43+1SKIP / 23, unchanged. Owed: port Lite's declared-binding distillation (finishes CR-034 structurally); CR-024 extension to `hooks/` still needs an operator plan re-export (C-26).
- **Next action:** Lite L4 — the stress phase, and the first live exercise of the cross-release law.

## [F8|2026-08-22T22:24:45Z] LITE L4 BUILT — this repo unchanged
- **Lite:** ef5e836, 40 tracked. verify.sh layer1 31/1/0 · sync 50/0 · distill 11/0 · stress 14/0 · layer2 28/0/0, no signal. Awaiting `APPROVE GATE-L4` in its own ledger.
- **This repo:** 165 / 43+1SKIP / 23, unchanged since 57e06d7.
- **Owed here:** port the declared-binding distillation (finishes CR-034); CR-024 extension to `hooks/` still needs an operator plan re-export (C-26); and generalise C-13 from one incident to a class — a harness exercising an audited artifact writes to a run-scoped copy.
- **Next action:** await `APPROVE GATE-L4`, which closes the Lite build.

## [F8|2026-08-22T22:34:56Z] C-27 — C-14 generalised from an incident to a class
- **Found:** C-14 had recurred on `logs/tooluse-audit.jsonl`. **5,817 of 6,177 denial records (94%) were fixture-generated**, against C-14's original 95% on a different file.
- **Fixed:** fixtures isolated to a temp root, the seven trail-reading assertions follow them, and the canary now covers **every** `logs/*.jsonl` rather than the one that got burned.
- **Redacted:** 5,860 records removed with an `AuditRedaction` event carrying counts, method and stated cost. Trail 7,944 → 2,085 lines; 413 genuine denials remain.
- **Counts:** run-crew-tests 165 → **166** (+1 generalised canary); registry 26 → **27 IDs**; validate-crew 43+1SKIP and save-context 23 unchanged.
- **Next action:** close GATE-L4 in the Lite ledger.

## [F8|2026-08-22T22:38:48Z] LITE L4 CLOSED — the Lite build is complete
- **Lite:** a8922a6, phase L4, 0 gates pending. Five phases, five gates.
- **This repo:** C-27 landed. validate-crew 43+1SKIP · run-crew-tests **166** · save-context 23 · PORTABLE · 27 registered IDs.
- **Still owed here:** port the declared-binding distillation (finishes CR-034 structurally); CR-024 extension to `hooks/` needs an operator plan re-export (C-26).
- **Next action:** no phase is open in either repo. The two owed items above are the remaining work.

## [F8|2026-08-22T23:43:10Z] PARENT-SYNC-1 — declared bindings ported, C-26 closed, plan v3.2
- **C-28:** declared-binding distillation ported from psychic-crew-lite. Versioned `CLAIMS-MANIFEST v1` in save-context.sh, 8 bindings, completeness FAILS on any unbound numeric span. Closes CR-034 as a class where C-24 and CR-034 each fixed an instance.
- **Found by the port:** four silently wrong claims — registry 22/27, save-context 23/30, crew suite **157/169**, validate-crew 42/44.
- **C-26 CLOSED:** CR-024 extended to `hooks/` both ways against v3.2's by-name enumeration; `_common.sh` included as the map names it.
- **Counts, all attributed:** validate-crew 44→45 total · run-crew-tests 166→**169** · save-context 23→**30** · corrections 27→**28 rows/IDs**, 21 APPLIED / 0 PENDING · app 18/18 · drill PORTABLE · EX-01 delta 0.
- **Disclosed:** the precondition allowed one uncommitted file and the tree carried two; the second was verified to be the matching v3.2 payload at delta 0.
- **Next action:** operator replaces MASTER_FIFO_PLAN_CLAUDE.md and DIRECTORY_GUIDE.md with the v3.2 pair so the triple is byte-identical again. No phase is open in either repo.

## [F8|2026-08-22T23:51:31Z] TRIPLE BYTE-IDENTICAL — PARENT-SYNC-1 closed
- **Confirmed:** operator placed the v3.2 pair; the working tree is clean, so the placed files are byte-identical to what the gate committed. Plan sha256 e01256a3faabaf88 — the same hash measured at the precondition check, so the canonical copy, the repo copy and the §4.3-derived map now agree.
- **EX-01 delta 0** on all three §4 payloads (CLAUDE.md, CLAUDE_DESIGN.md, DIRECTORY_GUIDE.md).
- **Parent:** validate-crew 44+1SKIP · run-crew-tests **169** · save-context **30** · corrections **21 APPLIED / 0 PENDING** · app 18/18 · **PORTABLE** · 87 tracked.
- **Lite:** phase L4, 5 gates approved, 0 pending, 40 tracked, verify green with no signal.
- **Next action:** no phase or gate is open in either repo. Registry is at 0 PENDING. Remaining known items are operator decisions, not owed work: whether Lite's runtime state (heartbeats, seance log) should become durable, and whether skill-packs open under the §7.1 correlation.

## [F8|2026-08-23T00:02:38Z] Lite durability resolved — closes an open operator decision
- **Answered:** the previous entry listed "whether Lite's runtime state should become durable" as an open decision. Operator directed it; resolved as a **split** — raw heartbeat log stays runtime/gitignored, a recorded checkpoint is durable in Lite's `docs/session-history.jsonl`.
- **Lite:** f03835f, 41 tracked, validate-lite **37 PASS / 1 SKIP / 0 FAIL**, 32 attested corrections, verify green.
- **This repo:** unchanged at 4e28be2 — 44+1SKIP / 169 / 30 / 21 APPLIED / PORTABLE.
- **Worth carrying here:** the `grep -c … || echo 0` idiom broke a history write for the fifth time in this build, again only on a CLEAN tree. This repo was swept and is clean of it (recorded at C-27), but the recurrence rate says it belongs in guidance, not only in a correction entry.
- **Next action:** no phase or gate open. Remaining operator decision: whether skill-packs open under the §7.1 correlation.

## [F8|2026-08-23T00:38:13Z] GUIDANCE-1 — R-SD-1 standing rule + class assertion + plan v3.3
- **R-SD-1:** `.claude/rules/shell-discipline.md` written byte-for-byte (upstream-authored; will be MIRRORED into Lite). Promotes a five-times-recurring defect from registry memory to standing guidance.
- **Class assertion:** comment-stripped scan of all 23 tracked shell files, fragment-assembled needles, **empty allowlist**. C-27 fixed the instances; this stops the next one entering.
- **Controls 2/2:** planted composite FAILs naming file and line; the correct `|| true` form is NOT flagged.
- **Counts, attributed:** run-crew-tests 169 → **171** (+2 R-SD-1); tracked 87 → **88** (+1 rule file). validate-crew 45, save-context 30, corrections 28/28 unchanged. EX-01 delta 0.
- **Disclosed:** precondition allowed one uncommitted file, two present; the second verified as the matching v3.3 payload at delta 0. The first attempt was stopped outright when v3.3 was absent.
- **Next action:** BLOCK 2 (LITE-SYNC-1) in `~/projects/psychic-crew-lite`. **Step 3 (skill-packs) will be SKIPPED** — no R-SP-1 ruling line was pasted, though v3.3's D18 describes it as ratified; the block's own mechanism governs unless the operator says otherwise.

## [F8|2026-08-23T00:44:07Z] LITE-SYNC-1 closed — R-SD-1 now enforced in both builds
- **Lite:** 4b2ba82, 42 tracked. Rule MIRRORED byte-identical (sha256 c38813323b9a9066 both sides); class assertion live; verify green.
- **The rule earned itself immediately:** Lite's class assertion found **two live violations** in `continuity.sh` on its first run — the third and fourth occurrence of the idiom in that repo, after two already fixed as instances.
- **This repo:** 320bbe2 — validate-crew 44+1SKIP · run-crew-tests **171** · save-context 30 · corrections 21 APPLIED / 0 PENDING · PORTABLE · 88 tracked.
- **Open, operator-side:** R-SP-1 skill-packs. The block required a pasted ruling line and none was given, while v3.3's D18 describes the ruling as ratified. Step 3 was skipped and the conflict reported rather than resolved unilaterally.
- **Next action:** none open. Resolve the R-SP-1 discrepancy if skill-packs are to proceed; the operator's AFTER step (replace the plan/map pair with v3.3) is already satisfied at delta 0.

## [F8|2026-08-23T08:37:32Z] GUIDANCE-2 — pipe-to-grep-q class swept, shell-discipline v2, plan v3.4
- **Rule v2:** rules 1–4 unchanged; **5** adds the pipeline-status class, **6** adds probe fidelity. Written byte-for-byte for the Lite mirror.
- **Sweep:** 29 sites converted across 7 files; census **0**. Ruling-time census 31 reconciles as 3 fixed at b77fbec + 29 here.
- **The census found its own blind spot:** one site hid because the census comment-stripped with `s/#.*//` — the same idiom the line contained. The assertion now strips only whitespace-introduced hashes.
- **Behaviour verified across the sweep:** every suite at its pre-sweep number; swept hooks exercised for deny/allow/exit-0 directly.
- **Counts:** run-crew-tests 171 → **172** (+1 rule-5 assertion). validate-crew 45, save-context 30, corrections 21/0, tracked 88 — all unchanged.
- **Next action:** BLOCK 2 (LITE-SYNC-2) — re-mirror the rule, census and sweep Lite, add its second class assertion.

## [F8|2026-08-23T08:52:40Z] v3.4 triple byte-identical — GUIDANCE-2 / LITE-SYNC-2 closed
- **Confirmed:** operator placed v3.4; the working tree is clean, so the placed file is byte-identical to what the gate committed. Plan sha256 c9f4e458f822ee8b — the same hash measured at the GUIDANCE-2 precondition check. `DIRECTORY_GUIDE.md` untouched, as the revision specifies.
- **EX-01 delta 0** on all three §4 payloads.
- **Parent:** validate-crew 44+1SKIP · run-crew-tests **172** · save-context 30 · corrections 21 APPLIED / 0 PENDING · PORTABLE · 88 tracked.
- **Lite:** d99a958 — layer1 41/1/0 · sync 52/0 · distill 11/0 · stress 14/0 · layer2 38/0/0 · 42 tracked.
- **R-SD-1 v2 enforced in both builds**, rule text byte-identical (0298d9759f6a2589), two class assertions each, pipe-to-grep-q census **0 / 0**.
- **Next action:** no phase or gate is open in either repo. Open operator decision: R-SP-1 skill-packs, where the block's pasted-ruling mechanism and the plan's D18 disagree.

## [F8|2026-08-23T09:02:30Z] R-SP-1 closed in Lite — the last open decision is settled
- **Lite:** f67cc92, 43 tracked. Skill-packs open under §7.1, class-guarded disk→map, A4a intact. verify green across three clean-tree runs.
- **This repo:** unchanged at 9bc765b — 44+1SKIP / **172** / 30 / 21 APPLIED / PORTABLE / 88 tracked.
- **Cross-build state:** R-SD-1 v2 byte-identical (0298d9759f6a2589); pipe-to-grep-q census 0/0; four class assertions in the parent, five in Lite.
- **Next action:** none open. The first skill-pack, when it lands, needs a `PACK` row, a recorded why, and its own per-pack gate under A4a.

## [F8|2026-08-23T09:26:28Z] GUARD-1 — gate-order guard (H0a) + CR-006 closed (H2a) + plan v3.5
- **H0a:** `scripts/gate-guard.sh` — repo-agnostic, obeys R-SD-1 v2, refuses unless GATES.md carries the token's APPROVED row. Every gated commit is guard-fronted from now on, starting with this one.
- **Stated limit:** defeats ordering mistakes, **not forgery**. A fabricated APPROVED line defeats it; that class stays a ledger-vs-memory audit.
- **H2a / CR-006 CLOSED:** tracked confirm-landed snapshot `docs/metrics-snapshot.json` + phase-labelled spec `docs/dispatch-cost.vl.json` whose data URL must resolve to a tracked file. Ships as a specification, not an image.
- **Adjudicated:** CR-024's script extractor, against v3.5's parenthetical map line (PLAN-V3 precedent).
- **Counts:** run-crew-tests 172 → **177** (+2 H0a, +3 H2a) · tracked 88 → **91**. validate-crew 45, save-context 30, corrections 21/0 unchanged. EX-01 delta 0.
- **Registered, not fixed:** the map covers `docs/audit/` only, so the two new `docs/` files sit outside any mapped path — C-26's shape; needs a re-export.
- **Next action:** BLOCK 2 (LITE-GUARD-1), then BLOCK 3 (PACK-CONFLUENCE-1).

## [F8|2026-08-23T09:39:26Z] All three GUARD/PACK blocks closed
- **Parent:** e0445e0 — gate guard (H0a) live and fronting every gated commit; CR-006 closed (H2a). 177 / 44+1SKIP / 30 / 21 APPLIED / PORTABLE / 91 tracked.
- **Lite:** 423daf8 — guard mirrored; first skill-pack live under R-SP-1. layer1 55/1/0 · sync 56/0 · distill 11/0 · stress 14/0 · layer2 48/0/0 · 48 tracked.
- **Next action:** operator replaces `MASTER_FIFO_PLAN_CLAUDE.md` and `DIRECTORY_GUIDE.md` with the v3.5 pair, then exports one internal document into the pack inbox for the first real run.

## [F8|2026-08-24T01:10:47Z] SECURITY-1 — threat model, R-SEC-1, red-team pass — awaiting the token
- **3 findings, all fixed in-session:** error-recovery leaked tokens (length limit ≠ redaction); model-guard blind to indirection (Lite was already ahead); `.gitignore` didn't cover what `security.md` claimed.
- **28 probes executed** and recorded in `docs/security/redteam-1.md`; 12 surfaces in `docs/security/threat-model.md` with honest residuals.
- **Counts:** run-crew-tests 177 → **179** (+2 R-SEC-1 rule-3) · tracked 91 → **94** · settings.json **untouched**.
- **NOT COMMITTED — awaiting `APPROVE SECURITY-1`;** the guard enforces it.

## [F8|2026-08-24T01:12:43Z] GATE SECURITY-1 CLOSED — APPROVED
- **Token:** `APPROVE SECURITY-1` @ 2026-08-24T01:12:43Z, guard-fronted.
- **Verified:** run-crew-tests **179 PASS / 0 FAIL** · validate-crew 44+1SKIP · save-context 30 · corrections 21 APPLIED / 0 PENDING · 94 tracked.
- **Next action:** BLOCK 2 — LITE-SECURITY-1: mirror the contract, untrusted-input contract in PACK.md, tracked attack fixtures, live drill.

## [F8|2026-08-24T01:19:50Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 1 file(s) uncommitted
- **HEAD:** d2cdc36
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** BLOCK 2 — LITE-SECURITY-1: mirror the contract, untrusted-input contract in PACK.md, tracked attack fixtures, live drill.

## [F8|2026-08-24T01:48:32Z] v3.6 pair confirmed delta 0; BLOCK 2 (Lite) closed
- **Plan pair:** `MASTER_FIFO_PLAN_CLAUDE.md` sha256 `990ce5e42ca5df97` (404 lines) · `DIRECTORY_GUIDE.md` sha256 `bbcd740c42f56f8b` (26 lines). Both **byte-identical to HEAD** — the placed pair introduces no change.
- **EX-01 delta 0** on all three pinned payloads: `CLAUDE.md`, `CLAUDE_DESIGN.md`, `DIRECTORY_GUIDE.md`.
- **CR-024 / C-26 map↔tree both directions**, each with its vacuity guard non-empty: scripts/ 10, context/ 6, hooks/ 14.
- **The one FAIL was a dirty tree, not a delta** — `hooks/pre-compact-checkpoint.sh` had written its own emergency checkpoint at 01:19:50Z and left it uncommitted. The assertion flipped PASS→FAIL with the total unchanged at 179, which is the count discipline working: no assertion disappeared.
- **BLOCK 2 closed in Lite:** `APPROVE LITE-SECURITY-1` @ 2026-08-24T01:36:16Z, commits `416ac4d` + `713a3bf` pushed. Four findings fixed; the closing gate itself found the fourth — the R-PD-1 cap keyed on a token the ledger never writes, so it could never have lifted.
- **Next action:** none pending. Both repos green, both trees clean, no open gate.

## [F8|2026-08-25T08:35:24Z] CONTEXT-TRANSFER Phase A — fence landed, suite repaired, awaiting the token
- **Hazard closed:** `Context-Transfer*/` fenced. Measured before: `git add -A -n` staged all six bundle files on a PUBLIC repo. Measured after: **zero**. The glob also ignores `Context-Transfer-2/`, verified.
- **Backed up first** to `$HOME/context-transfer-backup/`, byte-identical per file — `git clean -fdx` deletes ignored files and no suite control would have noticed.
- **Three new assertions**, all with firing negative controls: check-ignore on a **non-existent** path under the fence; the stage-everything probe the parent never had; and the `git ls-files` companion that catches a force-add.
- **My own probe was vacuous and Control A caught it** — the regex anchored on `(^|/)` could never match `add '<path>'`. Fixed by normalising to bare paths so one regex serves both assertions.
- **CR-006 repaired at the right file:** the stale copy was the hand-maintained `vega-lite` fence in `context/budget-baseline.md`, **not** `docs/dispatch-cost.vl.json` (url-backed, embeds nothing). Fence, prose role table and totals all re-derived from the 33-row TSV. `measure-dispatch-cost.sh` was **not** re-run to fix it.
- **Registered, not fixed:** `check-plan-corrections.sh:289` executes the generator, so the standard verification set is what stales the fence. Options recorded; H2a is an operator ruling and redesign needs its own gate.
- **Counts:** validate-crew 44 → **47 PASS / 1 SKIP / 0 FAIL** (+1 ignore probe, +1 stage probe, +1 tracked companion) · README structural-assertion count 45 → **48** at both CR-027-bound sites · save-context **30/0** unchanged · tracked **94** unchanged (Phase A adds no tracked file).
- **run-crew-tests `178 PASS / 1 FAIL`** — the single FAIL is the dirty-tree canary over **nine** entries, all enumerated in the gate row (the count grew from six as these ledgers were written). Not a delta. Expected to read **179/0** after the gated commit.
- **The portability drill did not exercise the new guard** — it runs `git archive HEAD`, so it tested the committed validate-crew, not this one. Proven directly instead: a no-`.git` extract of the working tree announces `[SKIP]`, and an 11-file work tree FAILs `publication probe is VACUOUS`. Re-confirm through the drill post-commit.
- **NOT COMMITTED — awaiting `APPROVE CONTEXT-TRANSFER-FENCE`;** the guard enforces it.
- **Next action:** operator issues `APPROVE CONTEXT-TRANSFER-FENCE`; then the guard-fronted commit and push, then Phase B (`APPROVE CONTEXT-TRANSFER-1`) writes the reconciliation record.

## [F8|2026-08-25T08:49:46Z] CONTEXT-TRANSFER Phase B — reconciliation record written, awaiting the token
- **New tracked file:** `docs/context-transfer-reconciliation.md` — twelve claims checked against repo truth (4 CORRECTED · 1 PRECISION · 1 ALREADY DONE · 4 CONFIRMED · 2 open-and-confirmed), plus the lost-artifact register.
- **Placed in `docs/` deliberately:** `context/` would fail CR-024's converse (the map names exactly six files and needs an operator re-export); `docs/audit/` is a dated record CR-033's doctrine protects from rewriting; `docs/RULINGS.md` is Lite-only. `docs/` is exempt from the converse correlation by D21 — but still inside the mermaid validator and the absolute-path scan, so: no mermaid fences, no absolute paths. Both verified zero.
- **The crossing rule is a firing assertion, not a promise** — validate-crew FAILs if the record ever carries an upstream conversation URL. Control: planted URL FAILs, removal passes.
- **Two categories of missing artifact, kept apart:** `source_files/` was **never delivered** (recoverable — the web project still holds it); `AUDIT_TRAIL_R3/R4/R5` and `CLAUDE_CODE_FINAL_AUDIT_PROMPT.txt` are **lost from both sides**, taking the P1–P5 pushback record with them. No re-export requested.
- **Upstream ledger reconciled:** PACK-1 LIVE **done** (the channel still listed it pending) · SYNC **open, operator-side** (web pair still v3.0 against repo v3.6; direction is repo → web) · PACK-2 gated, IAM first · H3b web-side.
- **Counts:** validate-crew 47 → **48 PASS / 1 SKIP / 0 FAIL** (+1 crossing rule) · README structural count 48 → **49** at both CR-027 sites · tracked 94 → **95** at the commit.
- **run-crew-tests `177 PASS / 2 FAIL` — both expected, both boundary conditions, neither a defect.** One is the dirty-tree canary over **8** entries, all enumerated in the gate row (it grew from five as these ledgers were written). The other is `save-context check` exiting 1 on **PB-06**: the summary records the **post-commit** tracked count 95 while the file is not tracked yet, so the binding is wrong on exactly one side of a gate the token defers. Recording 94 instead would be green now and wrong forever after. Expected **179/0** and **30/0** after the gated commit.
- **NOT COMMITTED — awaiting `APPROVE CONTEXT-TRANSFER-1`;** the guard enforces it.
- **Next action:** operator issues `APPROVE CONTEXT-TRANSFER-1`; then the guard-fronted commit, push, and a re-run to confirm 179/0 · 30/0 · 95 tracked.

## [F8|2026-08-25T09:18:34Z] R-CH-1 — upstream channel retired; the plan is authored here now
- **Ruled:** the Claude.ai web project is closed. All work continues in Claude Code.
- **Plan authority replaced, not relaxed:** `MASTER_FIFO_PLAN_CLAUDE.md` is editable **here**, only inside a gated commit with its own token. Kept: §4 payloads at delta 0, a **hand-authored** `DIRECTORY_GUIDE.md`, and CR-024 policing map against tree both ways. Rejected: generating the guide from the tree — it would make CR-024 vacuous.
- **Why it mattered:** "never edited locally" assumed an external author. Without one it would have frozen §4.3's map permanently — `scripts/` at 10, `context/` at 6 — the constraint that already forced S3's validator inline.
- **First exercise fixed its own subject:** the map line read `v3.0 canonical; never edited locally` on a **v3.6** plan, stale in both halves and on both sides of the pinned pair. Corrected in plan and guide together; **EX-01 delta 0** verified on all three payloads.
- **SYNC is VOID**, not done — closed by the disappearance of its destination. **H3b re-homed** into Claude Code, still queued; the corpus is already local behind the fence.
- **A claim from 597cd0e is falsified and corrected:** `source_files/` was recorded as a recoverable gap "since the web project still holds them". R-CH-1 removes that ground. Category kept, reason restated — those files exist and will not be fetched; the other four no longer exist anywhere.
- **Counts:** plan **v3.6 → v3.7** (D22) · validate-crew **48 PASS / 1 SKIP / 0 FAIL** · save-context **30/0** · tracked **95** — all unchanged; this ruling adds no assertion and no file.
- **run-crew-tests `178 PASS / 1 FAIL`** — the dirty-tree canary over 8 entries: GATES.md, IRECTORY_GUIDE.md, MASTER_FIFO_PLAN_CLAUDE.md, PROGRESS.md, Plan.md, ROADMAP.md, context/session-summary.md, docs/context-transfer-reconciliation.md. Not a delta.
- **NOT COMMITTED — awaiting `APPROVE R-CH-1`.**
- **Next action:** operator issues `APPROVE R-CH-1`; then the guard-fronted commit and push. Open ledger after that: **PACK-2** (gated, IAM first) and **H3b** (queued here).

## [F8|2026-08-25T09:28:48Z] EMERGENCY CHECKPOINT (PreCompact)
- **In-flight:** 1 file(s) uncommitted
- **HEAD:** 562dd65
- **Recovery:** tail of Plan.md, plus the newest snapshot in .claude/state/checkpoints/
- **Next action:** operator issues `APPROVE R-CH-1`; then the guard-fronted commit and push. Open ledger after that: **PACK-2** (gated, IAM first) and **H3b** (queued here).

## [F8|2026-08-25T10:23:23Z] PROJECT-AUDIT-1 — full-history audit checklist created, executed, on disk; awaiting operator read
- **Deliverable:** docs/audit/PROJECT_AUDIT_CHECKLIST_2026-08-25.md — untracked, 987 lines, 71 checks (CHECK==LIVE==71), 0 skipped, 0 deferred. Zero subagent dispatches, so C-25's SKIP and the CR-006 metrics surface are untouched (idempotency sandwich on record).
- **Baselines (this session):** run-crew-tests 178/1 (the 1 = dirty-tree canary over this file's own PreCompact entry) · validate-crew 48/1/0 · save-context 30/0 · corrections 21 APPLIED / 0 PENDING / 2 SUPERSEDED at 33 TSV rows · PORTABLE at 562dd65 · app suite 18/18 · Lite verify 62-1-0 / 60-0 / 12-0 / 14-0 / 48-0-0, no signal.
- **Headline:** zero unbound drift in either repo; 14 stale-doc sites REPORTED not corrected (per the task's non-goal); 3 MISSING; 16 unenforced gaps (6 newly recorded); the deliverable's R-registers and NEXT-PLAN INPUTS carry the successor-plan feed.
- **Counts:** tree = M PROGRESS.md (pre-existing checkpoint + this entry) + the untracked deliverable; nothing else moved.
- **Next action:** operator reads the checklist, replies with numbered corrections, or issues a token in the AUDIT-CHECKLIST shape if it should be tracked (PB-06 then moves 95 -> 96 at that commit). Open ledger otherwise unchanged: PACK-2 (gated, IAM first) and H3b (queued here).

## [F8|2026-08-25T15:34:52Z] CLEANUP-1 built — awaiting the token
- **Task:** execute the PROJECT-AUDIT-1 cleanup slate (R1 x14, R2 x3, R4-11/12/14 bindings+widening); record PACK-2 skipped, H3b next.
- **Workflow status:** at STOP by design: validate-crew 48/1/1 · run-crew-tests 177/3 · save-context 29/1 — all three the commit straddle (README/summary carry the post-commit 96/180/50 truths); R4-11 negative control fired and restored; EX-01 delta 0 at plan v3.8.
- **Active artifact:** 13 modified tracked files + the audit checklist becoming tracked (dirty enumeration in the gate row).
- **Open decisions:** none inside this phase; the token is the only outstanding input.
- **In-flight changes:** everything above, uncommitted.
- **Closed avenues:** retro-editing D20 or the frozen audit record (corrections ride D23 and this ledger instead); editing gate-guard.sh (MIRRORED — a parent-side change would break the Lite mirror and witness hashes).
- **Next action:** operator issues `APPROVE CLEANUP-1`; then gate-guard-fronted commit and push, post-commit suites (expect 180/0 · 49+1SKIP/0 · 30/0), the post-commit next-action refresh line this very phase added — then H3b opens as the next phase. PACK-2 stays skipped.

## [F8|2026-08-25T17:04:28Z] CLEANUP-1 CLOSED at 3a529de — post-commit refresh (the R2-03 line, practiced on its first outing)
- **Post-commit suites:** run-crew-tests **180 PASS / 0 FAIL** · validate-crew **49 PASS / 1 SKIP / 0 FAIL** · save-context **30 PASS / 0 FAIL** · **PORTABLE at 3a529de** · **96 tracked** · pushed.
- **Next action:** open H3b (operator-ordered): census which corpus deep-dives S6 already covered, run the remaining ones, and build the standalone decision-matrix suite over docs/audit/ outputs. PACK-2 stays skipped.

## [F8|2026-08-25T17:10:57Z] H3B-1 built — awaiting the token
- **Task:** execute H3b (operator-ordered after CLEANUP-1): close the deep-dive half by census under M4's law; deliver the standalone decision-matrix suite.
- **Workflow status:** at STOP by design: rct 178/3 · validate 48/1/1 · save-context 29/1 (the commit straddle: README/summary carry post-commit 97 tracked / 181 crew); new suite 13/0/9-noted; census negative control fired by name; EX-01 delta 0 at plan v3.9.
- **Active artifact:** scripts/check-decision-matrices.sh (new, untracked) + 6 modified tracked files.
- **Open decisions:** none — the token is the only outstanding input.
- **In-flight changes:** the 7 enumerated entries, uncommitted.
- **Closed avenues:** reading the eight BARRED corpus directories (M4's law, no named question); asserting cross-repo rows (parent suite stays twin-independent); invoking the corrections checker from the new suite (H2a generator loop).
- **Next action:** operator issues `APPROVE H3B-1`; then guard-fronted commit, push, post-commit suites (expect 181/0 · 49+1SKIP/0 · 30/0), the post-commit next-action refresh. After that the active ledger is EMPTY — PACK-2 skipped, every remaining item a recorded deferral with a wake condition.

## [F8|2026-08-25T18:17:42Z] H3B-1 CLOSED at 176f668 — post-commit refresh
- **Post-commit suites:** run-crew-tests **181 PASS / 0 FAIL** · validate-crew **49 PASS / 1 SKIP / 0 FAIL** · save-context **30 PASS / 0 FAIL** · **PORTABLE at 176f668** · **97 tracked** · pushed.
- **Next action:** none scheduled — the active ledger is EMPTY. PACK-2 skipped by operator instruction (reopens only on a new one); every other item is a recorded deferral with a named wake condition (H1b renderer half, Q2/R-SEC-1, WORKAROUND-01, the two dormant lanes, OQ-2, C-25 prevention). The operator's next instruction opens the next phase.

## [F8|2026-08-26T01:19:54Z] README-SYNC-1 built — awaiting the token
- **Task:** cross-link the repos; Lite quickstart + figure de-rot + two new bindings; audit CORRECTIONS entry 1.
- **Workflow status:** parent 180/1 (canary: README + checklist) · 49+1/0 · 30/0; Lite verify layer1 64/1/0 · no signal; witness re-stamped 48/0/0; F2 negative control fired.
- **Active artifact:** parent README + audit checklist; Lite README + validate-lite.sh + WITNESS-MANIFEST.md.
- **Open decisions:** none — one token covers both guard-fronted commits.
- **In-flight changes:** 5 parent + 6 Lite entries with the ledger writes counted (2 + 3 at verification), uncommitted.
- **Closed avenues:** fixing Lite's stop.sh toast here (recorded sibling of R4-14, future Lite phase); restating suite counts in Lite's README (made agnostic instead — bind one, delete the rest).
- **Next action:** operator issues `APPROVE README-SYNC-1`; guard-fronted commits in BOTH repos, pushes, post-commit suites (parent 181/0 · 49+1/0 · 30/0; Lite no signal), post-commit refresh lines.

## [F8|2026-08-26T05:09:45Z] README-SYNC-1 CLOSED at fddbe27 (parent) / f863479 (Lite) — post-commit refresh
- **Post-commit suites:** run-crew-tests **181 PASS / 0 FAIL** · validate-crew **49 PASS / 1 SKIP / 0 FAIL** · save-context **30 PASS / 0 FAIL**; Lite verify green, no signal; both pushed.
- **Next action:** none scheduled — the active ledger is EMPTY in both repos. Recorded deferrals with wake conditions stand (Lite stop-toast sibling joins them). The operator opens the next phase.

## [F8|2026-08-26T06:54:09Z] ONBOARD-1 built — awaiting the token
- **Task:** fix the fresh-clone guard defect the operator's laptop found; add the drill's clone-shaped leg C; ship plain-language GETTING-STARTED docs + README pointers, both repos.
- **Workflow status:** clone-shaped repro NOT READY pre-fix / READY post-fix; primary validate 49/1/0 with bindings live; STOP straddles: validate 48/1/1 (R4-12 98-vs-97) · rct 178/3 · save-context 29/1 (PB-06); drill leg C RED at pre-fix HEAD by design, green at commit; Lite: sync 61/0 · distill 11/1 (CL-01 straddle) · layer1 64/1/0.
- **Active artifact:** parent validate-crew.sh + portability-drill.sh + README + summary + docs/GETTING-STARTED.md; Lite README + SYNC-CORRELATION + summary + docs/GETTING-STARTED.md.
- **Open decisions:** none — the token is the only outstanding input.
- **In-flight changes:** 5 parent + 4 Lite entries plus these ledgers, uncommitted.
- **Closed avenues:** loosening the bindings instead of fixing the guards (the bindings are right; the classifier was wrong); making the drill clone (HC-5 stands — the clone's SHAPE is built instead).
- **Next action:** operator issues `APPROVE ONBOARD-1`; guard-fronted commits + pushes both repos; post-commit expect parent 181/0 · 49+1/0 · 30/0 · PORTABLE (three legs) and Lite fully green incl. distill 12/0; then the laptop unblocks with git pull (+ PSYCHIC_CREW_PARENT for its ~/dev layout).
