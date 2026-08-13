# F7 Implementation Plan — JML Simulator (`stress-project/`)

Authored by `lead-planner` under dispatch `F7-P1-jml-simulator-plan`. **Approved by the operator at mid-gate G-F7a.** Persisted here so it survives the Stage A/B session split — Session 2 re-grounds from disk and needs nothing from a context window.

Authority: `MASTER_FIFO_PLAN_CLAUDE.md` §6 F7 + §7 rubric, as corrected by `context/plan-corrections.md` (that file wins on implementation).

## Operator decisions fixed at G-F7a (pre-run, per C-18)

- **Wall ceiling**: 45 min **per session**. Breaching it triggers an early gate, not a phase failure — Q5's wording is "hard ceiling per phase before mandatory early gate".
- **Token denominator** for §7's `token spend ≤ Q5 ceiling`: **207K** (F7's §6 budget plus the accepted 7K overrun), superseding Q5's generic 150K.
- **Overrun accepted** rather than trimming A3 35K→30K and B5 18K→15K: the trim would compress module build and round-2 discourse, which `lead-planner` flagged as the two places least safe to squeeze.
- **Mid-gate token** (C-17): the plan defines none. The operator issued `APPROVE GATE-F7a`, recorded verbatim.

## Gate 0 — preconditions

| #   | Precondition                    | Check                                                                                                                                                                                                   |
| --- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0.1 | HC-2 session-model hold cleared | Operator attestation, recorded in `GATES.md` — **not machine-checkable**; the session model is written nowhere a script can read, and asserting it via the settings pin would bind a control to a proxy |
| 0.2 | Tree clean on `dev`             | `git status --porcelain \| wc -l` = 0                                                                                                                                                                   |
| 0.3 | Baseline green                  | suite 131 PASS / 0 FAIL · validate-crew 36 PASS / 0 FAIL · corrections 13 APPLIED / 0 PENDING                                                                                                           |
| 0.4 | Workspace empty                 | `stress-project/` has no tracked files                                                                                                                                                                  |

## Design decisions (derived from disk, not preference)

- **D1** — ESM, zero dependencies. `stress-project/package.json` carries `private`, `type: "module"`, `scripts.test`, and **no `dependencies`/`devDependencies` keys at all**. Runner is `node:test` + `node:assert/strict`. HC-5 assertion: `jq -e 'has("dependencies") or has("devDependencies")' stress-project/package.json` must exit 1.
- **D2** — runtime output goes to `stress-project/tmp/`, already covered by `.gitignore`. Nothing runtime-generated is committed.
- **D3** — the malformed fixture must **not** carry a `.json` extension. `hooks/auto-format.sh` prettifies `*.md|*.json|*.js|*.ts`, so an intentionally-invalid `.json` fixture sits in the formatter's path and would be silently repaired by our own hook. It is `edge-malformed-payload.json.txt`, read as raw bytes. `.jsonl` is not in the formatter's list.
- **D4** — determinism is a build requirement. `now()` and `newId()` are injected into every module; without this no audit-trail assertion is machine-checkable.
- **D5** — the app's failure block reuses the crew FALLBACK schema from `.claude/rules/fallback-protocol.md`, making "cleanly FALLBACK'd" in §7 a schema assertion rather than a judgement call.
- **D6** — Q4 containment. Theme tokens are permitted in `stress-project/fixtures/**`, test-case descriptions and README prose, where they are data. Forbidden in `src/` and `bin/`. Assertion: `git grep -il -e charmander -e squirtle -e bulbasaur -- stress-project/src stress-project/bin` returns nothing.
- **D7** — metrics mirroring. `logs/` is gitignored, so `logs/metrics/f7.json` will not survive F8's fresh-clone drill. The rubric numbers are therefore **also** written into the `G-F7b` ledger row, which is tracked.

## Domain model

States `NONE | ACTIVE | SUSPENDED`. Events `HIRE | MOVE | TERMINATE`. Emissions `iam.create | iam.transfer | iam.suspend`. `applyEvent()` returns a result object for every domain outcome and throws only on programmer error — expected failures are values, so tests assert on them.

## File manifest

