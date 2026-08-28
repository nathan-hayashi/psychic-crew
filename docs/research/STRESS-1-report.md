# STRESS-1 — the full-bench build, measured

Status: FINAL. The one sanctioned hot run of the 8-agent bench since F7. Everything below is
sourced from this phase's own artifacts (ledgers, audit records 20–28, round packets, suite
outputs); evidence classes per house law. Rubric axes were frozen at RSCH-2 (C-18); budgets and
tokens were fixed in Plan.md before the first dispatch.

## Restatement (≤5 lines)

Objective: build an original cats-and-dogs mock site (landing page + privacy page, localhost,
zero dependencies) using the full psychic-crew pipeline — plan, mid-gate, staged build, two
discourse rounds, fixer, runners, final release — measured F7-style and scored against the
pre-fixed five-axis rubric vs CrewAI open-source as documented. This report is the binding record.

## A. What was built `[E]`

`stress-site/` — 17 tracked files: two pages of original copy ("Kettle Lane Cats & Dogs"), one
stylesheet, one progressive-enhancement script, a four-module `node:http` static server
(mime/safepath/router/server) bound to loopback only, a CLI, a zero-install branch-count proxy
(threshold 8, negative control asserting exactly 9), and an app suite that grew **18 → 33 cases**
under review with set-equality to the plan's contract preserved and every addition named.
Stability: two consecutive full runs byte-identical outside duration lines, ×10 at Stage B close,
re-verified at the end. Live E2E: 11/12 scripted probes MATCH; the one mismatch was ruled a
**script defect** (the curl client's explicit-verb HEAD form sets only the request verb, not
its no-body expectation), the server correct by two instruments.

## B. The bench, dispatch by dispatch `[E]`

| #   | task_id         | agent              | measured                                | line    | trigger                                |
| --- | --------------- | ------------------ | --------------------------------------- | ------- | -------------------------------------- |
| 1   | STRESS1-A1      | lead-planner       | 128,098                                 | 15,000  | fired                                  |
| 2   | STRESS1-ARB1    | arbiter            | 136,427                                 | 10,000  | fired                                  |
| 3   | STRESS1-EXA     | lead-executor      | 74,287                                  | 52,000  | fired                                  |
| 4   | STRESS1-EXB     | lead-executor      | 126,579                                 | 68,000  | fired                                  |
| 5   | STRESS1-R1-sec  | security-reviewer  | 90,935                                  | 35,000  | fired                                  |
| 6   | STRESS1-R1-qual | quality-reviewer   | 147,631 (+143,198 re-emit continuation) | 35,000  | fired                                  |
| 7   | STRESS1-ARB-R1  | arbiter            | 145,784                                 | 15,000  | fired                                  |
| 8   | STRESS1-R2-sec  | security-reviewer  | 90,757                                  | 25,000  | fired                                  |
| 9   | STRESS1-R2-qual | quality-reviewer   | 134,953                                 | 25,000  | fired                                  |
| 10  | STRESS1-ARB-R2  | arbiter            | 261,965                                 | 18,000  | fired                                  |
| 11  | STRESS1-FIX     | fixer              | 180,913                                 | 190,000 | **not fired** — the one line that held |
| 12  | STRESS1-TEST    | test-runner        | 72,701                                  | 40,000  | fired                                  |
| 13  | STRESS1-E2E     | integration-runner | 130,491                                 | 40,000  | fired                                  |
| 14  | STRESS1-ARB-FIN | arbiter            | 301,037                                 | 20,000  | fired                                  |

