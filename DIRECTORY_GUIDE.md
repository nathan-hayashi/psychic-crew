# DIRECTORY_GUIDE.md
psychic-crew/
├─ MASTER_FIFO_PLAN_CLAUDE.md   # execution authority (this build)
├─ CLAUDE.md                    # standing context (loaded every session)
├─ CLAUDE_DESIGN.md             # architecture rationale
├─ DIRECTORY_GUIDE.md           # this map
├─ Plan.md                      # LIVE log: debugging, fixes, review notes, navigation decisions
├─ GATES.md                     # gate ledger: token, timestamp, demo/stress results
├─ PROGRESS.md                  # compaction-safe phase/step checkpoints
├─ models.config.json           # SINGLE source of truth: per-agent model/version/effort
├─ .claude/
│  ├─ settings.json             # permissions + hooks + env (project scope)
│  ├─ agents/                   # 8 agent definitions (frontmatter stamped by apply-models.sh)
│  ├─ rules/                    # fallback-protocol.md · arbiter-protocol.md · model-policy.md · security.md
│  └─ skills/threshold-router/SKILL.md
├─ hooks/                       # repo-tracked hook scripts (POSIX-safe, bash -c wrapped)
├─ scripts/                     # setup.sh · apply-models.sh · validate-crew.sh · run-crew-tests.sh · save-context.sh (§15.5) · restore-context.sh (§15.9)
├─ logs/                        # gitignored: arbiter-audit.jsonl · tooluse-audit.jsonl · build-errors.jsonl · metrics/
├─ context/                     # HC-8 distilled knowledge base (tracked): session-summary.md · decisions.md · architecture.md · runbook.md · troubleshooting.md · open-items.md
└─ stress-project/              # F7 end-to-end build workspace
Navigation rule: any fix or anomaly → append to Plan.md first (what/where/why/fix), then act. Runtime flags and auto-snapshots (.claude/state/compact-pending · .claude/state/checkpoints/) are gitignored; the context/ tree is tracked and merge-distilled, never appended-to raw (§15.5/§15.9).
