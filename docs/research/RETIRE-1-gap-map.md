# RETIRE-1 — gap map: retiring the orchestration guide in favor of psychic-crew

**Target:** the sibling repo `claude-agent-orchestration-guide` (public, MIT; 2 commits, both
2026-04-06; 101 tracked files, 1.2 MB; a 10-phase runbook-turned-guide documenting the operator's
ORIGINAL Claude Code orchestration stack — the user-global scaffolding that predates psychic-crew).
Surveyed fresh 2026-08-31, read-only. The operator's standing question — _"if we retire the old
system with psychic-crew, are all gaps covered?"_ — is answered row by row below, and the roll-up
is at the end. Crossing rules applied: no absolute machine paths, no personal identifiers.

**A distinction that keeps this map honest:** the guide is DOCUMENTATION; the scaffolding it
documents (user-global hooks, skills, router mandates) is LIVE CONFIG in the user scope. Retiring
the guide freezes the documentation. The live scaffolding is dispositioned per-row: superseded
pieces note their successor; still-useful generic pieces are KEPT (some fixed at this gate);
conflict pieces are SCOPED. Nothing here touches any other sibling repo.

## Phase-by-phase coverage

| Guide phase                                                        | What its stack provides                 | Estate coverage today                                                                                                                                                      | Verdict                                                                                 |
| ------------------------------------------------------------------ | --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| 00 preflight · 01 core-config (CLAUDE.md, settings, memory, rules) | hand-assembled per-machine config       | per-repo gated CLAUDE.md law; HARNESS-BUILD-1 user layer + `deploy-harness.sh` (explicit, reversible, suite-bound)                                                         | **COVERED — superior**                                                                  |
| 02 hooks system (global destructive-deny, prettier, toasts, stop)  | inline user-scope hooks, unaudited      | 15-hook enforcement layer (parent), universal user layer w/ central REDACTED trail + defer keystone; prettier stays generic but gains the byte-pin exemptions AT THIS GATE | **COVERED — superior** (prettier KEPT+FIXED)                                            |
| 03 threshold-router                                                | per-prompt tier scoring, global mandate | intake classifier + army-selector + gate law; inside the harness repos the tier is LOCKED, making the global mandate a double-router                                       | **COVERED inside the estate; global mandate KEPT for other repos, SCOPED at this gate** |
| 04 turbo skills (the 61-skill library)                             | generic workflow skills                 | in daily use (plan-style, code-style, finalize…); not superseded                                                                                                           | **KEPT — not part of the retirement**; ROUTE-1 curates                                  |
| 05 open-code-review · 06 codex plugin                              | cross-model review tooling              | HC-7 bars it inside the harness estate (arbiter/review discourse replaced it); outside, operator's own toolchain                                                           | **SUPERSEDED in-estate; HC-7-BARRED class lands at ROUTE-1**                            |
| 07 custom subagents                                                | hand-rolled subagent configs            | the 8-agent bench + arbiter broker, model-stamped, suite-bound                                                                                                             | **COVERED — superior**                                                                  |
| 08 skills library                                                  | skills catalog docs                     | project skills + ROUTE-1's coming curation                                                                                                                                 | **COVERED**                                                                             |
| 09 auto-mode                                                       | permissive-mode guidance                | gate law + guards make the trade explicit; deploy targets get universal safety                                                                                             | **COVERED**                                                                             |
| 10 integration testing                                             | smoke scripts                           | four parent suites (217/54/33/13) + Lite's five planes + witness                                                                                                           | **COVERED — superior**                                                                  |

## What is lost by freezing the guide

Nothing functional — it executes nothing. Two soft losses, both accepted at this STOP:
its tutorial framing for newcomers (superseded by both repos' GETTING-STARTED and the
CHANGE-PLANE chronicle, which document the LIVING system rather than the April snapshot), and its
public-reference value (it stays public and readable after the ARCHIVED banner; the banner points
readers at the successor). **No high-severity gap exists; nothing needs porting.**

## Interference cleanup executed at this gate (user-global, snapshot-first)

1. **Rules-directory symlink loop** — the user rules dir contained a self-referential `rules`
   symlink (infinite recursion for any rule walker) and a dead `nonexistent` link: both DELETED
   (directory snapshotted at FENCE-2; four real rule files untouched).
2. **Global prettier hook** — gains the same byte-pin exemption basenames the parent's
   `auto-format.sh` defends (the EX-01 identity files); everything else formats as before.
3. **Threshold-router double-mandate** — the short duplicate block removed from the user
   CLAUDE.md; the canonical block gains one scoping sentence: repos that pin their own tier (the
   harness repos' `CREW_TIER_LOCK`) follow their repo law, the router governs everywhere else.
4. **Duplicate toasts** — the global Notification/Stop inline hooks now defer wherever the repo
   carries its own `hooks/notify.sh`/`hooks/stop.sh` (one toast per event, same keystone shape as
   the user guard layer).
5. **`clone()` bootstrap wrapper** — its skip-list gains the harness estate (`psychic-*`), so a
   future clone of any estate repo is never auto-scaffolded by the old `new-project` flow.
6. **Parent README d2 claim** — corrected to its honest scope: the suite binds the PROJECT
   settings' hook topology; user-scope hooks merge in addition and are governed by the harness
   layer's own laws, not this diagram.

Out of scope, recorded: the barred repo's own `.claude/rules` symlink (prohibition — never
touched); the 61 turbo skills and the codex-family skills (ROUTE-1's inventory); the SessionStart
reload nag (benign, left).

## Freeze mechanics

`RETIRED.md` banner committed on the guide's own `main` (successor pointer to psychic-crew, date,
this map's path), SHA recorded in the parent ledger. **Not pushed** unless the operator says so at
the STOP — the public GitHub copy is unchanged until then. The repo stays on disk, read-only by
convention.

## Roll-up answer

**Are all gaps covered? YES.** Nine phases: seven COVERED (five superior), two KEPT-as-generic
(prettier fixed, turbo skills untouched pending ROUTE-1), zero requiring a port, zero
accepted-losses above `low`.
