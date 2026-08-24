# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Maintained with `scripts/save-context.sh` (`prepare` to distill, `check` to verify these semantics).

## Where the build stands

**verified** — **BUILD COMPLETE. All nine phases F0–F8 executed and gated** (tags `crew-f0`…`crew-f8`), `APPROVE GATE-F8` received, **the plan is CLOSED**, and the repo is tagged **`v1.0.0`** at the final commit. Nothing is outstanding.

Live numbers (post-S4): crew suite **179 PASS / 0 FAIL** · validate-crew **44 PASS / 1 SKIP / 0 FAIL** · save-context **30 PASS / 0 FAIL** · app suite **18/18** · corrections **28 rows across 28 registered correction IDs** · portability drill **PORTABLE** · **94 tracked files**.

The one SKIP is honest and named: C-25's identity coverage has no live trail until a subagent is dispatched in-session. These figures are bound — `save-context.sh check` compares the tracked-file count against the tree and the registered-ID count against the registry, so this line cannot silently rot again (C-24, extended at CR-034).

**verified — an independent audit ran after closure (2026-08-17) and its record is in `docs/audit/`.** It fixed nothing; its product was truth plus a priced backlog, now at 33 change requests. Start at `docs/audit/FINAL_AUDIT_REPORT.md`; the backlog is `docs/audit/CHANGE_REQUESTS.md`.

**verified — the audit's findings have since been worked, and its own text is a historical record, not current state.** S1 repaired nineteen items, S2 landed the enforcement gate, S3 the diagrams, S4 the intake layer. Where a document under `docs/audit/` describes a defect in the present tense, read it as *found on 2026-08-17* and check the registry or this file for what happened next. The three things that file warns a cold reader about — the miscounted corrections figure, two detectors that reported APPLIED while testing nothing, and four unadjudicated findings — are all closed.

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

**verified** — **C-05 acted on at a gate as C-25 (2026-08-19).** `SubagentStart` supplies `agent_id` and `agent_type`, so attribution is deterministic and specialist creations are correlated by identity against the arbiter trail — which also closes coverage of dispatches that FAILED, the hole C-12 observed where `PostToolUse` cannot fire for a tool that never ran. **Prevention at the call is NOT available**: `SubagentStart` cannot block subagent creation. Detection moved from the gate to the moment; blocking remains impossible, and this file previously implied otherwise.

**verified — G-F3 round-2 re-emission is CLOSED.** All four of branch B's anchor-verified findings were adjudicated at audit phase A4: three ACCEPT, one REJECT. Two of the accepted three were then resolved outright by the v3.0 map re-export.

**verified — the `DIRECTORY_GUIDE.md` drift is RESOLVED and EX-01 is retired.** Ruling A1b re-exported the plan under the permanent name, so the map now matches the tree and every §4 seed sits at delta 0. The map is still byte-pinned — to plan v3.1 — so it can only gain a path through an operator re-export, which is exactly how the intake skill's path arrived (D16). A tenth script was rejected by that constraint during S3 and had to move inline.

**verified — `REPLAYED` is now PROVEN live (CR-017, S4).** It was not merely undemonstrated but *unreachable*: the parked MOVE belongs to `EMP-30442` and no shipped fixture hired that employee, so no pair of deliveries in any order could drain the lot. `fixtures/edge-hire-drains-parked.json` closes it, and the suite asserts the full path — two runs sharing one `--out` produce `PARKED` then `REPLAYED` with the parking lot empty. Control: removing that fixture returns the assertion to failing.

**verified** — **OQ-2**: the orchestrator ran a context-variant model id that `.pinned` cannot express. Alias mode unaffected; a pinned reproducibility run would not reproduce the variant.

## The failure families this build kept hitting

**verified** — **A control bound to a proxy rather than the artifact — ten instances.** The most recent three: `[ -d .git ]` standing in for "is this a repo" (C-23); a detector grepping the word "retrospective" in a _comment_ rather than the enforcement (C-19); the drill grepping `setup.sh`'s condensed summary, which could never contain the line it looked for. **A check must bind to the artifact that would change if the defect were real.**

**verified** — **`set -o pipefail` with a meaningful nonzero stage — five instances.** Capture into a variable, then test.

**verified** — **A dispatch contract can be wrong — three instances**, all caught by executors who flagged rather than reinterpreted. Verify a command before putting it in a contract.

## Next action

**verified** — **None. The build is complete.** `APPROVE GATE-F8` was received @ 2026-08-14T01:54:54Z and closed the plan; all nine phases are gated, `v1.0.0` is tagged at the final commit, and `crew-f8` is pushed.

_CR-012 (audit A0-F3): this read `01:58:11Z` until 2026-08-17. Not a typo — a conflation. `Plan.md`'s last two entries are adjacent, `[F8|…01:54:54Z] G-F8 APPROVED` and `[F8|…01:58:11Z] BRANCH LAYOUT SETTLED`, and the distillation attached the second entry's timestamp to the first entry's event. Every constituent fact was true of something in the source; the assembled sentence was true of nothing. `save-context.sh check` returned 20 PASS against this file throughout, because all twenty assertions were hygiene properties of the distilled file considered alone and none compared a distilled claim to its source. C-24 now does._

**verified — branch layout is a SETTLED operator decision, not an oversight.** There is no `main` branch and none will be created: `dev` is the remote's default branch and the only branch that has ever existed, `v1.0.0` marks the release, and the standing "never push main without an approved gate" rule was moot throughout because there was never a `main` to push to. Do not "fix" this in a later session.

Open items carried past v1.0.0 are in `ROADMAP.md`; the largest available upgrade is C-05 (hook-enforced bypass detection).
