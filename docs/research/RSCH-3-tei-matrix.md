# RSCH-3 — the Trusted Execution Infrastructure decision matrix

Gate: RSCH-3 (HELIX centerpiece). Subject: the operator's Assurance-Layer concept and the pasted
feasibility analysis — treated as DATA and verified, per the program law. Evidence classes as
throughout; web retrievals dated 2026-08-26.

## A. The pasted feasibility text, verified

| Citation it leaned on | Verified? | What verification found |
| --- | --- | --- |
| MCP specification (2026-07-28) | **[E] direct** | Confirmed: JSON-RPC host/client/server; resources, prompts, tools; elicitation; the Tasks extension (async long-running ops with durable handles) and Skills-over-MCP. Bonus: the spec's own security section states MCP "cannot enforce these security principles at the protocol level" and demands explicit user consent before any tool call — the policy-outside-the-model thesis, in the protocol's own words |
| OWASP LLM01 prompt injection | **[E] via corroborated search** (origin 403s a plain fetch) | 2025 framing confirmed: top-ranked risk; layered mitigations (privilege control, least privilege, input/output filtering, context isolation); "unclear if there are fool-proof methods of prevention" — so enforcement must live outside the model. Matches the text's claim |
| W3C PROV-O | **[E] direct** | Confirmed: Entity/Activity/Agent, wasGeneratedBy / wasDerivedFrom / wasAttributedTo / wasAssociatedWith; W3C Recommendation (2013), domain-neutral, designed as a reference model |
| ISO/IEC 42001 | **[E] via corroborated search** (iso.org 403s) | Confirmed: first certifiable AI-management-system standard; explicit Plan-Do-Check-Act continual-improvement framing — the "helix", standardized |
| OpenAI Agents HITL | **[E] direct** | Confirmed mechanisms by name: `needs_approval`, `RunState`, `interruptions` with `ToolApprovalItem`, `state.approve()/reject()`, serializable pause/resume across processes |
| EU AI Act (high-risk) | **[E] direct** | Requirement set confirmed (risk mgmt, documentation/traceability, human oversight, data quality, accuracy/robustness/cybersecurity) — with a MATERIAL timeline update the text predates: high-risk rules now apply **December 2, 2027** (Digital Omnibus extension from Aug 2026) |

**Verdict on the text [E]:** its architecture is sound and its citations check out; its one
correction ("approval only after completion is insufficient — use two gates") is **already
embodied** by the crews (plan approval before execution; exact-token STOP + post-commit acceptance
after). Its feasibility ratings (prototype 9/10 … universal 2/10) are judgments, not facts —
recorded as the author-session's [I], not adopted as ours.

## B. The incorporation matrix — TEI's ten components against what exists

Verdict vocabulary: **EXISTS** (crew artifact already does it — named) · **GENERALIZE** (crew
artifact is the seed; productization work named) · **BUILD-NEW** (no seed; build under a SIDE/TEI
gate) · **REJECT** (declined with reason). Nothing scored REJECT.

| # | TEI component (pasted text's terms) | Verdict | The crew artifact, named | The gap to product |
| --- | --- | --- | --- | --- |
| 1 | Request Contract | **EXISTS → GENERALIZE** | `.claude/skills/intake/SKILL.md` — goal, observable completion condition, class, quoted approval, contract line to `logs/intake-contracts.jsonl` | SIDE-0 template library (fields incl. unknown-stays-unknown, `context_policy` block); Sidekick fill-in UI |
| 2 | Context Fetch | **BUILD-NEW** | none (WebFetch/WebSearch are session tools, not a governed layer) | the RSCH-2 shortlist (Firecrawl/MarkItDown/Stagehand patterns, Mem0-shaped extraction), governed by declared `context_policy`; a SIDE/TEI gate |
| 3 | Context Envelope | **GENERALIZE + PILOT** | `context/` distill-merge with declared bindings (C-28) + the reconciliation crossing rule (what may/may not cross a boundary) | the RSCH-1 graph pilot: portable JSON manifest — source_manifest w/ hashes, claims, contradictions, expiration; "no shared source, no edge" |
| 4 | Risk & Escalation Router | **GENERALIZE** | intake classifier (first-match-wins data table, suite-exercised) + `security.md` severity vocabulary + the R3a blocking rule | tier table below; deterministic rule-engine core per cookbook #7 (a rule engine that never calls a model); n8n-shaped approval branches |
| 5 | Plan & Preflight Compiler | **EXISTS → GENERALIZE** | lead-planner's PLAN schema — `{"step","paths","acceptance","rollback_tag","budget_tokens"}`, acceptance-is-verifiable law, measured budgets | add the preflight fields the text names: expected_state_changes, affected_entities, reversibility, verification_tests |
| 6 | Approval Service (dual gate) | **EXISTS** | plan-mode approval (authorization BEFORE) + dirty-tree STOP + exact-token + `gate-guard.sh` + post-commit verification (acceptance AFTER) — both gates, mechanical | UI ergonomics for non-operators (Sidekick); nothing structural |
| 7 | Execution Gateway | **EXISTS → GENERALIZE** | hooks (deny-lists matched on whole strings, model-guard resolution, sensitive-guard, scrub()), allow-lists gated by rule, R-SEC-1 zero-credential default + A4a per-pack grants | per-workflow scoped credentials when a gate ever grants one (R-SEC-1 rules 2/4/6 already written for this); idempotency keys + spend caps for transactional actions |
| 8 | Verification Engine | **EXISTS → GENERALIZE** | the suites' doctrine: independent mechanism verifies (read-back after write, fidelity vs source, negative controls, announced SKIP ≠ pass) | the Outcomes pattern (cookbook #22) for content workflows; an explicit `indeterminate` verdict (today's honest SKIP-with-reason, renamed for workflow consumers) |
| 9 | Evidence & Provenance Ledger | **EXISTS → GENERALIZE** | GATES/Plan/PROGRESS + append-only logs/ trails + AuditRedaction discipline ("a redaction not recorded is indistinguishable from tampering") | PROV-O projection: Entity=artifact, Activity=phase/dispatch, Agent=operator/session/subagent; edges = the four relations; attribution-not-legal-ownership framing |
| 10 | Controlled Improvement Loop | **EXISTS** | corrections registry + gated releases + witness manifest re-stamp ritual + "no new allow-rules without a gate" (successful outcomes never auto-widen anything) | codify as the helix contract in TEI-PREPLAN; ISO 42001's PDCA is the external vocabulary for what already runs |

