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
