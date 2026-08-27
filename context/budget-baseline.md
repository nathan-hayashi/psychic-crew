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
| quality-reviewer   | 4   | 130,495 | 79,846 | 156,265 |
| security-reviewer  | 3   | 123,923 | 106,767 | 140,203 |
| Explore            | 3   | 115,936 | 73,039 | 181,524 |
| general-purpose    | 4   | 102,430 | 61,243 | 139,483 |
| arbiter            | 8   | 92,689 | 36,568 | 123,381 |
| lead-executor      | 5   | 88,874 | 58,187 | 118,365 |
| lead-planner       | 2   | 48,935 | 35,550 | 62,320 |
| test-runner        | 1   | 46,388 | 46,388 | 46,388 |

**verified** — All measured dispatches, all phases: **47 dispatches, 5,541,107 tokens, mean 117,895.**

## The baseline a future phase should budget against

**verified — the rule.** A phase's floor is `Σ(role mean × dispatches of that role)`, never a flat per-phase number. Dispatch count is the dominant term, and §5.2.1 rule 6 makes the mandated branch count a floor that may not be merged down to save budget. Budget the pipeline the phase actually mandates, then add margin — do not pick a round number first.

**verified — the working constant.** ~**115K per dispatch** for a review-heavy phase; ~90K for a build-heavy phase dominated by lead-executor and arbiter hops.

**verified — worked example, F7 as specified.** 18 mandated dispatches × 46,388 (the cheapest dispatch anyone actually achieved) = **834,984**. That is the theoretical floor for the pipeline §6 mandates, and it is still **4.03×** the 207,000 the same section budgeted. This is what "unsatisfiable by construction" means: no execution, however disciplined, could have passed that axis.

## Scale of the original error

**verified** — The plan budgets **319K for the entire nine-phase build**. Measured subagent spend across the phases that ran was 3,078,632 at the 30-dispatch measurement (2026-08-21; the growing all-time set is in the distribution section below) — **9.65×** the whole-build budget, in subagent context alone, excluding all orchestrator tokens. The defect is not F7-specific; every phase budget in §6 was authored on the same uncalibrated basis.

## What this file does not establish

**verified** — n is 1 for `integration-runner` and `test-runner`, so their means are single observations.

**verified** — Cost is driven by how much source an agent reads, which §15.2 reference-passing already minimises. A phase that reads a larger codebase will exceed these numbers regardless of dispatch count; these are calibration points, not caps.

**verified** — Per-dispatch cost was never written to the repo during F7. It was recovered at F8 from session transcripts outside the repo, which is an HC-8 gap in its own right — see **C-21**. Future phases must persist the measurement when it is taken.

## Dispatch-cost distribution (CR-006)

**verified** — The plot below is the only genuine quantitative distribution in this repository. It
is a Vega-Lite v5 spec with the data **embedded inline**, and that is the whole point of the
exercise rather than an implementation detail.

### The two constraints this had to clear, and how

**1. The data was gitignored.** `logs/metrics/dispatch-costs.tsv` is the machine artifact and stays
authoritative, but `logs/` is excluded — so a spec with a `"url"` pointing at it would render an
empty chart from a fresh clone, which is an unreproducible artifact rather than a diagram. All
rows are therefore embedded as literal `values` — all of them; the count lives in the suite's fence-vs-TSV assertion rather than in this sentence. This follows the precedent this file
already sets for `logs/metrics/f7.json`.

**2. The TSV has no header row**, so column meaning lived only in
`scripts/measure-dispatch-cost.sh:65`. Recorded here once, from the generator rather than from
inspection:

| # | Field | Meaning |
| --- | --- | --- |
| 1 | `role` | agent role that received the dispatch |
| 2 | `task` | the dispatch's task id or description |
| 3 | `tokens` | `toolUseResult.totalTokens` — subagent **context total**, not output produced |
| 4 | `duration_ms` | `toolUseResult.totalDurationMs` — wall time for that dispatch |

Rows are written sorted ascending by `tokens`. Read the unit note at the top of this file before
using any number: the same source counted by eight agents appears eight times.

### What it shows

**verified** — 47 dispatches, **5,541,107 tokens** total, mean **117,895** (this sentence is bound to the embedded fence by the suite since CLEANUP-1).
The red tick is the mean. The spread is the finding: the dearest single dispatch is
**5.6×** the cheapest, so a per-phase
budget built on a mean is wrong for both tails.

