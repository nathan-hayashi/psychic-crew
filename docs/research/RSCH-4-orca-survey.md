# RSCH-4 input — orca read-only survey (2026-08-31)

**Status:** survey evidence, persisted at FENCE-2. This is the raw read-only inventory of the
`orca-main/` corpus drop (gitignored under the `*-main/` fence; census-classified `DIVED`), produced
by a very-thorough exploration agent on 2026-08-31 plus dated web fetches. The **RSCH-4 gate** turns
this into the bound decision matrix; nothing here executes a disposition. Paths are repo-relative to
the corpus root (`orca-main/`). Crossing rules applied: no absolute machine paths, no personal
identifiers; the corpus's NTFS `:Zone.Identifier` sidecar files carry a Windows-user path and are
excluded from all evidence listings here.

## 1. Identity

| Field          | Value                                                                                                                                         | Source                                |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| Name / version | `orca` `1.4.178-rc.2`                                                                                                                         | `orca-main/package.json:2-3`          |
| Description    | "Next-gen IDE for parallel agentic development"                                                                                               | `package.json:4`                      |
| README tagline | "The AI Orchestrator for 100x builders. Run Codex, ClaudeCode, OpenCode or Pi side-by-side — each in its own worktree, tracked in one place." | `README.md`                           |
| **License**    | **MIT — copyright (c) 2026 "Lovecast Inc."**                                                                                                  | `orca-main/LICENSE:1-3`               |
| Org            | `stablyai` (GitHub); display name "Stably"; site stably.ai                                                                                    | `package.json:5-6` + fetch 2026-08-31 |

**License note (load-bearing):** MIT permits pattern-incorporation and copying with attribution;
reading triggers nothing; substantial verbatim copying triggers the notice-preservation obligation.
**Anomaly recorded, unresolved:** the org (`stablyai`) ≠ the copyright holder ("Lovecast Inc.");
no local file explains it — do not assume a rename.

**Scale:** ~20,900 files; TypeScript ~3.07M LOC + TSX ~0.51M; `src/` test LOC (~1.72M) EXCEEDS
source LOC (~1.52M). Disk: `src` 227M, `docs` 38M, `mobile` 19M.

**Web check (all fetched 2026-08-31):** GitHub org: 22 public repos, orca at **57.8k stars**, MIT,
active same-day, topics incl. `yc-backed`, `parallel-agents`, `worktrees`. stably.ai: YC-backed AI
end-to-end-testing company ("plain English → reliable Playwright tests"); orca is the adjacent
open-source project, not the core product. Local copy ≈15 patch releases behind head (estimate with
an unquantified error bar — the corpus has no `.git`, so no SHA anchor; mtimes reflect the copy).
Marketing page says "4.3k stars" vs GitHub's 57.8k — trust GitHub. Local Homebrew casks pin far
older versions and are not a currency signal.

## 2. Structure

| Path                                         | One line                                                                                               |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `src/main/`                                  | Electron main process (13.4k files) — orchestration, browser, SSH, git, skills, telemetry, rate limits |
| `src/renderer/`                              | React 19 UI (17.7k files) — essentially unread beyond census                                           |
| `src/shared/`                                | Cross-process contracts, schemas, budgets, telemetry event registry                                    |
| `src/cli/`                                   | The `orca` binary agents drive (`src/cli/index.ts`)                                                    |
| `src/relay/`                                 | Detached SSH daemon owning remote PTYs/git                                                             |
| `config/`                                    | Build + ALL enforcement gates: `reliability-gates.jsonc`, ratchet baselines, 428 `.mjs` scripts        |
| `tests/`                                     | Playwright E2E + tools                                                                                 |
| `skills/` · `skill-guides/` · `skill-stubs/` | 8 agent skills in three parallel representations                                                       |
| `docs/reference/`                            | 24 engineering-boundary docs (SSH, WSL, Windows, git-compat, wire-compat)                              |
| `mobile/` · `native/`                        | RN companion app; per-OS computer-use runtimes — out of scope                                          |

