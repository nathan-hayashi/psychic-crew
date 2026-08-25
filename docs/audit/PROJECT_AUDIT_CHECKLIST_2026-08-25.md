# PROJECT_AUDIT_CHECKLIST_2026-08-25.md — full-history requirements audit, created then executed

Gate context: PROJECT-AUDIT-1 (operator plan approval, 2026-08-25). Uncommitted until a token says
otherwise. Repo state audited: parent `562dd65` (dev), Lite `713a3bf` (dev). All file:line
citations are pinned to those commits — the CR-033 doctrine applies: line numbers were true on this
date and are not maintained afterward.

## Restatement (task spec item 8)

1. Objective: a binary, evidence-cited audit checklist of every requirement the plan family has
   stated — vision through R-CH-1 — against what exists today in both repos and every non-pushed
   directory; created, then executed, nothing skipped.
2. Hard constraints: no assumptions, no hypothesis-as-result, no web root-causing; every check ran
   live this session against the files themselves; stale facts re-verified before reliance.
3. Non-goals: no user-input escalation mid-checks; documented falsehoods are REPORTED here, never
   corrected in place.
4. Standing corrections: none yet; errors found in settled material are flagged where found.
5. Output: this file; its registers are the direct inputs to a successor plan.

## How to scan this file (written for machine read passes)

- `grep -n '^### CK-'` lists every check. `grep -c 'STATUS: <X>'` tallies a verdict class.
- `grep -n '^## E'` jumps eras. `grep -n '^## R[0-9]'` jumps the registers.
- Field order inside every check block is fixed: REQ, CHECK, LIVE, VERDICT, STATUS, WHY, CLASS.
- STATUS vocabulary: `DONE` · `MISSING` · `CHANGED-AUTHORIZED(<record>)` · `CHANGED-UNBOUND` ·
  `ADDED-AUTHORIZED(<record>)` · `ADDED-UNBOUND` · `STALE-DOC-REPORTED` · `OPEN-BY-DECISION(<record>)` ·
  `RECORDED-EXCEPTION(<record>)` · `NOT-EXECUTABLE(<reason>)`.
- CLASS uses the plan's own evidence labels: `[E]` established · `[I]` inferred · `[S]` speculative.
- Every LIVE line reports a command actually executed on 2026-08-25 in this audit session. No check
  is answered from recall. VERDICT is the binary result of the CHECK predicate; STATUS is the
  requirement-level disposition that verdict supports.

## Content discipline this file obeys

Repo-relative paths only (the §5.2.4 scan is high-recall). No mermaid fences (the tracked-md
validator would parse them). No upstream conversation URLs, no memory-export content, no employer
or personal identifiers — the reconciliation record's crossing rule, extended to this file. Deny-
listed command adjacencies are described, never spelled (the C-22/CR-015 lesson: guards match whole
strings, and a contiguous literal here would deny future commands that quote this region).

## Method, stated

Zero subagent dispatches (planning and execution) so the audit could not desynchronize the
CR-006-bound metrics surface or flip C-25's honest SKIP — the audit must not mutate what it
measures. Solo evidence reads: every tracked file of both repos was read (authority and enforcement
files end-to-end; bulky dated audit records structurally plus every claim a check binds to — depth
per file is in the R6 inventory). Non-pushed surfaces read per the approved depth rule: the
Context-Transfer bundle in full, reports at identity level, the 16-directory reference corpus at
provenance/fence level only. The suites themselves are reused as instruments — a requirement is
"enforced" only if a named live assertion binds it, and this file says which one.

## B. Live baseline — seven runs, all captured 2026-08-25, tree as-found

The tree carried exactly one dirty entry before this audit began: ` M PROGRESS.md` (the PreCompact
emergency checkpoint appended by the compaction that preceded this task — see CK-E8-09). Every
deviation from a clean-tree expectation below is attributed, not chased.

### CK-B-01 · corrections checker is idempotent at the settled metrics state
REQ: H2a/CR-006 registered tension (Plan.md `[F8|2026-08-25T08:35:24Z] REGISTERED, NOT FIXED`): any regeneration after a dispatch desyncs the fence.
CHECK: git-status + TSV-line + snapshot-sha sandwich around `./scripts/check-plan-corrections.sh`.
LIVE: PRE tsv_lines=33 snapshot=61247ecc46b13855 → rc=0 → POST tsv_lines=33 snapshot=61247ecc46b13855; status delta empty; `== 21 APPLIED / 0 PENDING / 2 SUPERSEDED ==`.
VERDICT: PASS — byte-idempotent; the registered tension did not fire (zero dispatches post-settle).
STATUS: DONE
WHY: proves the audit's own mandatory checker run changed nothing tracked; validates the zero-dispatch method.
CLASS: [E]

### CK-B-02 · crew suite green except the attributed canary
REQ: suite green from the primary checkout (README:97-98; session-summary live-numbers line).
CHECK: `./scripts/run-crew-tests.sh`; FAIL lines enumerated.
LIVE: `== run-crew-tests: 178 PASS / 1 FAIL ==`; the single FAIL is `working tree dirty (1 entries)` = the pre-existing ` M PROGRESS.md`. C-28's canary-adjusted binding matched: "summary's crew suite figure matches this run (179 PASS / 0 FAIL)"; CR-027 matched 179 across every README claim.
VERDICT: PASS (expected shape exactly; zero substantive failures).
STATUS: DONE
WHY: the dirty-tree canary is doing its job on a real dirty entry; every functional assertion held.
CLASS: [E]

### CK-B-03 · structural validator green with the honest SKIP
REQ: 49 structural assertions, one announced SKIP (README:97; session-summary).
CHECK: `./scripts/validate-crew.sh`.
LIVE: `== validate-crew: 48 PASS / 1 SKIP / 0 FAIL ==`; SKIP = "C-25: no specialist subagent start recorded yet (identity coverage untestable)". C-28 binding matched.
VERDICT: PASS. STATUS: DONE
WHY: C-25's SKIP is the designed no-dispatch state, named and announced — and this audit deliberately preserved it.
CLASS: [E]

### CK-B-04 · distillation fidelity checker green
REQ: §15.5 semantics + PB-01..08 declared bindings (save-context.sh CLAIMS-MANIFEST v1).
CHECK: `./scripts/save-context.sh check`.
LIVE: `== save-context: 30 PASS / 0 FAIL ==`; PB-03 self-binding matched.
VERDICT: PASS. STATUS: DONE
WHY: every bold numeric claim in the summary is covered by a declared binding; completeness FAILs on unbound spans.
CLASS: [E]

### CK-B-05 · portability proven by both clone-free mechanisms
REQ: C-22 (the G-F8 demo re-expressed): archive extract + detached worktree both green.
CHECK: `./scripts/portability-drill.sh`.
LIVE: `PORTABLE — both mechanisms green at 562dd65`; extract ran validate-crew 39 PASS / 5 SKIP / 0 FAIL (announced work-tree SKIPs), worktree 45 PASS / 3 SKIP / 0 FAIL; absolute-path assertion RAN in the worktree (C-23 held); setup left the checkout clean (stamps idempotent).
VERDICT: PASS. STATUS: DONE
WHY: proves the shipped byte-set is self-contained and the C-23 fix has not regressed.
CLASS: [E]

### CK-B-06 · JML app suite green at the §7 floor
REQ: §7 "tests ≥15 and 100% green"; §6 F7(f) "test suite ≥15 cases incl. failure paths".
CHECK: `npm test` inside stress-project/, git-status sandwich.
LIVE: `tests 18 · pass 18 · fail 0`; sandwich clean (writes confined to gitignored tmp/).
VERDICT: PASS. STATUS: DONE
WHY: 18 ≥ 15 with the 18 case NAMES set-asserted by the suite (cases_F7), not merely counted.
CLASS: [E]

### CK-B-07 · Lite three-layer verification green, no signal
REQ: Lite plan §4 three-layer design; LITE-SECURITY-1 closing figures.
CHECK: `./scripts/verify.sh` in the Lite repo (no --record), git-status sandwich.
LIVE: `layer1 62/1/0 · sync 60/0 · distill 12/0 · stress 14/0 · layer2 48/0/0` · `no signal`; rolling-median comparison ran (62 vs median 31, no regression signal); sandwich clean.
VERDICT: PASS. STATUS: DONE
WHY: matches the LITE-SECURITY-1 gate row figures exactly — nothing in the twin moved since 713a3bf.
CLASS: [E]

## E0 — Vision and execution contract (plan header, §0–§3; the beginning)

### CK-E0-01 · the mission statement survives verbatim where the plan planted it
REQ: §4.1 payload line: "Mission: from-scratch AI Agent Crew for IT-automation orchestration… MASTER_FIFO_PLAN_CLAUDE.md … is the execution authority" (plan:47-48).
CHECK: byte-compare deployed CLAUDE.md against the §4.1 fenced payload (EX-01 delta assertion).
LIVE: suite line `EX-01 CLAUDE.md delta 0` (CK-B-02 run).
VERDICT: PASS. STATUS: DONE
WHY: the vision line is byte-pinned; the seed identity IS the requirement's enforcement.
CLASS: [E]

### CK-E0-02 · provenance and authorship trail of the vision itself
REQ: plan:3 "Authored 2026-08-02 R1/R2; re-iterated R3 same date after full ingestion of 5 repos + CrewAI docs + Claude Platform docs (see AUDIT_TRAIL_R3.md…)".
CHECK: existence of the cited authorship evidence.
LIVE: AUDIT_TRAIL_R3/R4/R5.md absent from both repos and from the retired channel's own listing; registered LOST at CONTEXT-TRANSFER-1 (docs/context-transfer-reconciliation.md, lost register; ROADMAP lost-artifact entry). The plan's header still cites them by name.
VERDICT: FAIL of the citation-resolves predicate — by prior registration, not new loss.
STATUS: RECORDED-EXCEPTION(lost-artifact register, 597cd0e)
WHY: the audit's findings survive in docs/audit/; the ARGUMENT (P1–P5 pushback trail) is gone from every side. Nothing new to chase; recorded so nobody re-derives it.
CLASS: [E]

### CK-E0-03 · the human counterpart the header promises does not exist anywhere reachable
REQ: plan:2 "Human counterpart: MASTER_FIFO_PLAN_USER.pdf v2."
CHECK: `ls` root PDFs + `git ls-files | grep -i user` + backup and bundle listings.
LIVE: the three root PDFs are research reports (405,477 / 382,032 / 194,017 bytes); no MASTER_FIFO_PLAN_USER.pdf on disk, in either repo's history, in the bundle's 21-file inventory categories, or in the backup. The lost-artifact register does NOT list it.
VERDICT: FAIL (cited artifact unreachable).
STATUS: MISSING
WHY: with the channel retired (R-CH-1) it joins the source_files category — exists-somewhere-unfetchable at best — but unlike source_files it was never adjudicated. NEXT-PLAN input: register it, or amend the header line under the plan's own gate.
CLASS: absence [E]; category [I]

