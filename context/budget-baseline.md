# budget-baseline.md — measured dispatch cost (closes C-20)

**verified** — Every number here is measured from completed dispatches in this build, recovered at F8 from the session transcripts and deduplicated across the two project stores (the `hiya-crew` store and its `psychic-crew` copy hold the same runs). No number here is estimated. This file exists because the plan's per-phase token budgets were authored before any multi-agent execution had been measured, and were wrong by roughly an order of magnitude.

## The unit — read this before using any number below

**verified** — These are **subagent context totals** (`totalTokens` per dispatch), not output produced. The same source artifact is counted once per reading agent, so a phase where eight agents each read the same ~27K of source carries that ~27K eight times. This is the correct unit for "what did this phase cost to run", and the wrong unit for "how much work was produced". §10's report template says "token spend est", singular, which reads as a single session's output — a different quantity from the one measured here. Any future budget must state which of the two it means.

**verified** — Orchestrator tokens are not measurable from inside the session and are excluded. Every total below is therefore a lower bound on true phase cost.

## F7 — the only phase that ran the full mandated pipeline

**verified** — 18 dispatches, **2,045,319 tokens**, 3.0 agent-hours of subagent wall time.

|                                 | tokens                                              |
| ------------------------------- | --------------------------------------------------- |
| total                           | 2,045,319                                           |
| cheapest dispatch               | 46,388 (test-runner — mostly shell, little reading) |
| mean dispatch                   | 113,628                                             |
| most expensive                  | 198,302 (integration-runner, 7 end-to-end runs)     |
| §6 budget it was judged against | 207,000                                             |
| **actual ratio**                | **9.88×**                                           |

**verified** — This total corrects the figure carried at G-F7b, which was 1,922,184 across 17 dispatches and was explicitly labelled a lower bound because one dispatch had gone unreported. The missing dispatch is recovered: `arbiter / F7-P1-jml-simulator-plan`, 123,135 tokens. The complete set is 18 of 18, and the ratio moves from 9.3× to 9.88×. The G-F7b verdict is unaffected — Velocity passed as a gate trigger, not against a threshold — but the ledger now carries the complete number rather than the partial one.

## Measured cost per agent role

**verified** — All phases, deduplicated. `n` is small for several roles; treat means with n≤2 as indicative, not settled.

| Role               | n   | mean    | min     | max     |
| ------------------ | --- | ------- | ------- | ------- |
| integration-runner | 1   | 198,302 | 198,302 | 198,302 |
| fixer              | 2   | 169,410 | 167,905 | 170,915 |
| quality-reviewer   | 4   | 130,495 | 79,846  | 156,265 |
| security-reviewer  | 3   | 123,923 | 106,767 | 140,203 |
| arbiter            | 8   | 92,689  | 36,568  | 123,381 |
| lead-executor      | 5   | 88,874  | 58,187  | 118,365 |
| Explore            | 2   | 83,142  | 73,039  | 93,245  |
| general-purpose    | 2   | 75,665  | 61,243  | 90,087  |
| lead-planner       | 2   | 48,935  | 35,550  | 62,320  |
| test-runner        | 1   | 46,388  | 46,388  | 46,388  |

**verified** — All measured dispatches, all phases: **30 dispatches, 3,078,632 tokens, mean 102,621.**

## The baseline a future phase should budget against

**verified — the rule.** A phase's floor is `Σ(role mean × dispatches of that role)`, never a flat per-phase number. Dispatch count is the dominant term, and §5.2.1 rule 6 makes the mandated branch count a floor that may not be merged down to save budget. Budget the pipeline the phase actually mandates, then add margin — do not pick a round number first.

**verified — the working constant.** ~**115K per dispatch** for a review-heavy phase; ~90K for a build-heavy phase dominated by lead-executor and arbiter hops.

**verified — worked example, F7 as specified.** 18 mandated dispatches × 46,388 (the cheapest dispatch anyone actually achieved) = **834,984**. That is the theoretical floor for the pipeline §6 mandates, and it is still **4.03×** the 207,000 the same section budgeted. This is what "unsatisfiable by construction" means: no execution, however disciplined, could have passed that axis.

## Scale of the original error

**verified** — The plan budgets **319K for the entire nine-phase build**. Measured subagent spend across the phases that ran is 3,078,632 — **9.65×** the whole-build budget, in subagent context alone, excluding all orchestrator tokens. The defect is not F7-specific; every phase budget in §6 was authored on the same uncalibrated basis.

## What this file does not establish

**verified** — n is 1 for `integration-runner` and `test-runner`, so their means are single observations.

**verified** — Cost is driven by how much source an agent reads, which §15.2 reference-passing already minimises. A phase that reads a larger codebase will exceed these numbers regardless of dispatch count; these are calibration points, not caps.

**verified** — Per-dispatch cost was never written to the repo during F7. It was recovered at F8 from session transcripts outside the repo, which is an HC-8 gap in its own right — see **C-21**. Future phases must persist the measurement when it is taken.
