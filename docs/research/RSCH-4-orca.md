# RSCH-4 — the orca surgical decision matrix

**Status:** binding record (RSCH-2/3 pattern). Inputs: the fenced corpus `orca-main/` (census
`DIVED`), the scrubbed survey `docs/research/RSCH-4-orca-survey.md` (FENCE-2, granular inventory +
dated 2026-08-31 fetches), and spot re-reads at this gate. Identity re-stated from the LICENSE
file, not memory: **MIT, copyright "Lovecast Inc."** (org `stablyai` ≠ holder — anomaly recorded,
unresolved; no local file explains it). Upstream: 57.8k stars, active same-day; Stably is a
YC-backed AI end-to-end-testing company and orca is its adjacent open-source **agent-orchestration
ADE** — not an LLM client (agents run as PTY subprocesses in worktrees). ~3.6M LOC TS/TSX of which
the survey read <0.1% — verdicts below cite the specific files actually read.

**Law:** HC-5 forever bars installing or importing its runtime — every verdict is about PATTERNS.
MIT permits pattern-incorporation freely; substantial verbatim copying would trigger the
notice-preservation obligation and is flagged per-row where plausible. Dispositions EXECUTE only
under their own future gates; this record decides direction, not work.

## The matrix (machine-readable; the suite binds counts and verdict legality)

```text
# ORCA-MATRIX v1
1	reliability-gate-manifest	TAKE-PATTERN
2	three-value-verdict-vocabulary	TAKE-PATTERN
3	dispatch-preamble-contract	TAKE-PATTERN
4	decision-gates-reblocked-every-tick	TAKE-PATTERN
5	escalation-provenance-fencing	TAKE-PATTERN
6	refuse-before-allocate	TAKE-PATTERN
7	shrink-only-ratchet-baselines	TAKE-PATTERN
8	discovery-stub-anti-drift	TAKE-PATTERN
9	idempotency-receipts-generation-fencing	MODULATE-OURS
10	telemetry-ordering-schema-registry	VALIDATE-AGAINST
11	browser-automation-boundary	VALIDATE-AGAINST
12	cli-vocabulary-policy	MODULATE-OURS
```

Roll-up: **8 TAKE-PATTERN · 2 MODULATE-OURS · 2 VALIDATE-AGAINST · 0 REJECT-of-candidates** (the
wholesale REJECT list — the SQLite runtime, Electron shell, mobile/native trees, SSH federation —
is not candidate-shaped and is recorded in §3).

## 1. The eight TAKEs, each with its landing shape