Runs as: Electron app, CLI, headless daemon (`orcad`, must boot on plain Node — ratchet-enforced),
and CDP browser automation. Deps: 24 runtime / 103 dev; heavyweight (Electron, Monaco, tiptap,
sherpa-onnx). **Notable:** the orchestration DB is a zero-dependency adapter over Node's built-in
`node:sqlite` (`src/main/sqlite/sync-database.ts`). Tests: 7,745 unit files + 343 E2E specs; 33 CI
workflows; `pr.yml` (977 lines) fails closed on an empty diff.

## 3. System

**Not an LLM client** — it orchestrates other agent CLIs as PTY subprocesses in git worktrees; the
only Anthropic/OpenAI endpoints in-tree are OAuth/usage for rate-limit display (claim rests on
endpoint/model-string greps; a proxied provider would evade it — flagged).

**Coordinator** (`src/main/runtime/orchestration/coordinator.ts`): phases
decomposing→dispatching→monitoring→merging→done; 2000 ms tick, `maxConcurrent` 4; per tick:
processMessages → processEscalations → reblockTasksWithPendingGates → warnStaleDispatches →
dispatchReadyTasks → checkConvergence. Honest: `decompose()` THROWS if tasks were not pre-created —
"AI-driven decomposition is a future phase" (the advertised DAG decomposition does not exist).

