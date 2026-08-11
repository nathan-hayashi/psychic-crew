# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Seeded at G-F0; F5 formalizes the distill-merge executor (`scripts/save-context.sh`, which does not yet exist — see open items).

## Where the build stands

**verified** — F0, F1, F2 and F3 are complete and gated (`APPROVE GATE-F0` @ 04:41:35Z · `GATE-F1` @ 05:01:16Z · `GATE-F2` @ 06:00:49Z · `GATE-F3` @ 2026-08-11). Tags `crew-f0` … `crew-f3`. **F4 — Router + Tier Lock is now active.** Suite 87 PASS / 0 FAIL; validate-crew 27 PASS / 0 SKIP / 0 FAIL; corrections 11 APPLIED / 1 PENDING (C-13, F4-owned) / 2 SUPERSEDED.

## Decisions that constrain everything downstream

- **verified** — Project is `psychic-crew` (renamed from `hiya-crew` at Q1), **public** at `github.com/nathan-hayashi/psychic-crew`, branch `dev`.
- **verified** — `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally. Every plan defect is corrected in the artifact this repo builds, under a numbered exception in `Plan.md` and registered in `context/plan-corrections.md`, which is machine-checked by `scripts/check-plan-corrections.sh <phase>`.
- **verified** — EX-01 replaces §14.5 byte-identity with a bounded modulo-rename rule (deltas 1/0/1). EX-02 and EX-03 fix apply-models. **EX-05 replaces the broker's dispatch law** (below). EX-04 was applied and then reverted as inert.
- **verified** — Seed files are Bash-only. The global Prettier `PostToolUse` hook silently reformats `.md`/`.json` written via Write/Edit; `hooks/auto-format.sh` carries a skip-list for exactly that.
- **verified** — Q0: secrets deferred · desktop notify reused · F7 is the JML simulator with a Pokémon overlay (Charmander/Squirtle/Bulbasaur, fixture-level only) · 45 min per-phase wall ceiling · default roadmap order · §11 ETL lanes pre-authorized.

## EX-05 — the broker law, as it actually is

**verified** — Nested dispatch does not exist: a subagent cannot invoke `Agent` at any depth. The original law ("leads never SEE raw specialist output") asserted a property no configuration can deliver, and no exception can lift a platform constraint. The law now reads: **no specialist output may be ACTED ON until the arbiter has released it.** The orchestrator dispatches, every dispatch carries a `task_id`, and the arbiter must emit an audit line bearing that same id before its packet is consumed. No agent holds a dispatch tool — an inert grant reads as capability on disk, so least privilege means none.

**verified** — Coverage is identity-correlated in `scripts/validate-crew.sh`: the SET of dispatched `task_id`s must be covered by arbiter lines of the same id. Surplus lines cannot mask a missing one.

**proposed** — Residual gap, stated rather than hidden: an arbiter could still write a covering line without genuinely processing the packet. Identity correlation stops a _missing_ line, not a _hollow_ one.

## What is proven live, not merely written

- **verified** — All ten hooks dispatch through the platform. Six-op adversarial stress: 6/6 denied with correct HC reasons, 6/6 audit records.
- **verified** — The full broker chain ran end to end: lead-planner → orchestrator fan-out → two reviewers in parallel → arbiter (order check, anchor verification, severity recalibration, quarantine, audit, partial release) → fixer (steelman, ACCEPT/DEFER, applied fix, suite re-run).
- **verified** — The same-named global agents in the user's global agents directory do **not** shadow the project definitions. Both reviewers reported PROJECT dimension vocabularies via SELFCHECK.
- **verified** — `deny()` and `audit-logger.sh` scrub secret shapes before writing; verified live (`MY_API_TOKEN=[REDACTED]` in the trail).

## The recurring failure this build keeps hitting

**verified** — Six times a control has gone green for the wrong reason: the validator matching its own grep pattern; a `Plan.md` sentence quoting it; F2's `deny()` blocking with no record; a detector reading "RELEASE replaced by FALLBACK" as success; C-05's detector bound to one _spelling_ of a check; and fixtures writing fabricated records into the trail they audit. The generalisation: **a check must bind to the artifact that would change if the defect were real.** Counting proxies and substring presence are satisfiable by the audited party; identity and field-level assertions are not.

## Open items carried into F4 and beyond

- **verified** — C-13 (F4, gate-enforced): no hook inspects content bound for `Plan.md`/`PROGRESS.md`/`context/*`, yet the Navigation rule says append anomaly text there then act. Needs two operator decisions before implementation: block-vs-flag, and provenance-vs-keywords (a keyword list would trip on C-13's own entry and on the §0.2d rule text).
- **verified** — Branch B of round 1 was quarantined as malformed JSON. Its four findings were anchor-verified and are factually sound but remain unreleased; round 2 is owed, including the deferred SEC-DG-02/QR-DG-1 merge.
- **verified** — `DIRECTORY_GUIDE.md` has drifted from the tree (names files that do not exist, omits `plan-corrections.md`, `f2-readiness.md`, `check-plan-corrections.sh`). It is a byte-pinned §4.3 seed, so the fix needs an operator routing decision. Precedent at `Plan.md:132`: route the correction outside the pin rather than widen EX-01.
- **verified** — `scripts/save-context.sh` is referenced by the map and by this file's own header but does not exist; F5 owns it.
- **proposed** — The arbiter holds `Write` but not `Edit`, so appending to an append-only audit log means rewriting it whole, and one bad transcription silently rewrites evidence. Worth a contract change at F5.
- **proposed** — `SubagentStart`/`SubagentStop` carry `agent_type` and could make coverage hook-enforced rather than self-reported, closing the hollow-line gap above.

## Next action

**verified** — F4 — Router + Tier Lock. Steps: write `.claude/skills/threshold-router/SKILL.md` (§5.3, currently listed in the map but absent from disk); confirm the tier announcement across three probe prompts; add a tier-announcement check to validate-crew. C-13 must also be resolved — `check-plan-corrections.sh F4` exits 1 until it is.
