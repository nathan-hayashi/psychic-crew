# Explainers — the plain-language layer (COMPREHEND-2)

Every gate from the epoch below ships a plain-language explainer here: what changed, why, what each
piece does, **how to verify it yourself** (commands you run), and what could break with the
assertion that catches it. Written for the operator's altitude — no correction IDs, no doctrine
prerequisites. The expert record (Plan.md, GATES.md, the D-changelog) stays the audit surface; this
layer is the trust surface, and trust here means checks you can perform, not claims you believe.

## Epoch (machine-read by the suite — do not reword the next line)

EXPLAINER-EPOCH: COMPREHEND-1

Every row in `GATES.md` **after** the row whose gate name equals the epoch must have
`docs/explainers/<GATE-NAME>.md`. The binding is row-position, not date (the ledger's timestamp
column is empty on many rows); the suite carries a vacuity guard (the post-epoch set must be
non-empty) and a fire-probe (a planted post-epoch row without an explainer fails by name). An
explainer describes a **frozen** commit, so it does not rot as code moves; the binding guards
existence, and staleness is bounded by the gate it describes.

## On-demand explanation (the D half of the operator's choice)

Any file, change, or subsystem can be explained plainly on request at any depth — ask in plain
words ("explain X to me plainly"). This is deliberately an unpersisted answer built live from the
frozen record: nothing is written, so nothing rots. ROUTE-1 wires the natural-language routing
entry for it.

## Explainers

- [COMPREHEND-2](COMPREHEND-2.md) — this mechanism itself: the explainer discipline and its binding.
- [ROUTE-1](ROUTE-1.md) — invocation by intent: trigger phrases, explain-plainly, and the barred class.
- [MATRIX-AI-1](MATRIX-AI-1.md) — the 51-item checklist, every verdict written down and suite-checked.
- [S0-RECONCILE](S0-RECONCILE.md) — MIT estate-wide, identity, visibility truth, sibling explainer ports.
- [RPG-2](RPG-2.md) — the estate consumes the gallery: the vendored pin, the path-not-body cap.
- [S5-README-UX](S5-README-UX.md) — six front doors: bound badges, honesty sections, derived diagrams.
- [CORPUS-0](CORPUS-0.md) — the accounting before the reading: coverage bound, questions named, prohibition machine-visible.
- [CORPUS-ZEROSHOT](CORPUS-ZEROSHOT.md) — the first dive: typed completion studied, the coherence check transferred.
- [CORPUS-OPENHANDS](CORPUS-OPENHANDS.md) — dive 2: bounds compared, one rejection recorded, no-transfer stated loudly.
- [CORPUS-CONDUCTOR](CORPUS-CONDUCTOR.md) — dive 3: the explicit-vs-crash line and the failure trio, adopted with named owners.
- [CORPUS-SDKPY](CORPUS-SDKPY.md) — dive 4: three unseen lifecycle events, priced as assertions, queued for an operator gate.
- [CORPUS-TAKT](CORPUS-TAKT.md) — dive 5: the liveness axis our budget cannot see, landed in the baseline.
- [CORPUS-LANGGRAPH](CORPUS-LANGGRAPH.md) — dive 6: computed resume vs judged resume; the seen-cursor joins the hook queue.
- [CORPUS-AGENTFW](CORPUS-AGENTFW.md) — dive 7: ledgers as working-state vs ledgers as law; author-declared vs operator-declared gates.
- [CORPUS-BABYSITTER-1](CORPUS-BABYSITTER-1.md) — split part 1: mandatory per-step detection, filed with C-05.
- [CORPUS-BABYSITTER-2](CORPUS-BABYSITTER-2.md) — split part 2: interventions weighed, signing blocked by the secrets law, the ladder closed.
- [CORPUS-DELTA](CORPUS-DELTA.md) — four refresh verdicts in one gate; the coverage arithmetic closes 18/18.
- [BASE-1](BASE-1.md) — arc 3 opens: four candidates named, five axes reaffirmed frozen, posture stated.
- [BASE-2](BASE-2.md) — the matrix: setup settles, sixteen cells honestly open, roll-up suite-bound.
- [ARC4-1](ARC4-1.md) — the audit constitution: bands from the early baseline, empty-legal queue, three schemas discharged, gated-fixes law.
- [ARC4-2](ARC4-2.md) — the engine, fenced: tree-hash no-write control, seven skip-guards, human invocation.
- [TEI-0](TEI-0.md) — the envelope contract, the jq-only checker, and the graph verdict: PARK with a named wake.
