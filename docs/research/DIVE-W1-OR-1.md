# DIVE-W1-OR-1 — orca, under the wave's first question

**Gate:** DIVE-W1-OR-1 (vector program, wave 1, dive 1). **Source:** `orca-main/` (census `DIVED`,
re-opened by this named question per its own record's re-opening clause). **Question (fixed at
SOURCE-MAP-1, before this reading):** what does orca's reliability-gate VALIDATOR reject that
our registry accepts — and what do its lockfile-declared transitive dependencies reveal that
the survey could not? **Prediction on record:** TAKE-MANY.

## Read manifest (measured; sidecar exclusion applies; nothing else was opened)

| artifact | lines | how read |
|---|---|---|
| `config/scripts/check-reliability-gates.mjs` | 431 | FULL, line by line |
| `config/reliability-gates.jsonc` | 17,172 | parsed WHOLE as data (jsonc → distributions); prose fields not line-read |
| `pnpm-lock.yaml` | 13,798 | parsed whole; 769 unique packages censused by category pattern |
| `src/` (node:sqlite probe) | 5 grep hits | targeted: 3 filenames + 2 import lines, question-scoped |
| `config/scripts/check-reliability-gates.test.mjs` | 460 | NOT read (validator behavior taken from source; stated) |

## The answer