**The headline [E]:** seven of ten components EXIST in enforced, suite-proven form; two GENERALIZE
from strong seeds; exactly one (Context Fetch) is a true build. The pasted text's "durable product
value is the context contract, policy router, approval architecture, verification layer and
provenance record" — four of those five are the crews' existing spine. TEI is a productization
program, not an invention program.

## C. Risk tiers — one vocabulary, not a second scale

The text's 0–4 tiers projected onto the vocabulary the repos already enforce (the CR-026 lesson:
no second scale):

| TEI tier | Text's example | Existing vocabulary | Existing control |
| --- | --- | --- | --- |
| 0 | read-only summarization | intake `low` | log and proceed (contract line) |
| 1 | reversible internal change | intake `med` | proceed on acknowledgement; suites verify |
| 2 | external communication / material impact | intake `high` | **blocking**: explicit approval quoted back before work (R3a) |
| 3 | financial/legal/security/employment action | intake `crit` + `security.md crit/high` | exact gate token; dual-gate; specialist review = the discourse bench |
| 4 | prohibited / unverifiable | deny-list | mechanically refused (hooks); no route to override in-session |

Specialist modules → existing agents, reuse over invention: devil's advocate = discourse CHALLENGE
verb · hallucination auditor = evidence-class labeling + verification doctrine · risk assessor =
security-reviewer lens · business-justification reviewer = intake goal/completion-condition fields ·
data-completeness collector = Context Envelope `missing_information` (pilot) · approval-authority
resolver = **BUILD** (per-department policy packs; no seed exists).

## D. Compliance API — the legal/privacy gate (criteria, not a build)

The idea: programmatically collect session/memory/file artifacts into per-department assurance
views. **Six criteria, ALL required before any SIDE-5 build opens:**

1. **Sanctioned surface only [E-partial]:** Anthropic's Admin/Usage API demonstrably covers usage
   and cost (cookbook #45). Whether a sanctioned *content* export surface exists for an
   organization's sessions must be verified at SIDE-5 against current Anthropic enterprise docs —
   never assumed, never scraped around.
2. **Consent + jurisdiction:** written worker-notification/consent model reviewed against the
   operating jurisdiction (employee-monitoring law varies hard); the EU AI Act timeline (high-risk
   rules 2027-12-02) recorded as context where applicable.
3. **Data classification + internal-only storage** with named retention (the operator's own rule:
   company data is internal only).
4. **Delegated-filter distribution** — access routed through the legal/compliance filter the
   operator named, expressed as policy rows, not habits.
5. **Transparency artifact** — the collected-from population can see what is collected and why
   (the crews' own ledger ethic applied to people).
6. **Attribution, not ownership** — the PROV-O projection records contribution/derivation/
   responsibility; it never claims legal ownership (the text's own correction, adopted).

## E. First workflow — selected

Scored against the text's "best initial scope" checklist (internal data, explicit policies, limited
permissions, reversible, clear success criteria, known approval hierarchy, observable results):

**Selected: the Confluence documentation workflow — the Lite pack, instrumented as a TEI chain.**
[E-grounded choice] It already exists (P1a file intake, P2a no credentials, P3a proposals-only,
gitignored workspaces, live-drill hardened at LITE-SECURITY-1), it is reversible by construction
(proposals, never publishes), its approval hierarchy is the operator, and its outputs are
observable files. The TEI instrumentation gap is exactly the Envelope + Router + acceptance-record
pieces — the pilot surface. Runner-up (second workflow): SOC2/ISO evidence collection (the genesis
Audit-Agent vision) — higher stakes, natural tier-3, deferred until the chain is proven on tier-1.

## Confidence and weakest claim

**Core conclusion [E]:** TEI is feasible as a productization of the crews' existing constitution —
7/10 components exist enforced, the citations the concept leans on all verify, and the first
workflow has a live, hardened embryo. Confidence high.

**Weakest claim, flagged [I→S]:** the per-department policy packs (component 4's authority-resolver
and the "compile company policy into deterministic rules" step) assume real organizations' rules can
be formalized to first-match-wins tables the way this repo's intake classifier was — the pasted
text itself names policy formalization as the hardest problem, and nothing here has tested it
against a messy real policy corpus. What would overturn it: a pilot attempt at TEI-3 showing a
department's actual approval rules cannot be expressed deterministically without judgment calls at
every row — which would move the Router's core from "deterministic engine" to "deterministic
skeleton + gated human interpretation," a materially weaker product claim.
