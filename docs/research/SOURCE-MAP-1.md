# SOURCE-MAP-1 — the rabbit holes (wave 1)

**Purpose.** The queue's research demand, made into named sources: every `research-dive` and
`web-verify` vector from `docs/research/VECTOR-QUEUE.md` is covered by at least one row below,
each row carrying its pre-named question (M4 satisfied AT BIRTH — drop-request questions exist
before their corpora arrive), its register demand link, and a falsifiable yield prediction. The
suite binds all of it both directions (section I).

**Lane laws.**
- `web` — read-only, dated fetches, scrubbed survey persistence (FENCE-2/CR-033); the
  estate-only communications ruling as scoped at PROGRAM-OPEN: git/API contribution stays
  barred, read-only research fetches are the sanctioned lane. Any row later promoted to
  INCORPORATE is web-re-verified first (RSCH-2:145).
- `corpus-redive` — on-disk gitignored corpora only (sources are census NAMES; the ⊆-census
  arm holds); a re-dive reads ONLY against its named question.
- `drop-request` — the operator's shopping list. REQUIRED directory name is the `source`
  column verbatim (`<name>-main/` — the .gitignore glob; an off-pattern drop lands
  untracked-and-unignored in a PUBLIC repo and the no-unignored-root arm reds). **Census
  interaction, the risk-2 decision taken and why:** the census/coverage records stay
  UNTOUCHED today — GAP-REGISTER-1's own tier-arithmetic arm binds the CORPUS-0 roll-up
  line, and extending the census vocabulary for zero on-disk drops would rebuild that arm
  speculatively. Instead, ARRIVAL is the classified event: when a drop lands, its dive gate
  (or an arrival disclosure) adds the census row + coverage row (+ question row) in the same
  change — four coordinated edits, and any suite window between arrival and classification
  is that drop's DECLARED STRADDLE. The coverage discharge allowlist gains the
  `DIVE-W1-*` grammar NOW so those future rows have a legal discharge to name.
- The PROHIBITED name appears in no row, arm-asserted.

**Census-vocabulary mapping (two records, two meanings, stated):** this map's
`QUEUED`/`DIVED` are WAVE states (queued-for-dive / dive-complete); the CORPUS-0 census's
`QUEUED`/`DIVED` are ARC-2 record states. Neither redefines the other; lane-b sources
reference census rows by name only.

**Status vocabulary:** `QUEUED · DIVED · REQUESTED · ABORTED · UNFILLED-AT-DRY · PARKED-DRY ·
DECLINED` (ABORTED = a dive opened and could not complete; recorded, excluded from the dry
tail).

**Calibration, falsifiable by declaration (fixed BEFORE any prediction is scored):**
TAKE-class ≜ {TAKE-PATTERN, MODULATE-OURS}; TAKE-ZERO ≜ 0 · TAKE-FEW ≜ 1-2 · TAKE-MANY ≜ >=3
TAKE-class verdicts. Predictions are the `expected_yield` column below, locked at this gate;
outcomes land in the `outcome` column at each dive; SYNTH-1 computes the roll-up — the
estate's first measured confidence-vs-outcome record.

**The dry criterion (frozen here, over EXECUTION order):** DRY ≜ the last two dives PERFORMED
(outcome-append order; the ledger dates every flip) both scored outcome 0, with a minimum of
2 completed dives; ABORTED dives excluded from the tail; mid-wave source appends land AFTER
the current tail and are disclosed in the appending gate's ledger entry. Map order below is
the default execution order; a deviation is legal but disclosed. Dry is a state, not a wall —
the DIVE-W1-DRY token is the operator's override in both directions.

**The per-dive contract** (every `docs/research/DIVE-W1-<ID>.md` instantiates; the generic
validator in section I enforces the mechanical parts): read ONLY against the named question ·
open with the READ MANIFEST (exact files/URLs read, measured counts, sidecar exclusion,
denominator-defined) · answer · fenced `# DIVE-<ID>-VERDICTS v1` (5 fields: n ·
mechanism-slug · verdict · register_link · evidence) · roll-up prose agreeing with the fence ·
landing-shape table for every TAKE-class row (mechanism → landing shape → future-gate →
register rows closed) · register delta (flips + new rows, evidence-cited) · `## Weakest
claims` · evidence-census line. Same gate, one commit: register flips + queue re-derivation +
map-row flip + outcome — atomic, never a red window. Transfers: med-class doc-only; every
mechanism-shaped finding becomes a landing shape for SYNTH-1. Web dives may persist a FENCE-2
survey. Drop dives verify the drop landed as named, perform the census arrival edits, and
re-state identity from the drop's own LICENSE.

**Dive tokens** (grammar pre-declared at PROGRAM-OPEN; each row's exact token is fixed by its
id): `APPROVE DIVE-W1-<id>` — e.g. `APPROVE DIVE-W1-OR-1`.

