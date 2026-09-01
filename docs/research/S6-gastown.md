# S6 dive — gastown (promoted at CORPUS-0)

Provenance: these findings were recorded in `Plan.md` as dated S6 ledger entries (2026-08-19/20)
and are promoted here VERBATIM — the census showed gastown as DIVED with no standing document, so
the record moves to where a reader looks, unedited. The ledger remains the original.

## The dive record, quoted

> [S6|2026-08-19T15:38:58Z] GASTOWN DIVE (D1a, mandated first). Read targeted rather than whole: Project-Explorer named six files, so ~30KB was read against a 4.3M-token repo. THREE MECHANISMS THIS BUILD LACKS, confirmed and detailed. (1) STALL DETECTION — three heartbeat stores with different readers and thresholds, plus a documented incident (hq-qxl9) where a Deacon refreshed its session heartbeat while the file store aged past threshold and produced a FALSE stuck-agent escalation. Their rule of thumb is this build's own lesson in another domain: "never declare an agent stuck from a single store" — cross-check actual session activity before escalating, because a live session with a stale store is heartbeat-write DIVERGENCE, not a stuck agent. That is a control bound to a proxy versus bound to the artifact, arrived at independently. They also prefer SELF-REPORTED state over liveness inferred from timers. (2) A WATCHDOG CHAIN — Deacon watches workers, Witness performs second-order monitoring of the Deacon, and Boot the Dog checks the Deacon every five minutes: "ensuring the watchdog itself is still watching". This build has no answer for a hung agent at all; an operator notices or nobody does. (3) SEANCE — a successor queries its predecessor's event log rather than inheriting a distilled summary. Different answer to the handoff problem than §15.5, and possibly better for facts a distillation would drop.

> [S6|2026-08-19T15:38:58Z] GASTOWN — TWO FURTHER IDEAS the map had not extracted. (a) NDI, Nondeterministic Idempotence: "useful outcomes through orchestration of potentially unreliable processes ... guarantee eventual workflow completion even when individual operations may fail or produce varying results." That is a philosophy this build has no name for, and it is what the FALLBACK protocol and the fixer's revert-on-red rule are groping toward. (b) UNIVERSAL ATTRIBUTION: every action, commit and work item carries a hierarchical agent identity (rig/role/name), motivated by four questions this build also faces — which agent broke it, how do you measure quality you cannot attribute, who approved this code, and which agent is better at what. C-25 landed the first half of that at S2 (runtime-supplied agent_id/agent_type); gastown carries it into git authorship, splitting AUTHOR (the agent) from the owning human. NOT adoptable here as-is: the operator's standing rule is that commits carry only their identity and never name an assistant as author or co-author. Recorded as considered-and-rejected-with-reason rather than silently skipped.

> [S6|2026-08-19T15:38:58Z] GASTOWN — THE PHILOSOPHICAL OPPOSITE, and it matters for the Lite plan. GUPP, the propulsion principle: "If you find something on your hook, YOU RUN IT ... there is no supervisor polling asking did you start yet ... every moment you wait is a moment the engine stalls." Gastown optimises for autonomous throughput at 20-30 agents; psychic-crew optimises for a human gate on every phase, and ruling B4b puts FULL FIFO gates into Lite as well. So propulsion is explicitly NOT adopted — but its enabler is: orientation commands (gt hook, gt prime, bd show) let an agent DISCOVER its own state rather than be told it, which is precisely §15.4 re-grounding and is worth keeping in Lite's four-agent roster where there is no orchestrator to re-brief anyone.

## Disposition

Adopted into the estate: the never-declare-stuck-from-a-single-store rule (a control bound to a
proxy vs the artifact, arrived at independently); orientation-commands-as-re-grounding (kept for
Lite's four-agent roster). Considered and REJECTED with reason: universal attribution in git
authorship (the operator's standing rule: commits carry only their identity); GUPP propulsion
(this program optimises for a human gate per phase, not autonomous throughput).