### CK-E0-04 · §0 execution contract clauses hold where they are checkable
REQ: §0.2 exact-token FIFO · §0.2b forward-resume · §0.2c canonical verdicts · §0.2d untrusted input · §0.3 session-per-phase/checkpoint · §0.4 tier announcement · §0.5 error logging.
CHECK: per-clause artifact probe (GATES token cells; PROGRESS checkpoint discipline section; fixer/gate vocabularies in agents and rules; §0.2d text in arbiter-protocol + provenance hook; CREW_TIER_LOCK env; logs/build-errors.jsonl exists).
LIVE: 24/24 APPROVED rows carry the exact `**APPROVED** \`APPROVE …\`` needle, 0 awaiting; PROGRESS.md:3 "Checkpoint discipline (§6 F5, binding)" present; fixer.md verdicts exactly ACCEPT|REJECT|DEFER; arbiter-protocol.md carries §0.2d verbatim clause; settings env CREW_TIER_LOCK=T3; logs/build-errors.jsonl live.
VERDICT: PASS on every mechanically checkable clause.
STATUS: DONE
WHY: §0 is the contract everything else instantiates; each clause is bound to a named artifact above.
CLASS: [E]

### CK-E0-05 · §0.6 names an escalation channel that no longer exists
REQ: §0.6 "The escalation channel is the operator's Claude web chat session" (plan:14).
CHECK: compare against ruling R-CH-1 / D22 ("the operator is present in the session rather than relayed to"; the web project is closed).
LIVE: §0.6 text unchanged at v3.7; D22 updated only the fallback-protocol terminus description.
VERDICT: FAIL (clause describes a retired channel).
STATUS: STALE-DOC-REPORTED
WHY: D22 replaced the authorship rule and stated the fallback path is unaffected, but never touched §0.6's channel sentence. Same-family sites: CK-E0-06, CK-E1-22.
CLASS: [E]

### CK-E0-06 · HC-1..HC-8, each against its named enforcement
REQ: §1's eight hard constraints, each claiming machine-checkable enforcement.
CHECK: HC-1 lock+router+announcement checks (validate-crew tier block) · HC-2 five-layer guard (config forbidden list, apply-models scan, model-guard incl. resolution-over-proposed-config, validate-crew EX-03 assignment scan, F1 poison cases) · HC-3 stamps match the role table · HC-4 one-file-one-command (reroute/revert case) · HC-5 deny-list by name + behavioural denials + zero-dependency probe · HC-6 interpretation locks recorded · HC-7 vendor scan (CR-030) + deny case · HC-8 the §15 machinery (ccs-01..03, session-start, save-context).
LIVE: all named assertions PASSED in CK-B-02/B-03 this session (F1 five poison vectors exit 2; deny set present by name; HC-7 scan clean outside the 2-file allowlist; ccs-01/02/03 green; C-16 behavioural deny-list mutation caught).
VERDICT: PASS on all eight constraints' enforcement TODAY.
STATUS: DONE — with two textual caveats reported separately: HC-2's stale role sentence (CK-E0-07) and HC-2's session-model practice gap (CK-E0-08).
WHY: the constraints are the spine; each one's claimed enforcement demonstrably fires.
CLASS: [E]

### CK-E0-07 · HC-2's stated role for the forbidden family is out of date in two rule surfaces
REQ: §1 HC-2 and .claude/rules/model-policy.md both say the forbidden family "exists only as the operator's separate web-chat escalation channel".
CHECK: compare with R-CH-1 (channel retired).
LIVE: both sentences unchanged at 562dd65.
VERDICT: FAIL. STATUS: STALE-DOC-REPORTED
WHY: the prohibition itself is intact and enforced (CK-E0-06); only the narrative role sentence rotted. Gated one-line edits to plan §1 and model-policy.md would close it.
CLASS: [E]

### CK-E0-08 · the session-model decision trail — reported, not resolved
REQ: HC-2: "No agent, subagent, or session created by this plan may run on any fable model"; §4.6 pins the session model; settings.json today stamps `"model": "opus"` (alias mode).
CHECK: read the recorded precedent and compare with practice.
LIVE: Plan.md:259 `[F6|2026-08-13] MODEL` — G-F6 approval arrived with the orchestrator session on the forbidden family; F7 was opened and HELD, an escalation issued, blast radius recorded as zero because subagents run stamped frontmatter models regardless of the session model; PROGRESS.md:227 `HOLD LIFTED — F7 started` (operator). Current practice: the operator's standing directive runs interactive sessions on that family at max effort (this audit session included, operator-set via /model). No tracked rule records that directive; the only in-repo trace is the F6 hold/lift pair.
VERDICT: FAIL of "the practice is documented in a tracked rule"; PASS of "every agent surface is clean" (CK-B-03).
STATUS: STALE-DOC-REPORTED — a standing operator decision lives outside the filesystem, which is the exact breach class Lite's RULINGS.md preamble names.
WHY: NEXT-PLAN input: record the session-model ruling (scope, rationale, blast-radius argument) in model-policy.md under a gate, or revert practice. Not resolved here per the audit's non-goals.
CLASS: trail [E]; the standing-directive characterization [I] (it is operator practice + session evidence, not a repo record)

