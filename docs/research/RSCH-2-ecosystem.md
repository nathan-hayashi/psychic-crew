# RSCH-2 — ecosystem triage: all 50 named options

Gate: RSCH-2 (HELIX program). Full-coverage triage — every one of the 50 named items gets a row,
no skips (spec hard constraint). Evidence classes: [E] established (web-verified this gate, dated,
or read directly), [Ekn] established from training knowledge that is stable and low-risk to be
stale, [I] inferred, [S] speculative. Load-bearing or uncertain items were web-verified 2026-08-26;
stable well-known projects carry [Ekn] and are flagged where staleness would change a verdict.

Verdict vocabulary (from the plan): **INCORPORATE-PATTERN** (named pattern → named TEI/crew
component) · **COMPARE-BASELINE** (input to STRESS-1's rubric) · **CONTEXT-FETCH-CANDIDATE** (Context
Envelope / Packager option) · **LEARNING-SHELF** (reference value, not a build input) · **PARK**
(revisit on a named question) · **DISCARD** (out of scope by HC-5/HC-7 or irrelevance).

Coverage assertion: 50 rows below, numbered 1–50 matching the operator's list exactly.

## The triage table

| # | Item | Identity (what it is) | Licence / status | Verdict | Reason (bound to a component) | Ev |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | iFix | AI misalignment / red-team testing harness | OSS | PARK | Adversarial-eval patterns could feed the STRESS-1 robustness axis and the hallucination-auditor; revisit if TEI needs a misalignment gate | [I] |
| 2 | Public APIs | curated free-API directory | list | LEARNING-SHELF | Context-Fetch source catalog for the eventual connector set; not a build input | [Ekn] |
| 3 | Build Your Own X | learn-by-building tutorial index | list | LEARNING-SHELF | reference only | [Ekn] |
| 4 | Developer Roadmaps | skill roadmaps (roadmap.sh) | list | LEARNING-SHELF | reference only | [Ekn] |
| 5 | Free Programming Books | book index | list | LEARNING-SHELF | reference only | [Ekn] |
| 6 | System Design Primer | system-design study repo | list | LEARNING-SHELF | reference; distant relevance to the Scalability-agent doctrine | [Ekn] |
| 7 | Coding Interview University | interview-prep curriculum | list | DISCARD | out of scope for this program | [Ekn] |
| 8 | The Art of Command Line | shell mastery notes | list | LEARNING-SHELF | mild relevance to the crews' shell discipline (R-SD-1) as reading | [Ekn] |
| 9 | Project-Based Learning | tutorial index | list | LEARNING-SHELF | reference only | [Ekn] |
| 10 | You Don't Know JS | JS deep-dive books | book | LEARNING-SHELF | reference; relevant if Sidekick's UI is JS-heavy | [Ekn] |
| 11 | The Book of Secret Knowledge | ops/security cheatsheet index | list | LEARNING-SHELF | Security-agent reference catalog | [Ekn] |
| 12 | Tech Interview Handbook | interview prep | list | DISCARD | out of scope | [Ekn] |
| 13 | Awesome Selfhosted | self-hosting catalog | list | CONTEXT-FETCH-CANDIDATE | source catalog for internal-only deployment options (Compliance API, local runtimes) | [Ekn] |
| 14 | JavaScript Algorithms | algorithms in JS | repo | LEARNING-SHELF | reference | [Ekn] |
| 15 | 30 Seconds of Code | snippet library | repo | LEARNING-SHELF | reference | [Ekn] |
| 16 | GitHub Gitignore Templates | canonical .gitignore set | repo | INCORPORATE-PATTERN | direct hygiene input for every SIDE repo's fence at scaffold time (the L0 "controls travel with the scaffold" lesson) | [Ekn] |
| 17 | Ollama | local LLM runtime | MIT | DISCARD (dependency) | HC-7 Claude-only; a local non-Claude runtime cannot run any agent here. PARK-able ONLY as a Compliance-API research datapoint for on-prem inference geography | [Ekn] |
| 18 | LangChain | LLM app/agent framework | MIT | DISCARD (dependency); LEARNING-SHELF (patterns) | HC-5 no-install; its router/memory/tool abstractions are already natively present. Read for pattern vocabulary only | [Ekn] |
| 19 | n8n | fair-code workflow + AI automation | **Sustainable Use License (source-available, NOT OSI-open)** | INCORPORATE-PATTERN | its visual node/edge workflow + escalation branches are the **Escalation Threshold Router**'s reference model; the licence nuance matters — pattern-transform only, never bundle | [E] |
| 20 | OpenClaw | local AI assistant | OSS | PARK | local-assistant UX datapoint for Sidekick; verify identity before relying (low-signal name) | [S] |
| 21 | Dify | LLMOps / AI-app builder | OSS (partly) | COMPARE-BASELINE | a visual agent/app builder — a UX baseline for Sidekick and a STRESS-1 comparison alongside CrewAI | [Ekn] |
| 22 | Langflow | visual LangChain flow builder | MIT | COMPARE-BASELINE | visual-flow UX reference for Sidekick's fill-in-fields front end | [Ekn] |
| 23 | Mem0 | agent memory layer (vector + graph) | **Apache-2.0; graph memory via `mem0ai[graph]`; 52.8k stars** | CONTEXT-FETCH-CANDIDATE | the leading **Context Packager** candidate — its LLM fact-extraction + graph memory is the RSCH-1 graph-lane pilot's closest prior art; pattern-transform, do not install into the crews | [E] |
| 24 | Browser Use | browser-driving agent lib | OSS | CONTEXT-FETCH-CANDIDATE | web-context acquisition for Context Fetch; overlaps Playwright already available | [Ekn] |
| 25 | CrewAI | role/goal/backstory multi-agent framework | **MIT; 54.2k stars; Flows = event-driven stateful orchestration** | COMPARE-BASELINE | **the STRESS-1 head-to-head baseline** (operator-named) AND corroboration — its role/goal/backstory shape is already in the crew agent bodies (§14.3, cited at build time) | [E] |
| 26 | MetaGPT | SOP-driven multi-agent software company | MIT | COMPARE-BASELINE | its "SOP encoded as agent roles" is a design comparison for the QA/Lean/Velocity agent vision from the genesis spec | [Ekn] |
| 27 | AutoGen | conversational multi-agent framework | MIT | COMPARE-BASELINE; LEARNING-SHELF | async multi-agent messaging patterns (cookbook #19 covers the Claude-native equivalent) | [Ekn] |
| 28 | Aider | terminal AI pair-programmer | Apache-2.0 | INCORPORATE-PATTERN | its repo-map + edit-format + git-commit-per-change UX is the closest prior art for **Sidekick's execution surface** and confirms the crews' commit-per-step law | [Ekn] |
| 29 | MarkItDown | any-doc → Markdown converter | MIT | INCORPORATE-PATTERN | **Context Fetch** normalizer — the "MarkItDown" step that turns files into model-readable text (Defuddle/S8 is the sibling); pattern only | [Ekn] |
| 30 | Open WebUI | self-hosted LLM chat UI | OSS | PARK | internal-only chat surface option for the Compliance API's per-department view; not a crew input | [Ekn] |
| 31 | Maigret | OSINT username recon | MIT | DISCARD | out of scope; potential Security-agent tool far downstream only | [Ekn] |
| 32 | TradingAgents | multi-agent trading framework | OSS | LEARNING-SHELF | domain-specific multi-agent design reference; not applicable to the IT-automation scope | [Ekn] |
| 33 | Stagehand | AI browser automation (Browserbase) | MIT | CONTEXT-FETCH-CANDIDATE | structured web-action layer for Context Fetch; compare with Browser Use / Playwright | [Ekn] |
| 34 | Firecrawl | web → clean-markdown crawl API | OSS + hosted | CONTEXT-FETCH-CANDIDATE | the strongest **Context Fetch** web-ingestion candidate (clean, structured, schema-extract); pattern/connector, not install | [Ekn] |
| 35 | Hugging Face Transformers | model library | Apache-2.0 | DISCARD (dependency) | HC-7; no non-Claude model runs here | [Ekn] |
| 36 | vLLM | high-throughput LLM serving | Apache-2.0 | DISCARD (dependency) | HC-7; serving infra for non-Claude models | [Ekn] |
| 37 | llama.cpp | CPU/GPU local inference | MIT | DISCARD (dependency) | HC-7 | [Ekn] |
| 38 | LlamaIndex | data framework for RAG/agents | MIT | CONTEXT-FETCH-CANDIDATE | RAG/index patterns for Context Packager (cookbook has native LlamaIndex recipes); pattern only | [Ekn] |
| 39 | nanoGPT | minimal GPT training repo | MIT | LEARNING-SHELF | educational; no build relevance | [Ekn] |
| 40 | RAGFlow | deep-document-understanding RAG engine | Apache-2.0 | CONTEXT-FETCH-CANDIDATE | document-heavy retrieval for the Confluence/audit-evidence workflows; pattern reference | [Ekn] |
| 41 | Supermemory | hosted memory + connectors | **CLOSED-SOURCE; self-host needs an enterprise agreement** | PARK (downgraded) | broad connectors (Drive/Gmail/Notion/GitHub) are attractive for Context Fetch, but closed-source + enterprise-only self-host makes it a connector-list reference, not a buildable pattern | [E] |
| 42 | Awesome Claude Skills | curated Claude skills catalog | list | INCORPORATE-PATTERN | **Psychic-Plugins (SIDE-2)** primary source — the catalog of skill surfaces to mirror natively; verify each entry at SIDE-2 | [Ekn] |
| 43 | Bumblebee | Elixir ML (Nx) library | Apache-2.0 | DISCARD | HC-7; wrong ecosystem | [Ekn] |
| 44 | ComfyUI | node-based image-gen workflow UI | GPL-3.0 | LEARNING-SHELF | its node-graph UX is a distant reference for Sidekick's visual builder; GPL makes any bundling a hard no | [Ekn] |
| 45 | DeepSeek | non-Claude LLM family | model | DISCARD | HC-7 Claude-only | [Ekn] |
| 46 | LobeChat | polished self-host chat UI | MIT | PARK | internal-view UX option for Compliance API; not a crew input | [Ekn] |
| 47 | freeCodeCamp | learning platform/curriculum | BSD | LEARNING-SHELF | reference only | [Ekn] |
| 48 | Coding Interview Resources | interview prep index | list | DISCARD | out of scope | [Ekn] |
| 49 | AI Agents Ecosystem | curated agent-tooling catalog | list | LEARNING-SHELF | meta-catalog; cross-check RSCH-2's own coverage against it | [Ekn] |
| 50 | n8n AI Workflows | n8n's AI-workflow template set | templates | INCORPORATE-PATTERN | concrete escalation/approval workflow templates for the Escalation Router design (pairs with #19) | [Ekn] |

## Category roll-up

- **DISCARD (11):** #7, #12, #17, #18(dep half), #31, #35, #36, #37, #43, #45, #48 — mostly HC-7
  non-Claude runtimes/models and out-of-scope interview prep. HC-5/HC-7 do the filtering the plan said
  they would.
- **LEARNING-SHELF (14):** the awesome-lists and books — real value as reference catalogs (source
  lists for Context Fetch, security reading for the Security-agent), zero build coupling.
- **CONTEXT-FETCH-CANDIDATE (8):** Mem0, Firecrawl, LlamaIndex, RAGFlow, Stagehand, Browser Use,
  MarkItDown/#29, Awesome-Selfhosted — the Context Fetch / Packager shortlist for RSCH-3, every one
  pattern-transformed, none installed.
- **COMPARE-BASELINE (5):** CrewAI (the named STRESS-1 baseline), Dify, Langflow, MetaGPT, AutoGen.
- **INCORPORATE-PATTERN (6):** gitignore-templates (scaffold hygiene), n8n + n8n-AI-workflows
  (Escalation Router), Aider (Sidekick execution UX), MarkItDown (Context Fetch normalizer),
  Awesome-Claude-Skills (Psychic-Plugins).
- **PARK (6):** iFix, OpenClaw, Open WebUI, Supermemory, LobeChat — each with a named revisit
  condition.

## Named-question dives (M4 law: dive only where a verdict names a question)

**Dive 1 — CrewAI, because it is the STRESS-1 baseline [E, 2026-08-26].** MIT, 54.2k stars, Python.
Primitives: Agents (role/goal/tools), Crews (role-divided teams), **Flows** (event-driven stateful
orchestration with explicit triggering/sequencing/state). Adoption claims: >100k certified devs,
1.4B agentic automations/month, "60% of Fortune 500." The STRESS-1 rubric dimensions this sets up:
CrewAI optimizes for *developer velocity and scale* (fast to wire a crew, huge ecosystem); the
psychic-crew thesis optimizes for *control, verification, and evidence* (gated, suite-proven,
ledgered). The comparison is not "which builds faster" — it is **"which produces a verifiable
outcome you could hand an auditor,"** which is exactly TEI's differentiator. STRESS-1 must fix that
rubric before the run (the C-18 rule) so the comparison is not self-scored.

**Dive 2 — n8n for the Escalation Router [E, 2026-08-26].** Sustainable Use License — source-
available, self-hostable free, resale-as-a-service prohibited. The transferable pattern is its
node-graph with **conditional/approval branches**: a workflow routes on a value, pauses for a human
approval node, and resumes — the deterministic policy-routing the feasibility text and cookbook #7
both demand. **Licence consequence, stated:** n8n is NOT OSI-open, so even at pattern level it is
read-for-shape only; nothing n8n is bundled, and the crews' own deny-list already forbids the
install. The Escalation Router is built native (JSON policy + code routing), taking only the *idea*
of visual approval branches.

**Dive 3 — Mem0 vs Supermemory for Context Packager [E, 2026-08-26].** Mem0: Apache-2.0, 52.8k
stars, vector + **graph** memory (`mem0ai[graph]`), LLM fact-extraction from conversations — the
closest prior art for the RSCH-1 graph-lane pilot, and open enough to pattern-transform. Supermemory:
broader connectors (Drive/Gmail/Notion/GitHub) but **closed-source, enterprise-only self-host** —
disqualifying for a pattern port, so it drops to a connector-list reference. **Decision input for
RSCH-3:** the Context Packager pilot should mirror Mem0's fact-extraction-into-graph shape natively
(plain JSON, suite-validated), taking Supermemory only as the *connector wishlist* for what Context
Fetch should eventually reach.

**Dive 4 — Aider for Sidekick's execution UX [Ekn].** Aider's repo-map + strict edit-format +
commit-per-change is the closest existing model for how Sidekick should hand a compiled contract to
a Claude session and get auditable, per-step commits back. It also independently confirms the crews'
commit-per-step law. Sidekick borrows the *interaction shape*, not the code.

**Dive 5 — promptbuilder.cc, the SIDE-0 competitor [E, 2026-08-26].** Feature set: draft → refine-in-
chat → save/pin/version, an Optimizer, a community template library, version timeline with revert,
"shows the assumptions the engine made," <15s generation, team sharing. **This is the audit target
for SIDE-0.** Preliminary read [I]: promptbuilder optimizes for *speed and reuse* of single prompts;
the HIGH-STAKES TASK SPEC template optimizes for *contract completeness under uncertainty*
(unanswered-fields-stay-unknown, hard/soft constraints, priority-on-conflict, evidence labeling,
self-audit). The competitive-advantage claim to test at SIDE-0: our template forces the *request
contract* discipline (what may/may not cross, what is unknown) that a prompt optimizer has no reason
to. Full head-to-head is SIDE-0's acceptance test, not this gate's.

## Confidence and weakest claim

**Core conclusion [E→I]:** the 50-item field reduces cleanly under HC-5/HC-7 — 11 discard on the
no-install/Claude-only law alone; the genuine build inputs are a Context-Fetch shortlist (Mem0/
Firecrawl/LlamaIndex-shaped, native), an Escalation-Router pattern (n8n/#7-shaped, deterministic),
and a Sidekick UX model (Aider/Langflow-shaped). CrewAI is the STRESS-1 baseline with the rubric
axis identified (verifiable-outcome, not velocity). Confidence high for the web-verified rows,
medium for the [Ekn] rows.

**Weakest claim, flagged:** the [Ekn] licence/identity labels on the ~30 unverified rows (e.g.
Dify's partial-OSS status, OpenClaw's identity, ComfyUI's GPL) are training-knowledge and could be
stale; none is load-bearing for a build decision *this gate* (they only steer PARK/LEARNING-SHELF/
DISCARD), but any row promoted to INCORPORATE at a later gate must be web-re-verified first. What
would overturn a verdict: a discarded item turning out to have a Claude-native, install-free surface
(would move it from DISCARD to PARK), or a Context-Fetch candidate proving closed-source like
Supermemory did (would drop it to reference-only).

## Verify

- 50/50 rows present (numbered 1–50). `grep -c '^| [0-9]' docs/research/RSCH-2-ecosystem.md`.
- Web-verified rows (#19, #23, #25, #41) + the five dives carry the 2026-08-26 retrieval date.
- No mermaid fence, no absolute path, no upstream conversation URL.

## EK-1 currency addendum (2026-09-03 — dated appends only; the table above stays frozen per CR-033)

The DIVE-W1-EK-1 sweep (vector program, wave 1) performed the [Ekn] re-verification this
file's own law demands before any promotion. Four rows diverge from reality as recorded:
**#27 AutoGen** is in maintenance mode, folded into Microsoft Agent Framework 1.0 (GA
2026-04) — any comparison built on row 27 should target the successor framework (whose
corpus this estate already dived as CORPUS-AGENTFW); **#30 Open WebUI** is dual-licensed
(BSD-3 through v0.6.5, a custom branding-clause license after); **#46 LobeChat** left MIT
(now LobeHub Community License); **#22 Langflow** is IBM-stewarded with DataStax Astra
hosting shut down (2026-04), MIT intact. Stable-confirmed and presumed-stable rows, with
sources and the survey's stated limits: `docs/research/DIVE-W1-EK-1-survey.md`. The
promotion-time re-verify law above stands unchanged.
