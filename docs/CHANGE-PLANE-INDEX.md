# CHANGE-PLANE INDEX — navigation for `docs/CHANGE-PLANE.md`

The chronicle is **5,184 lines / 727KB** and cannot be loaded whole. This index is the map into it:
one file, small enough to read in a single pass, that resolves any identifier, era, or register to an
exact location. Built 2026-08-28 against chronicle HEAD `40ec5b5`.

**Anchors are derived, never retyped.** Every anchor below was extracted from the chronicle itself and
verified to resolve — section anchors by exact line match, gate and decision anchors by substring —
so this index cannot silently disagree with the document it maps. A suite assertion re-checks that
property in both directions on every run (see §6).

## §0 — Orientation: what the chronicle contains

| Part     | What it is                                                                                                             | Where                                                                                       |
| -------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| **I**    | The integrated chronology — nine eras, genesis → now, each with the operator's words, the decision, the why, the forks | `## PART I — THE INTEGRATED CHRONOLOGY`                                                     |
| **II**   | The complete registers, inlined verbatim from their sources (the appendix — the bulk of the file)                      | `## PART II — THE COMPLETE REGISTERS (verbatim appendix, inlined from source)`              |
| **III**  | Current state and the seven honest gaps                                                                                | `## PART III — CURRENT STATE & THE HONEST GAPS (the diff)`                                  |
| **IV**   | The operator-inputs log — requests beside rationale, nothing bucketed                                                  | `## PART IV — OPERATOR-INPUTS LOG (kept whole: request beside rationale, nothing bucketed)` |
| **IV-A** | The HELIX kickoff prompt, persisted (closes gap #7)                                                                    | `## PART IV-A — THE HELIX KICKOFF PROMPT (persisted; closes gap #7)`                        |

Part II's six registers:

| Register | Contents                             | Anchor                                                                                    |
| -------- | ------------------------------------ | ----------------------------------------------------------------------------------------- |
| **II.A** | 42 gates (the ledger)                | `### II.A — Gate ledger (verbatim: GATES.md)`                                             |
| **II.B** | 26 design decisions D1–D26           | `### II.B — Design-decision changelog (verbatim: MASTER_FIFO_PLAN_CLAUDE.md §13, D1–D26)` |
| **II.C** | 308 dated decision-log entries       | `### II.C — The decision log, all 308 entries (verbatim: Plan.md)`                        |
| **II.D** | The nine audit documents             | `### II.D — The nine audit documents (verbatim: docs/audit/)`                             |
| **II.E** | 28 corrections C-01…C-28             | `### II.E — Corrections registry (verbatim: context/plan-corrections.md)`                 |
| **II.F** | Operator rulings & deployment record | `### II.F — Operator rulings & deployment record`                                         |

**How to search fast:** identify the ID class → look it up in §2 → grep the chronicle for its anchor.
For "where has this pattern appeared before" questions, start at §4 (thematic), not §2.

## §1 — The anchor block (machine-readable)

351 anchors, each verified to resolve exactly once. Format: `anchor⇥kind⇥advisory-line`. Kind
`section` matches a whole line; `gate` and `decision` match as a substring. Line numbers are
**advisory as of the build HEAD** — the anchor is the binding pointer, the number is a convenience.

```text
# CHANGE-PLANE-ANCHORS v1
## PART I — THE INTEGRATED CHRONOLOGY	section	23
### Era 0 — Genesis & the execution contract (2026-08-11)	section	29
### Era 1 — The F0–F8 build (2026-08-11 → 08-14, nine gated phases)	section	43
### Era 2 — v1.0.0 & the independent audit (2026-08-16 → 08-17; A0–A5, ~176 findings)	section	63
### Era 3 — Hardening S1–S4 & the standing rulings (2026-08-17 → 08-24)	section	75
### Era 4 — The Lite twin (parallel)	section	88
### Era 5 — Channel retirement & cleanup (2026-08-25 → 08-26)	section	95
### Era 6 — The HELIX program (2026-08-26 → 08-27; the mega-prompt)	section	106
### Era 7 — STRESS-1 (2026-08-27; the one sanctioned hot run)	section	118
### Era 8 — HARNESS-1 & CORRECTIONS-2 (2026-08-27 → 08-28)	section	127
## PART III — CURRENT STATE & THE HONEST GAPS (the diff)	section	136
## PART IV — OPERATOR-INPUTS LOG (kept whole: request beside rationale, nothing bucketed)	section	162
## PART II — THE COMPLETE REGISTERS (verbatim appendix, inlined from source)	section	211
### II.A — Gate ledger (verbatim: GATES.md)	section	222
### II.B — Design-decision changelog (verbatim: MASTER_FIFO_PLAN_CLAUDE.md §13, D1–D26)	section	275
## §13 CHANGELOG (v1 structure preserved; deltas D1 → current — the current version lives in this file's header alone)	section	277
### II.C — The decision log, all 308 entries (verbatim: Plan.md)	section	310
## Baseline (F0 verification results)	section	314
## Q0-Answers	section	334
## Open Questions / Blind Spots (feeds fallback escalations)	section	347
## Fix Ledger	section	361
## Review Notes per Gate	section	379
### G-F0 (in progress)	section	380
### F0 step 6 — doc verification (sanctioned; no installs)	section	404
### Gate-adjacent — plan-corrections registry	section	427
## F1 — Model Routing Layer	section	459
## F2 — Enforcement Layer	section	486
## Standing lesson (promote to context/ at the next gate)	section	528
## Fix Ledger — F3-D1 (arbiter-released packet, round 1, PARTIAL)	section	534
### II.D — The nine audit documents (verbatim: docs/audit/)	section	861
#### verbatim: docs/audit/CHANGE_REQUESTS.md	section	866
## A NOTE ON THE LINE NUMBERS IN THIS FILE (CR-033, 2026-08-20)	section	880
## BACKLOG FROZEN until S6 completes — operator decision, 2026-08-19	section	901
## Ranked by value	section	932
## The detail	section	976
### CR-009 — bind the C-12 detector to code, not comments	section	978
### CR-024 — make the map-vs-tree check read the map	section	998
### CR-014 — stop the phase stamp from being self-reinforcing	section	1018
### CR-015 — assert secret-path `Read` denials by identity	section	1044
### CR-013 — move the error-recovery fixture to a temp root	section	1058
### CR-025 — C-05 structural bypass prevention, re-scoped	section	1082
### CR-023 — DIRECTORY_GUIDE routing decision (operator)	section	1123
### CR-022 — enforce or retire the 30-line reference-passing cap	section	1140
### CR-016 — distinguish "declared read-only" from "declared nothing"	section	1157
### CR-010 — implement C-21's own stated Verify	section	1171
### CR-017 — make `REPLAYED` reachable	section	1180
### CR-034 — the distilled summary's live numbers are stale, and its open-items list is wrong	section	1193
### CR-033 — the audit's line-number citations are stale, and half of them should stay that way	section	1217
### CR-031 — add `.gitattributes` with `eol=lf`	section	1258
### CR-030 — add the HC-7 content scan the plan says exists	section	1282
## The remaining CRs, briefly	section	1299
#### verbatim: docs/audit/DECISION_AUDIT.md	section	1404
## A2.1 The decision register	section	1419
### Q0 — the seven opening answers (operator, 2026-08-11T03:41:25Z) `[E]`	section	1421
### A2-F1 — the axis that produced two operator rulings was never affirmatively chosen	section	1435
### EX-01 … EX-05 — the five exceptions `[I]`	section	1460
### The two Velocity rulings `[E]`	section	1477
### The branch-layout decision (2026-08-14) `[E]`	section	1489
## A2.2 The detectors, audited	section	1498
### A2-F2 — the C-12 detector is satisfied by comments, which is the defect C-12 exists to record	section	1535
### A2-F4 — the C-21 detector checks a file mode, not a measurement	section	1572
### A2-F3 — C-02 can only prove the absence of the wrong name, not the presence of a right one	section	1592
### A2.2b Minor binding gaps	section	1607
## A2.3 Reverse pass — decisions nobody wrote down	section	1622
### A2-F5 — the provenance hook's span threshold is an undocumented security tuning constant	section	1641
## A2.4 Included vs excluded — and whether the reason still holds	section	1668
### A2-F6 — one exclusion's ground truth has moved, and the repository says so in five places without acting	section	1687
## A2.5 The count that propagated	section	1710
#### verbatim: docs/audit/DECISION_MATRICES.md	section	1732
## M1 — Constraint enforcement: where is this build actually weakest?	section	1747
## M2 — The correction registry, three ways `[E]`	section	1771
## M3 — Failure-family closure: is the lesson actually held?	section	1785
## M4 — Corpus value realised: was the reading worth it? `[E]`	section	1806
## M5 — What a decision costs, measured `[E]`	section	1824
## M6 — What is actually open	section	1845
#### verbatim: docs/audit/DIAGRAM_AUDIT.md	section	1864
## A1.0 Inventory — ground truth	section	1881
### A1-F1 — the execution authority mandates a diagram it does not contain	section	1899
## A1.1 Validity `[E]`	section	1916
## A1.2 Accuracy — each diagram against the artifact it depicts	section	1938
### A1-F2 — the dispatch diagram draws the routing law the build proved unexecutable	section	1943
### A1-F3 — the sequence diagram is right about every message and wrong about nine of fourteen actors	section	1983
### A1-F4 — the guarding assertion binds to the diagram's shape, never to its meaning	section	2047
## A1.3 Coverage matrix	section	2072
### Notes on the "yes, absent" cells	section	2089
### DELIVERED — S3, 2026-08-19 (appended; the findings above are left as written)	section	2122
### What is deliberately not recommended	section	2152
#### verbatim: docs/audit/FINAL_AUDIT_REPORT.md	section	2163
## A0 — Orient, baseline, integrity	section	2196
### A0.1 Repository state `[E]`	section	2198
### A0.2 Measured baseline	section	2223
### A0-F1 — the corrections registry, its detectors, and its report disagree three ways	section	2247
### A0-F2 — the only rebrand guard scans the two directories with zero hits	section	2301
### A0-F3 — the distilled entry point disagrees with both sources it distils	section	2346
### A0.3 Corpus fencing `[E]`	section	2379
### A0.4 Carried forward to later phases	section	2394
## A3 — Function and code audit	section	2409
### A3.1 Mechanical sweep — clean `[E]`	section	2414
### A3.2 Pipeline sweep (lesson 6.2) — one real finding	section	2430
### A3-F1 — the C-14 fix was applied to one audit trail and not its sibling	section	2440
### A3-F2 — every hook-written record since F7 closed carries the wrong phase, and the error is self-sustaining	section	2469
### A3-F3 — a permission boundary asserted by count, inside the block C-16 fixed by asserting meaning	section	2506
### A3-F4 — an agent file that declares no tools at all reports as read-only	section	2529
### A3-F5 — `REPLAYED` is not merely undemonstrated, it is unreachable from the shipped fixtures	section	2553
### A3-F6 — the error hints are written to the channel that does not reach the model	section	2587
### A3-F7 — the gitignore assertion binds to rule text where the repo elsewhere binds to state	section	2604
### A3-F8 — the README's first command is one this repository's own guard forbids	section	2617
### A3-F9 — resolved and refuted: `PostToolUseFailure` is a real event	section	2632
### A3.3 Execution checks	section	2646
## A4 — Flow, integration, and the four owed findings	section	2667
### A4.1 The release law, traced by identity	section	2669
### A4-F1 — the C-19 fix has never been exercised, and A3-F2 would exempt the first line that could exercise it	section	2685
### A4-F2 — three arbiter lines carry no `task_id`, and nothing checks for that	section	2708
### A4.2 Untrusted input and the reference-passing cap	section	2736
### A4-F3 — the reference-passing cap is the proven economic lever and is prose only	section	2743
### A4.3 The four owed findings, re-adjudicated	section	2759
### A4.4 Pattern-flow narrative — one event, end to end	section	2825
## A5 — Optimization, gaps, avenues, conformance	section	2877
### A5.1 Optimization register	section	2879
### A5.2 Unbuilt avenues	section	2914
#### d. README and accessibility review	section	2920
#### e. Psychic-Crew-Lite derivation seams	section	2954
#### f. Capability classes over `models.config.json` — feasible	section	2981
### A5.3 Conformance	section	3001
#### A5-F1 — HC-7 names an enforcement in `validate-crew` that is not there	section	3020
#### A5-F2 — the conformance check the brief mandates cannot be run as a plain command here	section	3033
#### A5-F3 — no `.gitattributes`, which is a latent portability defect today and a blocking one on Windows	section	3048
#### verbatim: docs/audit/PLATFORM_GAP_POWERSHELL.md	section	3066
## The question that decides everything	section	3075
## Scenario A — Git for Windows present	section	3094
### The two files that are genuinely WSL-specific	section	3123
### PG-F1 — no `.gitattributes`, and that is the real Windows trap	section	3134
### Exec bits	section	3164
## Scenario B — pure PowerShell, no Git Bash	section	3173
### The recommendation this report will not make	section	3198
## What is verified and what is not	section	3217
#### verbatim: docs/audit/PROJECT_AUDIT_CHECKLIST_2026-08-25.md	section	3238
## Restatement (task spec item 8)	section	3247
## How to scan this file (written for machine read passes)	section	3259
## Content discipline this file obeys	section	3272
## Method, stated	section	3280
## B. Live baseline — seven runs, all captured 2026-08-25, tree as-found	section	3291
### CK-B-01 · corrections checker is idempotent at the settled metrics state	section	3297
### CK-B-02 · crew suite green except the attributed canary	section	3306
### CK-B-03 · structural validator green with the honest SKIP	section	3315
### CK-B-04 · distillation fidelity checker green	section	3323
### CK-B-05 · portability proven by both clone-free mechanisms	section	3331
### CK-B-06 · JML app suite green at the §7 floor	section	3339
### CK-B-07 · Lite three-layer verification green, no signal	section	3347
## E0 — Vision and execution contract (plan header, §0–§3; the beginning)	section	3355
### CK-E0-01 · the mission statement survives verbatim where the plan planted it	section	3357
### CK-E0-02 · provenance and authorship trail of the vision itself	section	3365
### CK-E0-03 · the human counterpart the header promises does not exist anywhere reachable	section	3374
### CK-E0-04 · §0 execution contract clauses hold where they are checkable	section	3383
### CK-E0-05 · §0.6 names an escalation channel that no longer exists	section	3392
### CK-E0-06 · HC-1..HC-8, each against its named enforcement	section	3401
### CK-E0-07 · HC-2's stated role for the forbidden family is out of date in two rule surfaces	section	3410
### CK-E0-08 · the session-model decision trail — reported, not resolved	section	3418
### CK-E0-09 · Q0 answers recorded verbatim and each one traced to its consequence	section	3427
### CK-E0-10 · the evidence-label vocabulary the project promised to use	section	3435
## E1 — Build F0–F8: payloads, contracts, phases, thresholds	section	3443
### CK-E1-01 · §4 seed identity, all three pinned seeds at delta zero	section	3445
### CK-E1-02 · §4.4 Plan.md seed-prefix rule	section	3453
### CK-E1-03 · §4.5 model seed byte-identical	section	3461
### CK-E1-04 · §4.6 settings divergence — fully authority-bound	section	3469
### CK-E1-05 · §4.7 ignore seed retained; growth append-only and gate-bound	section	3478
### CK-E1-06 · §5.1 roster: eight agents, contracts honored, stamps live	section	3486
### CK-E1-07 · arbiter divergence from its verbatim seed — every changed line bound	section	3494
### CK-E1-08 · §5.2 rules: four seeded, two added, one frontmatter dropped	section	3503
### CK-E1-09 · §5.3 router skill byte-faithful and falsifiable	section	3512
### CK-E1-10 · §5.4 discourse grammar lives in the reviewer/arbiter contracts and ran at F7	section	3520
### CK-E1-11 · §5.5 script contracts vs the ten deployed scripts	section	3528
### CK-E1-12 · §5.6 hook contracts vs the fourteen deployed hooks	section	3537
### CK-E1-13 · gates G-F0..G-F8 all closed with exact tokens, tags, and demo/stress evidence	section	3546
### CK-E1-14 · F7 rollback discipline left real tags	section	3554
### CK-E1-15 · §7 thresholds, re-verified against today's artifact	section	3563
### CK-E1-16 · §9 error-corpus assertions live (the 23→17 transform)	section	3571
### CK-E1-17 · §10 gate-report template and §12 self-check practiced	section	3579
### CK-E1-18 · §15 continuity system — every mechanism live-proven	section	3588
### CK-E1-19 · §6 phase budgets — superseded by measurement, by ruling	section	3596
### CK-E1-20 · §11 ETL registry: five lanes, all consumed or dormant as stated, licences on record	section	3605
### CK-E1-21 · plan end-marker debris	section	3613
### CK-E1-22 · §14.1's oracle row still routes to the retired channel	section	3622
## E2 — v1.0.0 and the independent audit era	section	3630
### CK-E2-01 · the audit record exists, is complete, and is deliberately frozen	section	3632
### CK-E2-02 · the audit-gate token convention, verified precisely	section	3640
### CK-E2-03 · the 33-CR priced backlog and its freeze discipline	section	3649
### CK-E2-04 · CR-003's status is stated three ways that do not agree on the surface	section	3657
## E3 — Hardening S1–S4 and the plan's v3.x era	section	3666
### CK-E3-01 · every S-era gate closed in ledger grammar with its work verifiable today	section	3668
### CK-E3-02 · the intake layer (CR-026) — asserted half green, model-interpreted half stated	section	3676
### CK-E3-03 · README bound figures vs unbound figures	section	3684
## E4 — The Lite twin	section	3693
### CK-E4-01 · eleven Lite gates, grammar-clean, one recorded breach	section	3695
### CK-E4-02 · the §7.1 sync correlation — 55 rows, five relations, enforced not documented	section	3703
### CK-E4-03 · all five MIRRORED rows byte-identical, re-proven now	section	3711
### CK-E4-04 · Lite's three-layer verification design delivered as specified	section	3719
## E5 — Rulings in force	section	3727
### CK-E5-01 · R-SD-1 v2 — both class scanners live in both repos, allowlists empty	section	3729
### CK-E5-02 · H0a gate-order guard — present, mapped, refusal branch real, limit stated	section	3737
### CK-E5-03 · R-SEC-1 — zero-credential default holds; redaction enforced, not promised	section	3745
### CK-E5-04 · R-PD-1 — the pack cap lifted mechanically and both directions are proven	section	3753
### CK-E5-05 · R1d — bash-native permanence honored everywhere it binds	section	3761
### CK-E5-06 · R-CH-1 — the newest ruling, all three consequences landed	section	3769
## E6 — Security phase (both repos)	section	3777
### CK-E6-01 · the joint threat model exists with honest residuals — and the residuals still hold	section	3779
### CK-E6-02 · both red-team passes recorded with findings that map to live fixes	section	3788
## E7 — Packs	section	3796
### CK-E7-01 · the first pack holds its three-letter contract and its publication perimeter	section	3798
### CK-E7-02 · PACK-1 LIVE ran on a real document and the record is honest about re-derivation	section	3806
## E8 — Context-transfer and the channel retirement	section	3814
### CK-E8-01 · the fence holds by every mechanism, including history	section	3816
### CK-E8-02 · the stage-everything claim is finally asserted, with its limit stated	section	3824
### CK-E8-03 · the reconciliation record — contract, twelve claims, crossing rule enforced	section	3832
### CK-E8-04 · the backup is real — proven at the correct layout, after one wrong probe	section	3840
### CK-E8-05 · the lost-artifact register keeps its two categories, post-R-CH-1	section	3848
### CK-E8-06 · v3.7 exercised its own new rule correctly	section	3857
### CK-E8-07 · the map's logs/ line lags the runtime tree	section	3865
### CK-E8-08 · the suite's own comment still narrates the pre-D17 hooks state	section	3874
### CK-E8-09 · the dirty PROGRESS entry is the parachute working as designed — exposing a close-convention gap	section	3882
## OPEN — the ledger as it stands (verified, not assumed)	section	3891
### CK-OP-01 · exactly two active work items, both operator-gated	section	3893
### CK-OP-02 · standing deferrals and dormant lanes, each with its recorded condition	section	3901
## R1 — Stale-documentation register (hallucination-class; REPORTED, deliberately uncorrected)	section	3909
## R2 — Missing register	section	3931
## R3 — Change and addition census (drift trail; every entry bound or it would be flagged)	section	3939
## R4 — Unenforced register (requirement exists; no mechanical assertion binds it)	section	3966
## R5 — Lost register (cross-reference; ownership stays with the reconciliation record)	section	3990
## R6 — Function inventory (intended use of every granular unit, with provenance)	section	3998
### R6a — parent scripts (10; all FULL; all in the §4.3 map; CR-024 both directions green)	section	4003
### R6b — parent hooks (14; all FULL; wiring↔disk asserted both directions)	section	4018
### R6c — parent agents (8; FULL), skills (2; FULL), rules (6; FULL)	section	4037
### R6d — parent context/ (6; FULL), root docs (FULL), docs/ (STRUCT for the four big dated	section	4050
### R6e — Lite (57 tracked; scripts+hooks+rules+agents FULL; docs FULL; pack machinery FULL)	section	4066
### R6f — check-ID registry (every named check, its home, its live state today)	section	4082
## R7 — Non-pushed evidence census (CF-H; local-only surfaces, verified live)	section	4103
## NEXT-PLAN INPUTS — everything a successor plan must cover or consciously decline	section	4119
## INDEX — every check, one line	section	4158
## SELF-CHECK — the deliverable against task-spec item 1, clause by clause	section	4174
## CONFIDENCE — core conclusion, and what would overturn it	section	4198
## CORRECTIONS	section	4223
#### verbatim: docs/audit/PROMPT_READINESS.md	section	4250
## 1. Agent-side contracts — measured against the rubric	section	4262
### PR-F1 — `lead-planner` is the thinnest contract and the most consequential	section	4289
### PR-F2 — the arbiter has no self-verification step	section	4320
## 2. The user-facing intake layer — confirmed absent	section	4339
### CR-026 — user-facing intake / task-contract layer (specification only)	section	4357
#### verbatim: docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md	section	4401
### II.E — Corrections registry (verbatim: context/plan-corrections.md)	section	4484
## C-01 — hook entries use a key that does not exist (F2, blocking)	section	4537
## C-02 — `PostToolUseFail` is not a real event (F2, blocking)	section	4558
## C-03 — PreToolUse denial is not exit 2 (F2, blocking)	section	4563
## C-04 — `.claude/state/` is tracked despite DIRECTORY_GUIDE (F2)	section	4576
## C-05 — bypass detection greps a renamed tool (F3, blocking)	section	4583
## C-06/C-07/C-08 — §5.5 apply-models.sh (F0, APPLIED as EX-02)	section	4591
## Working note — the §5.2.4 absolute-path check is blunt by design	section	4599
## C-09 — §5.5's HC-2 scan is a bare substring match (F0/F1, APPLIED as EX-03)	section	4605
## Working note — detectors must test code, not comments	section	4615
## Working note — `set -o pipefail` and exit-2 guards	section	4619
## C-10 — a binding rule that no phase step ever writes (F3)	section	4629
## C-11 — the broker pattern is unexecutable as specified (F3, P0, BLOCKING G-F3)	section	4641
## Working note — the coverage check is live, and it caught the orchestrator	section	4655
## C-11 REOPENED — EX-04 is inert; nested dispatch is disabled at runtime (F3, P0)	section	4661
## C-12 — the bypass detector is satisfiable by the thing it audits (F3, P0)	section	4669
## C-13 — nothing inspects CONTENT bound for the continuity files (F4, operator decision; DEFERRED from F3-D1)	section	4681
## C-14 — tests wrote to the artifact they audit (F3)	section	4701
## Working note — `set -o pipefail`, fourth instance (F5)	section	4721
## C-25 — bypass detection had no record of a dispatch that failed (F8, CR-025, gated)	section	4727
## C-24 — the §15.5 checker verified hygiene and never fidelity (F8, opened and closed by CR-032)	section	4781
## C-15 — the PreCompact parachute displaced the field it exists to protect (F5)	section	4811
## C-16 — the deny-list had no integrity check (F6, found by the G-F6 mutation test)	section	4838
## C-17 — the mid-gate has a name but no token (F7, blocking G-F7a)	section	4848
## C-18 — §7 judges F7 against a ceiling smaller than F7's own budget (F7)	section	4860
## C-20 — §7's token axis is unsatisfiable for the pipeline §6 mandates (F7)	section	4876
## C-19 — the arbiter's audit schema specified `ts` with no format, making coverage order undecidable (F7→F8)	section	4892
## C-21 — the measurement the whole Velocity axis rests on was never written to disk (F8)	section	4903
## C-22 — the G-F8 demo mandates an operation this build's own guard prohibits (F8)	section	4915
## C-23 — the G-F8 stress assertion silently skips in the checkout the G-F8 demo uses (F8)	section	4932
## C-26 — the map-vs-tree check polices `scripts/` and `context/` and has never policed `hooks/` (F8, CR-003)	section	4942
## C-27 — C-14 recurred on a second trail, and the canary written for the first never saw it (F8, L4)	section	4985
## C-28 — fidelity bound claims one at a time; the class was never closed (F8, PARENT-SYNC-1)	section	5019
### II.F — Operator rulings & deployment record (verbatim: docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md — repeated here for direct access; also in II.D)	section	5059
## PART IV-A — THE HELIX KICKOFF PROMPT (persisted; closes gap #7)	section	5142
| G-F0 |	gate	229
| G-F1 |	gate	230
| G-F2 |	gate	231
| G-F3 |	gate	232
| G-F4 |	gate	233
| G-F5 |	gate	234
| G-F6 |	gate	235
| G-F7a |	gate	236
| G-F7b |	gate	237
| G-F8 |	gate	238
| PLAN-V3 |	gate	239
| CR-BATCH-1 |	gate	240
| CR-025 |	gate	241
| R1D |	gate	242
| CR-DIAGRAMS |	gate	243
| CR-026 |	gate	244
| PARENT-SYNC-1 |	gate	245
| GUIDANCE-1 |	gate	246
| GUIDANCE-2 |	gate	247
| GUARD-1 |	gate	248
| SECURITY-1 |	gate	249
| CONTEXT-TRANSFER-FENCE |	gate	250
| CONTEXT-TRANSFER-1 |	gate	251
| R-CH-1 |	gate	252
| CLEANUP-1 |	gate	253
| H3B-1 |	gate	254
| README-SYNC-1 |	gate	255
| ONBOARD-1 |	gate	256
| HELIX-0 |	gate	257
| RSCH-1 |	gate	258
| RSCH-2 |	gate	259
| RSCH-3 |	gate	260
| SIDE-0 |	gate	261
| SIDE-1 |	gate	262
| SIDE-2 |	gate	263
| SIDE-3 |	gate	264
| SIDE-4 |	gate	265
| SIDE-5 |	gate	266
| STRESS-1 |	gate	267
| STRESS-1a |	gate	268
| HARNESS-1 |	gate	269
| CORRECTIONS-2 |	gate	270
D1 NEW HC-7 Claude-only; Codex/ChatGPT logic r	decision	278
D2 Model routing moved to alias-mode default (	decision	279
D3 v1 [V?] "per-agent model via frontmatter" u	decision	280
D4 §5.4 discourse upgraded from ad-hoc "challe	decision	281
D5 Fallback protocol gains binding anti-skip/a	decision	282
D6 NEW PreCompact hook (emergency checkpoint) 	decision	283
D7 §11 ETL registry expanded 2→5 lanes with pe	decision	284
D8 F0 gains one verification step: if an API k	decision	285
D9 (v2.1) Reviewer dimension-label contract, P	decision	286
D10 (v2.1) Forward-resume rule (never regress,	decision	287
D11 (v2.1) Standalone context files emitted; r	decision	288
D26 (v3.11, 2026-08-27, gate STRESS-1) THE MAP	decision	289
D25 (v3.10, 2026-08-26, gate SIDE-3) THE ARMY 	decision	290
D24 (v3.9, 2026-08-25, gate H3B-1) H3b EXECUTE	decision	291
D23 (v3.8, 2026-08-25, gate CLEANUP-1; second 	decision	292
D22 (v3.7, 2026-08-25, operator ruling R-CH-1)	decision	293
D21 (v3.6, 2026-08-23, operator ruling line S1	decision	294
D20 (v3.5, 2026-08-23, operator ruling line H0	decision	295
D19 (v3.4, 2026-08-22, operator ruling on the 	decision	296
D18 (v3.3, 2026-08-22, operator flag ratified)	decision	297
D17 (v3.2, 2026-08-22) §4.3 hooks/ line now EN	decision	298
D16 (v3.1, 2026-08-19) §4.3 map gains one path	decision	299
D15 (v3.0.1, 2026-08-17) One-sentence correcti	decision	300
D14 (v3.0, 2026-08-16, operator rulings sessio	decision	301
D13 (v2.3) §15.9 WORKAROUND-01: autonomous num	decision	302
D12 (v2.2) HC-8 Context Continuity elevated to	decision	303
```

**Dual-site headings — declared, not hidden.** Six headings resolve **twice**, because the chronicle
deliberately inlines `docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md` at both II.D and II.F (stated
in the chronicle's own II.F header). They are excluded from the block above and declared here, so the
assertion can hold "exactly once" without a false failure:

```text
# CHANGE-PLANE-DUAL-SITE v1
## 1. Rulings → effect → landing spot	section	4406,5064
### SUPERSESSION — R1d (2026-08-19): C1b is superseded; this project is bash-native, permanently	section	4426,5084
### R2a and R3a — recorded with R1d (2026-08-19)	section	4454,5112
## 2. Deployment sequence — DO NOT run while the audit session is mid-flight	section	4467,5125
## 3. D2b — placing Ralph (operator, manual, outside this repo's tooling)	section	4475,5133
## 4. Standing next-session agenda (planning, per READ FIRST)	section	4478,5136
```

## §2 — ID → location

### Gates (42)

| Gate | Anchor | Line |
| ---- | ------ | ---- |

| `G-F0` | `| G-F0 |` | 229 |
| `G-F1` | `| G-F1 |` | 230 |
| `G-F2` | `| G-F2 |` | 231 |
| `G-F3` | `| G-F3 |` | 232 |
| `G-F4` | `| G-F4 |` | 233 |
| `G-F5` | `| G-F5 |` | 234 |
| `G-F6` | `| G-F6 |` | 235 |
| `G-F7a` | `| G-F7a |` | 236 |
| `G-F7b` | `| G-F7b |` | 237 |
| `G-F8` | `| G-F8 |` | 238 |
| `PLAN-V3` | `| PLAN-V3 |` | 239 |
| `CR-BATCH-1` | `| CR-BATCH-1 |` | 240 |
| `CR-025` | `| CR-025 |` | 241 |
| `R1D` | `| R1D |` | 242 |
| `CR-DIAGRAMS` | `| CR-DIAGRAMS |` | 243 |
| `CR-026` | `| CR-026 |` | 244 |
| `PARENT-SYNC-1` | `| PARENT-SYNC-1 |` | 245 |
| `GUIDANCE-1` | `| GUIDANCE-1 |` | 246 |
| `GUIDANCE-2` | `| GUIDANCE-2 |` | 247 |
| `GUARD-1` | `| GUARD-1 |` | 248 |
| `SECURITY-1` | `| SECURITY-1 |` | 249 |
| `CONTEXT-TRANSFER-FENCE` | `| CONTEXT-TRANSFER-FENCE |` | 250 |
| `CONTEXT-TRANSFER-1` | `| CONTEXT-TRANSFER-1 |` | 251 |
| `R-CH-1` | `| R-CH-1 |` | 252 |
| `CLEANUP-1` | `| CLEANUP-1 |` | 253 |
| `H3B-1` | `| H3B-1 |` | 254 |
| `README-SYNC-1` | `| README-SYNC-1 |` | 255 |
| `ONBOARD-1` | `| ONBOARD-1 |` | 256 |
| `HELIX-0` | `| HELIX-0 |` | 257 |
| `RSCH-1` | `| RSCH-1 |` | 258 |
| `RSCH-2` | `| RSCH-2 |` | 259 |
| `RSCH-3` | `| RSCH-3 |` | 260 |
| `SIDE-0` | `| SIDE-0 |` | 261 |
| `SIDE-1` | `| SIDE-1 |` | 262 |
| `SIDE-2` | `| SIDE-2 |` | 263 |
| `SIDE-3` | `| SIDE-3 |` | 264 |
| `SIDE-4` | `| SIDE-4 |` | 265 |
| `SIDE-5` | `| SIDE-5 |` | 266 |
| `STRESS-1` | `| STRESS-1 |` | 267 |
| `STRESS-1a` | `| STRESS-1a |` | 268 |
| `HARNESS-1` | `| HARNESS-1 |` | 269 |
| `CORRECTIONS-2` | `| CORRECTIONS-2 |` | 270 |

### Corrections (28 ids across 27 headings — C-06/C-07/C-08 share one section)

| Correction | Anchor | Line |
| ---------- | ------ | ---- |

| C-01 | `## C-01 — hook entries use a key that does not exist (F2, blocking)` | 4537 |
| C-02 | `## C-02 — `PostToolUseFail` is not a real event (F2, blocking)` | 4558 |
| C-03 | `## C-03 — PreToolUse denial is not exit 2 (F2, blocking)` | 4563 |
| C-04 | `## C-04 — `.claude/state/` is tracked despite DIRECTORY_GUIDE (F2)` | 4576 |
| C-05 | `## C-05 — bypass detection greps a renamed tool (F3, blocking)` | 4583 |
| C-06/C-07/C-08 | `## C-06/C-07/C-08 — §5.5 apply-models.sh (F0, APPLIED as EX-02)` | 4591 |
| C-09 | `## C-09 — §5.5's HC-2 scan is a bare substring match (F0/F1, APPLIED as EX-03)` | 4605 |
| C-10 | `## C-10 — a binding rule that no phase step ever writes (F3)` | 4629 |
| C-11 | `## C-11 — the broker pattern is unexecutable as specified (F3, P0, BLOCKING G-F3)` | 4641 |
| C-11 REOPENED | `## C-11 REOPENED — EX-04 is inert; nested dispatch is disabled at runtime (F3, P0)` | 4661 |
| C-12 | `## C-12 — the bypass detector is satisfiable by the thing it audits (F3, P0)` | 4669 |
| C-13 | `## C-13 — nothing inspects CONTENT bound for the continuity files (F4, operator decision; DEFERRED from F3-D1)` | 4681 |
| C-14 | `## C-14 — tests wrote to the artifact they audit (F3)` | 4701 |
| C-25 | `## C-25 — bypass detection had no record of a dispatch that failed (F8, CR-025, gated)` | 4727 |
| C-24 | `## C-24 — the §15.5 checker verified hygiene and never fidelity (F8, opened and closed by CR-032)` | 4781 |
| C-15 | `## C-15 — the PreCompact parachute displaced the field it exists to protect (F5)` | 4811 |
| C-16 | `## C-16 — the deny-list had no integrity check (F6, found by the G-F6 mutation test)` | 4838 |
| C-17 | `## C-17 — the mid-gate has a name but no token (F7, blocking G-F7a)` | 4848 |
| C-18 | `## C-18 — §7 judges F7 against a ceiling smaller than F7's own budget (F7)` | 4860 |
| C-20 | `## C-20 — §7's token axis is unsatisfiable for the pipeline §6 mandates (F7)` | 4876 |
| C-19 | `## C-19 — the arbiter's audit schema specified `ts` with no format, making coverage order undecidable (F7→F8)` | 4892 |
| C-21 | `## C-21 — the measurement the whole Velocity axis rests on was never written to disk (F8)` | 4903 |
| C-22 | `## C-22 — the G-F8 demo mandates an operation this build's own guard prohibits (F8)` | 4915 |
| C-23 | `## C-23 — the G-F8 stress assertion silently skips in the checkout the G-F8 demo uses (F8)` | 4932 |
| C-26 | `## C-26 — the map-vs-tree check polices `scripts/` and `context/` and has never policed `hooks/` (F8, CR-003)` | 4942 |
| C-27 | `## C-27 — C-14 recurred on a second trail, and the canary written for the first never saw it (F8, L4)` | 4985 |
| C-28 | `## C-28 — fidelity bound claims one at a time; the class was never closed (F8, PARENT-SYNC-1)` | 5019 |

### Change requests (34 — 16 with a definition heading, 18 referenced only)

Eighteen CRs are discussed in prose and tables but never given their own heading in the source
documents; they carry a first-occurrence line instead of an anchor, marked `ref-only`. That is a
property of the underlying record, not an omission here.

| CR  | Anchor | Line |
| --- | ------ | ---- |

| CR-009 | `### CR-009` | 978 |
| CR-024 | `### CR-024` | 998 |
| CR-014 | `### CR-014` | 1018 |
| CR-015 | `### CR-015` | 1044 |
| CR-013 | `### CR-013` | 1058 |
| CR-025 | `### CR-025` | 1082 |
| CR-023 | `### CR-023` | 1123 |
| CR-022 | `### CR-022` | 1140 |
| CR-016 | `### CR-016` | 1157 |
| CR-010 | `### CR-010` | 1171 |
| CR-017 | `### CR-017` | 1180 |
| CR-034 | `### CR-034` | 1193 |
| CR-033 | `### CR-033` | 1217 |
| CR-031 | `### CR-031` | 1258 |
| CR-030 | `### CR-030` | 1282 |
| CR-026 | `### CR-026` | 4357 |
| CR-001 | _(ref-only — no definition heading)_ | 243 |
| CR-002 | _(ref-only — no definition heading)_ | 243 |
| CR-003 | _(ref-only — no definition heading)_ | 243 |
| CR-004 | _(ref-only — no definition heading)_ | 243 |
| CR-005 | _(ref-only — no definition heading)_ | 243 |
| CR-006 | _(ref-only — no definition heading)_ | 243 |
| CR-007 | _(ref-only — no definition heading)_ | 240 |
| CR-008 | _(ref-only — no definition heading)_ | 1309 |
| CR-011 | _(ref-only — no definition heading)_ | 693 |
| CR-012 | _(ref-only — no definition heading)_ | 240 |
| CR-018 | _(ref-only — no definition heading)_ | 691 |
| CR-019 | _(ref-only — no definition heading)_ | 681 |
| CR-020 | _(ref-only — no definition heading)_ | 1343 |
| CR-021 | _(ref-only — no definition heading)_ | 240 |
| CR-027 | _(ref-only — no definition heading)_ | 182 |
| CR-028 | _(ref-only — no definition heading)_ | 728 |
| CR-029 | _(ref-only — no definition heading)_ | 728 |
| CR-032 | _(ref-only — no definition heading)_ | 240 |

### Design decisions (26)

| Decision | Anchor | Line |
| -------- | ------ | ---- |

| D1 | `D1 NEW HC-7 Claude-only; Codex/ChatGPT logic r` | 278 |
| D2 | `D2 Model routing moved to alias-mode default (` | 279 |
| D3 | `D3 v1 [V?] "per-agent model via frontmatter" u` | 280 |
| D4 | `D4 §5.4 discourse upgraded from ad-hoc "challe` | 281 |
| D5 | `D5 Fallback protocol gains binding anti-skip/a` | 282 |
| D6 | `D6 NEW PreCompact hook (emergency checkpoint) ` | 283 |
| D7 | `D7 §11 ETL registry expanded 2→5 lanes with pe` | 284 |
| D8 | `D8 F0 gains one verification step: if an API k` | 285 |
| D9 | `D9 (v2.1) Reviewer dimension-label contract, P` | 286 |
| D10 | `D10 (v2.1) Forward-resume rule (never regress,` | 287 |
| D11 | `D11 (v2.1) Standalone context files emitted; r` | 288 |
| D26 | `D26 (v3.11, 2026-08-27, gate STRESS-1) THE MAP` | 289 |
| D25 | `D25 (v3.10, 2026-08-26, gate SIDE-3) THE ARMY ` | 290 |
| D24 | `D24 (v3.9, 2026-08-25, gate H3B-1) H3b EXECUTE` | 291 |
| D23 | `D23 (v3.8, 2026-08-25, gate CLEANUP-1; second ` | 292 |
| D22 | `D22 (v3.7, 2026-08-25, operator ruling R-CH-1)` | 293 |
| D21 | `D21 (v3.6, 2026-08-23, operator ruling line S1` | 294 |
| D20 | `D20 (v3.5, 2026-08-23, operator ruling line H0` | 295 |
| D19 | `D19 (v3.4, 2026-08-22, operator ruling on the ` | 296 |
| D18 | `D18 (v3.3, 2026-08-22, operator flag ratified)` | 297 |
| D17 | `D17 (v3.2, 2026-08-22) §4.3 hooks/ line now EN` | 298 |
| D16 | `D16 (v3.1, 2026-08-19) §4.3 map gains one path` | 299 |
| D15 | `D15 (v3.0.1, 2026-08-17) One-sentence correcti` | 300 |
| D14 | `D14 (v3.0, 2026-08-16, operator rulings sessio` | 301 |
| D13 | `D13 (v2.3) §15.9 WORKAROUND-01: autonomous num` | 302 |
| D12 | `D12 (v2.2) HC-8 Context Continuity elevated to` | 303 |

### Audit checks (72 — 71 headed, `CK-CONFLUENCE-1` referenced only)

| Check | Anchor | Line |
| ----- | ------ | ---- |

| CK-B-01 | `### CK-B-01` | 3297 |
| CK-B-02 | `### CK-B-02` | 3306 |
| CK-B-03 | `### CK-B-03` | 3315 |
| CK-B-04 | `### CK-B-04` | 3323 |
| CK-B-05 | `### CK-B-05` | 3331 |
| CK-B-06 | `### CK-B-06` | 3339 |
| CK-B-07 | `### CK-B-07` | 3347 |
| CK-E0-01 | `### CK-E0-01` | 3357 |
| CK-E0-02 | `### CK-E0-02` | 3365 |
| CK-E0-03 | `### CK-E0-03` | 3374 |
| CK-E0-04 | `### CK-E0-04` | 3383 |
| CK-E0-05 | `### CK-E0-05` | 3392 |
| CK-E0-06 | `### CK-E0-06` | 3401 |
| CK-E0-07 | `### CK-E0-07` | 3410 |
| CK-E0-08 | `### CK-E0-08` | 3418 |
| CK-E0-09 | `### CK-E0-09` | 3427 |
| CK-E0-10 | `### CK-E0-10` | 3435 |
| CK-E1-01 | `### CK-E1-01` | 3445 |
| CK-E1-02 | `### CK-E1-02` | 3453 |
| CK-E1-03 | `### CK-E1-03` | 3461 |
| CK-E1-04 | `### CK-E1-04` | 3469 |
| CK-E1-05 | `### CK-E1-05` | 3478 |
| CK-E1-06 | `### CK-E1-06` | 3486 |
| CK-E1-07 | `### CK-E1-07` | 3494 |
| CK-E1-08 | `### CK-E1-08` | 3503 |
| CK-E1-09 | `### CK-E1-09` | 3512 |
| CK-E1-10 | `### CK-E1-10` | 3520 |
| CK-E1-11 | `### CK-E1-11` | 3528 |
| CK-E1-12 | `### CK-E1-12` | 3537 |
| CK-E1-13 | `### CK-E1-13` | 3546 |
| CK-E1-14 | `### CK-E1-14` | 3554 |
| CK-E1-15 | `### CK-E1-15` | 3563 |
| CK-E1-16 | `### CK-E1-16` | 3571 |
| CK-E1-17 | `### CK-E1-17` | 3579 |
| CK-E1-18 | `### CK-E1-18` | 3588 |
| CK-E1-19 | `### CK-E1-19` | 3596 |
| CK-E1-20 | `### CK-E1-20` | 3605 |
| CK-E1-21 | `### CK-E1-21` | 3613 |
| CK-E1-22 | `### CK-E1-22` | 3622 |
| CK-E2-01 | `### CK-E2-01` | 3632 |
| CK-E2-02 | `### CK-E2-02` | 3640 |
| CK-E2-03 | `### CK-E2-03` | 3649 |
| CK-E2-04 | `### CK-E2-04` | 3657 |
| CK-E3-01 | `### CK-E3-01` | 3668 |
| CK-E3-02 | `### CK-E3-02` | 3676 |
| CK-E3-03 | `### CK-E3-03` | 3684 |
| CK-E4-01 | `### CK-E4-01` | 3695 |
| CK-E4-02 | `### CK-E4-02` | 3703 |
| CK-E4-03 | `### CK-E4-03` | 3711 |
| CK-E4-04 | `### CK-E4-04` | 3719 |
| CK-E5-01 | `### CK-E5-01` | 3729 |
| CK-E5-02 | `### CK-E5-02` | 3737 |
| CK-E5-03 | `### CK-E5-03` | 3745 |
| CK-E5-04 | `### CK-E5-04` | 3753 |
| CK-E5-05 | `### CK-E5-05` | 3761 |
| CK-E5-06 | `### CK-E5-06` | 3769 |
| CK-E6-01 | `### CK-E6-01` | 3779 |
| CK-E6-02 | `### CK-E6-02` | 3788 |
| CK-E7-01 | `### CK-E7-01` | 3798 |
| CK-E7-02 | `### CK-E7-02` | 3806 |
| CK-E8-01 | `### CK-E8-01` | 3816 |
| CK-E8-02 | `### CK-E8-02` | 3824 |
| CK-E8-03 | `### CK-E8-03` | 3832 |
| CK-E8-04 | `### CK-E8-04` | 3840 |
| CK-E8-05 | `### CK-E8-05` | 3848 |
| CK-E8-06 | `### CK-E8-06` | 3857 |
| CK-E8-07 | `### CK-E8-07` | 3865 |
| CK-E8-08 | `### CK-E8-08` | 3874 |
| CK-E8-09 | `### CK-E8-09` | 3882 |
| CK-OP-01 | `### CK-OP-01` | 3893 |
| CK-OP-02 | `### CK-OP-02` | 3901 |
| CK-CONFLUENCE-1 | _(ref-only — no definition heading)_ | 817 |

### Constraints and standing rulings (23, all referenced in prose — first occurrence given)

| Ruling | Anchor | Line |
| ------ | ------ | ---- |

| HC-1 | _(ref-only)_ | 38 |
| HC-2 | _(ref-only)_ | 236 |
| HC-3 | _(ref-only)_ | 238 |
| HC-4 | _(ref-only)_ | 238 |
| HC-5 | _(ref-only)_ | 229 |
| HC-6 | _(ref-only)_ | 743 |
| HC-7 | _(ref-only)_ | 259 |
| HC-8 | _(ref-only)_ | 38 |
| EX-01 | _(ref-only)_ | 70 |
| EX-02 | _(ref-only)_ | 355 |
| EX-03 | _(ref-only)_ | 464 |
| EX-04 | _(ref-only)_ | 521 |
| EX-05 | _(ref-only)_ | 51 |
| R-SD-1 | _(ref-only)_ | 81 |
| R-SEC-1 | _(ref-only)_ | 15 |
| R-SP-1 | _(ref-only)_ | 295 |
| R-PD-1 | _(ref-only)_ | 3753 |
| R-CH-1 | _(ref-only)_ | 100 |
| R1d | _(ref-only)_ | 84 |
| H0a | _(ref-only)_ | 93 |
| H1b | _(ref-only)_ | 248 |
| H2a | _(ref-only)_ | 248 |
| H3b | _(ref-only)_ | 102 |

## §3 — Chronological index

The nine eras, each an anchor in Part I:

| Era | Span          | Anchor                                                                                  |
| --- | ------------- | --------------------------------------------------------------------------------------- |
| 0   | 2026-08-11    | `### Era 0 — Genesis & the execution contract (2026-08-11)`                             |
| 1   | 08-11 → 08-14 | `### Era 1 — The F0–F8 build (2026-08-11 → 08-14, nine gated phases)`                   |
| 2   | 08-16 → 08-17 | `### Era 2 — v1.0.0 & the independent audit (2026-08-16 → 08-17; A0–A5, ~176 findings)` |
| 3   | 08-17 → 08-24 | `### Era 3 — Hardening S1–S4 & the standing rulings (2026-08-17 → 08-24)`               |
| 4   | parallel      | `### Era 4 — The Lite twin (parallel)`                                                  |
| 5   | 08-25 → 08-26 | `### Era 5 — Channel retirement & cleanup (2026-08-25 → 08-26)`                         |
| 6   | 08-26 → 08-27 | `### Era 6 — The HELIX program (2026-08-26 → 08-27; the mega-prompt)`                   |
| 7   | 08-27         | `### Era 7 — STRESS-1 (2026-08-27; the one sanctioned hot run)`                         |
| 8   | 08-27 → 08-28 | `### Era 8 — HARNESS-1 & CORRECTIONS-2 (2026-08-27 → 08-28)`                            |

**The 308 decision entries by phase tag** (all inside II.C; entries are chronological, so a phase's
entries are contiguous — find the first by grepping `[<TAG>|` and read forward):

| Tag | Entries | Tag | Entries | Tag                      | Entries |
| --- | ------- | --- | ------- | ------------------------ | ------- |
| F0  | 10      | A0  | 3       | S3                       | 7       |
| F1  | 8       | A3  | 2       | S4                       | 10      |
| F2  | 13      | A4  | 2       | S6                       | 16      |
| F3  | 16      | A5  | 3       | L0                       | 5       |
| F4  | 6       | S1  | 25      | F8 (08-14)               | 3       |
| F5  | 4       | S2  | 7       | F8 (resumed 08-21→08-28) | 91      |
| F6  | 6       | R1d | 5       |                          |         |
| F7  | 66      |     |         | **total**                | **308** |

Note: the phase tag stays `F8` from 2026-08-14 onward — F8 was never formally closed after the
"PLAN CLOSED" entry, so all post-plan work files under it by the log's own convention. Sub-programs
inside that span (the CR gates, R-SD-1, SECURITY-1, the channel retirement, HELIX, STRESS-1,
HARNESS-1, CORRECTIONS-2) are found by era in §3 or by gate in §2, not by tag.

## §4 — Thematic index (the fastest route for "has this happened before?")

These are the recurring patterns the project tracked across its own history. Each is a search entry
point: the theme, its count as the record states it, and where to start reading.

| Theme                                                                                                                                             | As recorded                                                                         | Start at                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------ |
| **A control bound to a proxy rather than the artifact** — the single most-repeated defect family; the record counts it to the "eleventh instance" | C-12, C-16, C-23, C-26, A2-F2, A3-F3, A3-F4, QR-DG-2 → CR-024                       | Era 2; then `## C-23 —`, `## C-26 —` |
| **A guard firing on its own documentation** ("guard-fires-on-prose")                                                                              | 6 instances, the last three inside STRESS-1/HARNESS-1                               | Era 7, Era 8; `## C-22 —`            |
| **The pipefail / count-then-default family** → became R-SD-1                                                                                      | 6 recurrences across two builds                                                     | Era 3; `## C-09 —`                   |
| **A control that reported green while testing nothing** (vacuous controls)                                                                        | 5 instances; CR-BATCH-1 restored 11 such controls                                   | Era 3; `### CR-013`, `### CR-024`    |
| **Budget and velocity rulings** — a ceiling as a gate trigger, not a pass/fail bar                                                                | C-18, C-20, C-21, G-F7a, G-F7b                                                      | Era 1; `## C-18 —`, `## C-20 —`      |
| **Publication-fence events** on a public repo                                                                                                     | the Context-Transfer bundle, the PNG drop                                           | Era 5, Era 6                         |
| **The author's own control catching the author**                                                                                                  | C-24, C-28, R-SD-1 rules 5/6, SIDE-0, SIDE-1, SIDE-4                                | Era 6                                |
| **Operator rulings that redirected the project**                                                                                                  | Q1 public naming, EX-01, option-A velocity, R1d bash-native, R-CH-1, fork-bomb keep | Era 0, Era 3, Era 5                  |
| **Measurement existing only in context, not on disk**                                                                                             | C-21 — the inversion HC-8 exists to prevent                                         | `## C-21 —`                          |
| **A law that proved unexecutable and had to be redesigned**                                                                                       | C-11 → EX-05                                                                        | `## C-11 —`                          |

## §5 — Durable sources (when to read the live register instead)

The chronicle is a **frozen snapshot** at HEAD `c446055`. For current truth, read the live register:

| Register         | Frozen at | Live source                                       |
| ---------------- | --------- | ------------------------------------------------- |
| Gates            | II.A      | `GATES.md`                                        |
| Design decisions | II.B      | `MASTER_FIFO_PLAN_CLAUDE.md` §13                  |
| Decision log     | II.C      | `Plan.md`                                         |
| Audit corpus     | II.D      | `docs/audit/*.md`                                 |
| Corrections      | II.E      | `context/plan-corrections.md`                     |
| Rulings          | II.F      | `docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md` |
| Current state    | III       | `context/session-summary.md`, `PROGRESS.md`       |

## §6 — Staleness contract and stated limits

**Binding:** the anchors. Every anchor in §1 is asserted to resolve in the chronicle (exactly once for
the block, exactly twice for the declared dual-site set), and every heading in the chronicle is
asserted to appear in one of those two lists. Both directions run in `scripts/run-crew-tests.sh` with
fire-probes, so a drifted index fails the suite rather than misleading a reader.

**Advisory, not binding:** the line numbers. They are correct as of the build HEAD and will shift if
the chronicle is ever edited. Re-derive with a grep for the anchor; do not trust a line number that
disagrees with its anchor.

**What this index does not do, stated plainly:**

- It does not index every _mention_ of an ID — only its definition site (or first occurrence, for the
  19 `ref-only` entries). A theme sweep should use §4 and then grep, not §2 alone.
- The 18 heading-less CRs and `CK-CONFLUENCE-1` have no unique definition anchor **in the source
  record**; pointing at one would be inventing a precision the chronicle does not have.
- It indexes structure and identifiers, not claims. Whether a finding is still true is the live
  register's business (§5), and the chronicle's Part III gap list is the honest starting point.
