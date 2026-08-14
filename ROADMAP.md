# ROADMAP

Stub, written at F8 per the plan. Nothing here is scheduled or committed to; each item names what would have to be decided before work starts. The build itself is complete at `v1.0.0`.

## Domain skill-packs — the Q6 order

The operator accepted the default ordering at Q0. Each pack is a set of domain agents, rules and fixtures layered on the existing crew, not a new crew.

1. **IAM** — joiner/mover/leaver is already modelled by `stress-project/`, which makes this the shortest path from simulator to something that touches a real directory. Blocking decision: which identity provider, and whether any pack ever gets write credentials or stays proposal-only.
2. **Compliance** — evidence collection and control mapping. The audit trail, severity rubric and gate ledger already produce most of the artifacts an auditor asks for; the work is mapping them to a framework rather than building new machinery. Note the SOC 2 datapoint recorded against Managed Agents below.
3. **HR-lifecycle** — the upstream half of IAM: the HRIS events that trigger everything else. Depends on IAM landing first, since it produces the events IAM consumes.
4. **ITSM** — ticketing and change management. `src/ticketing.js` is the toy version; the real question is whether the crew files tickets or only drafts them.
5. **Rest** — unordered until the four above have run.

## Dormant lanes

**Claude Managed Agents (§11.5).** Evaluated and deliberately not adopted: Claude Code is the runtime, the target is a local WSL2 environment on a Max subscription, and the FIFO's human-gate cadence fits an interactive CLI rather than a remote harness. Held open as the event-automation lane. Opening it is a gated decision and needs three facts weighed: it is API-billed separately from Max, the beta is subject to change, and stateful sessions are not ZDR-eligible — a compliance datapoint, mitigable with self-hosted sandboxes and session deletion. The scheduled/event-driven choice is between Managed Agents deployments + webhooks, self-hosted n8n, GitHub Actions, and Okta Workflows, scored per event source. Required reading before the gate opens is listed in the plan's residual queue.

**Peer review (§14.1).** A fresh-context Claude subagent, worktree-isolated with no conversation history, running the same prompt contract as the author. Designed, not built. The independence contract is the hard part: partial or empty peer output must be handled as a failure, never synthesised locally and never treated as empty success.

## Interim mechanisms with removal conditions

**WORKAROUND-01 — auto-checkpoint snapshots (§15.9).** Explicitly a workaround, not architecture: PreCompact numbered snapshots, a rolling `latest.md` refreshed every turn, 10-deep retention, and a restore path. It exists because compaction cannot be shaped from inside the session. **Remove it when an official continuity capability lands**; removal is a gated change like any other, and the tests covering it (`ccs-01`…`ccs-03`) go with it.

## Open decisions carried out of the build

- **C-05 — hook-enforced bypass detection.** Detection is audit-based today: a bypass is caught at the gate, not blocked at the call. `SubagentStart`/`SubagentStop` carry `agent_type`, which would make attribution deterministic and turn detection into prevention. The plan assumed hooks could not attribute caller identity; that assumption is now outdated. Operator decision, and the single largest available upgrade to the build's self-declared weakest enforcement point.
- **C-19 residual — F7 coverage ordering.** Fixed forward, unrecoverable backward. Nothing to decide, recorded so nobody re-derives it.
- **C-21 residual — dispatch cost is measured from session transcripts outside the repo.** A dispatch's cost is not knowable at dispatch time, so no hook can record it; the honest structure is the phase-end regeneration step that now exists. Worth revisiting only if the runtime starts exposing per-dispatch usage to the session.
- **`DIRECTORY_GUIDE.md` drift.** Byte-pinned under EX-01 and out of step with the tree. The precedent from F4 is to route around the pin by creating what the map already claims rather than editing the map. Needs an operator routing decision either way.
- **G-F3 round-2 re-emission.** Four anchor-verified findings from branch B remain quarantined and unreleased. Small, and still owed.
- **OQ-2 — pinned-mode reproducibility.** The orchestrator ran a context-variant model id that the pinned config cannot express. Alias mode is unaffected; a pinned reproducibility run would not reproduce the variant.

## Not on the roadmap

Anything requiring an install, a clone, `npx`, or an MCP server, and any cross-vendor model invocation. Those are excluded by the build's hard constraints, not by preference — lifting one is a change to the constraints, not a roadmap item.