```
stress-project/package.json
stress-project/README.md                     # mermaid sequenceDiagram, GitHub-native
stress-project/bin/jml.js                    # CLI entry
stress-project/src/intake.js                 # (a) webhook parse/validate/dedupe
stress-project/src/lifecycle.js              # (b) state machine -> IAM actions
stress-project/src/ticketing.js              # (c) Jira-style ticket JSON
stress-project/src/notify.js                 # (d) Slack-style payload
stress-project/src/audit.js                  # (e) JSONL append writer
stress-project/src/adapters/iam.js           # mock IAM adapter (injectable failure)
stress-project/src/adapters/clock.js         # D4 injectable now()/newId()
stress-project/fixtures/joiner-charmander.json
stress-project/fixtures/mover-squirtle.json
stress-project/fixtures/leaver-bulbasaur.json
stress-project/fixtures/edge-duplicate-webhook.json
stress-project/fixtures/edge-mover-before-hire.json
stress-project/fixtures/edge-malformed-payload.json.txt
stress-project/test/{intake,lifecycle,ticketing,notify,audit,e2e}.test.js
scripts/run-crew-tests.sh                    # + cases_F7() and F7 in the dispatcher
```

## Stage A — build (Session 1), 100K

| Step | Work                                                               | Route                                              | Budget | Acceptance                                                                                                 | Rollback   |
| ---- | ------------------------------------------------------------------ | -------------------------------------------------- | ------ | ---------------------------------------------------------------------------------------------------------- | ---------- |
| A0   | Arbiter releases this plan                                         | orchestrator → arbiter, `F7-P1-jml-simulator-plan` | 2K     | `grep -c 'F7-P1-jml-simulator-plan' logs/arbiter-audit.jsonl` ≥ 1                                          | —          |
| A1   | Gate 0 checks, `Plan.md` entry, PROGRESS checkpoint                | orchestrator                                       | 3K     | tree clean; three validators at baseline                                                                   | `rb/f7-a1` |
| A2   | Scaffold, `package.json`, 6 fixtures — **Bash heredoc, not Write** | lead-executor, `F7-A2-fixtures`                    | 12K    | 6 fixtures exist; the five `.json` each `jq -e .`; the `.json.txt` does **not**; D1 jq assertion exits 1   | `rb/f7-a2` |
| A3   | 6 `src/` modules + 2 adapters + `bin/jml.js`                       | lead-executor, `F7-A3-modules`                     | 35K    | 10 files; `node --check` each exits 0; D6 grep empty; `node bin/jml.js --help` exits 0                     | `rb/f7-a3` |
| A4   | Test suite, **18 cases** (floor 15 is never merged down)           | lead-executor, `F7-A4-tests`                       | 25K    | capture output into a variable, then test: `# pass` ≥ 15 and `# fail 0` — never branch on the pipeline     | `rb/f7-a4` |
| A5   | README + mermaid sequence diagram                                  | lead-executor, `F7-A5-readme`                      | 8K     | even fence count; block contains `sequenceDiagram`, ≥4 `participant`, ≥6 `->>`; no renderer binary invoked | `rb/f7-a5` |
| A6   | `cases_F7()` + `F7)` dispatcher entry                              | lead-executor, `F7-A6-suite`                       | 10K    | `run-crew-tests.sh F7` runs; `all` ≥143 PASS / 0 FAIL; earlier `cases_F*` untouched                        | `rb/f7-a6` |
| A7   | Checkpoint, distill, ledger prep, commit                           | orchestrator                                       | 5K     | `save-context.sh check` exits 0; tree clean                                                                | `rb/f7-a7` |

### The 18 app test cases (names are the contract)

**intake**: `parses-valid-hire` · `rejects-missing-employee-id` · `rejects-unknown-event-type` · `dedupes-identical-event-id` · `dedupe-survives-whitespace-variant` · `malformed-bytes-return-fallback-schema`
**lifecycle**: `hire-none-to-active-emits-create` · `move-active-emits-transfer` · `terminate-active-to-suspended-emits-suspend` · `terminate-twice-is-idempotent` · `move-before-hire-parks-and-fallbacks` · `parked-move-replays-after-hire` · `unknown-transition-returns-error-value-not-throw`
**ticketing**: `ticket-shape-matches-jira-fields` · `iam-adapter-failure-produces-failed-ticket`
**notify**: `slack-payload-has-blocks-and-no-secret-shaped-fields`
**audit**: `every-stage-appends-exactly-one-jsonl-line`
**e2e**: `leaver-suspend-ticket-notify-full-trail`

6 of 18 are failure paths. The §7 "tests ≥15" bar counts **only** these; `cases_F7` crew assertions are gate evidence and must not be counted toward it.

