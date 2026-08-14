# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Maintained with `scripts/save-context.sh` (`prepare` to distill, `check` to verify these semantics).

## Where the build stands

**verified** — **F0–F7 complete and gated** (tags `crew-f0`…`crew-f7`). **F8 work is complete and the repo is tagged `v1.0.0`.** The only thing outstanding is the operator's token: the plan defines `APPROVE GATE-F8` and says it closes the plan.

Live numbers: crew suite **144 PASS / 0 FAIL** · validate-crew **37 PASS / 0 SKIP / 0 FAIL** · app suite **18/18** · corrections **all applied, 0 pending** · portability drill **PORTABLE** · 74 tracked files.

## What F8 delivered

**verified** — Gap register closed, and closing it found three defects the earlier phases had not:

- **C-19** was root-caused to the wrong layer by its own description. The problem was never the coverage check; `.claude/agents/arbiter.md` specified the audit line as `{"ts",...}` with **no format**, so the arbiter emitted a date-only timestamp that could never be ordered against the full-ISO dispatch records. Fixed at both ends. **F7's own coverage stays ordering-undecidable forever** — that granularity was never captured.
- **C-21** (opened and closed at F8) — the per-dispatch token measurement underpinning every Velocity number, C-18 and C-20 **was never written to disk**. It lived only in the orchestrator's context window: the exact inversion HC-8 exists to prevent, surviving undetected into the handover phase of the build whose central doctrine is that inversion. Recovering it corrected F7's spend from 1,922,184/17 to **2,045,319 across 18 dispatches (9.88×)**; the missing dispatch was `arbiter / F7-P1` at 123,135.
- **C-23** — `validate-crew.sh` gated the absolute-path check on `[ -d .git ]`, which is false in a worktree (`.git` is a file there). The one assertion the G-F8 stress requirement names was the one assertion that silently skipped in the checkout the G-F8 demo uses, while reporting "git not initialized yet". Tenth instance of the proxy-binding family and the worst-shaped: a plausible-sounding reason for not checking, exactly where checking mattered.

**verified** — New on disk: `scripts/setup.sh` (installs nothing; toolchain, runtime dirs, exec bits, model stamp, validation, app suite) · `scripts/portability-drill.sh` · `scripts/measure-dispatch-cost.sh` · `README.md` · `ROADMAP.md` · `context/budget-baseline.md`.

## Binding facts a future session must not re-derive

**verified — the plan's G-F8 demo is unexecutable as written (C-22).** It mandates a fresh-clone drill; `hooks/bash-blocker.sh` denies the clone verb under HC-5. The guard was **not** widened. `scripts/portability-drill.sh` proves the same property by `git archive` (stricter — tracked bytes only, no `.git`, no local config) plus a detached worktree (keeps `.git` so repo-dependent assertions run).

**verified — a denied Bash call kills every command in that invocation.** The HC-5 denial silently discarded a `git commit` that shared its command line, and the commit appeared to have succeeded. Never chain a commit behind anything a hook might block.

**verified — guards trip on prose that documents them.** The clone-verb block fired on a registry entry describing it, exactly as the security rules already warn for the absolute-path token. Tracked files and detectors now assemble those patterns from fragments.

**verified — Velocity passed as a gate TRIGGER, not against a threshold** (operator ruling, option A, G-F7b). Q5's ceiling reads "hard ceiling per phase before mandatory early gate", and the operator had already applied that reading to the wall-clock limb at G-F7a. The measurement is recorded, not waived, and per C-20 the axis was unsatisfiable by construction: 18 mandated dispatches × the cheapest observed (46,388) = 834,984, still 4.03× the 207K denominator.

**verified — budget every future phase from `context/budget-baseline.md`,** never from the plan's §6 numbers. Measured mean is ~113K per dispatch; the plan budgets 319K for the entire nine-phase build against 3,078,632 measured in subagents alone.

## The JML artifact

**verified** — `stress-project/`: 22 files, Node standard library only, zero dependencies. CLI takes the delivery file **positionally** (`node bin/jml.js <file> --out <dir> --now <iso> --seed <s>`) — no `run` subcommand, no `--input`; audit log at `<out>/audit.jsonl`. Exit 0 handled · 1 parked · 2 unusable input. `--now` plus `--seed` gives byte-identical runs.

**verified** — `npm test` runs the suite. **`node --test test/` runs ZERO cases and exits 1**; the working form is `node --test 'test/**/*.test.js'`, quoted so node globs rather than the shell. Reading `# pass` requires `--test-reporter=tap`; the default `spec` reporter prints `ℹ pass`.

## Open items carried past v1.0.0

**verified** — **C-05**, the largest available upgrade: bypass detection is audit-based, caught at the gate rather than blocked at the call. `SubagentStart`/`SubagentStop` carry `agent_type`, which would make it deterministic. Operator decision.

**verified** — **G-F3 round-2 re-emission** is still owed: branch B's four anchor-verified findings remain quarantined and unreleased.

**verified** — **`DIRECTORY_GUIDE.md` drifts from the tree** and is byte-pinned under EX-01. The F4 precedent is to route around the pin by creating what the map claims, rather than editing the map. Needs an operator routing decision.

**verified** — **`REPLAYED` appears in zero end-to-end artifacts.** The parked-replay path is green in tests but was never demonstrated live; no live replay is claimed.

**verified** — **OQ-2**: the orchestrator ran a context-variant model id that `.pinned` cannot express. Alias mode unaffected; a pinned reproducibility run would not reproduce the variant.

## The failure families this build kept hitting

**verified** — **A control bound to a proxy rather than the artifact — ten instances.** The most recent three: `[ -d .git ]` standing in for "is this a repo" (C-23); a detector grepping the word "retrospective" in a _comment_ rather than the enforcement (C-19); the drill grepping `setup.sh`'s condensed summary, which could never contain the line it looked for. **A check must bind to the artifact that would change if the defect were real.**

**verified** — **`set -o pipefail` with a meaningful nonzero stage — five instances.** Capture into a variable, then test.

**verified** — **A dispatch contract can be wrong — three instances**, all caught by executors who flagged rather than reinterpreted. Verify a command before putting it in a contract.

## Next action

**verified** — **None. The build is complete.** `APPROVE GATE-F8` was received @ 2026-08-14T01:58:11Z and closed the plan; all nine phases are gated, `v1.0.0` is tagged at the final commit, and `crew-f8` is pushed.

**verified — branch layout is a SETTLED operator decision, not an oversight.** There is no `main` branch and none will be created: `dev` is the remote's default branch and the only branch that has ever existed, `v1.0.0` marks the release, and the standing "never push main without an approved gate" rule was moot throughout because there was never a `main` to push to. Do not "fix" this in a later session.

Open items carried past v1.0.0 are in `ROADMAP.md`; the largest available upgrade is C-05 (hook-enforced bypass detection).
