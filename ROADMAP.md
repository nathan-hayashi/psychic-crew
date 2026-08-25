# ROADMAP

Stub, written at F8 per the plan. Nothing here is scheduled or committed to; each item names what would have to be decided before work starts. The build itself is complete at `v1.0.0`.

**Reviewed against `context/session-summary.md` on 2026-08-21.** Two entries under *Open decisions* were carrying work that had already closed — the `DIRECTORY_GUIDE.md` drift and the G-F3 re-emission — and both are corrected below rather than deleted, because a roadmap that silently drops an item reads the same as one that never had it. Nothing here binds these entries to the distilled summary, so this review is a periodic obligation, not a check; that gap is recorded in `Plan.md`.

## Domain skill-packs — the Q6 order

The operator accepted the default ordering at Q0. Each pack is a set of domain agents, rules and fixtures layered on the existing crew, not a new crew.

**Operator instruction, 2026-08-25 (CLEANUP-1 intake contract, verbatim): "Run everything for a cleanup phase. And skip Pack-2. H3b run that afterwards."** The pack lane is therefore SKIPPED — the ordering below stays recorded for whenever the operator reopens it, and nothing in it starts without a new instruction. H3b runs next, after the cleanup gate.

1. **IAM** — joiner/mover/leaver is already modelled by `stress-project/`, which makes this the shortest path from simulator to something that touches a real directory. Blocking decision: which identity provider, and whether any pack ever gets write credentials or stays proposal-only.
2. **Compliance** — evidence collection and control mapping. The audit trail, severity rubric and gate ledger already produce most of the artifacts an auditor asks for; the work is mapping them to a framework rather than building new machinery. Note the SOC 2 datapoint recorded against Managed Agents below.
3. **HR-lifecycle** — the upstream half of IAM: the HRIS events that trigger everything else. Depends on IAM landing first, since it produces the events IAM consumes.
4. **ITSM** — ticketing and change management. `src/ticketing.js` is the toy version; the real question is whether the crew files tickets or only drafts them.
5. **Rest** — unordered until the four above have run.

## Queued here, re-homed from the retired upstream channel (R-CH-1)

**H3b — corpus deep-dives and the standalone decision-matrix suite.** Queued, not dormant: it was
agenda work in the Claude.ai channel, and ruling R-CH-1 retired that channel rather than the work.
It runs here now. The reference corpus is already local and read-only behind the `.gitignore` fence,
so the deep-dives need nothing new; the decision-matrix suite runs over `docs/audit/` outputs.
Ordering settled by operator instruction (2026-08-25): H3b runs NEXT, immediately after gate CLEANUP-1; the pack lane above is skipped until reopened.

## Dormant lanes

**Claude Managed Agents (§11.5).** Evaluated and deliberately not adopted: Claude Code is the runtime, the target is a local WSL2 environment on a Max subscription, and the FIFO's human-gate cadence fits an interactive CLI rather than a remote harness. Held open as the event-automation lane. Opening it is a gated decision and needs three facts weighed: it is API-billed separately from Max, the beta is subject to change, and stateful sessions are not ZDR-eligible — a compliance datapoint, mitigable with self-hosted sandboxes and session deletion. The scheduled/event-driven choice is between Managed Agents deployments + webhooks, self-hosted n8n, GitHub Actions, and Okta Workflows, scored per event source. Required reading before the gate opens is listed in the plan's residual queue.

**Peer review (§14.1).** A fresh-context Claude subagent, worktree-isolated with no conversation history, running the same prompt contract as the author. Designed, not built. The independence contract is the hard part: partial or empty peer output must be handled as a failure, never synthesised locally and never treated as empty success.

## Interim mechanisms with removal conditions

**WORKAROUND-01 — auto-checkpoint snapshots (§15.9).** Explicitly a workaround, not architecture: PreCompact numbered snapshots, a rolling `latest.md` refreshed every turn, 10-deep retention, and a restore path. It exists because compaction cannot be shaped from inside the session. **Remove it when an official continuity capability lands**; removal is a gated change like any other, and the tests covering it (`ccs-01`…`ccs-03`) go with it.

## Open decisions carried out of the build

