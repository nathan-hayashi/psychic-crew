# TEI-PREPLAN — the buildable pre-plan for the Assurance Layer

Status: PRE-PLAN (RSCH-3 deliverable). Nothing here is authorized to build; each phase opens on
its own operator gate when the program reaches it. Grounded entirely in RSCH-1/2/3 findings.

## The one-sentence product

A policy-controlled execution layer that turns an underspecified human objective into a
context-grounded plan, routes it through risk-dependent controls, executes permitted actions,
verifies the resulting state, and produces an auditable evidence record — built by generalizing
psychic-crew's proven constitution, not by inventing a new one.

## Phase ladder (each its own gate; order adjustable by numbered correction)

**TEI-0 — Context Envelope schema + graph pilot.**
Deliverable: `envelope.schema.json` (source_manifest w/ content hashes + retrieval times +
classifications, claims, contradictions, missing_information, applicable_policies,
permitted_recipients, expiration, provenance) + the RSCH-1 native graph pilot (plain JSON
nodes/edges/source_doc; the "no shared source, no edge" rule as a validator; suite-checked like
the vega-lite fence). Falsification target (the RSCH-1 weakest claim): does the graph answer a
question the compiled-document store cannot, on the first workflow's real material?
Exit: schema validated by a new standalone checker; pilot verdict recorded (adopt/park).

**TEI-1 — Escalation Router deterministic core.**
Deliverable: policy-rule compiler in the cookbook-#7 shape — a written policy compiled to typed
JSON rules; a rule engine that never calls a model produces the tier verdict; the model may only
RECOMMEND a classification, logged beside the deterministic result. Tier table = RSCH-3 §C (one
vocabulary). Includes the router's audit line (who/what/why-allowed) into the provenance trail.
Exit: fixture policies route correctly incl. negative controls; a rule change requires a gate.

**TEI-2 — the first workflow, instrumented end to end.**
Subject: the Lite Confluence pack (selected at RSCH-3 §E). Chain to prove: request contract →
context envelope → evidence-linked recommendation → tier verdict → authorization gate → bounded
execution (proposals only) → independent verification → acceptance gate → immutable outcome
record. Most links already exist; the work is wiring the envelope + router + outcome record around
the pack without touching its P1a/P2a/P3a law. Exit: one real document run whose completed record
answers all ten of the pasted text's credibility questions.

**TEI-3 — per-department policy packs (the hard one, staged last).**
Finance/engineering/marketing assurance presets: authority-resolver tables (who approves what, to
which amount/classification), compiled per TEI-1. This is the phase most likely to falsify the
deterministic-router claim (RSCH-3 weakest claim) — run it as an experiment with an honest
fallback (deterministic skeleton + gated human interpretation) rather than a promise.

**Interlocks with the SIDE ladder:** SIDE-0 (Templates) supplies TEI-0's request-contract fields;
SIDE-1 (Sidekick) is TEI's front end and consumes TEI-1's tiers for its per-department presets;
SIDE-5 (Compliance API) stays closed until RSCH-3 §D's six criteria pass.

## Standing laws carried into every TEI phase

- Dual gates always: authorization before execution, acceptance after — never acceptance-only for
  tier ≥ 2 (the pasted text's correction, already the crews' practice).
- Verification by independent mechanism, `indeterminate` stated when no verifier exists.
- Provenance in PROV-O projection; attribution, never legal ownership.
- The improvement helix is gated: no success ever auto-widens permissions, auto-reduces approvals,
  or promotes a prompt to production without its own gate (ISO-42001-PDCA-shaped, already law).
- Zero credentials until a per-pack gate grants one under R-SEC-1 rules 2/4/6.
- Company data internal-only; distribution through the delegated legal/compliance filter.
