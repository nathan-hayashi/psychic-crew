# session-summary.md — distilled state (HC-8 §15.5)

Conclusions only, merged not appended. Every entry labelled **verified** or **proposed**. Repo-relative paths. Maintained with `scripts/save-context.sh` (`prepare` to distill, `check` to verify these semantics).

## Where the build stands

**verified** — F0–F6 complete and gated (tags `crew-f0`…`crew-f6`). **F7 Stage A is COMPLETE**: A0 arbiter release, A1 gate-0, A2 fixtures, A3 modules, A4 tests, A5 README, A6 harness wiring, A7 this checkpoint. Rollback tags `rb/f7-a1`…`rb/f7-a7`. **This is the planned Stage A/B split point — Session 2 resumes at B1 and needs nothing from a context window.**

Live numbers: crew suite **144 PASS / 0 FAIL** · app suite **18 PASS / 0 FAIL** · validate-crew **36 PASS / 0 SKIP / 0 FAIL** · corrections **13 APPLIED / 0 PENDING / 2 SUPERSEDED** · 22 tracked files under `stress-project/`.

## What Stage B must do (the remaining F7 work)

**verified** — Steps B1–B10 are specified in `context/f7-plan.md`, whose two amendment sections SUPERSEDE the tables above them. In order: re-ground · seed 3 bugs · round-1 discourse (2 parallel branches) · arbiter compiles round 1 · round-2 discourse · arbiter compiles round 2 and releases · fixer verdicts · test-runner · integration-runner e2e · metrics + §7 rubric roll-up at `G-F7b`.

**verified — binding amendments Stage B must honour:**

- F7 round artifacts go to **`logs/rounds/f7-round-1/`** and `f7-round-2/`. NEVER `logs/rounds/round-1/` — that path holds F3 fixtures read by two live detectors (`check-plan-corrections.sh` for C-13, `run-crew-tests.sh` for the F4 provenance cases) and `logs/` is gitignored, so an overwrite is unrecoverable.
- The **seed manifest goes to the scratchpad, never into the repo**. If it lands in the tree, reviewers read it as authoritative context and "find" all three — Robustness then measures nothing. This is the highest wrong-reason risk in F7.
- At least one seed must be **invisible to any test existing at seed time**, or the tests alone satisfy Robustness and the discourse pipeline is never exercised.
- Agent coverage 8/8 must bind each agent to a **named artifact** (findings file, verdict, run record, released packet), not to a grep count — C-12 is the precedent.
- Every dispatch carries `expected_output`; a DISPATCH without it is malformed per `.claude/rules/arbiter-protocol.md`.
- The §7 `tests >= 15` bar counts **`node --test` cases only**. `cases_F7`'s 13 crew assertions are gate evidence and must not be added to it.

**verified — operator decisions fixed pre-run at G-F7a (C-18):** wall ceiling is **45 min per session**, and breaching it triggers an early gate rather than failing the phase. The §7 token denominator is **207K** (F7's §6 budget plus the accepted 7K overrun), superseding Q5's generic 150K. Both were recorded before execution so Velocity cannot be self-scored.

## The JML artifact as built

**verified** — `stress-project/`: 22 tracked files, Node stdlib only, zero dependencies. CLI takes the delivery file **positionally** (`node bin/jml.js <file> --out <dir> --now <iso> --seed <s>`) — there is no `run` subcommand and no `--input`; the audit log is `<out>/audit.jsonl`. The plan's original invocation was wrong and is corrected in `context/f7-plan.md`; left unfixed it would have produced three false edge-case failures at B9.

**verified** — Exit contract: 0 handled · 1 needs a human (parked) · 2 unusable input. Edge cases verified independently: duplicate exit 0 with exactly **one** ticket (the load-bearing half — a dedupe that logs but still writes a ticket passes the audit-line check alone) · mover-before-hire exit 1 with `PARKED` and a D5 FALLBACK at confidence 0.25 · malformed exit 2, six D5 keys on stdout, exactly one audit line, no ticket, no notification.

**verified** — Determinism is falsifiable both ways: `--now` plus `--seed` gives byte-identical runs; unseeded runs differ with probability 1 (`randomUUID`), not by timing luck.

**verified** — `npm test` runs the suite. **`node --test test/` runs ZERO cases and exits 1 on Node v24** — a bare directory positional resolves as a module. The working form is `node --test 'test/**/*.test.js'`, quoted so node globs rather than the shell. Do not revert it.

**verified** — Reading `# pass` from `node --test` requires `--test-reporter=tap`; the default reporter here is `spec` and prints `ℹ pass`.

## Open items carried into Stage B

- **verified** — `bin/jml.js` imports `OUTCOMES` from `src/lifecycle.js` and never uses it. Dead import, IDE-flagged, left for B3 discourse rather than fixed silently.
- **verified** — The `NONE` row of the transition table is deliberately asymmetric: `NONE+MOVE` parks, `NONE+TERMINATE` suspends anyway, on the stated rule "err toward less access, never toward more". The 18 named cases do not constrain that row, so it is a design call worth arguing with at B3.
- **verified** — `fixtures/mover-squirtle.json` exits 1 with `PARKED` on a fresh `--out`: EMP-10043 has no prior HIRE and no fixture supplies one. The plan's phrase "both valid fixtures" is misleading for the mover, and there is no runnable replay demo in the current fixture set.
- **verified** — G-F3's round-2 re-emission is still owed: branch B's four anchor-verified findings remain quarantined and unreleased.
- **verified** — `DIRECTORY_GUIDE.md` still drifts from the tree; it is byte-pinned under EX-01, so the fix needs an operator routing decision. Precedent: route around the pin, as QR-DG-3 was closed at F4 by creating the file the map already claimed.

## The failure families this build keeps hitting

**verified** — **A control bound to a proxy rather than the artifact.** Nine instances, the most recent three during F7: C-14 matched the word "fixture" and flagged the legitimate dispatch `F7-A2-fixtures`; an A5 arrow count used a line proxy and returned 0 against a real 14; ERR6 caught a token-shaped literal in a tracked test file on a public repo, before it was pushed. The rule: **a check must bind to the artifact that would change if the defect were real.**

**verified** — **`set -o pipefail` with a meaningful nonzero stage.** Five instances. Capture into a variable, then test; pass JSON to printf as an argument, never as the format.

**verified** — **A dispatch contract can be wrong.** Three of my own F7 dispatches specified commands that do not work (`node --test test/`, `# pass` under the default reporter, `run --input`). Executors caught all three and flagged rather than reinterpreting. Verify a command before putting it in a contract.

## Next action

**verified** — **B1**: re-ground per §15.4, then B2 — seed three bugs with the manifest written to the scratchpad, never the repo. Full step table in `context/f7-plan.md`.
