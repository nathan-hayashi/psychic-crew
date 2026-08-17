# RULINGS_AND_DEPLOYMENT_2026-08-16.md — Operator Rulings Register + Swap Sequence
Recorded verbatim from the operator, 2026-08-16, while the Final Audit session runs. Pairs with MASTER_FIFO_PLAN_CLAUDE.md v3.0 (this re-export) and CLAUDE_CODE_FINAL_AUDIT_PROMPT.txt.

## 1. Rulings → effect → landing spot
| ID | Ruling | Effect | Lands in |
|---|---|---|---|
| A1b | Retire EX-01 via upstream re-export under the permanent psychic-crew name | EXECUTED this session: plan v3.0 produced; 8 occurrences renamed; DIRECTORY_GUIDE payload rewritten to the real v1.0.0 tree; byte-pin re-binds to v3.0. CLAUDE.md + CLAUDE_DESIGN.md seeds verified byte-identical to the deployed repo; Plan.md payload = F0 seed (live ledger exempt, seed-prefix check); DIRECTORY_GUIDE repo file update = CR post-audit | Plan v3.0 D14 + this file |
| A2a | C-05 structural bypass prevention authorized | Pre-authorized as a permission-boundary CR; requires its own gate + negative control; §5.2.2 corrected to current ground truth ([E]: lifecycle hooks carry agent type) | Plan v3.0 §5.2.2 + audit CHANGE_REQUESTS.md |
| A3a | Adjudicate the four quarantined findings in the audit | Already in the running prompt (Phase A4.3) — no mid-run change needed | Audit session |
| A4a | Skill-packs are proposal-only until a per-pack gate grants scoped write | Standing credential policy for every future domain pack | This file (policy); ROADMAP CR |
| B1a | Lite roster = four lean agents (session-orchestrator, builder, verifier, security; discourse collapsed to one adversarial pass) | Scoping input for the Lite plan | Next planning session |
| B2a | Lite runtime = Claude Code CLI inside a Zed terminal thread, plan-driven | Same | Next planning session |
| B3a | Work-agent list consolidated per taxonomy (Velocity→orchestration, Management→ledger, Audit→Compliance-Evidence, Lean→Specification; Confluence/ROVO/Okta/GCP = domain skill-packs, not permanent agents) | Same | Next planning session |
| B4b | Lite uses FULL FIFO gates (overrides my one-gate-per-sprint recommendation) | Lite plan gets the complete gate grammar, scaled phases | Next planning session |
| C1b | PowerShell-native scope = FULL 1:1 of all 9 scripts AND 12 hooks | Gating unknown stays live: how Claude Code invokes hooks on native Windows [V?] — the audit's PLATFORM_GAP_POWERSHELL.md must resolve it FIRST; full parity is then scoped as its own gated phase | Audit A5.2c → planning session |
| C2a | README floors: Win10 22H2 + Win11, PS 7.4+, Node 20 LTS, 16 GB RAM | Facts for the README requirements CR | Audit A5.2d |
| C3a+c | Document Max 5x minimum / Max 20x recommended (citing the measured 3.08M-token build) AND add an API-billing section | Same CR, both parts | Audit A5.2d |
| D1a | Corpus deep dives: gastown (mandated) + oh-my-claudecode + ruflo | Multi-session reading effort; Project-Explorer.md tiers govern depth | Next planning session(s) |
| D2b | Operator manually places Ralph into the local corpus for its stop-conditions design | See §3 placement instructions below — outside git, fenced by the existing .gitignore convention | Operator action |
| D3c | Drop the token pass/fail axis | EXECUTED in v3.0 at three sites; wall/context ceiling stays as an early-gate TRIGGER; measured baselines (context/budget-baseline.md) are the reference truth | Plan v3.0 |
| E1a | Task-Contract intake layer built for BOTH crews as a gated phase | Blueprint = the Army report's contract/intake schemas (untrusted source, patterns only); audit A5.2b specifies it; planning session authors the phase | Audit → planning session |
| E2a | Capability classes (economy/standard/deep) resolving to the existing aliases inside models.config.json | Single-file rule preserved; CR-scoped config+stamp change with its own gate | Audit CHANGE_REQUESTS.md |

## 2. Deployment sequence — DO NOT run while the audit session is mid-flight
The audit's conformance phase checks the plan byte-pin against the CURRENT canonical (v2.3-named copy). Swapping mid-audit changes ground truth under a running measurement. Sequence:
1. Wait for the audit to reach and receive `APPROVE AUDIT-GATE-A5`.
2. Copy into the repo root, replacing: MASTER_FIFO_PLAN_CLAUDE.md (v3.0), DIRECTORY_GUIDE.md (the new seed). CLAUDE.md, CLAUDE_DESIGN.md need no copy (already byte-identical); Plan.md is a live ledger — never replaced.
3. Run ./scripts/validate-crew.sh and ./scripts/run-crew-tests.sh; expect the baseline counts. Any check that pinned the old name or old map is adjudicated against v3.0 as authority (its detector updates are part of the same commit).
4. Commit as a single gated change: `docs: adopt canonical plan v3.0 (psychic-crew re-export, EX-01 retired, D3c, D14)` — operator token in GATES.md per the standing grammar.
5. Replace the copy in this Claude web project with v3.0 so upstream, repo, and project are one byte-identical triple again.

## 3. D2b — placing Ralph (operator, manual, outside this repo's tooling)
Obtain the Ralph repository on the host by any means OUTSIDE the psychic-crew tooling (its deny-list rightly blocks clone verbs); place it in the project root using the same corpus naming convention the .gitignore catch-all fences; then run the stage-everything probe and confirm it still stages ZERO files before doing anything else. It is read-only reference material — the sixteen become seventeen, the no-installs constraint is untouched.

## 4. Standing next-session agenda (planning, per READ FIRST)
Psychic-Crew-Lite plan (B1a/B2a/B3a/B4b) · intake/Task-Contract phase for both crews (E1a) · PowerShell full-parity phase pending the [V?] resolution (C1b) · corpus deep-dive schedule (D1a, gastown first) · capability-class CR (E2a) · C-05 implementation gate (A2a) · README/requirements + API-billing CRs (C2a, C3a+c) · decision-matrix suite ("matrices inside matrices") over audit outputs.