## The map

```text
# SOURCE-MAP v1
OR-1	corpus-redive	orca	What does orca reliability-gate VALIDATOR reject that our registry accepts - and what do its lockfile-declared transitive dependencies reveal that the survey could not?	GR-066,GR-077	TAKE-MANY	L	DIVED	3	DIVE-W1-OR-1
RU-1	corpus-redive	ruflo	What exactly would a parent-side temporal-bisect layer need from ruflo verification history design - and what does their implementation get wrong that ours must not?	GR-042	TAKE-FEW	M	DIVED	2	DIVE-W1-RU-1
GA-1	corpus-redive	gastown	What is the minimal liveness/stall vocabulary this estate could adopt from gastown three-store design without adopting propulsion - and does NDI deserve a name here?	GR-041,GR-086	TAKE-FEW	M	DIVED	2	DIVE-W1-GA-1
EK-1	web	rsch2-ekn-sweep	Which of the roughly thirty Ekn-flagged ecosystem rows and six PARK revisit conditions have materially changed since 2026-08-26 - dated re-verification, promotion-eligibility only?	GR-058,GR-078,GR-113	TAKE-ZERO	M	DIVED	0	DIVE-W1-EK-1
AT-1	web	agent-teams-flag	Does the agent-teams environment flag exist in current Claude Code documentation, and does its semantics touch the EX-05 dispatch law?	GR-085	TAKE-ZERO	S	DIVED	0	DIVE-W1-AT-1
HC-1	web	platform-currency	Have the platform facts this estate depends on drifted: hook-event set, PreCompact/PostCompact semantics (WORKAROUND-01 removal condition), model fallback behavior, the 1M-context variant (OQ-2), Team-plan content-endpoint coverage (SIDE-5)?	GR-062,GR-080,GR-093,GR-095	TAKE-FEW	M	QUEUED	-	-
OU-1	web	orca-upstream	Has orca upstream reliability-gate manifest changed since 2026-08-31, and does any public record resolve the stablyai-vs-Lovecast licence anomaly?	GR-076,GR-077	TAKE-ZERO	S	QUEUED	-	-
DR-DIFY	drop-request	dify-main	How does Dify gate human approval inside automated flows, and which of the 16 BASE-2 cells does its on-disk reality move?	GR-068	TAKE-FEW	M	REQUESTED	-	-
DR-LANGFLOW	drop-request	langflow-main	What does Langflow flow-versioning actually persist per change, against our ledger discipline (BASE-2 cells)?	GR-068	TAKE-ZERO	M	REQUESTED	-	-
DR-METAGPT	drop-request	metagpt-main	What does MetaGPT SOP-encoded role contract enforce mechanically that our agent contracts state in prose (BASE-2 cells)?	GR-068	TAKE-FEW	M	REQUESTED	-	-
DR-AUTOGEN	drop-request	autogen-main	Which AutoGen conversation-termination semantics are mechanical vs convention, against our gate machine (BASE-2 cells)?	GR-068	TAKE-FEW	M	REQUESTED	-	-
DR-MEM0	drop-request	mem0-main	Does Mem0 memory-scoping model carry a pattern for the Context Packager candidate the RSCH-2 shelf holds?	GR-058	TAKE-FEW	M	REQUESTED	-	-
DR-CREWAI	drop-request	crewai-main	Run-sourced at last: which STRESS-1 rubric column entries survive contact with CrewAI actual code (HC-5 kept the survey documentation-only)?	GR-068,GR-081	TAKE-FEW	M	REQUESTED	-	-
DR-AIDER	drop-request	aider-main	What does Aider commit-per-step discipline attest per change, and does its repo-map maintenance answer the temporal-bisect gap?	GR-042	TAKE-FEW	M	REQUESTED	-	-
DR-N8N	drop-request	n8n-main	SOURCE-AVAILABLE (not OSI) - pattern-transform only, no verbatim: does its workflow-credential separation carry a lesson for the pack lane?	GR-068	TAKE-ZERO	M	REQUESTED	-	-
CG-1	web	cogno-studio	What is cogno.studio (identity from its own pages, dated), and does anything observable there - product surface, published docs, stated patterns - VALIDATE-AGAINST or challenge this estate's designs, with TAKE candidates only where license permits?	GR-068,GR-113	TAKE-ZERO	S	DIVED	0	DIVE-W1-CG-1
```

## Weakest claims, flagged

[I] The yield predictions are one author's calls, recorded to be scored — their value is the
calibration they enable, not their accuracy. [I] The demand links assign each routed row to
the source likeliest to move it; a wrong assignment surfaces as a dive that answers its
question yet moves nothing — visible in the register delta, not hidden. [E-limits] The
drop-request lane depends wholly on operator action; drops never block the wave, and
UNFILLED-AT-DRY is the honest terminal record.
