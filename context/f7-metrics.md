# f7-metrics.md — the §7 rubric roll-up, tracked

**verified** — This is the durable mirror of `logs/metrics/f7.json`. The JSON is the machine artifact and stays authoritative for tooling, but `logs/` is gitignored, so F7's exit evidence would not survive a clone. This file is what a reader who only has the repo can audit. Denominators were fixed **before** execution at G-F7a (C-18) so Velocity could not be self-scored.

Generated from the roll-up dated 2026-08-13T23:37:06Z; the Velocity ruling was recorded 2026-08-14.

## Denominators, fixed pre-run

**verified** — tokens **207,000** (F7's §6 budget plus the operator-accepted 7K overrun, superseding Q5's generic 150K) · wall **45 min per session** · both set by operator decision at G-F7a and recorded before any F7 execution.

## §7 rubric — 7 of 7

| Axis                             | Observed                                                         | Verdict               |
| -------------------------------- | ---------------------------------------------------------------- | --------------------- |
| tests ≥ 15, 100% green           | 18 cases, 18 pass, 0 fail                                        | **PASS**              |
| seeded-bug catch 3/3             | 3/3 — two invisible to all 18 tests, found only by reading       | **PASS**              |
| edge cases 3/3                   | 3/3 exact                                                        | **PASS**              |
| agent coverage 8/8               | 8/8, each bound to a named artifact, not a grep count            | **PASS**              |
| token spend ≤ Q5 ceiling         | **1,922,184** subagent tokens vs 207,000 — **9.3× over**         | **PASS (by trigger)** |
| post-review defects 0            | 0 after the pipeline closed; 1 residual at `low`, arbiter-logged | **PASS**              |
| arbiter audit lines ≥ dispatches | 19 lines vs 18 dispatches                                        | **PASS (literal)**    |

**§6 axes:** Depth PASS · Breadth PASS · Robustness PASS · Velocity PASS (by trigger).

## The two verdicts that carry a caveat

**verified — token spend, PASS by trigger, not by measurement.** Q5 reads "hard ceiling per phase **before mandatory early gate**" — a gate _trigger_, not a pass/fail bar. The operator applied exactly that reading to the wall-clock limb at G-F7a; §7 had converted the same ceiling into a threshold for the token limb only. Option A (operator ruling, 2026-08-14) applies the reading consistently. Velocity passes because the mechanism fired: F7 gated at the G-F7a mid-gate, at the HC-2 model hold, at the Stage A/B split, and across ten checkpoints.

**The measurement is not waived.** 1,922,184 stands as the recorded figure, and it is a **strict lower bound** — it excludes one unreported dispatch and all orchestrator tokens. Passing by trigger asserts nothing about efficiency, because per **C-20** the axis was unsatisfiable by construction: §6 mandates 18 dispatches, and 18 × the cheapest dispatch actually observed (46,388) is 834,984 — still **4.0× the denominator in the best conceivable case**. C-20 stays PENDING and F8-owned.

**verified — arbiter coverage, PASS on the literal reading.** 19 ≥ 18 counts every arbiter line. The F7-scoped reading is 10 vs 18; the five uncovered ids are lead-executor build hops, which §5.2.2 does not require coverage for, and `validate-crew.sh` scopes to specialist hops and reports PASS. Both readings are stated because only one of them is flattering.

## Agent coverage — 8/8, artifact-bound

| Agent              | Named artifact                         |
| ------------------ | -------------------------------------- |
| lead-planner       | `context/f7-plan.md`                   |
| lead-executor      | `stress-project/` A2–A6, 22 files      |
| arbiter            | 19 audit lines, 2 discourse compiles   |
| security-reviewer  | round-1 4 findings, round-2 9 entries  |
| quality-reviewer   | round-1 7 findings, round-2 6 entries  |
| fixer              | 11 verdicts, all ACCEPT, all applied   |
| test-runner        | B8 observed suite evidence             |
| integration-runner | B9, 7 runs, `stress-project/tmp/b9-*/` |

## Findings and discourse

**verified** — 11 raised · 11 ACCEPT · 0 REJECT · 0 DEFER · **0 open P0 at the gate**. Two rounds of §5.4 discourse; round-2 verbs AGREE 7 · CHALLENGE 1 · CONNECT 5 · SURFACE 2, with 0 undefended challenges dropped.

## Stated limits — what this roll-up does NOT establish

**verified** — Orchestrator token spend is not measurable from inside the session, so the token figure is a lower bound, not a total.

**verified** — The arbiter holds no `Bash`, so it witnessed no run. B8 and B9 numbers are agent-captured, not arbiter-observed.

**verified** — `REPLAYED` appears in zero B9 artifacts. The parked-replay path is green at B8 (`ok 14`) but was never demonstrated live, so no live replay is claimed.

## Open corrections carried out of F7

**verified** — **C-19 (F8)** — a retrospective arbiter line satisfies C-12 identically to a contemporaneous one; green proves an id exists, not that it preceded consumption.

**verified** — **C-20 (F8)** — phase token budgets were never calibrated to multi-agent cost. The whole nine-phase build is budgeted 319K; F7's subagents alone measured 1,922K. Closes when `context/budget-baseline.md` records measured per-dispatch cost.