| #   | Pattern (evidence path in the corpus)                                                                                                                                                                                                                                                                      | Why it fits                                                                                                                                          | Landing shape (future gate)                                                                                                                                                                              |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Reliability-gate manifest + validator (`config/reliability-gates.jsonc`, 99 gates; `check-reliability-gates.mjs`) — per-behavior invariant/oracle/commands/named-assertions/red-green evidence, maturity ladder w/ promotion policy, validator rejecting brittle selectors and commandless "active" claims | the missing registry layer between "we have suites" and "a claim is provably covered"; their all-`experimental` honesty mirrors our evidence classes | a `RELIABILITY-REGISTRY v1` over the parent's 217 assertions: each named behavior → invariant, oracle, the assertion(s) proving it, maturity; validator in the suite. Largest single TAKE — its own gate |
| 2   | Three-value verdict vocabulary (`docs/reference/ssh-execution-boundary.md`) — `live`/`unverifiable`/`exited`, collapse forbidden; "no asserting what you cannot observe"; check durable state, not return codes                                                                                            | already our doctrine in prose (C-12, the STRESS-1 §C honesty rows); theirs is the mechanized form                                                    | adopt the vocabulary in the arbiter FINDINGS/verdict schema; forbid the collapse in arbiter-protocol.md                                                                                                  |
| 3   | Dispatch preamble contract (`src/main/runtime/orchestration/preamble.ts`, snapshot-tested) — worker_done exactly once w/ mandated 3-sentence body; heartbeats; rules land beside examples ("LLM readers anchor on examples and skim trailing prose"); depth-capped sections OMITTED not softened           | direct upgrades to the DISPATCH block law and §14.3 expected_output                                                                                  | fold the three authoring rules into arbiter-protocol.md's DISPATCH section; snapshot-test the packet shape                                                                                               |
| 4   | Decision gates re-blocked EVERY TICK (`coordinator-decision-gates.ts`) + resolution replayed into the next prompt; never auto-resolved                                                                                                                                                                     | "gate state is re-asserted, not merely set" is stronger than our one-shot STOP flags                                                                 | a re-assertion arm in the gate machinery: any awaiting row implies refusal-state re-checked per run (gate-guard already refuses; add the drift re-check)                                                 |
| 5   | Escalation provenance fencing + circuit breaker (`coordinator-escalation-triage.ts`) — a status message must prove (task, dispatch, sender) ownership through three independent checks before it can move state; 3 failures → circuit_broken                                                               | exactly the property a broker with 8 agents needs; our C-05/C-25 attribution is at creation, not at state-moves                                      | arbiter releases gain the three-check ownership rule; a per-dispatch failure budget in the DISPATCH schema                                                                                               |
| 6   | Refuse-before-allocate (`coordinator-task-dispatch.ts`) — precondition checks run BEFORE the dispatch row exists so refusal is free; a third outcome `dispatched-unobserved`; warn-never-autofail staleness w/ the tradeoff written down                                                                   | our FALLBACK blocks already refuse pre-work; the free-refusal ordering and the third outcome are the upgrades                                        | order the arbiter's precondition checks before any ledger row; add the unobserved outcome to the dispatch lifecycle                                                                                      |
| 7   | Shrink-only ratchet baselines (`check-max-lines-ratchet.mjs`; an EMPTY baseline enforcing "boots on plain Node")                                                                                                                                                                                           | empty-baseline-as-architecture-constraint mechanically enforces the zero-dependency doctrine itself                                                  | a dependency ratchet: baseline of allowed runtime deps = EMPTY, forever; file-size ratchet optional later                                                                                                |
| 8   | Discovery-stub anti-drift (`skill-stubs/` + `generate-bundled-skill-guides.mjs --check`) — the installed skill file deliberately carries NO commands; the live guide is served version-matched by the binary; renames go to an append-only alias ledger                                                    | mechanizes current-docs-never-memory, our standing law                                                                                               | ROUTE-1 applies the stub shape to the estate's skill surface where drift risk is real                                                                                                                    |

## 2. The four non-TAKEs, with reasons

**9 · idempotency receipts + generation fencing → MODULATE-OURS** — the concept
(`(caller_fingerprint, request_id, payload_hash)` receipts; at-most-one-outstanding via a partial
unique index; superseded consumers fenced not dropped) transfers to the arbiter's ledger semantics;
the SQLite implementation does not (HC-5, and our substrate is append-only JSONL). Adapt, not adopt.

**10 · telemetry ordering + schema registry → VALIDATE-AGAINST** — `posthog-node` is a network
dependency we can never take and we have no privacy surface; but the ordering-with-stated-reason
(shutdown → cap → consent → validate → capture), the event→schema registry, and the dual fail-closed
transmit gate are a measuring stick for our metrics layer at its next gate.

**11 · browser-automation boundary → VALIDATE-AGAINST** — 439 files of Electron/CDP plumbing is not
extractable; the one-line law ("CDP for your own app; computer-use only for foreign UI") and the
command-result cache + command-authority fencing are the checklist to hold psychic-sidekick's
cached-Playwright design against.

**12 · CLI vocabulary policy → MODULATE-OURS** — "agent-facing verbs are a typed, tested policy,
not a convention" is right; their registry-parity machinery is oversized for our surface. Fold a
verb-policy check into the existing suite when the skill surface is curated (ROUTE-1).

## 3. Wholesale REJECTs (not candidates — recorded so nobody re-derives them)

The orchestration SQLite runtime (28k LOC, schema v30 — read the schema as a state-model reference,
reject the implementation) · the Electron shell/renderer (~17.7k files) · `mobile/` and `native/`
computer-use binaries (compilation, out of mission) · the SSH federation layer (psychic-crew is
single-host by design).

## 4. Weakest claims, flagged

`[I]` The eight landing shapes assume the patterns survive contact with our zero-dependency,
bash-native substrate — #1 and #5 are the likeliest to shrink in translation, and each lands behind
its own gate where that gets tested. `[I]` The survey's currency estimate (~15 releases behind) has
an unquantified error bar (no `.git` anchor in the corpus); none of the twelve verdicts depends on
being current. `[E-limits]` <0.1% of the corpus was read; the candidates were selected by
architecture-first navigation, and a thirteenth candidate could exist unread — the census row stays
`DIVED`, and a named question reopens it.
