# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Seeded at G-F0; F5 formalizes the distill-merge executor (`scripts/save-context.sh`).

## Where the build stands

**verified** — F0 and F1 are complete and gated (`APPROVE GATE-F0` @ 2026-08-11T04:41:35Z, `APPROVE GATE-F1` @ 05:01:16Z; tags `crew-f0`, `crew-f1`). F2 Enforcement Layer is implemented and live-proven; **G-F2 is ready and awaiting `APPROVE GATE-F2`**. Nothing beyond F2 has started.

## Decisions that constrain everything downstream

- **verified** — Project is `psychic-crew` (renamed from `hiya-crew` at Q1), **public** at `github.com/nathan-hayashi/psychic-crew`, working branch `dev`.
- **verified** — `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally (standing operator decision). Every plan defect is corrected in the artifact this repo builds, under a numbered exception in `Plan.md` and registered in `context/plan-corrections.md`.
- **verified** — EX-01 replaces §14.5 byte-identity with a bounded modulo-rename rule (deltas 1/0/1). EX-02 and EX-03 correct §5.5's apply-models logic and narrow the HC-2 scan to assignment positions.
- **verified** — Seed files are Bash-only. The global Prettier `PostToolUse` hook silently reformats `.md`/`.json` written via Write/Edit and destroys byte-pinned payloads; `hooks/auto-format.sh` carries a skip-list for exactly that reason.
- **verified** — Q0: secrets deferred · desktop notify reused · F7 is the JML simulator with a Pokémon overlay (joiner Charmander, mover Squirtle, leaver Bulbasaur), fixture-level only with the §7 rubric unchanged · 45 min per-phase wall ceiling · default roadmap order · §11 ETL lanes pre-authorized.

## Enforcement layer — what is actually proven, not merely written

- **verified** — All ten hooks dispatch live through the platform, confirmed at G-F2 rather than by harness simulation alone.
- **verified** — Six-op adversarial stress: 6/6 denied with correct HC-specific reasons, 6/6 audit records written. Every probe was chosen to be inert if its guard had failed.
- **verified** — Denials were **silent** until G-F2's live stress found it: `deny()` wrote no record, and `PostToolUse` cannot cover a denial because the blocked tool never runs. Fixed in `hooks/_common.sh`; records now carry `event:"PreToolUse.deny"` plus tool, target, reason and phase.
- **verified** — `auto-format`, `error-recovery` and `notify` had zero harness coverage until G-F2. `cases_F2` is now 35 checks, up from 27.
- **verified** — R2 is closed: `$CLAUDE_PROJECT_DIR` is genuinely absent from the Bash tool shell, but hooks resolve anyway via a two-layer fallback (`${CLAUDE_PROJECT_DIR:-.}` in settings, dirname-derived `ROOT` in `_common.sh`). Any new hook must keep a fallback rather than depend on the bare variable.
- **verified** — `bash-blocker.sh` substring-matches the whole command, so it denies a command that merely _mentions_ a trigger. Tests must not inline literal trigger strings into a Bash call; running the harness script is unaffected.
- **verified** — PreCompact cannot be triggered on demand. Its coverage is ccs-01 at harness level plus the numbered snapshots already in `.claude/state/checkpoints/`.

## Open blockers carried into later phases

- **verified** — C-05 / OQ-10: `Task` is now `Agent`; §5.2.2's bypass detection must match both names or a real bypass passes silently. F3. `scripts/check-plan-corrections.sh F3` exits 1 until it lands.
- **verified** — OQ-2: `.pinned` cannot express a context-variant id such as `claude-opus-5[1m]`, so a pinned-mode reproducibility run would not reproduce this session's model. Alias mode is unaffected.
- **proposed** — `SubagentStart`/`SubagentStop` carry `agent_type`, which would make arbiter-bypass detection deterministic instead of audit-diff-based. Operator decision at F3.
- **proposed** — `PostCompact` exists and could strengthen §15.9, which currently concedes PreCompact cannot shape the compaction summary.

## Next action

**verified** — Await `APPROVE GATE-F2`. On approval: F3 — Core Bench, which must start by applying C-05.