- **C-05 — DONE at a gate, as C-25 (2026-08-19), in a corrected scope.** The plan assumed hooks could not attribute caller identity; that assumption was outdated. `SubagentStart` supplies `agent_id` and `agent_type`, so attribution is deterministic, detection moved from the gate to the moment of creation, and coverage now includes dispatches that FAILED — the hole C-12 observed, where `PostToolUse` cannot fire for a tool that never executed. **What this roadmap entry used to promise and cannot deliver:** turning detection into *prevention*. `SubagentStart` cannot block subagent creation `[V]`. A bypass is caught immediately and by identity; it is not stopped. Prevention at the call would need a `PreToolUse` deny on the dispatch itself and is not currently scoped.
- **C-19 residual — F7 coverage ordering.** Fixed forward, unrecoverable backward. Nothing to decide, recorded so nobody re-derives it.
- **C-21 residual — dispatch cost is measured from session transcripts outside the repo.** A dispatch's cost is not knowable at dispatch time, so no hook can record it; the honest structure is the phase-end regeneration step that now exists. Worth revisiting only if the runtime starts exposing per-dispatch usage to the session.
- **`DIRECTORY_GUIDE.md` drift — the entry as written is CLOSED, and a different one is open.** The drift this described is resolved: ruling A1b re-exported the plan under the permanent name, **EX-01's rename allowance is retired** (the EX-01 label lives on in the suite, naming the strict delta-0 seed checks), and the map now matches the tree in both directions for `scripts/` (9) and `context/` (6), asserted by CR-024 on every run. This entry still cited EX-01 four sessions after it stopped existing. **What is open is not the same thing.** C-26 (2026-08-21) found the map says 12 hook scripts against a tree of 14, and that CR-024 polices `scripts/` and `context/` but has never policed `hooks/` — the one directory holding the enforcement layer. The tree half is now bound to `.claude/settings.json`; the map half needs an **operator re-export**, because `DIRECTORY_GUIDE.md` is the plan's §4.3 byte-pinned payload and writing a corrected number into it locally would fail the seed-identity check the build rests on. The F4 precedent — route around the pin by creating what the map already claims — does not apply to a count. **CLOSED (recorded at CLEANUP-1, 2026-08-25):** the re-export happened at plan v3.2/D17 (all fourteen hooks enumerated by name), C-26 has policed map against tree in both directions ever since, and R-CH-1 then retired the re-export valve itself — the plan is edited here under gates now. This entry described the pre-D17 state to four days of later readers; corrected in place rather than deleted.
- **G-F3 round-2 re-emission — CLOSED at audit phase A4.** All four of branch B's anchor-verified findings were adjudicated: three ACCEPT, one REJECT. Two of the accepted three were then resolved outright by the v3.0 map re-export. Nothing is quarantined and nothing is owed; this entry claimed otherwise for four sessions after the fact.
- **Permanently lost upstream artifacts — recorded, not chased (2026-08-25).** The upstream channel's three audit trails (`AUDIT_TRAIL_R3/R4/R5.md`) and `CLAUDE_CODE_FINAL_AUDIT_PROMPT.txt` are absent from both the web project and `docs/audit/`. The trails were the only written record of the P1–P5 operator-pushback exchanges, and the plan's own header cites all three by name. The audit's *findings* survive in `docs/audit/`; what is gone is the *argument*. Separately, the transfer bundle's promised `source_files/` archive of 21 knowledge files was never delivered. That was recorded as a recoverable gap rather than a loss, on the ground that the web project still held them — **ruling R-CH-1 (2026-08-25) removes that ground.** With the channel retired the archive is not being fetched, so in practice it joins the four above. It is kept in its own category because the distinction is still true and still matters: those four no longer exist anywhere, this one exists and will not be retrieved. Operator decision: no re-export requested. Fixed forward, unrecoverable backward. Nothing to decide, recorded so nobody re-derives it. Full account in `docs/context-transfer-reconciliation.md`.
- **OQ-2 — pinned-mode reproducibility.** The orchestrator ran a context-variant model id that the pinned config cannot express. Alias mode is unaffected; a pinned reproducibility run would not reproduce the variant.

## Not on the roadmap

**Native Windows, in any form — SUPERSEDED and closed by operator ruling R1d (2026-08-19).** This
project is bash-native end to end, permanently: no PowerShell port of any script, hook or
assertion, no Node rewrite of the assertion layer, no Git-Bash bridge. **Windows 10/11 is supported
exclusively through WSL2**, and installing it is a documented prerequisite rather than a limitation
to engineer around. Why: one codebase and zero assertion divergence — the audit's
`docs/audit/PLATFORM_GAP_POWERSHELL.md` priced every alternative at either a 3–5 day port carrying
a dual 144-assertion divergence class, or new host-toolchain assumptions, for a target the operator
no longer requires. This entry did not previously exist on the roadmap; the work lived in the
rulings register (C1b) and the audit's gap report, so R1d is recorded here to close it where a
reader would look for it.

Anything requiring an install, a clone, `npx`, or an MCP server, and any cross-vendor model invocation. Those are excluded by the build's hard constraints, not by preference — lifting one is a change to the constraints, not a roadmap item.
