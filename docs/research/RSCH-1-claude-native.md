# RSCH-1 — Claude-native capability + graph-context sweep

Gate: RSCH-1 (HELIX program). All sources read-only; every claim carries an evidence class
([E] established / [I] inferred / [S] speculative) and, for web claims, a retrieval date. Nothing
here installs or clones into either crew. Line-number/citation dating follows CR-033: URLs were
retrieved 2026-08-26 and are not re-fetched after.

## Named questions this gate answers

1. What does the cookbook knowledge-graph guide actually provide, mechanically?
2. Does the graph pattern close TEI's Context Fetch / Context Envelope gap better than the crews'
   current `context/` tree — adopt, pilot, or decline?
3. What in the broader Claude-native surface (cookbook index, claude-code.graph, Hermes, the four
   capture threads) is worth incorporating, and as what?

## Source register

| # | Source | Retrieved | What it is | Evidence |
| --- | --- | --- | --- | --- |
| S1 | platform.claude.com/cookbook/capabilities-knowledge-graph-guide | 2026-08-26 | KG construction recipe | [E] |
| S2 | platform.claude.com/cookbook/ (index) | 2026-08-26 | 94 cookbook recipes | [E] |
| S3 | github.com/aibozo/claude-code.graph | 2026-08-26 | code-structure graph tool for Claude Code | [E] |
| S4 | hermes-agent.nousresearch.com/docs/getting-started/quickstart | 2026-08-26 | Nous Hermes agent CLI onboarding | [E] |
| S5 | capture `kimi` — "300 Agents, 15 Steps: Context Graph Engineering" (@slash1sol) | on disk, fenced | context-graph doctrine | [E] |
| S6 | capture `roadmap` — "Graph Engineering with Claude: 14-Step" (@0xCodez) | on disk, fenced | graph-topology course | [E] |
| S7 | capture `brain` — "Second Brain Is Not a Storage System. It's a Compiler" (@rvaniaaa) | on disk, fenced | compiled-knowledge doctrine | [E] |
| S8 | capture `bench` — "17 Skills I Would Install on a Fresh Hermes Setup" (@FareaNFts) | on disk, fenced | Hermes skills catalog | [E] |

## S1 — the knowledge-graph guide, mechanically [E]

Architecture: an in-memory `NetworkX.MultiDiGraph`; nodes are entities (`type`, `description`,
`source_docs`, `mentions`); edges are typed relations carrying a `predicate` and a `source_doc`.
Extraction is a single structured-output call per document (`claude-haiku-4-5` for volume), with
Pydantic schemas (`Entity`, `Relation`, `ExtractedGraph`) so validation happens at the tool-call
layer — no regex, no JSON-decode errors. Entity resolution clusters variant names to a canonical
form (`claude-sonnet-4-6`), catching semantic equivalence string-similarity misses. Querying
serialises a 2-hop subgraph as triples and hands them to the model with the question. Claimed
improvements: no training data, semantic-equivalence resolution, multi-hop reasoning, answers
grounded in extracted edges rather than pretraining, and cost efficiency (Haiku + batch + caching).
Dependencies: `anthropic requests networkx matplotlib python-dotenv pydantic`, Python 3.11+, an API
key.

**The one line that transfers wholesale [E]:** the guide's grounded-query result — "with graph:
Claude cites only edges extracted from documents; without graph: Claude invents locations from
pretraining" — is the crews' own doctrine (a claim must bind to the artifact; the arbiter releases
only evidence-bound findings) expressed for context retrieval. It is the same rigor, one layer out.

## S5/S6 — the two capture threads that matter most [E]

Both independently converge on a single claim: **fan-out is solved; the merge is the product.**

- S5 (Kimi): 300 sub-agents dispatch in parallel; ~15 orchestrator steps plan/dispatch/assemble.
  The orchestrator, unable to read 300 findings, *compresses* — and compression "keeps the facts and
  throws away the relationships between them." The remedy is to make **edges a named deliverable**:
  a node is one thing an agent found; an edge is a relationship carrying its reason; "an edge you
  cannot explain is an edge you cannot trust." The governing rule, quoted: **"no shared source, no
  edge. An empty edge list is a valid answer."** Output is `graph.json`, not prose, so the structure
  "survives being closed and reopened next week."