**State:** SQLite WAL, schema v30; tables incl. `runs`, `tasks`, `dispatch_contexts`,
`worker_dispatches`, `deliveries`, `mutation_receipts`, `decision_gates`, `questions`. 9 typed
messages; worker lifecycle has 9 states including three explicitly-unknown ones
(`start_unknown`/`stop_unknown`/`abandoned` — "a potentially-live worker must still count as a
nesting parent").

**Verification layers:** (1) `config/reliability-gates.jsonc` — 17,172 lines, **99 gates**, each
with invariant/oracle/commands/testFiles/named assertionRefs/red-green evidence/flake history/
budgets/promotion criteria. Current state: all 99 `experimental`, zero `blocking` — the registry
outruns its enforcement, honestly labeled. (2) A 431-line validator run in lint+CI (rejects brittle
test selectors; commandless gates must declare `protection: none`). (3) Ratchets — shrink-only
baselines (`check-max-lines-ratchet.mjs`; an EMPTY baseline enforcing "daemon boots on plain Node").

**Telemetry:** one funnel with declared-immutable ordering (shutdown → burst cap → consent →
validator → capture, security reason inline); Zod schema per event name; dual fail-closed transmit
gate (two CI-injected values, no runtime override).

**HITL:** decision gates — workers emit `decision_gate`, the task goes `blocked`, ONLY a human
resolves (`gate-resolve`); the coordinator re-asserts `blocked` EVERY TICK if anything drifted;
gate creation is ownership-fenced. ("The coordinator never auto-resolves gates (humans do) — that
would defeat them as approval checkpoints.")

## 4. Surgical candidates (verdicts are SUGGESTIONS; RSCH-4 binds the real matrix)

All pattern-read only — HC-5 forever bars installing or importing its runtime.

| #   | Candidate                                                                                                                                                                                                                       | Where                                                                           | Maps to                                                                                 | Suggested verdict    |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | -------------------- |
| 1   | Reliability-gate manifest + validator (invariant/oracle/commands/evidence per behavior, maturity ladder, promotion policy)                                                                                                      | `config/reliability-gates.jsonc` + `config/scripts/check-reliability-gates.mjs` | the missing registry layer between "we have suites" and "a claim is provably covered"   | **TAKE-PATTERN**     |
| 2   | Three-value verdict vocabulary — `live`/`unverifiable`/`exited`, collapse forbidden; "no asserting what you cannot observe"; check durable state, not return codes                                                              | `docs/reference/ssh-execution-boundary.md`                                      | evidence-gated doctrine; arbiter verdict schema                                         | **TAKE-PATTERN**     |
| 3   | Dispatch preamble contract (worker_done exactly once w/ 3-sentence body; heartbeats; AskUserQuestion ban with the reason stated; rules land beside examples, not in trailing prose; depth-capped sections omitted not softened) | `src/main/runtime/orchestration/preamble.ts` + snapshot tests                   | intake layer + per-agent task contract                                                  | **TAKE-PATTERN**     |
| 4   | Decision gates re-blocked every tick; resolution replayed into the next prompt; never auto-resolved                                                                                                                             | `coordinator-decision-gates.ts` + `db/decision-gates/`                          | our human gating — "gate state re-asserted, not merely set"                             | **TAKE-PATTERN**     |
| 5   | Escalation provenance fencing (exact task/dispatch binding, three independent checks) + circuit breaker at 3 failures                                                                                                           | `coordinator-escalation-triage.ts`                                              | arbiter dispatch: "a status message must prove its provenance before it can move state" | **TAKE-PATTERN**     |
| 6   | Refuse-before-allocate (drift check precedes dispatch-row creation so refusal is free); `dispatched-unobserved` third outcome; warn-never-autofail staleness with the tradeoff written down                                     | `coordinator-task-dispatch.ts`, `coordinator-stale-base-flag.ts`                | arbiter preconditions + budget                                                          | **TAKE-PATTERN**     |
| 7   | Shrink-only ratchet baselines; empty-baseline-as-architecture-constraint; scanner excludes itself                                                                                                                               | `config/scripts/check-max-lines-ratchet.mjs` + baselines                        | mechanical enforcement of the zero-dependency doctrine itself                           | **TAKE-PATTERN**     |
| 8   | Discovery-stub vs version-matched guide (installed skill file deliberately carries NO commands; live guide served by the binary; rename ledger append-only)                                                                     | `skill-stubs/` + `skills/` + `generate-bundled-skill-guides.mjs --check`        | current-docs-never-memory, mechanized                                                   | **TAKE-PATTERN**     |
| 9   | Idempotency receipts `(caller_fingerprint, request_id, payload_hash)` + consumer-generation fencing + at-most-one-outstanding partial unique index                                                                              | `db/mutation-receipts/`, schema                                                 | arbiter exactly-once semantics — concept transfers, SQLite does not                     | **MODULATE-OURS**    |
| 10  | Telemetry ordering-with-stated-reason + event→schema registry + dual fail-closed gate                                                                                                                                           | `src/main/telemetry/client.ts`, `src/shared/telemetry-event-registry.ts`        | our metrics layer — measure against, network dep barred                                 | **VALIDATE-AGAINST** |
| 11  | Browser-automation boundary rule (CDP for your own app; computer-use only for foreign UI) + command-result cache + command-authority fencing                                                                                    | `src/main/browser/` + `AGENTS.md`                                               | psychic-sidekick's cached-Playwright design                                             | **VALIDATE-AGAINST** |
| 12  | CLI vocabulary policy (canonical verbs as a typed, tested policy — "predictable verbs prevent failed agent guesses") + registry parity                                                                                          | `src/cli/vocabulary-policy.ts`, `registry-parity.ts`                            | command/skill surface consistency                                                       | **MODULATE-OURS**    |

**Explicit REJECTs:** the orchestration SQLite implementation (schema readable as reference; runtime
rejected); Electron shell/renderer; `mobile/`; `native/` computer-use binaries; the SSH federation
layer (psychic-crew is single-host).

## 5. Honest limits (the survey's own)

Read on the order of 3,000 lines of ~3.6M (<0.1%): `pnpm-lock.yaml` unread (transitive deps
unknown); 98 of 99 reliability gates known only through aggregate counts; 32 of 33 CI workflows by
filename; renderer essentially unread. **Weakest claim:** the "~15 releases behind" currency
estimate (no `.git` anchor in the corpus). **Second:** the all-`experimental` gate census is
regex-counted, not parsed. **Third:** "no LLM inference calls" rests on endpoint greps.