## Split point

**Primary: end of A7** — committed tree, `rb/f7-a7`, PROGRESS checkpoint naming `F7-B1`, distilled summary. **Secondary: end of B4.** Never split mid-round: a half-dispatched parallel branch violates fallback rule 6 on resume.

## Stage B — discourse → gate (Session 2), 107K

| Step | Work                                                                 | Route                                                      | Budget | Acceptance                                                                                                |
| ---- | -------------------------------------------------------------------- | ---------------------------------------------------------- | ------ | --------------------------------------------------------------------------------------------------------- |
| B1   | Re-ground per §15.4                                                  | orchestrator                                               | 3K     | SessionStart names `F7-B1`                                                                                |
| B2   | **Seed 3 bugs**; manifest to the scratchpad, **never into the repo** | orchestrator                                               | 4K     | manifest outside the tree; `git grep -c 'SEED-' -- stress-project` = 0                                    |
| B3   | Discourse round 1, two branches **in parallel**                      | orchestrator → 2 specialists, `F7-B3-sec` / `F7-B3-qual`   | 25K    | 2 dispatches, 2 correlated arbiter lines; every finding carries `dimension`, `P0–P3`, `Failure-scenario:` |
| B4   | Arbiter compiles round 1 → `logs/rounds/round-1/discourse.md`        | arbiter, `F7-B4-compile1`                                  | 8K     | all five §5.4 sections present                                                                            |
| B5   | Round 2 — AGREE/CHALLENGE/CONNECT/SURFACE, confidence arithmetic     | orchestrator → 2 specialists, `F7-B5-sec2` / `F7-B5-qual2` | 18K    | every entry opens with one of the four verbs; undefended challenges dropped and logged                    |
| B6   | Arbiter compiles round 2, releases to fixer                          | arbiter, `F7-B6-compile2`                                  | 8K     | release line precedes any fixer action                                                                    |
| B7   | Fixer: steelman, ACCEPT/REJECT/DEFER, apply                          | fixer, `F7-B7-fix`                                         | 15K    | one verdict per finding; zero open P0                                                                     |
| B8   | test-runner: app + crew suites                                       | test-runner, `F7-B8-tests`                                 | 8K     | `# fail 0`, pass ≥15; crew suite 0 FAIL                                                                   |
| B9   | integration-runner: live e2e + 3 edge cases                          | integration-runner, `F7-B9-e2e`                            | 12K    | per the edge-case table                                                                                   |
| B10  | Metrics, D7 mirror, seed disclosure, §12 self-check, §10 report      | orchestrator                                               | 6K     | metrics JSON validates; all seven §7 numbers present                                                      |

### Edge-case acceptance (the §7 Depth line)

| Case              | Assertion                                                                                                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| duplicate webhook | exit 0; exactly one `"outcome":"DUPLICATE"` audit line **and** exactly one ticket file — the ticket count is the load-bearing half, since a dedupe that logs but still writes a ticket passes the first alone |
| mover-before-hire | exit 1; `"outcome":"PARKED"` then `"REPLAYED"` after the HIRE replay; a FALLBACK record validating against the D5 schema with `confidence < 0.6`                                                              |
| malformed payload | exit 2; stdout parses as JSON with exactly the six D5 keys; **zero** audit lines beyond the single rejection record; no ticket, no notification                                                               |

## What could make this fail the §7 rubric for the wrong reason

1. **Seeded bugs caught by reading the answer key.** If the manifest lands anywhere in the tree, reviewers read it as authoritative context and "find" all three; Robustness then measures nothing. **Highest wrong-reason risk in F7.**
2. **All three seeds caught by tests, so discourse is never load-bearing.** At least one seed must be invisible to any assertion existing at seed time, so only a reading reviewer can find it. If all three are test-visible, re-seed rather than accept.
3. **Agent coverage 8/8 satisfied by attendance, not contribution.** Grep-counting names is a counting proxy — C-12 is the precedent. Bind each of the 8 to a named artifact: a findings file, a verdict, a run record, a released packet.
4. **`# fail 0` read from a pipeline that never ran.** Four recorded pipefail failures, the fourth committed while writing a test. Capture into a variable, then test.
5. **A `cases_F7` assertion denied by `bash-blocker`, silently weakening the check.** The blocker matches the whole command string, so HC-5 needles must be assembled from fragments.
6. **Crew assertions counted toward the ≥15.** The §7 count is `node --test` cases only.

