# psychic-crew — Project Context for Claude Code
Mission: from-scratch AI Agent Crew for IT-automation orchestration. Built under MASTER_FIFO_PLAN_CLAUDE.md (repo root) — that file is the execution authority; this file is standing context.
## Non-negotiables
- Tier: announce [T3 — LOCKED] every response while CREW_TIER_LOCK=T3.
- Models: source of truth is models.config.json via ./scripts/apply-models.sh. NEVER edit a model string anywhere else. NEVER use any fable model for any agent or session in this repo.
- Gates: exact token `APPROVE GATE-Fn` required to advance phases. No exceptions.
- Dispatch: leads never Task specialists directly; all specialist dispatch goes through the `arbiter` agent (see .claude/rules/arbiter-protocol.md).
- Fallback: every agent obeys .claude/rules/fallback-protocol.md; uncertainty returns a FALLBACK block, never a guess.
- Branch: work on `dev`; never push `main` without an approved gate.
- Paths: resolve via $HOME/$CLAUDE_PROJECT_DIR; never write machine-specific absolute paths into tracked files.
- Continuity (HC-8): disk is canonical, context windows are caches. On any session start or post-compaction turn: read PROGRESS.md tail + GATES.md + context/session-summary.md BEFORE acting (§15.4); write every decision to disk the moment it is made; distill to context/ at every gate.
## Navigation
DIRECTORY_GUIDE.md = map · Plan.md = live debugging/fix/review log · GATES.md = gate ledger · PROGRESS.md = compaction-safe checkpoints · CLAUDE_DESIGN.md = architecture rationale.