**The manifest, measured (replacing the survey's aggregate-only knowledge):** 99 gates,
schemaVersion 1, ALL 99 `experimental` (their all-experimental honesty is now parsed fact, not
a regex count), protection 88 `partial` + 11 `none`, **369 dated evidence runs across 88
gates**, **396 per-gate knownGaps entries**, **99/99 demotion rules**, promotion policy as
data: 100 soak runs · 14 soak days · 0 unexplained flakes.

**What their validator rejects that our registry accepts:**

1. **Missing evidence-run ledgers.** Every `partial`/`active` gate must carry dated runs
   `{date, runner(local|ci|soak|manual), platform, result, command, durationSeconds,
   summary}`, each run's command ∈ the gate's declared commands, and `coveredPlatforms` must
   include every platform a passed run claims. OUR registry records no dated proof-of-run
   anywhere: when a control last proved itself, and on what userland, rides session memory —
   exactly the hole the operator-BSD-cert row and the temporal gap already name from other
   directions.
2. **Missing demotion rules.** 99/99 of their gates state when they get demoted. Ours
   demotes MECHANICALLY (maturity is re-derived from the control-fires span every run — a
   rotted control auto-demotes), but that semantics is nowhere STATED as policy.
3. **Commandless claims.** A gate without a runnable command must declare `protection: none`
   — a claim that cannot be exercised may not claim protection. Our registry rows carry
   file:needle bindings but no per-row runnable probe; the whole-suite run is the only
   oracle. Parity-adjacent, weaker at row granularity.
4. **Brittle title selectors** (`-t`/`--grep`/`--testNamePattern`) are refused outright.
   Ours BINDS by needle and DETECTS breakage same-run (forward arm) — prevention vs
   detection, two defensible philosophies, recorded not adopted.
5. Referential integrity between claim layers (runs↔commands, assertionRefs↔testFiles,
   coveredPlatforms⊆platforms) — we hold the register↔section layer both ways; the run layer
   does not exist here (see 1).

**What the lockfile reveals (769 unique packages):** **zero LLM/AI SDKs** — the survey's
stated third-weakest claim ("no LLM inference calls", endpoint-greps only) gains an
independent dependency-layer corroboration; **exactly one telemetry package** (posthog-node —
RSCH-4 row 10's VALIDATE-AGAINST reasoning measured); electron ×10 and playwright ×4 (the
wholesale-REJECT surfaces, confirmed); and **zero sqlite packages** — the SQLite runtime the
REJECT list names is the `node:sqlite` BUILTIN (`DatabaseSync`, confirmed in src imports):
invisible to any lockfile, so the survey's attribution survives REFINED, not overturned.

## Verdicts

```text
# DIVE-OR-1-VERDICTS v1
1	evidence-run-ledger-dated-platform-attestation	TAKE-PATTERN	GR-135	config/scripts/check-reliability-gates.mjs:181-215 + 369 live runs
2	demotion-semantics-stated-as-policy	MODULATE-OURS	GR-047	validator demotionRule required 99/99; ours auto-demotes unstated
3	runnable-probe-column-per-row	MODULATE-OURS	GR-047	commandless-gates-declare-none rule; our rows carry needle not command
4	brittle-selector-prohibition-vs-needle-detection	VALIDATE-AGAINST	GR-030	commandUsesBrittleTestSelector regex vs our forward-arm philosophy
5	per-gate-knowngaps-vs-central-register	VALIDATE-AGAINST	GR-066	396 localized entries vs GAP-REGISTER centralization
6	no-llm-sdk-dependency-corroboration	VALIDATE-AGAINST	GR-077	769 packages, zero model clients
7	node-sqlite-builtin-survey-refinement	VALIDATE-AGAINST	GR-077	DatabaseSync from node:sqlite in src; zero lockfile trace
```

Roll-up: **1 TAKE-PATTERN · 2 MODULATE-OURS · 4 VALIDATE-AGAINST · 0 REJECT** — measured
outcome **3 TAKE-class** (= TAKE-MANY at the ratified boundary; the prediction held).

## Landing shapes

| mechanism | landing shape | future gate | register rows closed |
|---|---|---|---|
| evidence-run ledger | a dated suite-run ATTESTATION record (date · platform · userland · HEAD · measured totals), appended per green run to a tracked summary + runtime trail pair; registry rows, PORTABILITY, and the operator BSD cert all consume it — soak-style promotion semantics become possible later | SUITE-ATTEST-1 (successor program) | GR-135 |
| demotion semantics stated | one dated policy paragraph in RELIABILITY-REGISTRY's header naming the mechanical auto-demotion (span-derived, every run) | rides SUITE-ATTEST-1 or the next registry gate | GR-047 (partial) |
| runnable-probe column | registry v2 gains a per-row probe-command column WHEN a section splits (bound to the EXISTING v2 named wake — no new wake invented) | the v2 split gate, whenever its wake fires | GR-047 (partial) |

## Register delta

- GR-077 → **RESOLVED:DIVE-W1-OR-1** (flip logged): the lockfile is read (769 packages censused),
  the 99-gate manifest is parsed whole, the validator is read line-complete. The honest
  residue moves to a NEW narrower row (GR-134): the ~3.6M-LOC application source
  remains <1% read and the thirteenth-candidate clause stands.
- NEW GR-134 (open-question · unread-source · OPEN): orca application source <1%
  read; a thirteenth pattern-candidate could exist unread. Born of this dive's honesty, and
  mid-wave-born demand: it awaits a future source or parks at DRY (section I now NOTEs
  exactly this state instead of failing it — see the arms note below).
- NEW GR-135 (verification-gap · unverified-claim · no · OPEN): no dated suite-run
  attestation exists — when a control last proved itself, and on what platform/userland, is
  unrecorded; the BSD certification and every temporal claim ride session memory. Routed
  build-gate P1 by V-UNVER-NONE; SUITE-ATTEST-1 is its named landing.

**Arms evolution forced by this first live dive (measurement-machinery maintenance, in the
research gate's charter):** section I's link-resolution arm now resolves against ALL register
ids (a served link legitimately points at the row it RESOLVED — demanding links stay OPEN
forever would forbid success), and the demand-coverage arm now splits by the vector's `born`
field: map-era demand unclaimed = FAIL as before; demand born mid-wave by a dive = NOTE, the
honest new-work signal SYNTH-1 will consume.

## Weakest claims, flagged

`[I]` The validator's behavior is taken from its source alone; its 460-line test file went
unread — a behavior its tests reveal and its source hides would be missed. `[E-limits]` The
lockfile census is pattern-based over 769 names; a category outside the six patterns searched
is uncounted. `[I]` "Zero LLM SDKs" corroborates but does not prove the no-inference claim —
a raw fetch to a model endpoint needs no SDK; the survey's endpoint-grep evidence and this
dependency evidence are two layers, not proof.

Evidence census: [E] 14 · [I] 3 · [S] 0 · [V?] 0