### CK-E0-09 · Q0 answers recorded verbatim and each one traced to its consequence
REQ: §3 "Record answers verbatim in Plan.md §Q0-Answers"; seven questions.
CHECK: read Plan.md:23-34; trace each answer's artifact.
LIVE: all seven recorded verbatim with decisions. Q1 PUBLIC + name (repo is public, named psychic-crew — the visibility override of the plan's private default is operator-authored at Q0). Q2 secrets DEFER → R-SEC-1 later formalized the zero-credential default. Q3 notify reuse → notify.sh/stop.sh wrap the WSL toast. Q4 JML + fixture-level theme overlay → D6 containment asserted live (zero theme tokens under src/ or bin/). Q5 45-min wall + 150K co-limit → later re-read as gate TRIGGER by operator rulings (C-18/C-20, G-F7a/b). Q6 pack order accepted → ROADMAP Q6 section. Q7 ETL pre-authorized → §11 lanes consumed at F2/F3/F5/F6.
VERDICT: PASS. STATUS: DONE
WHY: the operator's founding answers are all on disk, verbatim, and every one has a live descendant.
CLASS: [E]

### CK-E0-10 · the evidence-label vocabulary the project promised to use
REQ: plan:4 defines [E]/[I]/[S]/[V?]; §12(6) demands staleness [V?] lines.
CHECK: grep usage across authority docs.
LIVE: labels used in plan, README requirements table, budget-baseline, reconciliation record, bundle, and this file. Open [V?] items are enumerated (OQ-2 the only standing one; F0-era [V?] items all resolved with recorded verdicts — hook events, Stop JSON contract, per-agent effort, tools: field name).
VERDICT: PASS. STATUS: DONE
WHY: the epistemic convention is real practice, not decoration; this audit adopts it for that reason.
CLASS: [E]

## E1 — Build F0–F8: payloads, contracts, phases, thresholds

### CK-E1-01 · §4 seed identity, all three pinned seeds at delta zero
REQ: §4.1/4.2/4.3 payloads equal their deployed files byte-for-byte (A1b strict form; D14).
CHECK: suite EX-01 assertions (awk fence extraction diffed against deployed files).
LIVE: `EX-01 CLAUDE.md delta 0` · `EX-01 CLAUDE_DESIGN.md delta 0` · `EX-01 DIRECTORY_GUIDE.md delta 0`.
VERDICT: PASS. STATUS: DONE
WHY: seed identity is the exception the whole build rests on; R-CH-1 kept exactly this half.
CLASS: [E]

### CK-E1-02 · §4.4 Plan.md seed-prefix rule
REQ: D14: deployed Plan.md is a live ledger, checked as seed-prefix only.
CHECK: deployed Plan.md:1 + section heads against the §4.4 payload skeleton.
LIVE: Plan.md opens with the §4.4 header and carries all five seeded sections (Baseline, Q0-Answers, Open Questions, Fix Ledger, Review Notes) in order, then grows as a ledger — 522 lines at audit.
VERDICT: PASS. STATUS: DONE
WHY: the exemption is scoped and stated (a ledger cannot be byte-pinned).
CLASS: [E]

### CK-E1-03 · §4.5 model seed byte-identical
REQ: §4.5 models.config.json "write verbatim — the HC-4 single point".
CHECK: diff of the fenced payload against the deployed file.
LIVE: diff empty (0 changed lines).
VERDICT: PASS. STATUS: DONE
WHY: the single source of truth has never drifted from its seed.
CLASS: [E]

### CK-E1-04 · §4.6 settings divergence — fully authority-bound
REQ: §4.6 payload (29 fenced lines) with "merge-not-clobber" instruction.
CHECK: diff payload vs deployed (190 lines; 197 differing) and bind every divergence class.
LIVE: divergences = hook-entry schema (C-01), event rename (C-02), alias-stamped model value (EX-02 machinery; apply-models writes aliases.opus), added wiring for reference-cap (CR-022, gated), provenance-flag (C-13, operator-directed at G-F4), subagent-start (CR-025, gated `APPROVE CR-025`), SessionStart (§15.4 [V?] resolved at F0 step 6), plus formatting. Permission surface UNCHANGED against the seed: same 33 allow entries, same 14 deny entries (the CR-025 entry records "34 allow rules and 14 deny rules before and after" — its 34 counts differently than this file's 33-entry list count; both describe the same untouched surface).
VERDICT: PASS — zero unexplained divergence.
STATUS: CHANGED-AUTHORIZED(C-01 · C-02 · C-13 · CR-022 · CR-025 · F0-step-6 verdicts)
WHY: security.md forbids allow-rule additions without a gate; none occurred in the file's whole history.
CLASS: [E]

### CK-E1-05 · §4.7 ignore seed retained; growth append-only and gate-bound
REQ: §4.7 six-line seed; sensitive-guard blocks removals, permits appends (C-04's own path).
CHECK: every seed line still present verbatim; each added block traced.
LIVE: 6/6 seed lines present. Added blocks each carry their authority in their own comment: .claude/state/ (C-04) · corpus fence 2026-08-16 · report/explorer fences · Context-Transfer fence (CONTEXT-TRANSFER-FENCE, a42d50e) · Lite-plan fence (S6) · R-SEC-1 secret shapes (SECURITY-1).
VERDICT: PASS. STATUS: CHANGED-AUTHORIZED(per-block, as listed)
WHY: the publication perimeter grew only through gates, and each block argues its own glob.
CLASS: [E]

### CK-E1-06 · §5.1 roster: eight agents, contracts honored, stamps live
REQ: §5.1.1/5.1.2 verbatim seeds + 5.1.3 six contracts (tools, lenses, verdict vocabularies).
CHECK: suite F3 block (16 stamp/frontmatter assertions + read-only lens checks + {{APPLY}} sweep) plus direct reads of all eight bodies.
LIVE: 8/8 present, stamped model+effort per config (HC-4), frontmatter complete, read-only lenses hold no mutating tools (CR-016's capture-then-test form), zero placeholders. Reviewer bodies carry the D9 dimension sets, P0–P3, failure_scenario and the located-mitigation dismissal rule; fixer carries ACCEPT/REJECT/DEFER + steelman + suite-after-every-change; test-runner carries the no-interpretation contract; integration-runner scoped to stress-project with the Q4 theme note.
VERDICT: PASS. STATUS: DONE
WHY: the roster is the crew; every §5.1.3 behavioural clause is present in the deployed bodies.
CLASS: [E]

### CK-E1-07 · arbiter divergence from its verbatim seed — every changed line bound
REQ: §5.1.1 arbiter payload "verbatim".
CHECK: diff payload vs deployed (20 changed lines) and bind them.
LIVE: divergences = EX-05 law rewrite (nested dispatch does not exist; released-before-acted-on), C-19 ISO-8601 ts mandate bullet, task_id-must-match bullet (CR-021 lineage), PR-F2 CONFIRM read-back step 5 (write is not a write until read back — R-SD-1 rule 3's origin), renumbered RELEASE as step 6.
VERDICT: PASS — zero unexplained divergence.
STATUS: CHANGED-AUTHORIZED(EX-05 · C-19 · PR-F2 · CR-021)
WHY: each divergence is a registered correction with its own detector still live in the suites.
CLASS: [E]

### CK-E1-08 · §5.2 rules: four seeded, two added, one frontmatter dropped
REQ: §5.2.1 verbatim fallback-protocol (with `paths: ["**/*"]` frontmatter); 5.2.2–5.2.4 contracts; later gates added shell-discipline (D18/D19) and secrets-contract (R-SEC-1/D21).
CHECK: read all six; diff §5.2.1 body; census.
LIVE: fallback-protocol.md body verbatim to the payload INCLUDING anti-skip items 5–8 — but the payload's paths frontmatter is absent from the deployed file, with no recorded reason found anywhere (searched Plan.md, registry, CHANGE_REQUESTS). arbiter-protocol/model-policy/security match their contracts as corrected (C-05, D15, EX-03 lineage). shell-discipline v2 and secrets-contract present, both MIRRORED into Lite byte-identically (verified live, CK-E4-03).
VERDICT: PASS except the frontmatter sub-predicate.
STATUS: DONE overall; the dropped frontmatter is STALE-DOC-REPORTED (low) — an undocumented seed deviation, likely deliberate (rules under .claude/rules load unconditionally) but nowhere stated.
WHY: an unexplained byte-level deviation from a "verbatim" payload is exactly what this registry exists to record, however small.
CLASS: divergence [E]; "likely deliberate" [I]

### CK-E1-09 · §5.3 router skill byte-faithful and falsifiable
REQ: §5.3 verbatim SKILL.md; G-F4 stress needs the scoring path reachable.
CHECK: diff deployed skill vs payload; suite F4 router assertions.
LIVE: deployed .claude/skills/threshold-router/SKILL.md matches §5.3 (3 rules); suite asserts rule 1 conditional on the lock, rule 2 an else-branch, exact `[T3 — LOCKED]` token, thresholds present — all PASS.
VERDICT: PASS. STATUS: DONE
WHY: an unconditional rule 1 would make the G-F4 stress unfalsifiable; the conditionality is asserted.
CLASS: [E]

### CK-E1-10 · §5.4 discourse grammar lives in the reviewer/arbiter contracts and ran at F7
REQ: dimension labels, P0–P3, Failure-scenario line, dismiss-only-with-read-mitigation, two rounds, AGREE/CHALLENGE/CONNECT/SURFACE, confidence arithmetic.
CHECK: reviewer bodies + arbiter contract + F7 evidence (logs/rounds/f7-round-1, f7-round-2 exist; GATES G-F7b row).
LIVE: contracts carry every element (CK-E1-06); logs/rounds holds both F7 round dirs plus round-1; G-F7b row records the discourse having run with findings adjudicated.
VERDICT: PASS. STATUS: DONE
WHY: the replaced-native-review design (D1/D4/HC-7) is implemented in contracts and exercised in the one phase that mandated it.
CLASS: [E]

### CK-E1-11 · §5.5 script contracts vs the ten deployed scripts
REQ: F0 contracts name apply-models (verbatim core), setup, validate-crew, run-crew-tests; §15 adds save-context and restore-context; corrections added the other four.
CHECK: per-script existence + contract conformance + authority for the additions.
LIVE: 10/10 present and read end-to-end. apply-models carries the EX-02(a,b,c) corrections over the §5.5 core (the payload's jq boolean-index bug and subshell-exit bug are fixed and registered); setup honors "installs nothing" (verified by the drill and by reading); validate-crew implements every §5.5-named assertion plus its audit-era growth; run-crew-tests implements the append-a-case pattern with cases_F0..F7. Additions: save-context (§15.5) · restore-context (§15.9d) · portability-drill (C-22) · measure-dispatch-cost (C-21) · check-plan-corrections (registry executor; its own header states the discovery path) · gate-guard (H0a/D20).
VERDICT: PASS — zero unbound scripts.
STATUS: DONE; additions ADDED-AUTHORIZED(§15.5 · §15.9 · C-22 · C-21 · registry · H0a)
WHY: the enforcement layer is exactly the contracted set plus six correction-born tools, each carrying its registration in its header.
CLASS: [E]

### CK-E1-12 · §5.6 hook contracts vs the fourteen deployed hooks
REQ: nine contracted hooks + conditional session-start [V?] + §15.9 machinery; corrections added the rest.
CHECK: census + wiring both directions + behavioural coverage.
LIVE: 14 tracked = 9 contracted (bash-blocker, model-guard, sensitive-guard, audit-logger, auto-format, error-recovery, pre-compact-checkpoint, notify, stop) + session-start ([V?] resolved YES at F0 step 6) + _common.sh (shared preamble, R2 fallback-root rule, scrub(), ledger-derived PHASE per CR-014) + provenance-flag (C-13) + reference-cap (CR-022) + subagent-start (CR-025). CR-003/C-26 assertions hold wiring↔disk in both directions; every wired hook behaviourally exercised in CK-B-02 (denials, allows, records, redactions, flag semantics, checkpoint mechanics).
VERDICT: PASS — zero unbound hooks, zero unwired tracked hooks.
STATUS: DONE; additions ADDED-AUTHORIZED(F0-step-6 · R2 · C-13 · CR-022 · CR-025)
WHY: the map enumerates all fourteen by name (D17), and the tree, the wiring, and the map three-way agree today.
CLASS: [E]

### CK-E1-13 · gates G-F0..G-F8 all closed with exact tokens, tags, and demo/stress evidence
REQ: §6 per-phase gates; §0.2 exact tokens; §0.3 tags crew-f<n>; C-17 for the F7 split.
CHECK: GATES rows + `git tag -l`.
LIVE: ten build tokens APPROVED in ledger grammar (GATE-F0..F6, GATE-F7a, GATE-F7b, GATE-F8); tags crew-f0..crew-f8 and v1.0.0 all exist; each row carries demo and stress cells with named evidence, several recording defects found AT the gate (G-F0 evidence decay repaired and re-verified; G-F2 silent-denial fix). C-17: the F7a/F7b tokens were operator-defined and recorded verbatim, closing the grammar gap by completion.
VERDICT: PASS. STATUS: DONE
WHY: the FIFO machine ran exactly as specified, and its ledger is grammar-perfect against the H0a needle (24/24, zero awaiting).
CLASS: [E]

### CK-E1-14 · F7 rollback discipline left real tags
REQ: lead-planner PLAN schema requires rollback_tag per step.
CHECK: `git tag -l` for rollback tags.
LIVE: rb/f7-a1 a2 a3 a4 a5 a7 b7 b10 exist (8 tags spanning Stage A and B steps).
VERDICT: PASS (partial coverage across steps — tags exist where the plan's steps declared rollback points).
STATUS: DONE
WHY: the schema's rollback field produced real, still-present anchors; nothing claimed full per-step coverage.
CLASS: [E]; the where-declared explanation [I]

### CK-E1-15 · §7 thresholds, re-verified against today's artifact
REQ: tests ≥15 green · seeded-bug 3/3 · edge 3/3 · coverage 8/8 · post-review defects 0 · arbiter lines ≥ dispatches correlated by identity · token spend measured-not-barred (D3c).
CHECK: live app suite + suite F7 block + GATES G-F7b row + f7-metrics.
LIVE: 18/18 today (CK-B-06); the three edge exits re-proven live this run (0/1/2 with exact artifact counts); determinism falsifiable both ways; REPLAYED path proven live (CR-017); historical axes (seeded 3/3, coverage 8/8, defects 0, Velocity by trigger) recorded in G-F7b + context/f7-metrics.md with denominators fixed pre-run (C-18).
VERDICT: PASS. STATUS: DONE — Velocity's disposition is CHANGED-AUTHORIZED(D3c · G-F7a/b operator rulings): measured and reported, never a pass/fail bar.
WHY: the one judgement rubric of the build holds up under re-execution where re-executable.
CLASS: [E]

### CK-E1-16 · §9 error-corpus assertions live (the 23→17 transform)
REQ: F6: transform the 23 documented corpus errors into executable assertions, zero verbatim copying.
CHECK: cases_F6 census + pass state.
LIVE: corpus/ERR1..ERR6 + E5/E6/E7/E10 + §9 naming + phantom-deps assertions all present and green; the file states the transform provenance (12 orchestration + 11 mermaid = 23) and each check binds to THIS repo's paths.
VERDICT: PASS. STATUS: DONE
WHY: the ETL lane's product is live enforcement, not notes.
CLASS: [E]

### CK-E1-17 · §10 gate-report template and §12 self-check practiced
REQ: §10 report shape at every gate; §12 six-point self-check before every gate.
CHECK: sampled gate-era records.
LIVE: Plan.md carries an explicit §12 six-point self-check at B10 (`[F7|2026-08-13T23:37:06Z] B10 §12 SELF-CHECK` — all six points addressed, weakest claim flagged); GATES rows carry the demo/stress/token structure the template demands; gate-mode `run-crew-tests.sh gate` regenerates live evidence by design ("answer a gate against this, never against a recorded claim").
VERDICT: PASS (procedural obligations, evidenced by their artifacts at the phases sampled).
STATUS: DONE
WHY: the self-check discipline demonstrably ran where the stakes were highest (F7).
CLASS: [E for the sampled evidence; I for "every gate" universality]

### CK-E1-18 · §15 continuity system — every mechanism live-proven
REQ: 15.1 filesystem-as-truth · 15.2 reference-passing · 15.3 PreCompact+flag+Stop-block · 15.4 re-grounding · 15.5 distill-merge · 15.6 cadence · 15.7 ccs-01/02 · 15.9 WORKAROUND-01 + ccs-03.
CHECK: suite ccs assertions + hook reads + live session evidence.
LIVE: ccs-01 (checkpoint append, flag armed, exit-0-under-unwritable), ccs-02 (cold start reproduces next_action; labels round-trip), ccs-03 (five-field snapshot, retention ≤10, latest refreshed, restore prints the reload instruction) all PASS; retention measured at exactly 10 numbered snapshots; SessionStart emitted the §15.4 block into THIS session (observed directly); reference-cap enforces 15.2's 30-line excerpt cap flag-only; save-context implements 15.5 with the C-28 manifest.
VERDICT: PASS. STATUS: DONE — WORKAROUND-01 remains OPEN-BY-DECISION(ROADMAP removal condition): interim by design, removed when an official capability lands.
WHY: HC-8 is the constraint this audit itself ran under; its machinery demonstrably carried this very session across a compaction.
CLASS: [E]

### CK-E1-19 · §6 phase budgets — superseded by measurement, by ruling
REQ: §6 per-phase token budgets (319K whole-build).
CHECK: budget-baseline.md + rulings.
LIVE: measured 2,045,319 for F7 alone (9.88×); operator rulings D3c + G-F7a/b re-read the ceiling as a gate trigger; budget-baseline.md is the standing instruction ("budget every future phase from measurement, never from §6"), and lead-planner.md hard-codes that instruction into its step 3.
VERDICT: PASS of the corrected requirement.
STATUS: CHANGED-AUTHORIZED(D3c · C-18 · C-20 rulings; baseline file)
WHY: the original numbers were wrong by an order of magnitude; the correction is recorded, bound (C-20 row floor ≥5), and contractually consumed by the planner.
CLASS: [E]

### CK-E1-20 · §11 ETL registry: five lanes, all consumed or dormant as stated, licences on record
REQ: 11.1 F6 corpus → assertions · 11.2 OCR patterns → discourse/warn-contract/setup-guard · 11.3 turbo → anti-skip/prompt-contracts/handoff · 11.4 neatcontext → §15 mechanics (MANDATORY under HC-8) · 11.5 Managed Agents lane dormant.
CHECK: per-lane descendant artifacts + attribution sites.
LIVE: 11.1 = cases_F6 (CK-E1-16); 11.2 = §5.4 grammar + apply-models [WARN] contract + validate-crew-as-pre-op; 11.3 = fallback items 5–8 + DISPATCH XML shapes + PROGRESS checkpoint format; 11.4 = the §15.3/15.5 mechanics; 11.5 = ROADMAP dormant lane with gating facts. Attributions present in CLAUDE_DESIGN/plan (MIT ×3, Apache-2.0 ×1); all 16 corpus dirs carry license files (censused live).
VERDICT: PASS. STATUS: DONE
WHY: every sanctioned external contact produced a from-scratch native descendant with its licence trail.
CLASS: [E]

### CK-E1-21 · plan end-marker debris
REQ: internal version coherence of the authority document.
CHECK: header vs closing markers.
LIVE: header says v3.7; line 342 says "END OF MASTER FIFO PLAN (machine copy)"; §13 heading still says "CHANGELOG — v2.0"; line 405 closes with "# END v2.2". The changelog body itself documents through D22 (v3.7).
VERDICT: FAIL of marker coherence (content coherent, markers stale).
STATUS: STALE-DOC-REPORTED
WHY: harmless to execution, hostile to a cold reader inferring the version from the tail. One-line gated fix now possible under R-CH-1.
CLASS: [E]

### CK-E1-22 · §14.1's oracle row still routes to the retired channel
REQ: §14.1 consult-operator-oracle: "package a consult block for the OPERATOR to paste into their … web chat — the standing escalation channel".
CHECK: compare with R-CH-1.
LIVE: text unchanged at v3.7; same family as CK-E0-05/E0-07.
VERDICT: FAIL. STATUS: STALE-DOC-REPORTED
WHY: the consult-block pattern itself survives (the operator is present in-session); the routing sentence does not.
CLASS: [E]

## E2 — v1.0.0 and the independent audit era

### CK-E2-01 · the audit record exists, is complete, and is deliberately frozen
REQ: an independent post-v1.0.0 audit with its record in docs/audit/ (session-summary claim).
CHECK: census + CR-033 doctrine.
LIVE: 8 files present (FINAL_AUDIT_REPORT 897L, DECISION_AUDIT, DECISION_MATRICES, DIAGRAM_AUDIT, CHANGE_REQUESTS 532L, PLATFORM_GAP_POWERSHELL, PROMPT_READINESS, RULINGS_AND_DEPLOYMENT). CR-033's note pins their line-number semantics to their date; session-summary instructs reading them as found-on-2026-08-17.
VERDICT: PASS. STATUS: DONE
WHY: the audit's product was "truth plus a priced backlog"; the record survives unrewritten by doctrine.
CLASS: [E]

### CK-E2-02 · the audit-gate token convention, verified precisely
REQ: A-series gates approved with exact tokens; recorded outside GATES.md by stated convention.
CHECK: grep all four surfaces for the A-token forms.
LIVE: await-lines with exact tokens at PROGRESS.md:405 (A0), :412 (A3), :421 (A5); the verbatim token also at docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md:67; approvals recorded as events — Plan.md:363 "[A5|2026-08-17T05:50:43Z] AUDIT-GATE-A5 APPROVED — AUDIT CLOSED. Three audit gates approved: A0, A3, A5" and PROGRESS.md:423 heading. GATES.md deliberately carries none (reopening-a-closed-plan rationale, stated at Plan.md:514).
VERDICT: PASS of the convention.
STATUS: DONE — one precision note: Plan.md:514's sentence "Plan.md:363 records it" overstates by a word; :363 records the approval EVENT, not the verbatim token string. Under this project's own verb-is-part-of-the-token doctrine (Lite F-L4) that distinction is load-bearing; the tracked reconciliation entry X-05 phrases it correctly ("recorded in Plan.md") and its Verify predicate passes.
WHY: three A-gates, all traceable; the convention is a decision with a stated reason, not drift.
CLASS: [E]

### CK-E2-03 · the 33-CR priced backlog and its freeze discipline
REQ: CHANGE_REQUESTS.md as the priced backlog; operator freeze until S6; correct-in-place afterwards.
CHECK: read structure + freeze note + post-freeze consumption trail.
LIVE: ranked table + detail + "BACKLOG FROZEN until S6 completes — operator decision, 2026-08-19"; S6 completed 2026-08-20 (PROGRESS); post-freeze CR work proceeded only through gates (CR-BATCH-1, CR-025, CR-026, CR-DIAGRAMS rows). CR-status language inside the frozen file reads as of its date per CR-033.
VERDICT: PASS. STATUS: DONE
WHY: the backlog is the audit's deliverable and its freeze was honored to the recorded date.
CLASS: [E]

### CK-E2-04 · CR-003's status is stated three ways that do not agree on the surface
REQ: single coherent status for CR-003 (the d2 hook-pipeline topology).
CHECK: all status sites.
LIVE: PROGRESS `[F8|2026-08-21T15:55:25Z] CR-003 + CR-006 DELIVERED` and Plan.md:439 ("the operator lifted the deferral") record delivery; the suite's three CR-003 assertions are live and green today (both-direction set difference against settings.json). Against that: plan D20 (v3.5, 2026-08-23) says "H1b: CR-003 (d2) remains deferred by ruling", and CHANGE_REQUESTS.md:500 says "CR-003 remains deferred by ruling H1b". The reconcilable reading: the SPEC half shipped (bound d2 topology in README; renderer honesty stated) while the RENDERER half remains deferred under HC-5 — CHANGE_REQUESTS:482's "no d2 renderer" wording supports this. No single record states the split.
VERDICT: FAIL of surface coherence; the underlying state is consistent under the split reading.
STATUS: STALE-DOC-REPORTED — D20's clause and the backlog's blanket "remains deferred" postdate the delivery and name the whole CR.
WHY: a future session grepping "CR-003" gets contradictory verdicts depending on which file it hits first; one gated clarifying line would close it. (This audit's own memory index carried the imprecise version and is corrected as part of closing.)
CLASS: sites [E]; split reading [I]

## E3 — Hardening S1–S4 and the plan's v3.x era

### CK-E3-01 · every S-era gate closed in ledger grammar with its work verifiable today
REQ: the post-audit hardening ran gated: CR-BATCH-1 (S1), CR-025 (S2), CR-DIAGRAMS (S3), CR-026 (S4), plus PLAN-V3, R1D, GUIDANCE-1, GUIDANCE-2, GUARD-1, PARENT-SYNC-1.
CHECK: GATES rows (all 10 tokens in the 24-row census) + each gate's product probed live.
LIVE: S1 detector repairs (CR-009/010/013/015/016/019/024) all present in today's scripts and each carries its registry account; S2's two hooks wired and behaviourally tested (CK-E1-12); S3's mermaid validator inline with ≥5-block floor green and the inline-placement reason stated in code; S4's intake skill present at the mapped path with vocabulary parity and an exercised classifier (suite F4 block); PLAN-V3 swapped the canonical plan per D14; R1d closed native-Windows permanently (README + ROADMAP + PLATFORM_GAP); GUIDANCE-1/2 landed R-SD-1 v1/v2 with both class scanners live (29-site census swept to 0, asserted every run); GUARD-1 landed gate-guard + the CR-006 tracked-data form; PARENT-SYNC-1 landed D17 hooks enumeration + C-26 closure + declared bindings.
VERDICT: PASS. STATUS: DONE
WHY: every hardening token's product is independently alive in today's green suites — none is a paper gate.
CLASS: [E]

### CK-E3-02 · the intake layer (CR-026) — asserted half green, model-interpreted half stated
REQ: R3a hybrid intake; classifier as data; no second severity scale; manual drills for the judgment half.
CHECK: suite CR-026 assertions + skill read + this session's own use.
LIVE: path-from-map, vocabulary parity (crit/high/med/low == security.md), classifier table exercised (read-only=low, settings=high, gate-rule=crit) — all PASS; the skill's own §5 states what is deliberately NOT mechanically asserted. This audit itself ran the intake flow (med-class contract emitted with read-back, zero questions per rule 2).
VERDICT: PASS. STATUS: DONE
WHY: the weakest-link observation that motivated CR-026 (the human side had no contract) is closed to exactly the depth the skill claims and no further.
CLASS: [E]

### CK-E3-03 · README bound figures vs unbound figures
REQ: CR-027: every README count claim agrees with the live run.
CHECK: suite CR-027 assertions + a sweep of README's other numeric claims.
LIVE: bound and green: "49 structural assertions" (both sites) and "179 crew assertions" match this run. UNBOUND and stale: README:50 "Tracked files / bytes | 87 files, ~1.0 MB" — live count 95 (and ~1.1 MB). Nothing binds the footprint row; it froze at its writing date while eight files arrived through later gates.
VERDICT: FAIL for the footprint row's accuracy.
STATUS: STALE-DOC-REPORTED — the exact class CR-027 was built for, on a claim CR-027 does not cover.
WHY: NEXT-PLAN input: bind or date-stamp the footprint row (the CR-027 mechanism already exists to extend).
CLASS: [E]

## E4 — The Lite twin

### CK-E4-01 · eleven Lite gates, grammar-clean, one recorded breach
REQ: L0–L4 phase gates + LITE-SYNC-1/2 + R-SP-1 + LITE-GUARD-1 + PACK-CONFLUENCE-1 + LITE-SECURITY-1, exact-token discipline.
CHECK: Lite GATES rows.
LIVE: 11 APPROVED rows in the same needle grammar; LITE-SYNC-2's row records its own violation verbatim ("the commit landed BEFORE this token… Recorded here rather than smoothed over") — the breach that earned H0a.
VERDICT: PASS. STATUS: DONE; the breach is RECORDED-EXCEPTION(LITE-SYNC-2 row · H0a/D20)
WHY: the ledger carries its own worst moment in its own words, which is the property that makes it a ledger.
CLASS: [E]

### CK-E4-02 · the §7.1 sync correlation — 55 rows, five relations, enforced not documented
REQ: docs/SYNC-CORRELATION.md as the requirement; check-sync as its enforcement; versioned anchor.
CHECK: map census + live run.
LIVE: SYNC-MAP v1 parses to 55 rows (21 ADAPTED · 14 ADDED · 14 DROPPED · 5 MIRRORED · 1 PACK); check-sync 60 PASS / 0 FAIL / 0 REVIEW in CK-B-07; vacuity guard first; PACK relation carries the parent-side why.
VERDICT: PASS. STATUS: DONE
WHY: the map-rots-into-documentation failure class (CR-024's origin) is structurally closed in the twin.
CLASS: [E]

### CK-E4-03 · all five MIRRORED rows byte-identical, re-proven now
REQ: MIRRORED means byte-identical (L0 row: ".gitattributes diverging was caught within minutes").
CHECK: per-row cmp against the parent, live.
LIVE: fallback-protocol.md, shell-discipline.md, gate-guard.sh, secrets-contract.md, .gitattributes — 5/5 identical.
VERDICT: PASS. STATUS: DONE
WHY: parent moved to v3.7 after Lite's last commit; nothing MIRRORED was touched by R-CH-1, and the live cmp proves the skew is zero where the contract demands zero.
CLASS: [E]

### CK-E4-04 · Lite's three-layer verification design delivered as specified
REQ: Lite plan §4: behavioural suites + witness manifest + temporal history; declared bindings (CLAIMS.md); stall/divergence detection; release law.
CHECK: verify.sh layers + witness/claims/history files + stress run.
LIVE: layer1 62/1/0 (single-script design, stated as a decision) · sync 60/0 · distill 12/0 (CLAIMS.md-bound) · stress 14/0 (release law under traffic, fixture-isolated post-C-13) · layer2 48 OK/0 STALE/0 FAIL (comment-stripped markers + content hashes; STALE exits 2 distinct from FAIL) · layer3 rolling-median no-signal. verification-history.jsonl tracked (bisectable from a clone, by stated design).
VERDICT: PASS. STATUS: DONE
WHY: the twin's verification stack is the parent's lessons rebuilt as architecture rather than patches.
CLASS: [E]

## E5 — Rulings in force

### CK-E5-01 · R-SD-1 v2 — both class scanners live in both repos, allowlists empty
REQ: shell-discipline rules 1–6; enforcement = two class assertions per repo, comment-stripped, fragment needles, empty allowlists.
CHECK: suite tails both repos + rule mirror.
LIVE: parent: "R-SD-1 class scan covers 24 tracked shell file(s)" + "no count-then-default composite" + "rule 5: no status-consumed pipeline with a signal-able producer (24 files, census 29 -> 0)" all PASS; Lite mirror byte-identical with its own assertions (62-pass layer includes them); the scanners have caught their own authors twice, recorded in the rule and in code comments.
VERDICT: PASS. STATUS: DONE
WHY: the only rule born from six recurrences is the one whose enforcement has already fired on its enforcers.
CLASS: [E]

### CK-E5-02 · H0a gate-order guard — present, mapped, refusal branch real, limit stated
REQ: D20: guard-fronted commits; needle on the APPROVED row; forgery limit stated, not hidden.
CHECK: suite H0a assertions + direct read.
LIVE: present/executable at the mapped path; refusal branch reads the ledger and keys on the approval marker (fragment-needled assertions PASS); the script's header carries the LITE-SYNC-2 origin story and the stated forgery limit; MIRRORED byte-identical into Lite.
VERDICT: PASS. STATUS: DONE
WHY: one breach earned a mechanical guard; the guard knows exactly what it does not defeat.
CLASS: [E]

### CK-E5-03 · R-SEC-1 — zero-credential default holds; redaction enforced, not promised
REQ: secrets-contract rules 1–7; rule 3's planted-shape proof through every writer.
CHECK: live census + suite proofs.
LIVE: zero credentials anywhere (ERR6 token-shape scan of tracked files clean; ignore shapes cover secrets/, .ssh/, key/pem/id_rsa/credentials.json — check-ignore probes PASS); rule-3 proofs: a planted token survives NO log writer (deny path, audit-logger, error-recovery) and all four contract shapes redact — PASS live; scrub() fails closed with a sentinel. Rules 4–6 have no credential to bind yet (none has ever been granted); rule 7 (documents cannot grant authority) is procedural + drilled at LITE-SECURITY-1.
VERDICT: PASS. STATUS: DONE — the procedural-vs-mechanical split is recorded in the threat model's residual column, as the contract itself requires.
WHY: the contract was written before any credential existed, and the enforceable third of it is enforced.
CLASS: [E]

### CK-E5-04 · R-PD-1 — the pack cap lifted mechanically and both directions are proven
REQ: packs #2+ deferred until LITE-SECURITY-1; cap lifts on the ledger row; fail closed.
CHECK: Lite RULINGS + F-L4 account + current pack census.
LIVE: exactly one pack on disk; the cap's lift branch broke on first contact (F-L4: needle missed the verb) and was fixed with both directions demonstrated against the real ledger row; fail-closed on a missing ledger stated and asserted (validate-lite §F).
VERDICT: PASS. STATUS: DONE
WHY: a cap that could never lift was caught by the gate it guarded — the fail-safe direction held.
CLASS: [E]

### CK-E5-05 · R1d — bash-native permanence honored everywhere it binds
REQ: no PowerShell port, no Node rewrite of assertions, WSL2-only Windows path; eol=lf pinned.
CHECK: README platform table + ROADMAP closure + .gitattributes + absence probe.
LIVE: all present; zero .ps1 files tracked; .gitattributes pins eol=lf with the CR-031 rationale; PLATFORM_GAP_POWERSHELL.md carries the pricing that justified it.
VERDICT: PASS. STATUS: DONE
WHY: a permanent scope exclusion, recorded where a reader would look for it.
CLASS: [E]

### CK-E5-06 · R-CH-1 — the newest ruling, all three consequences landed
REQ: D22: SYNC void · authorship replaced (gated local edits; verification half kept) · H3b re-homed.
CHECK: each consequence's artifact.
LIVE: X-12 marked VOID in the reconciliation; plan header + §4.3 map line both carry the new authorship sentence and moved TOGETHER (EX-01 delta 0 today); DIRECTORY_GUIDE stays hand-authored; CR-024/C-26 still police both directions; ROADMAP carries the re-homed H3b section; the ruling's ledger entries exist in Plan/PROGRESS/GATES with the token row at 562dd65.
VERDICT: PASS. STATUS: DONE
WHY: the constitutional change of the era is fully instantiated — and its residue (four stale narrative sites in the plan/rules, CK-E0-05/07, E1-22) is reported above rather than absorbed silently.
CLASS: [E]

## E6 — Security phase (both repos)

### CK-E6-01 · the joint threat model exists with honest residuals — and the residuals still hold
REQ: D21/S2a: one parent-side document covering both repos: assets, boundaries, actors, 12 surfaces with control/tested-by/residual.
CHECK: read all 12 rows; spot-verify residual claims against today's state.
LIVE: all 12 rows present. Residuals re-verified where checkable: forgery limit still real (row 1; gate-guard header agrees); docs/ converse exemption still by-design (row 7; this file relies on it); prose-confidentiality gap now partially narrowed by the crossing-rule assertion (row 12 predates it — the validator now DOES read one prose file for one confidentiality property; the residual sentence "no check reads prose for confidentiality" is a shade stale post-CONTEXT-TRANSFER-1).
VERDICT: PASS with one residual-row refinement reported.
STATUS: DONE; row-12 wording is STALE-DOC-REPORTED (low) — strictly, one check now reads one prose file for one URL class.
WHY: a threat model whose residuals rot silently becomes a comfort document; this one is one sentence from current.
CLASS: [E]

### CK-E6-02 · both red-team passes recorded with findings that map to live fixes
REQ: parent redteam-1 (F-1 error-recovery leak, F-2 model-guard indirection, F-3 gitignore-vs-security.md) and Lite redteam-1 (F-L1..F-L4 + 6-fixture drill + probes + one honest SKIP).
CHECK: each finding's fix live today.
LIVE: F-1 → error-recovery scrubs (rule-3 proof green); F-2 → model-guard resolves proposed configs (code present; ported back from Lite); F-3 → the R-SEC-1 ignore block (check-ignore green); F-L1 → continuity scrubber sourced + fail-closed; F-L2 → run-scoped drills/ gitignored; F-L3 → find-based fixture handling; F-L4 → cap needle fixed. Every finding has a live descendant control.
VERDICT: PASS. STATUS: DONE
WHY: the red-team era's product is enforcement deltas, all still present.
CLASS: [E]

## E7 — Packs

### CK-E7-01 · the first pack holds its three-letter contract and its publication perimeter
REQ: P1a file-based intake · P2a no credentials by construction · P3a proposals only · A4a untouched · workspaces gitignored on the pack-root glob · PACK row with parent-side why.
CHECK: pack census + Lite ignore rules + sync PACK row + live suite.
LIVE: one pack (confluence-docs) with tracked machinery only (PACK.md, doc-standards.md, templates, fixtures); inbox/work/out/drills all gitignored via the pack-root glob; PACK row declared with its why (B3a); zero credentials anywhere (CK-E5-03); check-sync PACK branch green.
VERDICT: PASS. STATUS: DONE
WHY: the only surface that ingests foreign content is the most fenced thing in either repo.
CLASS: [E]

### CK-E7-02 · PACK-1 LIVE ran on a real document and the record is honest about re-derivation
REQ: reconciliation X-02: real document processed 2026-08-24; artifacts re-derived after the F-L2 drill loss (18 findings vs the original 17, the extra med NOT dropped).
CHECK: reconciliation entry + Lite redteam F-L2 account.
LIVE: both records present and agree; the loss, the structural fix (run-scoped drills/), and the refusal to force the totals to match are all written down.
VERDICT: PASS. STATUS: DONE — the artifact loss itself stands as RECORDED-EXCEPTION(F-L2)
WHY: an evidence chain that admits "re-derived, not restored" is worth more than one that pretends continuity.
CLASS: [E]

## E8 — Context-transfer and the channel retirement

### CK-E8-01 · the fence holds by every mechanism, including history
REQ: Context-Transfer*/ never tracked, staged, or pushed; probes ask git, not the rule text.
CHECK: check-ignore probe on a non-existent path; stage-everything probe + tracked companion; add-history scan.
LIVE: all three green this session — the probe path ignores; the normalized stage scan names zero fenced paths across 95 tracked files; `git log --all --diff-filter=A` over every fenced pattern returns empty (nothing fenced was EVER tracked in any commit).
VERDICT: PASS. STATUS: DONE
WHY: in a public repo the history is the publication surface; all three tenses are clean.
CLASS: [E]

### CK-E8-02 · the stage-everything claim is finally asserted, with its limit stated
REQ: five documents claimed "stage-everything = 0" for weeks with nothing checking it (SECURITY-1's F-3 shape).
CHECK: validate-crew publication block.
LIVE: vacuity-guarded (fails if git answers with <50 tracked files), normalization-aware (the add-dry-run wrapper is stripped so one regex serves probe and companion), enumerative limit STATED in code ("will report ZERO for tomorrow's unfenced drop — extend it with every new fence").
VERDICT: PASS. STATUS: DONE
WHY: the parent's first asserted version of its oldest publication claim, with the honest boundary written where the next editor will read it.
CLASS: [E]

### CK-E8-03 · the reconciliation record — contract, twelve claims, crossing rule enforced
REQ: bundle never edited; X-01..X-12 each with Bundle-says/ground-truth/Verify/Disposition; crossing rule asserted by the validator.
CHECK: read the record; run its own Verify predicates where cheap; the URL assertion in CK-B-03.
LIVE: header contract present; twelve entries with dispositions (4 CORRECTED · 1 PRECISION · 1 ALREADY DONE · 4 CONFIRMED · 1 CONFIRMED-then-VOID · X-12 VOID under R-CH-1); the conversation-URL assertion PASSED live; the bundle itself untouched (mtimes 2026-08-25 00:38, pre-fence; byte-identity vs backup below).
VERDICT: PASS. STATUS: DONE
WHY: the repo's first convention for correcting an external record works and is enforced.
CLASS: [E]

### CK-E8-04 · the backup is real — proven at the correct layout, after one wrong probe
REQ: reconciliation: "copied to the backup directory under $HOME, verified byte-identical per file".
CHECK: cmp per file.
LIVE: first probe compared a flat layout and reported all six differing — a wrong-construct probe (the copy is nested: backup-dir/Context-Transfer/*.md). Re-probed at the actual layout: 6/6 byte-identical. Both probes recorded here per R-SD-1 rule 6 — the near-miss's clean-looking failure was void, not evidence.
VERDICT: PASS. STATUS: DONE
WHY: the recovery path for a `git clean` accident exists and is intact; and the audit's own first probe is disclosed rather than discarded.
CLASS: [E]

### CK-E8-05 · the lost-artifact register keeps its two categories, post-R-CH-1
REQ: never-delivered (source_files/, 21 files promised by the bundle index) ≠ lost-from-both-sides (AUDIT_TRAIL_R3/R4/R5, the final-audit prompt); R-CH-1 removed the recoverability ground without merging the categories.
CHECK: register + ROADMAP entry + bundle index line.
LIVE: all present and mutually consistent; the bundle's own manifest still promises source_files/ (its last table row), and the directory is absent — the register's account matches. One adjacent gap: the plan-header's USER.pdf citation is in NEITHER category (CK-E0-03).
VERDICT: PASS for the register as scoped; the USER.pdf omission carried as MISSING at E0-03.
STATUS: DONE
WHY: never-delivered and destroyed are different failures and the record refuses to blur them.
CLASS: [E]

### CK-E8-06 · v3.7 exercised its own new rule correctly
REQ: D22 is "itself the first exercise of the rule it establishes" — plan edited HERE, in a gated commit, with the §4.3 pair moving together.
CHECK: R-CH-1 commit content + EX-01 today.
LIVE: 562dd65 carries plan v3.7 + DIRECTORY_GUIDE map-line fix in one gated commit under `APPROVE R-CH-1`; EX-01 delta 0 across all three seeds today.
VERDICT: PASS. STATUS: DONE
WHY: the first use of local plan authorship kept the byte-pin honest — the precedent future edits will be judged against.
CLASS: [E]

### CK-E8-07 · the map's logs/ line lags the runtime tree
REQ: DIRECTORY_GUIDE's logs/ line enumerates the gitignored trails.
CHECK: line vs live directory.
LIVE: the line names arbiter-audit, tooluse-audit, build-errors, metrics/, rounds/; the live directory also holds subagent-starts.jsonl (CR-025) and intake-contracts.jsonl (CR-026's own §4). CR-024 does not police logs/ (untracked), so nothing catches this class.
VERDICT: FAIL of enumeration currency.
STATUS: STALE-DOC-REPORTED (low) — a descriptive line about an ignored directory, two trails behind.
WHY: gated one-line map edit now possible under R-CH-1; or accept descriptive drift for ignored dirs and say so.
CLASS: [E]

### CK-E8-08 · the suite's own comment still narrates the pre-D17 hooks state
REQ: code comments should not contradict the current tree (docs-drift lens, quality-reviewer contract).
CHECK: run-crew-tests.sh:388-393 comment vs today.
LIVE: the comment says "Registered at S7, NOT fixed: DIRECTORY_GUIDE.md says 12 hook scripts… leaves the map to the re-export it needs" — while the same file's C-26 block 450 lines later enforces the CLOSED state (map enumerates 14; both directions policed) and the map has said 14 since D17.
VERDICT: FAIL. STATUS: STALE-DOC-REPORTED (low)
WHY: the assertion below the comment is correct; only the narration rotted. Same era-lag class as ROADMAP's C-26 entry (R1 register).
CLASS: [E]

### CK-E8-09 · the dirty PROGRESS entry is the parachute working as designed — exposing a close-convention gap
REQ: C-15: PreCompact carries the prior next_action forward verbatim.
CHECK: read the uncommitted emergency-checkpoint block + C-15's behavioural assertion (green in CK-B-01's checker run).
LIVE: the block (appended by the pre-audit compaction) carries forward "operator issues `APPROVE R-CH-1`; then the guard-fronted commit and push…" — an action already completed at 562dd65. C-15 worked exactly as specified; the staleness exists because the gated-close convention commits the awaiting-token checkpoint and writes no post-commit next-action refresh, so between a gate closing and the next phase's first checkpoint, the newest recorded next_action describes a finished step.
VERDICT: PASS for C-15; FAIL for next-action currency at rest.
STATUS: DONE (the hook); the convention gap is an UNENFORCED finding (R4 register).
WHY: §15.4's cold reader resumes on the newest next_action; for the window after every gated close, that pointer is one step behind. NEXT-PLAN input: a post-commit checkpoint line in the close ritual.
CLASS: [E]

## OPEN — the ledger as it stands (verified, not assumed)

### CK-OP-01 · exactly two active work items, both operator-gated
REQ: post-R-CH-1 open ledger = PACK-2 (IAM first) + H3b (queued here).
CHECK: ROADMAP + session-summary + Lite RULINGS.
LIVE: PACK-2 ordered by Q6 with the blocking decision named (identity provider; proposal-only vs write credentials under A4a); H3b re-homed with its corpus already local behind the fence and the matrix-suite target named. No third active item found in any ledger.
VERDICT: PASS. STATUS: OPEN-BY-DECISION(Q6 · R-CH-1/D22)
WHY: the successor plan's first two candidate phases, already scoped by standing records.
CLASS: [E]

### CK-OP-02 · standing deferrals and dormant lanes, each with its recorded condition
REQ: every parked item names what would unpark it.
CHECK: per-item record.
LIVE: H1b renderer-half of CR-003 (deferral wording needs the clarifying line — CK-E2-04); Q2 secrets deferral now governed by R-SEC-1 (a gate + the seven rules would unpark it); WORKAROUND-01 (removed when an official continuity capability lands; removal gated, tests go with it); Managed Agents lane (§14.2 gating facts recorded: separate billing, beta, ZDR caveat); peer-review lane (designed, not built; independence contract stated); OQ-2 (pinned-mode variant inexpressible — revisit only if config gains the suffix form); C-25 prevention (impossible at the platform layer — a PreToolUse deny on the dispatch is the only path and is explicitly not scoped).
VERDICT: PASS. STATUS: OPEN-BY-DECISION(each named record)
WHY: nothing is parked without a wake condition; the successor plan can adopt these verbatim.
CLASS: [E]

## R1 — Stale-documentation register (hallucination-class; REPORTED, deliberately uncorrected)

Reported per the task's non-goal: analysis-identified falsehoods are recorded, never edited in
place. Severity is informal: none blocks execution; all mislead a cold reader.

| # | Site | Says | Ground truth | Check |
| --- | --- | --- | --- | --- |
| R1-01 | ROADMAP C-26 entry | map says 12 hooks; fix needs an operator re-export | map enumerates 14 since D17; C-26 CLOSED in-suite; the re-export valve is abolished (R-CH-1) | CK-E8-08 kin |
| R1-02 | ROADMAP + session-summary | "EX-01 is retired" | the RENAME-ALLOWANCE was retired (A1b); the ID lives on labeling the strict delta-0 checks that PASS three times per run | CK-E1-01 |
| R1-03 | plan §0.6 | escalation channel = operator's web chat session | channel retired; operator present in-session (D22) | CK-E0-05 |
| R1-04 | plan §1 HC-2 + model-policy.md | forbidden family "exists only as the web-chat escalation channel" | channel retired; session-model practice differs and is unrecorded | CK-E0-07/08 |
| R1-05 | plan §14.1 oracle row | consult block pasted into the web chat | same retirement | CK-E1-22 |
| R1-06 | plan markers (§13 heading, line 405) | "CHANGELOG — v2.0" / "# END v2.2" | content documents v3.7 | CK-E1-21 |
| R1-07 | context/budget-baseline.md CR-006 section | "All 30 rows … embedded" (L76); "30 dispatches, 3,078,632 tokens, mean 102,621" (L95); second role table sums to 30 (Explore 2, general-purpose 2) | the fence embeds 33 rows / 3,518,549 and the file's own top table says 33 (Explore 3, general-purpose 4); no assertion binds the section prose | new — this audit |
| R1-08 | README:50 | "87 files, ~1.0 MB" | 95 tracked, ~1.1 MB; claim unbound | CK-E3-03 |
| R1-09 | CHANGE_REQUESTS:500 + plan D20 | "CR-003 remains deferred (H1b)" without scoping | spec half DELIVERED 2026-08-21, assertions live; renderer half deferred; split stated nowhere | CK-E2-04 |
| R1-10 | run-crew-tests.sh:388-393 comment | pre-D17 hooks narration | closed state enforced 450 lines below | CK-E8-08 |
| R1-11 | DIRECTORY_GUIDE logs/ line | three jsonl trails | five live (subagent-starts, intake-contracts) | CK-E8-07 |
| R1-12 | threat-model residual row 12 | "no check reads prose for confidentiality" | the crossing-rule assertion now reads one prose file for URL classes | CK-E6-01 |
| R1-13 | Plan.md:514 | "Plan.md:363 records it [the token]" | :363 records the approval event; the verbatim token lives elsewhere | CK-E2-02 |
| R1-14 | §5.2.1 payload frontmatter | paths frontmatter in the seed | absent from the deployed rule; no recorded reason | CK-E1-08 |

## R2 — Missing register

| # | Item | Evidence | Disposition input |
| --- | --- | --- | --- |
| R2-01 | MASTER_FIFO_PLAN_USER.pdf v2 (plan:2's human counterpart) | absent from disk, history, bundle inventory, backup; unregistered in the lost register | register it (which category is an operator call) or amend the header under the plan's own gate |
| R2-02 | a tracked record of the session-model directive | only the F6 hold/lift pair exists in-repo; the standing practice lives outside the filesystem | record it in model-policy.md under a gate, or revert practice |
| R2-03 | post-commit next-action refresh in the gated-close ritual | every close leaves the newest next_action one step behind until the next phase writes | one added line in the close convention |

## R3 — Change and addition census (drift trail; every entry bound or it would be flagged)

**Core structural conclusion of this audit: zero CHANGED-UNBOUND and zero ADDED-UNBOUND items were
found in either repo.** Every divergence from a seeded payload and every artifact beyond the
original contracts binds to a named gate, ruling, correction, or recorded operator answer. The
complete bindings:

| Surface | Changed/added vs the plan | Authority |
| --- | --- | --- |
| Repo visibility | private default → PUBLIC | Q1 operator answer, verbatim in Plan.md |
| settings.json | schema, event name, 4 added hook wirings, alias-stamped model | C-01 · C-02 · C-13 · CR-022 · CR-025 · F0-step-6 |
| .gitignore | 6-line seed → 7 fence blocks | C-04 · corpus drop record · CT-FENCE · S6 · R-SEC-1 |
| arbiter.md | 20 lines vs verbatim seed | EX-05 · C-19 · PR-F2 · CR-021 |
| arbiter dispatch law | broker-dispatches → released-before-acted-on | C-11 → EX-04 → EX-05 (platform limit, proven live) |
| apply-models.sh | §5.5 core's three defects fixed | EX-02(a,b,c) |
| HC-2 scan semantics | bare substring → assignment positions (+ resolution of proposed configs) | EX-03 · SECURITY-1 F-2 |
| scripts 4→10 | six additions | §15.5 · §15.9 · C-21 · C-22 · registry · H0a |
| hooks 9→14 | five additions | F0-step-6 · R2 · C-13 · CR-022 · CR-025 |
| skills 1→2 | intake | CR-026 (+D16 map valve) |
| rules 4→6 | shell-discipline · secrets-contract | D18/D19 · D21/R-SEC-1 |
| §6 budgets | authored numbers → measured baseline | D3c · C-18 · C-20 · G-F7a/b rulings |
| EX-01 semantics | rename-allowance → strict delta-0 | A1b / D14 |
| plan authorship | never-edited-locally → edited here under its own gate | R-CH-1 / D22 |
| docs/ tree | audit 8 + security 2 + metrics pair + reconciliation | A-gates · D21/S-rulings · GUARD-1/H2a · CT-1 |
| Lite repo entire | 57 files | L0..LITE-SECURITY-1 rows (11 gates) |
| git tags | 8 rb/f7-* rollback anchors | lead-planner rollback_tag schema, F7 plan |

## R4 — Unenforced register (requirement exists; no mechanical assertion binds it)

Aggregated so the successor plan chooses deliberately. STATED = the gap is already written down at
the cited site; NEW = first recorded by this audit.

| # | Gap | Status |
| --- | --- | --- |
| R4-01 | gate-guard defeats ordering, not forgery; ledger-vs-operator-memory audit is procedural | STATED (guard header; threat-model row 1; S4a) |
| R4-02 | scrub() covers known shapes; novel credential formats uncovered by construction | STATED (row 4) |
| R4-03 | docs/ converse map exemption: a stray tracked file under docs/ is uncaught | STATED (D21; row 7) |
| R4-04 | prose confidentiality beyond the one URL assertion | STATED (row 12, wording one shade stale — R1-12) |
| R4-05 | paraphrased relay invisible to provenance-flag; verbatim only | STATED (hook header; row 11) |
| R4-06 | diagram truth beyond the d2 topology (well-formed ≠ true) | STATED (row 8; validator comments) |
| R4-07 | scanner gaps: other early-exit consumers gain needles only on evidence | STATED (R-SD-1 rule 5 enforcement note) |
| R4-08 | C-25 is detection, never prevention (platform limit) | STATED (five surfaces corrected to say so) |
| R4-09 | intake judgment half (restatement quality, question quality) is model-interpreted; manual drills only | STATED (skill §5) |
| R4-10 | pack own-documents restriction is an instruction, not a guard | STATED (R-PD-1 "what the cap does not do") |
| R4-11 | budget-baseline CR-006-section prose bound to nothing (how R1-07 lived beside a green suite) | NEW |
| R4-12 | README footprint row unbound (how R1-08 lived beside CR-027) | NEW |
| R4-13 | post-gate next-action staleness window (R2-03) | NEW |
| R4-14 | stop.sh GATE READY toast matches phase-token shapes only; post-build named gates toast "turn complete" | NEW (design-era artifact, F5) |
| R4-15 | audit-gate A-token approvals have no ledger-grammar row anywhere (convention-recorded events only) | NEW as an aggregation; convention itself STATED |
| R4-16 | ROADMAP↔session-summary review is periodic-manual by admission | STATED (ROADMAP header) |

## R5 — Lost register (cross-reference; ownership stays with the reconciliation record)

Four artifacts lost from both sides (AUDIT_TRAIL_R3/R4/R5.md, the final-audit prompt) + one
never-delivered archive (source_files/, 21 files) — registered at 597cd0e, categories deliberately
distinct, recoverability ground removed by R-CH-1, no re-export requested. This audit adds ONE
candidate: the USER.pdf counterpart (R2-01), currently in neither category. Nothing else cited by
any tracked file was found unreachable.

## R6 — Function inventory (intended use of every granular unit, with provenance)

Read-depth legend: FULL = every line read this session · STRUCT = structure + every claim a check
binds · CENSUS = existence/provenance only.

### R6a — parent scripts (10; all FULL; all in the §4.3 map; CR-024 both directions green)

| Script | Intended use (contract) | Provenance |
| --- | --- | --- |
| setup.sh | one-command fresh-checkout bootstrap; installs nothing; toolchain + runtime dirs + exec bits + stamp + validation + app suite | §5.5; F8 |
| apply-models.sh | HC-4 single point: stamp model+effort from config; HC-2 refusal at exit 2 | §5.5 + EX-02/EX-03 |
| validate-crew.sh | 49 structural gate assertions (config, HC-2, tier, ignore/publication, paths, stamps, hooks kill-switch, coverage correlations, bindings) | §5.5; grown by corrections |
| run-crew-tests.sh | 179-assertion harness, per-phase cases F0–F7 + class scanners + canaries + bindings; gate mode regenerates live evidence | §5.5; append-a-case |
| check-plan-corrections.sh | machine-checks the 28-ID registry (23 detectors; 2 SUPERSEDED honest); phase-gating mode | registry preamble |
| save-context.sh | §15.5 distill-merge executor: prepare (delta+instruction) / check (hygiene + PB-01..08 declared bindings + completeness) | §15.5 · C-24 · C-28 |
| restore-context.sh | §15.9(d) snapshot reader + fixed reload instruction; read-only | §15.9 |
| portability-drill.sh | C-22 clone-free portability proof: archive extract + detached worktree + C-23 ran-not-skipped guard | C-22 |
| measure-dispatch-cost.sh | C-21: regenerate per-dispatch cost from transcripts → TSV + tracked snapshot with read-back confirmation | C-21 · H2a |
| gate-guard.sh | H0a: refuse any gated commit without the APPROVED ledger row; forgery limit stated | H0a/D20; MIRRORED |

### R6b — parent hooks (14; all FULL; wiring↔disk asserted both directions)

| Hook | Intended use | Provenance |
| --- | --- | --- |
| _common.sh | sourced library: PATH, fallback ROOT (R2), ledger-derived PHASE (CR-014), scrub() (SEC-DG-01/R-SEC-1), deny() with self-audit (C-03/G-F2) | F2 + corrections |
| bash-blocker.sh | PreToolUse[Bash]: HC-5 destructive/prohibited verbs + HC-7 vendor CLIs | §5.6 |
| model-guard.sh | PreToolUse[Write·Edit]: HC-2 assignment writes + resolution of proposed configs | §5.6 + EX-03 + SECURITY-1 F-2 |
| sensitive-guard.sh | PreToolUse[Write·Edit]: secret-path writes; .gitignore protected-entry removals (appends allowed, C-04) | §5.6 |
| audit-logger.sh | PostToolUse[*]: scrubbed evidence trail with dispatch identity (C-12 fields) | §5.6 |
| auto-format.sh | PostToolUse[Write·Edit]: prettier when present; byte-pinned set skipped by name | §5.6 + EX-01 identity |
| error-recovery.sh | PostToolUseFailure[*]: scrubbed failure record + §9 hint DELIVERED on stderr/exit-2 | §5.6 + CR-018 + R-SEC-1 |
| notify.sh | Notification[*]: platform-detected toast (Q3) | §5.6 |
| stop.sh | Stop[*]: rolling latest.md + one-shot compact-flag consumption + GATE READY toast (phase tokens) | §5.6 + §15.3/15.9(b) |
| pre-compact-checkpoint.sh | PreCompact: emergency checkpoint (prior next_action carried, C-15) + flag + numbered snapshot + retention 10 | §15.3/15.9(a,c) |
| session-start.sh | SessionStart: §15.4 re-grounding block into every session | §15.4 ([V?]→yes) |
| subagent-start.sh | SubagentStart: runtime-supplied identity per creation, success-independent | CR-025/C-25 |
| provenance-flag.sh | PostToolUse[Write·Edit]: source-correlated relay flag on continuity files; never blocks | C-13 (G-F4 ruling) |
| reference-cap.sh | PreToolUse[Agent]: §15.2 30-line fenced-excerpt cap; FLAG-only, coverage-excluded by field | CR-022 |

### R6c — parent agents (8; FULL), skills (2; FULL), rules (6; FULL)

Agents: arbiter (broker/auditor; six-step packet law with read-back) · lead-planner (plan-only,
five-field schema, measured budgets) · lead-executor (numbered-step executor, gate law, byte-pin
Bash-redirection law) · fixer (steelman, ACCEPT/REJECT/DEFER, suite after every change) ·
security-reviewer + quality-reviewer (read-only lenses, D9 dimensions, dismissal standard) ·
test-runner (no-interpretation instrument) · integration-runner (scripted e2e only, scoped to
stress-project). Skills: threshold-router (§5.3, lock announcement + reachable scoring) · intake
(CR-026, R3a contract layer). Rules: fallback-protocol (FALLBACK schema + anti-skip 5–8) ·
arbiter-protocol (EX-05 law, Task→Agent detection, C-25 precision) · model-policy (HC-2/3/4,
stamp-only, OQ-2) · security (severities, prohibitions, dismissal standard) · shell-discipline
(R-SD-1 v2) · secrets-contract (R-SEC-1).

### R6d — parent context/ (6; FULL), root docs (FULL), docs/ (STRUCT for the four big dated
records; FULL for reconciliation, threat-model, redteam, metrics pair), stress-project (suite-run +
STRUCT)

context/: session-summary (§15.5 entry point, PB-bound) · plan-corrections (registry, WINS for
implementation) · budget-baseline (C-20 measured baseline + CR-006 fence; carries R1-07) ·
f2-readiness (F2 acceptance spec) · f7-metrics (durable §7 roll-up mirror) · f7-plan (approved F7
plan, session-split survivor). Root: plan (authority) · CLAUDE.md/CLAUDE_DESIGN/DIRECTORY_GUIDE
(seeds) · Plan/PROGRESS/GATES (ledgers) · README (operator quickstart; carries R1-08) · ROADMAP
(carries R1-01/02) · models.config.json (HC-4 point) · .gitattributes (CR-031). docs/: the 8
audit-era records (frozen, CR-033) · threat-model + redteam (security era) · metrics-snapshot +
dispatch-cost.vl.json (H2a pair: generated data + url-backed spec) · context-transfer-reconciliation
(external-record corrections). stress-project/: 22 files — CLI (positional file, exits 0/1/2), four
domain modules + adapters, audit JSONL writer, 7 fixtures incl. the deliberately unparseable one and
the CR-017 drain fixture, 6 test files (18 named cases), README with the state machine.

### R6e — Lite (57 tracked; scripts+hooks+rules+agents FULL; docs FULL; pack machinery FULL)

Scripts (10): verify (three-layer entry) · validate-lite (single-file assertion layer) · check-sync
(§7.1 relations + R-SP-1/R-PD-1 guards) · check-witness (hash-stamped attestations; STALE≠FAIL) ·
distill (CLAIMS-bound summary fidelity) · continuity (checkpoint/stall/seance; F-L1-hardened) ·
stress (release law under traffic, fixture-isolated) · gate-guard (MIRRORED) · apply-models
(class→alias→id resolution with vacuity guard) · restore-context. Hooks (8): _common,
bash-blocker, model-guard, sensitive-guard, release-guard (the central cross-release law),
pre-compact-checkpoint, session-start, stop. Agents (4): session-orchestrator, builder, verifier,
security. Rules (6): three MIRRORED (shell-discipline, secrets-contract + gate-guard.sh via map),
security ADAPTED with the severity table pinned, model-policy ADAPTED for classes, release-protocol
NEW (replaces the arbiter for a crew of four). docs/: RULINGS (R-PD-1, R-SP-1 with detectors) ·
SYNC-CORRELATION (the 55-row map) · WITNESS-MANIFEST · security/redteam-1 (F-L1..L4 + drill) ·
session-history + verification-history (tracked temporal layers). Pack: confluence-docs machinery
tracked, workspaces fenced.

### R6f — check-ID registry (every named check, its home, its live state today)

- C-01..C-28: registry rows 28/28; enforcement homes — 23 in check-plan-corrections (21 APPLIED + 2
  honestly SUPERSEDED), C-16/C-26/C-27 in the suites, C-17 closed-by-completion (GATES rows),
  C-18 closed-by-ruling (ledger + f7-metrics). All green or closed today.
- EX-01..EX-05: seed identity (live ×3) · apply-models repairs (live code) · assignment-position
  scan (live) · the inert dispatch grant (superseded by EX-05) · the dispatch law + exclusivity
  assertion (live).
- CR-001..CR-034 (audit backlog): consumed subset live in code with per-CR accounts (009, 010, 012,
  013, 015, 016, 017, 018, 019, 021, 022, 024, 025, 026, 027, 030, 031, 032, 033, 034 traced this
  audit); the remainder priced-and-parked in the frozen backlog per its own doctrine.
- PB-01..PB-08: the CLAIMS-MANIFEST v1 rows, all live (30/0 run).
- ccs-01..ccs-03: continuity assertions, all live.
- F-1..F-3 (parent redteam), F-L1..F-L4 (Lite redteam): all fixed with live descendants.
- H-series: H0a (guard live) · H1b (deferral wording carries R1-09) · H2a (pair live; loop
  REGISTERED-NOT-FIXED) · H3b (queued).
- R-series rulings: R-SD-1 · R-SP-1 · R-SEC-1 · R-PD-1 · R1d · R-CH-1 — all in force, each with a
  live detector or a stated procedural status.
- D1..D22: the decision changelog, complete; every delta traced to its landing artifact during this
  audit's era passes.

## R7 — Non-pushed evidence census (CF-H; local-only surfaces, verified live)

| Surface | Census | Fence honored |
| --- | --- | --- |
| Context-Transfer/ | 6 files, 63,159 bytes, mtimes pre-fence, never edited | ignored (probe on a non-existent path passes); zero history; backup 6/6 byte-identical at `$HOME/context-transfer-backup/Context-Transfer/` |
| Reference corpus | 16 `*-main/` directories (matches the fence comment's own count of 16), every one carrying a license file; read-only H3b substrate + the 5 §11 ETL sources | globbed fence; zero tracked, zero staged, zero history |
| Root reports | ReportforClaudeWeb.txt 51,573 B (X-10-corrected size confirmed) · _2 12,857 B · Project-Explorer.md 55,658 B · deep-research-report.md 56,931 B · PSYCHIC-CREW-LITE-PLAN.md 16,763 B | each named or globbed in its fence block |
| Root PDFs | 3 research PDFs (405,477 / 382,032 / 194,017 B) | `*.pdf` glob |
| logs/ (parent) | 5 jsonl trails + metrics/ (TSV 33 lines + f7.json) + rounds/ (3 dirs) | gitignored; C-14 canary covered all 5 this run |
| .claude/state | checkpoints at exactly 10 numbered + latest.md (retention clause holds); compact-pending consumed | gitignored (C-04) |
| Lite runtime | pack inbox/work/out/drills + logs/ | pack-root glob + logs/ rule |
| stress-project/tmp | e2e evidence area | gitignored; unchanged across this audit's runs |

No unfenced local file of consequence was found at either root: `git status --porcelain --ignored`
enumerations at both repos reconcile completely against the fence blocks above.

## NEXT-PLAN INPUTS — everything a successor plan must cover or consciously decline

Grouped; each line is phrased as a candidate requirement. Sources: R1–R4 + OPEN checks.

**From MISSING (R2):**
1. Adjudicate and register MASTER_FIFO_PLAN_USER.pdf (lost vs unreachable vs header-amended).
2. Record the session-model ruling in a tracked rule, or revert the practice (the largest
   outside-the-filesystem decision found).
3. Add a post-commit next-action refresh to the gated-close ritual.

**From STALE-DOC (R1) — one gated documentation-repair phase could close all fourteen:**
4. Plan text: §0.6, §14.1, HC-2 role sentence, §13/END markers, D20's CR-003 clause scoping (five
   edits under the plan's own gate — the first substantive use of R-CH-1 authorship).
5. Rules/records: model-policy HC-2 sentence · ROADMAP C-26 + EX-01 phrasings · session-summary
   EX-01 phrasing · budget-baseline CR-006-section trio · README footprint row · threat-model row-12
   wording · run-crew-tests stale comment · DIRECTORY_GUIDE logs/ line · fallback-protocol
   frontmatter note · Plan.md:514 (ledger: correct forward per its own convention, never rewrite).
6. Fix the auditor's memory alongside (done at this audit's close for CR-003 and the retired
   re-export valve).

**From UNENFORCED (R4) — choose bind, state-as-limit, or decline, per row:**
7. Bind the two newly found unbound-figure classes (R4-11, R4-12) via the existing CR-027/C-28
   mechanisms.
8. Decide whether post-build named gates deserve the GATE READY toast (R4-14).
9. The ten STATED rows stand as known limits; a successor plan should re-affirm rather than
   re-discover them.

**From OPEN (verified wake conditions):**
10. PACK-2 — IAM first; blocking decision: identity provider + proposal-only vs write credentials
    under A4a and R-SEC-1's grant rules.
11. H3b — corpus deep-dives + the standalone decision-matrix suite over docs/audit/ outputs.
12. Standing deferrals (H1b renderer half, Q2 secrets, WORKAROUND-01, Managed-Agents lane,
    peer-review lane, OQ-2, C-25 prevention) — adopt verbatim with their recorded conditions.

**Registered tension to re-decide deliberately:**
13. The CR-006/H2a loop (checker executes the generator; fence hand-maintained) — REGISTERED, NOT
    FIXED, with closure options already written in Plan.md's entry; idempotent today (CK-B-01) but
    one dispatch away from firing.

## INDEX — every check, one line

B: 01 DONE · 02 DONE · 03 DONE · 04 DONE · 05 DONE · 06 DONE · 07 DONE
E0: 01 DONE · 02 RECORDED-EXCEPTION · 03 MISSING · 04 DONE · 05 STALE-DOC · 06 DONE · 07 STALE-DOC · 08 STALE-DOC · 09 DONE · 10 DONE
E1: 01 DONE · 02 DONE · 03 DONE · 04 CHANGED-AUTH · 05 CHANGED-AUTH · 06 DONE · 07 CHANGED-AUTH · 08 DONE+note · 09 DONE · 10 DONE · 11 DONE+ADDED-AUTH · 12 DONE+ADDED-AUTH · 13 DONE · 14 DONE · 15 DONE · 16 DONE · 17 DONE · 18 DONE · 19 CHANGED-AUTH · 20 DONE · 21 STALE-DOC · 22 STALE-DOC
E2: 01 DONE · 02 DONE+note · 03 DONE · 04 STALE-DOC
E3: 01 DONE · 02 DONE · 03 STALE-DOC
E4: 01 DONE+RECORDED-EXCEPTION · 02 DONE · 03 DONE · 04 DONE
E5: 01 DONE · 02 DONE · 03 DONE · 04 DONE · 05 DONE · 06 DONE
E6: 01 DONE+note · 02 DONE
E7: 01 DONE · 02 DONE
E8: 01 DONE · 02 DONE · 03 DONE · 04 DONE · 05 DONE · 06 DONE · 07 STALE-DOC · 08 STALE-DOC · 09 DONE+gap
OP: 01 OPEN-BY-DECISION · 02 OPEN-BY-DECISION

71 check blocks. Tallies: 0 × NOT-EXECUTABLE, 0 × DEFERRED, 0 × CHANGED-UNBOUND, 0 × ADDED-UNBOUND.

## SELF-CHECK — the deliverable against task-spec item 1, clause by clause

| Spec clause (as written) | Where satisfied |
| --- | --- |
| "Project Audit Checklist created then executed" | 71 CK blocks, each CHECK paired with a same-session LIVE line; CHECK-count == LIVE-count == 71 |
| "absolute binary execution, nothing skipped over" | every block carries a binary VERDICT; zero NOT-EXECUTABLE, zero deferrals (INDEX tallies) |
| "evidence of WHAT we have" | B baselines + R3 census + R6 inventory + R7 non-pushed census |
| "completed, missing, changed, added and as to why" | STATUS vocabulary + WHY field per check + R2/R3 registers |
| "Need a reason … intended use case of every granular function" | R6a–R6f, at the repo's own granularity (file + named check); interpretation flagged in Method and open to numbered correction |
| "checking new requirements not accounted for being added" | R3's zero-unbound conclusion + R4's NEW rows |
| "devise a BRAND NEW plan to cover everything else MISSING or to be CHANGED" | NEXT-PLAN INPUTS, 13 numbered candidates |
| Success criteria: "hard confirmed … pragmatically done in live time" | every LIVE line dated 2026-08-25 from commands run this session; no recall-as-evidence |
| Non-goal: "escalating the checks for user input" | zero questions asked (intake contract records questions_asked: 0) |
| Non-goal: "hallucinations not corrected but rather reported" | R1's fourteen sites verified UNTOUCHED: the working tree carries exactly the pre-existing PROGRESS.md checkpoint and this file |
| Hard constraints: no assumptions/theories/web | zero web fetches; every claim carries [E]/[I]/[S]; the six [I] shadings are individually visible (E0-03, E0-08, E1-08, E1-14, E1-17, E2-04) |

Deviation disclosures (approved in the plan, restated here): the plan-style review fan-out and T3
OCR/cross-vendor review stages were withheld — dispatch-based, and the cross-vendor half is
HC-7-barred — replaced by this solo adversarial self-check. Index placement: this file's full index
sits at the tail rather than the head; the header's grep recipes are the primary scan path.
Audit-process errors caught and kept: the backup probe first ran at the wrong layout (CK-E8-04) and
the planning notes carried a 17-directory corpus count against the true 16 (R7) — both corrected by
re-probing, both disclosed because a clean-looking wrong probe is void, not reassuring.

## CONFIDENCE — core conclusion, and what would overturn it

**Core conclusion [E-weighted]:** the build conforms to its own evolved requirement set. Every
constraint with claimed enforcement demonstrably fires today (all seven baseline runs green modulo
one attributed canary); every payload divergence and every added artifact binds to a recorded
authority; the complete open surface is 14 stale-documentation sites, 3 missing items, 16 known
unenforced gaps (10 previously stated, 6 newly aggregated or found), 1 registered tension, and 2
gated work items — all enumerated above with evidence.

**Confidence:** high for every enforcement, authority, and ledger surface (read in full, exercised
live). Moderate for the universal-negative half of R3.

**WEAKEST CLAIM, flagged:** "zero CHANGED-UNBOUND / zero ADDED-UNBOUND anywhere" is a universal
negative over 152 tracked files. It is fully grounded for the enforcement and authority layers
(FULL reads + live census both directions), but the four large dated audit records were read
structurally, and a provenance claim buried in one of them could name an artifact this audit did
not trace. That is the likeliest place this report is wrong.

**Overturn evidence, specifically:** (a) any tracked artifact whose creation binds to no gate,
ruling, correction, or Q0 answer; (b) a fenced path reachable by a staging route the two probes and
the history scan all miss; (c) a suite assertion shown to pass vacuously against a live defect
(the class this build has recorded five instances of); (d) an operator record contradicting the
CK-E0-08 or CK-E2-04 readings. Any one of these invalidates the respective register row and the
confidence sentence above; none was found in this pass.

## CORRECTIONS

(Empty. Filled only by numbered operator corrections; only what is named will change, and any error
either side finds in settled material gets flagged here the moment it is discovered.)
