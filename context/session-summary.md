# session-summary.md — distilled state (HC-8 §15.5)
Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Seeded at G-F0; F5 formalizes the distill-merge executor (scripts/save-context.sh).

## Where the build stands
**verified** — F0 complete, all 7 steps. Gate G-F0 awaiting `APPROVE GATE-F0`. Nothing beyond F0 has run.

## Decisions that constrain everything downstream
- **verified** — Project is `psychic-crew` (renamed from `hiya-crew` at Q1), public at github.com/nathan-hayashi/psychic-crew, working branch `dev`.
- **verified** — `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally (standing operator decision). Every plan defect is corrected in the artifact this repo builds, under a numbered exception in `Plan.md`.
- **verified** — EX-01 replaces §14.5 byte-identity with a bounded modulo-rename rule. EX-02 corrects three defects in §5.5's apply-models.sh logic.
- **verified** — Seed files are Bash-only. The global Prettier PostToolUse hook silently reformats `.md`/`.json` written via Write/Edit and destroys byte-pinned payloads.

## Open blockers carried into later phases
- **verified** — OQ-8/OQ-9: §4.6 hook entries use a shape that does not exist (`hook` string vs `hooks` array) and `PostToolUseFail` is not a real event; PreToolUse denial needs `hookSpecificOutput.permissionDecision`, not exit 2. F2 cannot work until both are corrected.
- **verified** — OQ-10: `Task` is now `Agent`; §5.2.2's bypass detection greps the old name and would pass while a bypass succeeds. F3.
- **verified** — OQ-7: `.claude/state/` is not gitignored despite DIRECTORY_GUIDE saying it is. F2.
- **proposed** — `SubagentStart`/`SubagentStop` hooks carry `agent_type`, which would make arbiter-bypass detection deterministic instead of audit-diff-based. Operator decision at F3.
- **proposed** — `PostCompact` exists and could strengthen §15.9, which currently concedes PreCompact cannot shape the compaction summary. F2.

## Next action
**verified** — Await `APPROVE GATE-F0`. On approval: F1 — Model Routing Layer.
