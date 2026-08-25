# DIRECTORY_GUIDE.md
psychic-crew/
├─ MASTER_FIFO_PLAN_CLAUDE.md   # execution authority (canonical; edited HERE under its own gate — R-CH-1; the version lives in this file's header alone)
├─ CLAUDE.md                    # standing context (loaded every session)
├─ CLAUDE_DESIGN.md             # architecture rationale + attributions
├─ DIRECTORY_GUIDE.md           # this map (matches the v1.0.0 tree + audit outputs)
├─ Plan.md                      # LIVE log: debugging, fixes, review notes, navigation decisions
├─ GATES.md                     # gate ledger: token, timestamp, demo/stress results
├─ PROGRESS.md                  # compaction-safe phase/step checkpoints
├─ README.md                    # operator quickstart (written at F8)
├─ ROADMAP.md                   # accepted domain order + dormant lanes (written at F8)
├─ models.config.json           # SINGLE source of truth: per-agent model/version/effort
├─ .gitignore                   # also fences the local reference corpus (stage-everything = 0)
├─ .claude/
│  ├─ settings.json             # permissions + hooks + env (project scope)
│  ├─ agents/                   # 8 agent definitions (frontmatter stamped by apply-models.sh)
│  ├─ rules/                    # arbiter-protocol · fallback-protocol · model-policy · security · shell-discipline · secrets-contract (R-SEC-1: the rules a credential must live under BEFORE any pack ever holds one)
│  ├─ skills/threshold-router/SKILL.md
│  └─ skills/intake/SKILL.md    # CR-026 user-facing task-contract intake (R3a: blocking only at high/crit; advisory below)
├─ hooks/                       # 14 tracked files — _common.sh (shared library, not a hook) · audit-logger.sh · auto-format.sh · bash-blocker.sh · error-recovery.sh · model-guard.sh · notify.sh · pre-compact-checkpoint.sh · provenance-flag.sh · reference-cap.sh · sensitive-guard.sh · session-start.sh · stop.sh · subagent-start.sh
├─ scripts/                     # 11: setup · apply-models · validate-crew · run-crew-tests · save-context (§15.5) · restore-context (§15.9) · portability-drill · measure-dispatch-cost · check-plan-corrections · gate-guard (H0a: refuses a gated commit until the session's APPROVED token line exists in GATES.md) · check-decision-matrices (H3b: dated-record fidelity + corpus census over docs/audit)
├─ logs/                        # gitignored: arbiter-audit.jsonl · tooluse-audit.jsonl · build-errors.jsonl · subagent-starts.jsonl · intake-contracts.jsonl · metrics/ · rounds/
├─ context/                     # tracked knowledge base — session-summary.md (entry) · plan-corrections.md (WINS for implementation) · budget-baseline.md · f2-readiness.md · f7-metrics.md · f7-plan.md
├─ docs/                        # audit/ (final-audit outputs) · security/ (threat model spanning both repos, red-team records) · metrics-snapshot.json + dispatch-cost.vl.json (CR-006)
└─ stress-project/              # F7 JML simulator (22 files)
Navigation rule: any fix or anomaly → append to Plan.md first (what/where/why/fix), then act. Runtime flags and auto-snapshots (.claude/state/compact-pending · .claude/state/checkpoints/) are gitignored; the context/ tree is tracked and merge-distilled, never appended-to raw (§15.5/§15.9).