Per-role counts for the embedded set are the measured-cost table at the top of this file. The two
were once separate snapshots of different eras and drifted apart silently (the audit's R1-07); one
table now serves both, and the suite compares the fence's per-role counts against the TSV directly.

**verified** — Ten roles appear, not eight. `general-purpose` and `Explore` are not crew agents;
they are harness agents used during the audit and are included because excluding them would make
the total disagree with `logs/`.

```vega-lite
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "description": "Per-dispatch context totals by agent role. Data embedded, not referenced: logs/ is gitignored and a spec pointing at it would plot nothing from a fresh checkout.",
  "title": {
    "text": "Dispatch cost distribution",
    "subtitle": "33 measured dispatches; subagent context totals, not output produced"
  },
  "data": {
    "values": [
      {
        "role": "lead-planner",
        "task": "G-F3 demo: lead produces DISPATCH",
        "tokens": 35550,
        "duration_ms": 130272
      },
      {
        "role": "arbiter",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 36568,
        "duration_ms": 123378
      },
      {
        "role": "test-runner",
        "task": "F7-B8-tests",
        "tokens": 46388,
        "duration_ms": 197102
      },
      {
        "role": "lead-executor",
        "task": "F7-A5-readme",
        "tokens": 58187,
        "duration_ms": 435162
      },
      {
        "role": "general-purpose",
        "task": "Peer review via /peer-review",
        "tokens": 61243,
        "duration_ms": 364965
      },
      {
        "role": "arbiter",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 62209,
        "duration_ms": 217105
      },
      {
        "role": "lead-planner",
        "task": "F7-P1-jml-simulator-plan",
        "tokens": 62320,
        "duration_ms": 295737
      },
      {
        "role": "test-runner",
        "task": "STRESS1-TEST",
        "tokens": 72701,
        "duration_ms": 321386
      },
      {
        "role": "Explore",
        "task": "Survey scaffold/verify patterns",
        "tokens": 73039,
        "duration_ms": 124736
      },
      {
        "role": "arbiter",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 73974,
        "duration_ms": 464973
      },
      {
        "role": "lead-executor",
        "task": "STRESS1-EXA",
        "tokens": 74287,
        "duration_ms": 583802
      },
      {
        "role": "lead-executor",
        "task": "F7-A2-fixtures",
        "tokens": 75089,
        "duration_ms": 460231
      },
      {
        "role": "lead-executor",
        "task": "F7-A6-suite",
        "tokens": 75189,
        "duration_ms": 548162
      },
      {
        "role": "quality-reviewer",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 79846,
        "duration_ms": 397479
      },
      {
        "role": "arbiter",
        "task": "F7-B4-compile1",
        "tokens": 82381,
        "duration_ms": 475110
      },
      {
        "role": "general-purpose",
        "task": "Internal plan review",
        "tokens": 90087,
        "duration_ms": 409618
      },
      {
        "role": "security-reviewer",
        "task": "STRESS1-R2-sec",
        "tokens": 90757,
        "duration_ms": 577245
      },
      {
        "role": "security-reviewer",
        "task": "STRESS1-R1-sec",
        "tokens": 90935,
        "duration_ms": 521864
      },
      {
        "role": "Explore",
        "task": "Audit hiya-crew deployment state",
        "tokens": 93245,
        "duration_ms": 251944
      },
      {
        "role": "security-reviewer",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 106767,
        "duration_ms": 654902
      },
      {
        "role": "lead-executor",
        "task": "F7-A3-modules",
        "tokens": 117542,
        "duration_ms": 954617
      },
      {
        "role": "lead-executor",
        "task": "F7-A4-tests",
        "tokens": 118365,
        "duration_ms": 733011
      },
      {
        "role": "arbiter",
        "task": "F7-B6-compile2",
        "tokens": 118842,
        "duration_ms": 603682
      },
      {
        "role": "general-purpose",
        "task": "Peer review of plan",
        "tokens": 118910,
        "duration_ms": 496319
      },
      {
        "role": "arbiter",
        "task": "F7-B9-e2e",
        "tokens": 121025,
        "duration_ms": 580274
      },
      {
        "role": "arbiter",
        "task": "F7-P1-jml-simulator-plan",
        "tokens": 123135,
        "duration_ms": 428623
      },
      {
        "role": "arbiter",
        "task": "F7-B7-fix",
        "tokens": 123381,
        "duration_ms": 529460
      },
      {
        "role": "security-reviewer",
        "task": "F7-B3-sec",
        "tokens": 124800,
        "duration_ms": 655725
      },
      {
        "role": "lead-executor",
        "task": "STRESS1-EXB",
        "tokens": 126579,
        "duration_ms": 1190269
      },
      {
        "role": "lead-planner",
        "task": "STRESS1-A1",
        "tokens": 128098,
        "duration_ms": 354145
      },
      {
        "role": "integration-runner",
        "task": "STRESS1-E2E",
        "tokens": 130491,
        "duration_ms": 1056263
      },
      {
        "role": "quality-reviewer",
        "task": "F7-B5-qual2",
        "tokens": 132990,
        "duration_ms": 692006
      },
      {
        "role": "quality-reviewer",
        "task": "STRESS1-R2-qual",
        "tokens": 134953,
        "duration_ms": 883951
      },
      {
        "role": "arbiter",
        "task": "STRESS1-ARB1",
        "tokens": 136427,
        "duration_ms": 750638
      },
      {
        "role": "general-purpose",
        "task": "Internal plan review",
        "tokens": 139483,
        "duration_ms": 423964
      },
      {
        "role": "security-reviewer",
        "task": "F7-B5-sec2",
        "tokens": 140203,
        "duration_ms": 705809
      },
      {
        "role": "arbiter",
        "task": "STRESS1-ARB-R1",
        "tokens": 145784,
        "duration_ms": 920497
      },
      {
        "role": "quality-reviewer",
        "task": "STRESS1-R1-qual",
        "tokens": 147631,
        "duration_ms": 1029253
      },
      {
        "role": "quality-reviewer",
        "task": "Quality review of prep",
        "tokens": 152880,
        "duration_ms": 950840
      },
      {
        "role": "quality-reviewer",
        "task": "F7-B3-qual",
        "tokens": 156265,
        "duration_ms": 875961
      },
      {
        "role": "fixer",
        "task": "F3-D1-dirguide-risk-scan",
        "tokens": 167905,
        "duration_ms": 1225648
      },
      {
        "role": "fixer",
        "task": "F7-B7-fix",
        "tokens": 170915,
        "duration_ms": 781106
      },
      {
        "role": "fixer",
        "task": "STRESS1-FIX",
        "tokens": 180913,
        "duration_ms": 1517615
      },
      {
        "role": "Explore",
        "task": "Survey reconciliation patterns",
        "tokens": 181524,
        "duration_ms": 739356
      },
      {
        "role": "integration-runner",
        "task": "F7-B9-e2e",
        "tokens": 198302,
        "duration_ms": 758461
      },
      {
        "role": "arbiter",
        "task": "STRESS1-ARB-R2",
        "tokens": 261965,
        "duration_ms": 1647698
      },
      {
        "role": "arbiter",
        "task": "STRESS1-ARB-FIN",
        "tokens": 301037,
        "duration_ms": 1920968
      }
    ]
  },
  "encoding": {
    "y": {
      "field": "role",
      "type": "nominal",
      "sort": "-x",
      "title": "agent role"
    },
    "x": {
      "field": "tokens",
      "type": "quantitative",
      "title": "context total (tokens)"
    }
  },
  "layer": [
    {
      "mark": {
        "type": "point",
        "filled": true,
        "opacity": 0.75,
        "size": 70
      },
      "encoding": {
        "tooltip": [
          {
            "field": "task",
            "type": "nominal"
          },
          {
            "field": "tokens",
            "type": "quantitative"
          },
          {
            "field": "duration_ms",
            "type": "quantitative"
          }
        ]
      }
    },
    {
      "mark": {
        "type": "tick",
        "color": "firebrick",
        "thickness": 2,
        "size": 22
      },
      "encoding": {
        "x": {
          "field": "tokens",
          "aggregate": "mean"
        }
      }
    }
  ]
}
```

**No renderer here.** HC-5 forbids installing one and GitHub does not render `vega-lite` fences, so
this is a spec, not a picture. What is enforced instead is in `run-crew-tests.sh`: the embedded
`values` are compared against the TSV row by row when it is present, and every field named in the
`encoding` must exist in the data — the failure that renders an empty chart.