Figures are subagent **context totals** (lower bounds; orchestrator tokens unmeasured — the
baseline's own caveat). Dispatch cap ≤14: **exactly consumed**. Coverage: **8/8 agent types
exercised**. Every specialist dispatch carries an arbiter release line — **15/15 task_ids,
C-05 uncovered set zero** at close, an improvement over F7's four uncovered.

## C. Findings and their fates `[E]`

R1: SEC-1 (security) + QUAL-01..09 (quality). R2: 14 grammar entries — 9 AGREE, **0 CHALLENGE**,
3 CONNECT, 2 SURFACE (QUAL-R2-1, QUAL-R2-2). Released to the fixer: 10 items; **10 ACCEPT, 0
REJECT, 0 DEFER**; six commits; **11 mutation tests, 11 kills**. Honesty rows the release
demanded: the zero-challenge round means nine findings survived a corroborating read, **not an
adversarial test**; the intermediate RED (18/1), the mutation kills, and the live-instance
observations are single-source captures, not independently confirmed.

Three moments where execution beat the round's reasoning, all verified by the final arbiter:
the release offered two "equivalent" fixes for the symlink finding and the fixer **proved them
inequivalent** (realpath taken; the lstat limb left a symlinked-directory shape open — a case in
the suite now pins it); the fixer's own fix **falsified the comment another finding asked for**
before it was written (corrected to what is true, then pinned by an observable ELOOP property);
and the --root question was **resolved by running it against the fixer's own wrong prediction**
(fails safe; pinned as measured behavior).

## D. Budgets vs actuals `[E]`

Phase ceiling: 250K fixed pre-run → early gate fired **before any build spend** (the planner alone
consumed half) → re-ratified at the mid-gate to 1,400,000 with the cap unchanged → final measured
**≈2.17M this phase** (14 dispatch rows sum 2,022,558 + the 143,198 re-emit continuation;
orchestrator unmeasured; TSV lifetime sum 5,541,107). The ratified ceiling breached mid-phase
exactly as the pre-registered projection said it would; per the option-A ruling every breach
above is a recorded trigger, and the phase's budget story is: **13 of 14 authored lines were
wrong, all low, and the one line grounded in a measured mean (the fixer's 190K) held.** Authored
lines under-predict; measured means predict. That sentence is this phase's budget finding.

## E. The rubric — five frozen axes vs CrewAI open-source `[E this run / E-RSCH-2 for CrewAI]`

CrewAI facts from the RSCH-2 dive (MIT, ~54.2k stars, role-based crews, sequential/hierarchical
process, `human_input` flag, developer-written verification). Axis law fixed at RSCH-2:
**verifiable outcome, not velocity.**

| Axis                  | CrewAI as documented                                                      | This run's evidence                                                                                                                                                  | Verdict                |
| --------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| Setup time            | pip install + a few dozen lines to a running crew                         | a constitution: repo law, seeds, suites — days, not minutes                                                                                                          | **CrewAI**, decisively |
| Control surface       | roles/tasks/process flags; guardrails developer-authored                  | byte-pinned seeds, deny-lists, dispatch law, gate tokens, per-dispatch budgets — every control mechanical and enumerated                                             | **psychic-crew**       |
| Verification depth    | whatever tests the developer writes; no framework-level adversarial layer | 18→33 suite with set-equality contract, negative controls, 11/11 mutation kills, red-then-green demonstrations, live E2E with a ruled mismatch                       | **psychic-crew**       |
| Evidence trail        | logs/telemetry; no release law                                            | 28 append-only audit records; 15/15 dispatch coverage; every packet persisted, released before consumption; provenance notes on every paraphrase                     | **psychic-crew**       |
| Human-gate ergonomics | `human_input: true` pauses for console input                              | exact-token gates that REFUSED the operator's own premature close token, a bounded fork question, mid-gate re-budgeting — the gate machine held against its approver | **psychic-crew**       |

**Verdict: 4–1 on the frozen axes — and the honest frame is the same as SIDE-0's: segmentation.**
CrewAI optimizes time-to-first-crew for developers who will author their own controls; this
system IS the controls. On the axis the program cares about — a verifiable outcome an auditor
can replay from disk — the 4–1 is earned by construction, and the one axis lost is lost by an
order of magnitude and by design. `[I]` One-sided limitation, stated: CrewAI was pattern-read
(HC-5 bars an install), so its column is its documentation, not a measured run. What would
change the verdict: running the same brief through CrewAI and watching its evidence trail —
that experiment needs its own gate and its own machine.

## F. The cascade, executed `[E]`

CR-006 fence regenerated 33→47 rows (sum 5,541,107, per-role identical); C-25 flipped LIVE with
the four pre-schema reviewer ids grandfathered by enumeration (the arbiter refused to mint ids
retroactively — the C-12 doctrine holding); §4.3 grew twice through the D26 valve (stress-site/
top-level + stress1-plan.md on the context/ line — both gaps the phase's own reviews named);
guide at delta 0; counts 105→124; summary figures cascaded (validate 51/0, save-context 33/0).

## G. Correction candidates registered at this gate

1. Guard-fires-on-prose, **four instances** this phase (this report's own first write was the
   fourth) — packet/document persistence should not route prose through command-shaped guards.
2. Never dispatch with a staged index (the plan file swept into an executor commit —
   orchestrator fault, ruled accepted). 3. Integration-runner seed still scopes F7's
   stress-project. 4. The E2E script's S8b line (the explicit-verb HEAD probe) is the
   near-miss-probe class from its confident-positive side. 5. CR-027/C-28 compare SUITE_TOTAL
   rather than the run's own count (PASS beside a red run). 6. arbiter.md: `agent_id` becomes a
   MUST on audit lines. 7. **Operator gate item, 4th ask:** arbiter `Edit` scoped to `logs/` (or a
   per-line append path) — every append currently rewrites the whole gitignored history with no
   recovery path. 8. CR-024 widening to top-level directories (QUAL-09's wake condition).

**Dispositions — CORRECTIONS-2 (2026-08-27), all eight resolved:**

1. **RECORDED** — shell-discipline.md rule 8 (persist prose by fragment-assembly or Write, never a
   raw Bash heredoc). The rule-writing itself was the sixth instance.
2. **RECORDED + mechanical FLAG** — arbiter-protocol.md commit-then-dispatch rule; reference-cap.sh
   warns (stderr, never denies) on a `lead-executor` dispatch with a staged index.
3. **FIXED** — integration-runner.md scope generalized to a `stress-*` allowlist (stress-project /
   stress-site); the F7 body labelled the stress-project exemplar.
4. **CLOSED** — no tracked artifact carries the `curl -X HEAD` probe (both plan reviewers verified);
   it existed only in the one-time dispatch. The correct form (`curl -I`) is recorded in §C.
5. **FIXED (both suites)** — C-28 in validate-crew and run-crew-tests now binds the clean summary
   only when the run is clean, and fails beside a red run instead of folding F into a green PASS;
   CR-027 documented as the legitimate authored-count binding.
6. **RECORDED (schema + rule)** — `agent_id` added to arbiter.md step-4 schema and made a MUST in
   arbiter-protocol.md; C-25 is the enforcement, pre-schema lines grandfathered.
7. **FIXED (append-only, create-safe)** — arbiter granted Edit and appends via Edit with a
   grep-confirm; sensitive-guard.sh denies a whole-file Write to an existing non-empty trail while
   permitting creation. The FLAG-lines-to-separate-file hardening for the residual race is deferred.
8. **FIXED** — CR-024 gained a top-level-directory arm (column-0 anchor, gitignore-filtered,
   both-ways comm, fire-probe); the map now mechanically must name every tracked top-level dir.

## H. Weakest claim, flagged

`[I]` The rubric's CrewAI column (§E's stated limitation) — documentation-sourced, not
run-sourced. Runner-up `[I]`: the branch-proxy correlated with nothing this run (no finding
traced to a high branch count), so the SIDE-3-parked promotion wake condition did NOT trigger;
the proxy stays a descriptive gate on this evidence.

## I. Verify

- App suite: `cd stress-site && node --test --test-reporter=tap 'test/**/*.test.js'` → 33/33.
- Coverage: records 20–28 of the arbiter audit cover all nine STRESS1 specialist task_ids;
  C-05/C-25 sections of validate-crew green post-commit.
- Fence: the CR-006 section of run-crew-tests green post-commit; rows/sum re-derivable from the TSV.
- Dispatch table: the metrics TSV rows 34–47.
