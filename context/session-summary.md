# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Maintained with `scripts/save-context.sh` (`prepare` to distill, `check` to verify these semantics).

## Where the build stands

**verified** — F0 through F6 are complete and gated; tags `crew-f0` … `crew-f6`, every operator token recorded in `GATES.md`. Suite 131 PASS / 0 FAIL · validate-crew 36 PASS / 0 SKIP / 0 FAIL · corrections 13 APPLIED / 0 PENDING / 2 SUPERSEDED. **F7 — the final orchestration stress test — is the active phase and is HELD before any work** (see next section). Nothing of F7 has executed.

## The F7 hold — session-model conflict (HC-2)

**verified** — At the moment G-F6 was approved, the orchestrator session was running `claude-fable-5`: an interactive model override supersedes the `.claude/settings.json` pin until the next session start. `CLAUDE.md`'s non-negotiable forbids any fable model for any session in this repo, so F7 was opened and immediately held rather than started. Escalated to the operator.

**verified** — The pin itself is intact (`model: opus`, `effortLevel: max`, `CREW_TIER_LOCK: T3`) and all 8 agent stamps are unchanged (4 opus / 4 sonnet). Blast radius zero: subagent models come from stamped frontmatter, not the session, and this turn performed ledger bookkeeping only.

**verified** — Resolution is one step: relaunch from the repo root. The pin restores Opus automatically and the SessionStart hook re-grounds. A mid-build `/model` change re-opens the fable window that F0 step 7 closed — treat any interactive model change as suspect until restart.

## Decisions that constrain everything downstream

- **verified** — Project is `psychic-crew`, **public** at `github.com/nathan-hayashi/psychic-crew`, branch `dev`.
- **verified** — `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally. Defects are corrected in the built artifact under numbered exceptions (`Plan.md` Fix Ledger) and machine-checked via `context/plan-corrections.md` + `scripts/check-plan-corrections.sh <phase>`.
- **verified** — EX-01 modulo-rename seed identity (deltas 1/0/1) · EX-02/EX-03 apply-models fixes · EX-05 broker law restated (below) · EX-04 applied then reverted as inert.
- **verified** — Seed files are Bash-only; the global Prettier hook corrupts byte-pinned payloads written via Write/Edit.
- **verified** — Q0: secrets deferred · desktop notify reused · F7 = JML simulator with Pokémon overlay (joiner Charmander, mover Squirtle, leaver Bulbasaur; fixture-level only, §7 rubric unchanged) · 45-min per-phase wall ceiling · default roadmap order · §11 ETL lanes pre-authorized.

## EX-05 — the broker law as it actually is

**verified** — Nested dispatch does not exist (a subagent cannot invoke `Agent` at any depth), so the enforceable law is: **no specialist output may be ACTED ON until the arbiter has released it.** The orchestrator dispatches; every dispatch carries a `task_id`; the arbiter must emit an audit line bearing that id before its packet is consumed. No agent holds a dispatch tool. Coverage is identity-correlated in `validate-crew.sh` — surplus lines cannot mask a missing one.

**proposed** — Residual: identity correlation stops a _missing_ arbiter line, not a _hollow_ one. `SubagentStart`/`SubagentStop` carry `agent_type` and could make coverage hook-enforced.

## Proven live, not merely written

- **verified** — All ten hooks dispatch through the platform; 6-op adversarial stress 6/6 denied with 6/6 audit records; denials self-audit and scrub secret shapes.
- **verified** — Full broker chain end to end: lead-planner → orchestrator fan-out → two reviewers in parallel → arbiter (order check, anchor verification, recalibration, quarantine, audit, partial release) → fixer (steelman, ACCEPT/DEFER, fix applied, suite re-run).
- **verified** — Same-named global agents do NOT shadow the project definitions (SELFCHECK vocabularies confirmed).
- **verified** — C-13 provenance guard: flags unattributed relays into continuity files, silent when attributed; 0 false positives on the real corpus.
- **verified** — F6 corpus transform: the "23-error corpus" = 12 (orchestration guide) + 11 (mermaid guide); 17 assertions rewritten against this repo, ccs-01/02/03 all real.

## The two failure families this build keeps hitting

**verified** — **Controls bound to a proxy rather than the artifact** (recurred through F6: C-16's deny-list removal was caught only by the dirty-tree canary; the E7 check matched POSIX `[[:space:]]` as bash `[[`). The rule: a check must bind to the artifact that would change if the defect were real; counting and substring proxies are satisfiable by the audited party.

**verified** — **`set -o pipefail` with meaningful nonzero exits** (four instances). Capture into a variable, then test; JSON goes to printf as an argument, never the format.

## Open items

- **verified** — G-F3 round 2 still owed: branch B's four anchor-verified findings remain quarantined/unreleased; SEC-DG-02/QR-DG-1 merge deferred with them.
- **verified** — `DIRECTORY_GUIDE.md` drift (phantom `decisions.md` etc., missing real files) needs an operator routing decision; the file is byte-pinned under EX-01, precedent says route around the pin.
- **verified** — OQ-2: pinned mode cannot express a context-variant session id; alias mode unaffected.
- **proposed** — Arbiter holds `Write` not `Edit`; appending to the audit log means rewriting it whole — transcription risk worth a contract change.

## Next action

**verified** — Operator relaunches Claude Code from the repo root (the pin restores Opus; SessionStart re-grounds automatically). Then F7 step 1: dispatch `lead-planner` for the JML-simulator plan and STOP at mid-gate `G-F7a` for plan approval. Full F7 pipeline per §6: plan → G-F7a → lead-executor build → two-round discourse → fixer → test-runner → integration-runner e2e → G-F7b with the §7 numeric rubric.