Non-wrong-reason risk: A3+A4 is 60K in one lane. If A3 exceeds 45K, checkpoint and split early rather than compressing A4 — a suite under 15 cases fails the rubric outright, while an extra session boundary costs only re-grounding.

## Handoff

Execution goes to `lead-executor` via the arbiter, one dispatch per step, each carrying its `task_id`. Rollback for step _n_: the tag marks the commit **before** the step, so a rollback restores the last known-good state, not the failure.

---

# A0 arbiter release — accepted amendments

The plan above is the operator-approved artifact and is preserved as approved. At A0 the arbiter released Stage A unconditionally and raised eight advisory flags plus two items for the orchestrator. Every one below was **independently verified before acceptance**, and each amendment supersedes the corresponding line above.

| # | Defect in the plan as approved | Verified how | Amendment (binding) |
|---|---|---|---|
| 1 | **B3/B4 would clobber a live fixture.** `logs/rounds/round-1/security-reviewer.json` is read by TWO detectors — `check-plan-corrections.sh:177` (C-13's probe) and `run-crew-tests.sh:177` (F4 provenance cases) — and `logs/` is gitignored, so an overwrite is unrecoverable | listed the directory, grepped both scripts, confirmed `git check-ignore` | F7 round artifacts go to **`logs/rounds/f7-round-1/`** and `f7-round-2/`. The F3 fixtures at `round-1/` are immutable evidence |
| 2 | **D6 containment is vacuous pre-A7.** `git grep` searches tracked files only; `stress-project/` has 0 tracked files until A7, so the theme-token assertion passes on an empty set | `git ls-files stress-project \| wc -l` = 0 | Use a working-tree scan (`grep -ril`) or `git grep --untracked`. Re-run it **after** A7 as well |
| 3 | **B2's seed assertion fails on the success case.** `git grep -c` exits 1 on zero matches, so `= 0` is false exactly when no seed has leaked | ran it against a nonexistent token; exit=1 | Capture into a variable, then test — fifth instance of the family already recorded four times |
| 4 | **Gate 0.1 points at the wrong file.** The HC-2 attestation is in `PROGRESS.md`, not `GATES.md` | grepped both: GATES 0, PROGRESS 3 | Attestation mirrored into the `G-F7a` ledger row; Gate 0.1 reads there |
| 5 | **Gate 0.3's baseline is decayed evidence** — 131/36/13 were measured before `context/f7-plan.md` and the G-F7a row existed | timestamps | Re-measure at A1; never reuse a recorded claim (G-F0's evidence-decay precedent) |
| 6 | **A0's own acceptance is a substring proxy** — `grep -c '<task_id>'` matches a line documenting a *non*-release, the exact trap that made the first C-11 detector read "RELEASE replaced by FALLBACK" as success | registry precedent | Assert at field level with `jq`, not by substring |
| 7 | **A4 asserts `# pass ≥ 15` while the deliverable is 18 named cases** — a counting proxy where a name-binding assertion is available | plan text vs its own contract | Assert the 18 case **names** are present, and separately that fail = 0 |
| 8 | **A2's `jq -e` must test for exit exactly 1** — a missing or malformed `package.json` exits 2/5, which reads as pass under a merely-nonzero test | jq semantics | `[ "$rc" = 1 ]`, not `[ "$rc" != 0 ]` |

**Orchestrator-owned, both accepted:**

- **My A0 dispatch omitted `expected_output`**, which `.claude/rules/arbiter-protocol.md` makes REQUIRED and calls malformed. The arbiter noted it rather than bouncing it, because the completion contract was present in the reference-passed artifact and fallback rule 4 forbids asking for what the sources already carry. **A2–A6 dispatches must each carry `expected_output`** — the Handoff section names only `task_id`.
- **`PROGRESS.md`'s tail lagged `GATES.md` and `Plan.md`** by one event, still reading "await the mid-gate token". That file is the *first* read §15.4 mandates, so a compaction in the A0→A1 window would have produced a cold reader that re-STOPped at a passed gate. Closed by A1's checkpoint.

**Arbiter conduct note:** it disclosed that holding `Write` but not `Edit` meant rewriting `logs/arbiter-audit.jsonl` whole, and stated that all 9 prior records were reproduced verbatim — the transcription risk the F3 checkpoint already logged against its own contract. It also declined to fabricate a timestamp, using a date-only `ts` as its nine predecessors did.
