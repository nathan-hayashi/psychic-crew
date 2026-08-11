# F2 Readiness — acceptance specification

Written at the G-F1 gate, before F2 is authorised, so F2 is transcription rather than discovery. **Read with `context/plan-corrections.md`** — C-01..C-04 are prerequisites, not optional cleanups, and `./scripts/check-plan-corrections.sh F2` exits 1 until all four land.

## 0. Order of operations (this order matters)

1. **C-04 first** — append `.claude/state/` to `.gitignore`. Do this _before_ installing `sensitive-guard.sh`, which blocks writes touching `.gitignore`. Installing the guard first can deadlock the correction it depends on.
2. **C-01/C-02** — rebuild the `.claude/settings.json` hooks block to the real schema.
3. Write the hook scripts, `bash -n` each, `chmod +x`.
4. **Install last, verify immediately.** A wrong `bash-blocker.sh` can deny the very commands needed to fix it.
5. §15.3 flag mechanics, then §15.9 snapshot pair, then `restore-context.sh`.
6. Register F2 cases in `cases_F2()` in `scripts/run-crew-tests.sh`.

## 1. Hook config shape (C-01, C-02)

Every entry is `{ "matcher": "<pattern>", "hooks": [ { "type": "command", "command": "<cmd>" } ] }`. The `hook` string key and the `description` key do not exist in the schema. Event `PostToolUseFail` does not exist — it is `PostToolUseFailure`. Nine entries in the §4.6 payload are affected; none of them would fire as written.

| Event (correct spelling) | Matcher        | Script                      | Purpose                                         |
| ------------------------ | -------------- | --------------------------- | ----------------------------------------------- |
| `PreToolUse`             | `Bash`         | `bash-blocker.sh`           | HC-5 destructive + clone/npx/sudo denial        |
| `PreToolUse`             | `Write\|Edit`  | `model-guard.sh`            | HC-2 — block writes assigning a forbidden model |
| `PreToolUse`             | `Write\|Edit`  | `sensitive-guard.sh`        | `.env` / secrets / `.gitignore` protection      |
| `PostToolUse`            | `*`            | `audit-logger.sh`           | append to `logs/tooluse-audit.jsonl`            |
| `PostToolUse`            | `Write\|Edit`  | `auto-format.sh`            | prettier if present, silent no-op otherwise     |
| `PostToolUseFailure`     | `*`            | `error-recovery.sh`         | `logs/build-errors.jsonl` + §9 hint             |
| `PreCompact`             | `auto\|manual` | `pre-compact-checkpoint.sh` | §15.3 checkpoint + §15.9 snapshot               |
| `Notification`           | `*`            | `notify.sh`                 | desktop toast (Q3: reuse `wsl-notify-send.exe`) |
| `Stop`                   | `*`            | `stop.sh`                   | gate toast + one-shot flag consumption          |

**Verify before wiring:** confirm `$CLAUDE_PROJECT_DIR` actually resolves at hook execution time. It is **not** present in this session's Bash environment, so a hook command depending on it may resolve to an empty path and silently no-op. Test one trivial hook end to end before writing the other eight.

> **RESOLVED 2026-08-11 (G-F2, live).** The concern was real and was engineered around at two layers: the settings commands use `"${CLAUDE_PROJECT_DIR:-.}"`, and `hooks/_common.sh` derives `ROOT` from the script's own location when the variable is absent. All ten hooks are confirmed dispatching live. The variable _is_ genuinely unset in the Bash tool's shell — that is harmless here only because of those fallbacks, so **any new hook or script must keep a fallback rather than depend on the bare variable.**

## 2. Denial contract (C-03)

PreToolUse denial is **JSON on stdout**, not a bare exit code:

```sh
printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<why>"}}'
exit 2
```

Emit both — the JSON is what denies; the exit code is belt-and-braces and matches the working local hook. A bare `exit 2` as §5.6 specifies does **not** block, so every HC-5 guard would be decorative.

`audit-logger.sh` and `pre-compact-checkpoint.sh` must **always exit 0** and never block; PreCompact additionally must complete in ≤10s.

## 3. Stop-hook contract (§15.3)

Blocking uses a **top-level** decision — `{"decision":"block","reason":"..."}` — confirmed against the current reference. One consumption per flag, no loops.

## 4. Exit criteria — F2 is done when all of these pass

- `./scripts/check-plan-corrections.sh F2` → exit 0 (C-01..C-04 all APPLIED)
- `./scripts/validate-crew.sh` → 0 FAIL, with the hooks section no longer SKIP: every `hooks/*.sh` executable, `bash -n` clean, no `[[`
- `./scripts/run-crew-tests.sh` → 0 FAIL with `cases_F2` populated
- Live denial demonstrated for each guard, with a matching `logs/tooluse-audit.jsonl` line
- G-F2 stress: six forbidden ops → six denials → six audit entries; hooks removed → validate-crew fails
- ccs-01 precondition: synthetic PreCompact event writes a checkpoint block, touches the flag, exits 0 **even when PROGRESS.md is unwritable**

## 5. Risk register

| #   | Risk                                                                          | Mitigation                                                                                          |
| --- | ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| R1  | Prettier `PostToolUse` hook mangles `.claude/settings.json` on any Write/Edit | All byte-sensitive writes via Bash. Non-negotiable, four incidents already.                         |
| R2  | `$CLAUDE_PROJECT_DIR` unset at hook time → silent no-op — **CLOSED, live-verified** | Two-layer fallback: `${CLAUDE_PROJECT_DIR:-.}` in the settings command plus a dirname-derived `ROOT` in `_common.sh`. All ten hooks confirmed dispatching live at G-F2. Keep the fallback in every new hook — the bare variable really is absent from the Bash tool shell. |
| R3  | A wrong `bash-blocker.sh` denies the commands needed to repair it             | Install last; keep a known-good copy outside the repo; verify immediately after install.            |
| R4  | `sensitive-guard.sh` blocks the `.gitignore` append C-04 needs                | Apply C-04 first (see §0).                                                                          |
| R5  | No PreCompact parachute exists _during_ F2 — the bootstrap gap                | §0.3's 70% early-gate rule plus per-step PROGRESS.md checkpoints until the hook is live and tested. |
| R6  | Guards trip on their own documentation                                        | EX-03 already narrowed HC-2 to assignment positions; keep detectors comment-stripped.               |
| R7  | A denial leaves no audit trace — the guard blocks silently, and `PostToolUse` cannot cover it because the blocked tool never runs — **FOUND BY THE LIVE STRESS, FIXED** | `deny()` in `_common.sh` now writes its own `PreToolUse.deny` record carrying tool, target, reason and phase. Regression-covered by two `cases_F2` checks. |

## 6. Opportunities the plan predates (operator decision, not defects)

- **`SessionStart`** exists — §15.4 re-grounding can be hook-enforced rather than relying only on the CLAUDE.md bullet.
- **`PostCompact`** exists — §15.9(e) concedes PreCompact cannot shape the compaction summary; PostCompact fires after and can inject context directly.
- **`SubagentStart`/`SubagentStop`** carry `agent_type` — this is the caller attribution §5.2.2 assumed impossible, and would make C-05's arbiter-bypass detection deterministic instead of audit-diff-based (F3).
