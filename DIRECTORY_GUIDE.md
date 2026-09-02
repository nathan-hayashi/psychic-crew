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
│  ├─ skills/intake/SKILL.md    # CR-026 user-facing task-contract intake (R3a: blocking only at high/crit; advisory below)
│  └─ skills/army-selector/SKILL.md  # SIDE-3 typed specialist chooser (ARMY-TABLE v1; advice, never dispatch — zero-dispatch default stands)
├─ hooks/                       # 19 tracked files — _common.sh + _profile.sh (shared library + repo-class resolver, not hooks) · audit-logger.sh · auto-format.sh · bash-blocker.sh · error-recovery.sh · model-guard.sh · notify.sh · pre-compact-checkpoint.sh · provenance-flag.sh · reference-cap.sh · sensitive-guard.sh · session-start.sh · stop.sh · subagent-start.sh · subagent-stop.sh (HOOK-1: the lifecycle death half) · user-prompt-submit.sh (HOOK-1: derived-only prompt receipts — never the body) · permission-request.sh (HOOK-1: the ask-side of the denial trail) · agent-dispatch-guard.sh (HOOK-2: specialist dispatch needs a fresh arbiter arm — ordering and attribution, forgery stated residual)
├─ scripts/                     # 14: setup · apply-models · validate-crew · run-crew-tests · save-context (§15.5) · restore-context (§15.9) · portability-drill · measure-dispatch-cost · check-plan-corrections · gate-guard (H0a: refuses a gated commit until the session's APPROVED token line exists in GATES.md) · check-decision-matrices (H3b: dated-record fidelity + corpus census over docs/audit) · deploy-harness (HARNESS-BUILD-1: projects universal governance into an explicit target repo — dry-run default, marked regions + manifest, drift-refusal, byte-restoring --remove) · self-audit (ARC4-2: measures the estate against the AUDIT-RUBRIC bands; writes ONLY logs/audit/; never self-schedules; --measure-only is the no-write-control mode) · check-envelope (TEI-0: the Context Envelope schema + graph-pilot checker — jq-only, embedded fixtures, controls fire every run)
├─ logs/                        # gitignored: arbiter-audit.jsonl · tooluse-audit.jsonl · build-errors.jsonl · subagent-starts.jsonl · subagent-stops.jsonl · prompt-receipts.jsonl · permission-requests.jsonl · grounding-cursor.jsonl · intake-contracts.jsonl · metrics/ · rounds/ · audit/
├─ context/                     # tracked knowledge base — session-summary.md (entry) · plan-corrections.md (WINS for implementation) · budget-baseline.md · f2-readiness.md · f7-metrics.md · f7-plan.md · stress1-plan.md
├─ docs/                        # audit/ (final-audit outputs) · research/ (HELIX RSCH/SIDE/STRESS + additions-program reports) · explainers/ (COMPREHEND-2: per-gate plain-language layer, suite-bound) · security/ (threat model spanning both repos, red-team records) · GETTING-STARTED.md · PORTABILITY.md · context-transfer-reconciliation.md · CHANGE-PLANE.md + CHANGE-PLANE-INDEX.md (INDEX-1) · metrics-snapshot.json + dispatch-cost.vl.json (CR-006)
├─ stress-project/              # F7 JML simulator (22 files)
└─ stress-site/                 # STRESS-1 cats-and-dogs bench site (17 files, app suite 33/33)
Navigation rule: any fix or anomaly → append to Plan.md first (what/where/why/fix), then act. Runtime flags and auto-snapshots (.claude/state/compact-pending · .claude/state/checkpoints/) are gitignored; the context/ tree is tracked and merge-distilled, never appended-to raw (§15.5/§15.9).