- S6 (Codez, 14 steps): the same shape as an engineering course — nodes are bounded-contract jobs
  (`bounded input, validated output, exactly one job`); edges are *data contracts* ("A produces this
  shape, B consumes this shape"); the **diamond** (split → fan-out → reduce → synthesize) is the
  workhorse topology; a **router node** classifies with a model but **routes with code** ("the model
  classifies, the code routes" — no emergent "Claude decided to skip the audit"); a **verifier sits
  on the edge** and tries to *kill* the finding before it passes (adversarial / perspective-diverse /
  judge-panel); nodes isolate in worktrees when they write in parallel; unknown-size discovery uses
  **loop-until-dry, deduping against everything seen**; models are tiered per node; and Claude Code's
  **dynamic workflows / ultracode** let Claude write the orchestration script itself, coordination
  costing zero model tokens because it is code.

**Finding [E]:** S6 is, almost line for line, a description of psychic-crew's own machinery and the
Workflow tool — router-classifies-code-routes is the intake+threshold-router; verifier-on-the-edge
is the two-round discourse + fixer; loop-until-dry-dedup-against-seen is the correction registry's
convergence discipline; "no shared source, no edge" is "a check binds to the artifact." The crews
did not copy this thread; they arrived at it independently, which is the strongest possible
corroboration that the doctrine is sound.

## S7 — second brain as compiler [E]

Karpathy's "LLM Wiki" (April 2026) reframed: **compile, don't store.** `raw/` is an input buffer,
`wiki/` is where one source touches ten pages and contradictions get flagged, `output/` is built
from compiled knowledge; a `CLAUDE.md` is "a compiled profile the model maintains." "RAG re-derives
knowledge on every query; a compiled wiki derives it once and keeps it current." Honest limits
stated in the thread: quality depends entirely on source quality ("a bad source in a compiler has
touched fifteen pages before you notice"); value only appears past ~50–100 well-compiled sources;
requires Claude Desktop + a paid plan + scheduled tasks. **This is the crews' `context/` distill-
merge doctrine and the R-CH-1 "disk is canonical" law, arrived at from the knowledge-management
side.** [I] The "one bad source touches fifteen pages" warning is a real risk the graph lane must
answer with provenance edges (S5's `source_doc` per edge).

## S2 — cookbook index: the TEI parts list [E]

94 recipes. The ones that are TEI components off the shelf, not analogies:

| Recipe | TEI component it supplies | Verdict |
| --- | --- | --- |
| #7 Content-policy enforcement — compile a written policy into deterministic JSON rules; a rule engine that **never calls a model** produces auditable verdicts | **Escalation Threshold Router** — exactly the "deterministic policy engine, model only recommends" the feasibility text demanded | INCORPORATE-PATTERN |
| #22 Outcomes — a stateless grader fetches every URL and checks every quote against a rubric, driving revisions until pass | **Verification Engine** — independent-verifier-on-the-edge (S6) as a shipped pattern | INCORPORATE-PATTERN |
| #17 Fraud review (Mongo Atlas) — HITL decision + **append-only audit trail** in the system of record; four retrieval patterns incl. `$graphLookup` | **Provenance Ledger** + a graph retrieval precedent | INCORPORATE-PATTERN |
| #25 SRE / #36 SRE — agent opens a fix PR and **waits for approval before merging** | the dual-gate **Approval Service** | CONFIRMS crew design |
| #29 Managed Agents production — vault-backed MCP creds, `session.status_idled` webhook for HITL without long-lived connections, `budget_reached` | **Execution Gateway** + async HITL surface (ROADMAP §14.2 lane) | PARK (gated lane) |
| #30 Prompt versioning + rollback | the **Controlled Improvement Loop** ("helix") with offline eval before release | INCORPORATE-PATTERN |
| #45 Usage & cost **Admin API** | the **Compliance API** sub-study's sanctioned surface — research target for SIDE-5's legal gate | CONTEXT for RSCH-3 |
| #34 Context engineering; #46 memory tool + context editing | Context Envelope compaction options | CONTEXT-FETCH-CANDIDATE |
| #33 Knowledge-graph construction (= S1) | Context Fetch / Envelope graph lane | PILOT (below) |

## S3 / S4 — the two that are mostly negative results

- **claude-code.graph [E]:** builds dependency/call/AST graphs of a *codebase* into `.graph/`, MIT,
  `ccg start/build/daemon`. Real signal in the *idea* (structural code map for the agent) but the
  artifact is low-adoption (0 stars / 1 fork / 50 commits, retrieved 2026-08-26) and installs a
  daemon + `madge` + tree-sitter. **DISCARD as a dependency; the pattern (a queryable structural
  map beside the code) is already partly what DIRECTORY_GUIDE + the sync map do by hand.** [I]
- **Hermes [E]:** a capable agent CLI, but it is fundamentally an *installer* (`~/.hermes` binaries,
  40+ providers, Docker/SSH sandboxes) — the category HC-5 defines the crews *against*. One thing
  worth mirroring: its onboarding doctrine — "if it cannot complete a normal chat, do not add more
  features yet," a linear verify-base-then-layer progression, a Recovery Toolkit, and a Common
  Failure Modes table. **DISCARD as software; INCORPORATE-PATTERN its onboarding rigor into the
  GETTING-STARTED guides (a "common failure modes" section is a natural SIDE/ONBOARD follow-on).**

## The graph-lane pre-decision — the gate's centerpiece verdict

**Decision: PILOT a knowledge-graph context lane for TEI's Context Fetch / Envelope — do not adopt
it into the crews, and do not decline it.** [I, high confidence]

Reasoning, from evidence:
- The crews' `context/` tree is a *compiled document* store (S7's model) with hand-maintained
  bindings. It is excellent for a single build's distilled state and it is **not** built to answer
  "which two of 300 findings point at the same supplier" (S5's exact gap). TEI's Context Envelope —
  a portable manifest of sources, claims, contradictions, and provenance — is closer to a graph than
  to a summary.
- The transferable core is small and native: S1's node/edge/`source_doc` schema + S5's "no shared
  source, no edge" rule + S6's "edge is a data contract." All three are the crews' own binding
  doctrine, so a graph lane is a *generalization* of what already works, not a foreign framework.
- The risk (S7) is source quality poisoning a compiled structure; the mitigation is exactly the
  provenance edge (every edge names its `source_doc`), which the crews would demand anyway.

**Pilot shape [S]:** a `docs/research/` or sibling-repo prototype that takes a set of fenced source
docs and emits a `graph.json` (nodes = claims/sources, edges = shared-source relations with
evidence), scored by the "empty edge list is valid" rule — built native (no `networkx` install; the
schema is plain JSON the suites can validate the way they validate the vega-lite fence). Sequenced
into RSCH-3 (as the Context Envelope's candidate mechanism) and SIDE (as a Context-Fetch module),
never merged into the crew's own enforcement layer.

## Incorporation register (this gate's verdicts)

| Item | Verdict | Target component |
| --- | --- | --- |
| KG node/edge/source_doc schema (S1) | INCORPORATE-PATTERN | TEI Context Envelope |
| "no shared source, no edge" rule (S5) | INCORPORATE-PATTERN | Context Fetch binding rule |
| edge = data contract; diamond; router-classifies/code-routes; verifier-on-edge; loop-until-dry (S6) | CONFIRMS + INCORPORATE | Escalation Router + Verification Engine (already embodied; graph vocabulary added) |
| compile-don't-store; per-source contamination warning (S7) | CONFIRMS | context/ helix + Context Envelope provenance |
| content-policy → deterministic JSON rule engine (S2 #7) | INCORPORATE-PATTERN | Escalation Threshold Router (deterministic core) |
| Outcomes stateless URL/quote grader (S2 #22) | INCORPORATE-PATTERN | Verification Engine |
| append-only audit trail + HITL in system-of-record (S2 #17) | INCORPORATE-PATTERN | Provenance Ledger |
| prompt versioning + rollback + offline eval (S2 #30) | INCORPORATE-PATTERN | Controlled Improvement Loop |
| Admin/Usage API (S2 #45) | CONTEXT | RSCH-3 Compliance-API legal gate |
| knowledge-graph context lane (S1+S5+S6) | PILOT | TEI Context Fetch (RSCH-3 / SIDE) |
| claude-code.graph tool (S3) | DISCARD (dependency) | — |
| Hermes CLI (S4) | DISCARD (installer); INCORPORATE-PATTERN onboarding doctrine | GETTING-STARTED failure-modes |

## Confidence and weakest claim

**Core conclusion [E→I]:** the Claude-native surface offers TEI's exact missing pieces as shipped
patterns — a deterministic policy rule-engine (S2#7), an independent verification loop (S2#22), an
append-only provenance ledger with HITL (S2#17) — and a graph-context lane is the right *pilot*
(not adoption) for the Context Envelope. Confidence high for the parts-list mapping (each is a read
recipe), medium for the pilot recommendation (it is a design judgment, not yet a built control).

**Weakest claim, flagged:** that a *native* graph lane (plain-JSON, suite-validated, no `networkx`)
will match the guide's resolution quality is [S] — the guide leans on `networkx` traversal and a
synthesis model; a hand-rolled equivalent is unproven and is exactly what the pilot must falsify
before RSCH-3 commits to it. What would overturn the graph-lane decision: a pilot showing the
node/edge structure adds no answer the `context/` tree cannot already give for TEI's actual first
workflow (RSCH-3's chosen scope) — in which case the lane drops to PARK and the compiled-document
model (S7) stands alone.

## Verify (runnable where checkable)

- Source captures fenced, never published: `git check-ignore -q "Screenshot 2026-08-26 at 00-19-44 X.png"` exits 0.
- This file carries no upstream conversation URL beyond the source register's platform/github links,
  no employer identifier, and no mermaid fence (docs/ tracked-md rules).
- Cookbook recipe count re-checkable at S2's URL; the #7/#22/#17 recipe identities are the
  load-bearing rows and are quoted from the index.
