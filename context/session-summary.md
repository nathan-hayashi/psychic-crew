# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Maintained with `scripts/save-context.sh` (`prepare` to distill, `check` to verify these semantics).

## Where the build stands

**verified** — F0 through F4 are complete and gated; tags `crew-f0` … `crew-f4`, every gate token recorded in `GATES.md`. **F5 — Gate & Ledger Protocolization is implemented and gate-ready.** Suite 113 PASS / 0 FAIL; validate-crew 34 PASS / 0 SKIP / 0 FAIL; corrections 12 APPLIED / 0 PENDING / 2 SUPERSEDED.

## Decisions that constrain everything downstream

- **verified** — Project is `psychic-crew` (renamed from `hiya-crew` at Q1), **public** at `github.com/nathan-hayashi/psychic-crew`, branch `dev`.
- **verified** — `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally. Plan defects are corrected in the artifact this repo builds, under a numbered exception in `Plan.md`, registered in `context/plan-corrections.md` and machine-checked by `scripts/check-plan-corrections.sh <phase>`.
- **verified** — EX-01 replaces §14.5 byte-identity with a bounded modulo-rename rule (deltas 1/0/1). EX-02/EX-03 fix apply-models. EX-05 restates the broker law. EX-04 was applied and reverted as inert.
- **verified** — Seed files are Bash-only: the global Prettier `PostToolUse` hook silently reformats `.md`/`.json` written via Write/Edit. `hooks/auto-format.sh` carries a skip-list for the byte-pinned payloads.
- **verified** — Q0: secrets deferred · desktop notify reused · F7 is the JML simulator with a Pokémon overlay (Charmander/Squirtle/Bulbasaur, fixture-level only) · 45 min per-phase wall ceiling · default roadmap order · §11 ETL lanes pre-authorized.

## EX-05 — the broker law as it actually is

**verified** — Nested dispatch does not exist: a subagent cannot invoke `Agent` at any depth, and no exception lifts a platform constraint. The law is therefore stated in the enforceable form: **no specialist output may be ACTED ON until the arbiter has released it.** The orchestrator dispatches, every dispatch carries a `task_id`, and the arbiter must emit an audit line bearing that id before its packet is consumed. No agent holds a dispatch tool — an inert grant reads as capability on disk.

**verified** — Coverage is identity-correlated in `scripts/validate-crew.sh`: the SET of dispatched `task_id`s must be covered by arbiter lines of the same id, so surplus lines cannot mask a missing one.

**proposed** — Residual: an arbiter could still write a covering line without genuinely processing the packet. Identity correlation stops a _missing_ line, not a _hollow_ one. `SubagentStart`/`SubagentStop` carry `agent_type` and would make this hook-enforced rather than self-reported.

## What is proven live, not merely written

- **verified** — All ten hooks dispatch through the platform. Six-op adversarial stress: 6/6 denied with correct HC reasons, 6/6 audit records.
- **verified** — The full broker chain ran end to end: lead-planner → orchestrator fan-out → two reviewers in parallel → arbiter (order check, anchor verification, severity recalibration, quarantine, audit, partial release) → fixer (steelman, ACCEPT/DEFER, applied fix, suite re-run).
- **verified** — The same-named global agents do **not** shadow the project definitions; both reviewers reported PROJECT dimension vocabularies via SELFCHECK.
- **verified** — `deny()` and `audit-logger.sh` scrub secret shapes before writing, confirmed live in the trail.
- **verified** — C-13's provenance guard flags an unattributed relay into the continuity files and stays silent when attributed: 5/5 behavioural cases, 0 false positives across all five real ledger files.

## The two failure families this build keeps hitting

**verified** — **A control bound to a proxy rather than the artifact.** Eight instances: the validator matching its own grep pattern; a `Plan.md` sentence quoting it; F2's `deny()` blocking with no record; a detector reading "RELEASE replaced by FALLBACK" as success; C-05's detector bound to one _spelling_ of a check; fixtures writing fabricated records into the trail they audit; `save-context check` demanding distilled-file labels of a registry and a spec; and an assertion grepping a script's own comment for "NOT a rewriter". The rule: **a check must bind to the artifact that would change if the defect were real.**

**verified** — **`set -o pipefail` and meaningful nonzero exits.** Four instances: apply-models' HC-2 guard; `check-plan-corrections`' printf-as-format JSON; `denies()` in the suite; and an F5 assertion where `grep -q` SIGPIPE'd its producer and pipefail reported a matched pattern as a failed pipeline. The rule: **capture into a variable, then test it** — never branch on the status of a pipeline whose stage exits nonzero meaningfully, and pass JSON as printf _arguments_, never as the format.

## Open items

- **verified** — Branch B of G-F3's review round was quarantined as malformed JSON. Its four findings were anchor-verified and are factually sound but remain unreleased; round 2 is owed, including the deferred SEC-DG-02/QR-DG-1 merge.
- **verified** — `DIRECTORY_GUIDE.md` still drifts from the tree (names `decisions.md` and others that do not exist; omits `plan-corrections.md`, `f2-readiness.md`, `check-plan-corrections.sh`, `save-context.sh`). It is a byte-pinned §4.3 seed, so the fix needs an operator routing decision. Precedent: route the correction outside the pin rather than widen EX-01 — which is how QR-DG-3 was closed at F4, by creating the file the map already claimed.
- **proposed** — The arbiter holds `Write` but not `Edit`, so appending to an append-only audit log means rewriting it whole; one bad transcription silently rewrites evidence.

## Next action

**verified** — Await `APPROVE GATE-F5`. On approval → F6 — Test Suite Consolidation, which transforms the 23-error corpus into executable assertions under ETL lane §11.1 and must reach a suite floor of 28 checks including ccs-01/02/03.
