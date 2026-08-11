# plan-corrections.md — authoritative plan-vs-reality registry
`MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally (standing operator decision: it stays identical to the PROJECT canonical copy). Every defect found in it is corrected **in the artifact this repo builds**, and recorded here.

**Read this before implementing any phase.** Where this file and the plan disagree, this file wins for implementation; the plan remains the authority for objectives, ordering, and gates. Each entry is machine-checked by `scripts/check-plan-corrections.sh`.

Discovery path (why this isn't pointed to from CLAUDE.md): CLAUDE.md is a byte-pinned §4.1 seed under EX-01 and adding a line would widen that exception. Instead, `PROGRESS.md` and `context/session-summary.md` both point here, and CLAUDE.md's own continuity bullet already mandates reading both at every session start.

| ID | Plan location | Owner | Status source |
|---|---|---|---|
| C-01 | §4.6 hook entry shape | F2 | settings.json |
| C-02 | §4.6 `PostToolUseFail` event name | F2 | settings.json |
| C-03 | §5.6 PreToolUse deny mechanism | F2 | hooks/*.sh |
| C-04 | §4.7 `.claude/state/` not ignored | F2 | .gitignore |
| C-05 | §5.2.2 `Task`→`Agent` bypass detection | F3 | validate-crew.sh + arbiter-protocol.md |
| C-06 | §5.5 apply-models HC-2 scan | F0 | scripts/apply-models.sh |
| C-07 | §5.5 apply-models session-model jq | F0 | scripts/apply-models.sh |
| C-08 | §5.5 apply-models subshell exit | F0 | scripts/apply-models.sh |
| C-10 | §5.2.1 vs §6 phase steps | F3 | .claude/rules/fallback-protocol.md |

---

## C-01 — hook entries use a key that does not exist (F2, blocking)
**Plan says** (§4.6): `{ "matcher": "Bash", "hook": "bash -c '...'", "description": "..." }`
**Reality**: the key is `hooks`, an array of handler objects.
**Apply**:
```json
{ "matcher": "Bash", "hooks": [ { "type": "command", "command": "$CLAUDE_PROJECT_DIR/hooks/bash-blocker.sh" } ] }
```
`description` is not part of the shape — keep the intent in the hook script's header comment instead. Affects all nine §4.6 entries (machine-counted). Evidence: current hooks reference, and the live working config in `~/.claude/settings.json`.
**Verify**: no entry under `.hooks[][]` has a `hook` key.

## C-02 — `PostToolUseFail` is not a real event (F2, blocking)
**Plan says** (§4.6): `"PostToolUseFail"`. **Reality**: `PostToolUseFailure`.
**Apply**: rename the key. **Verify**: `.hooks | has("PostToolUseFail")` is false.

## C-03 — PreToolUse denial is not exit 2 (F2, blocking)
**Plan says** (§5.6): `bash-blocker.sh` / `model-guard.sh` "print DENY reason, exit 2".
**Reality**: PreToolUse denial is expressed as JSON on stdout; exit 2 is the mechanism for other events. A bare exit 2 would not block, so HC-5's clone/npx/sudo/destructive guards would not actually guard.
**Apply** (the local working hook does both — copy that):
```sh
printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"REASON"}}'
exit 2
```
**Verify**: every PreToolUse-wired script in `hooks/` contains `permissionDecision`.

## C-04 — `.claude/state/` is tracked despite DIRECTORY_GUIDE (F2)
**Plan says**: §4.7 `.gitignore` omits it; DIRECTORY_GUIDE states it is ignored.
**Reality**: contradiction — snapshots would be committed every turn once §15.9 is wired.
**Apply**: append `.claude/state/` to `.gitignore`. sensitive-guard permits appends (it blocks removals).
**Verify**: `git check-ignore -q .claude/state/compact-pending`.

## C-05 — bypass detection greps a renamed tool (F3, blocking)
**Plan says** (§5.2.2): diff "tooluse-audit.jsonl Task calls" against arbiter coverage.
**Reality**: `Task` was renamed `Agent` in v2.1.63 (`Task` survives only as an alias). A lead calling `Agent` directly yields zero matches, so the check passes while the bypass succeeds — defeating the plan's own declared weakest enforcement point.
**Apply**: match `Task|Agent` everywhere bypass detection appears — `scripts/validate-crew.sh` (already done) and `.claude/rules/arbiter-protocol.md` (F3 writes it).
**Upgrade available, operator decision**: `SubagentStart`/`SubagentStop` hooks receive the subagent's name as `agent_type` — the caller/callee attribution §5.2.2 assumed hooks "cannot reliably" provide. This would make bypass detection hook-enforced and deterministic rather than audit-diff-based.
**Verify**: both names present wherever dispatch detection occurs.

## C-06/C-07/C-08 — §5.5 apply-models.sh (F0, APPLIED as EX-02)
- **C-06**: HC-2 scan piped `grep -ril` (filenames) into `grep -v forbidden_substrings`, so the filter tested the filename and never suppressed the legitimate declaration line — `[FAIL] HC-2`, exit 2, on a clean repo. Fixed: match lines, filter the declaration line.
- **C-07**: session model used `.[$m=="pinned" and "pinned" or "aliases"]`. jq's `and`/`or` return booleans, so this errors with *Cannot index object with boolean*. Fixed: `if/then/else`, matching the idiom the per-agent line already used.
- **C-08**: the agent loop ran as `jq ... | while read`, i.e. in a subshell, so its `exit 3` on malformed frontmatter could not stop the script — it would report success while violating HC-4. Fixed: iterate without the pipeline.

---

## Working note — the §5.2.4 absolute-path check is blunt by design
`validate-crew.sh` substring-matches tracked files for an absolute home-directory prefix. It is high-recall and low-precision on purpose: it is a cheap guard against machine-specific paths leaking into a public repo, and narrowing it to "looks like a real path" would create exactly the gap it exists to close.

Consequence for every phase: **do not write the literal token in tracked prose**, not even when documenting the check itself. Describe it ("an absolute home-directory prefix") or use `$HOME`. Two failures were caused this way at F0 — once by the validator's own grep pattern (fixed by splitting the string literal) and once by a Plan.md sentence describing the fix. Neither was a real violation; both cost a red gate.

## C-09 — §5.5's HC-2 scan is a bare substring match (F0/F1, APPLIED as EX-03)
**Plan says** (§5.5): grep the config surface for each forbidden substring; any hit fails.
**Reality**: any *mention* trips it. `.claude/rules/model-policy.md` documents the prohibition and fails. Decisively, **F2's `model-guard.sh` must contain the string to guard against it**, so under the plan's scan that hook can never pass validation — the check makes its own enforcement mechanism unwriteable.
**Apply**: match assignment positions only — model-bearing JSON values (`.aliases`, `.pinned`, `.session.model`, `.agents[].model`; `.model` in settings.json) plus lines that are model assignments under `.claude/`. Prose is not configuration.
**Second-order trap, also fixed**: implement the check by capturing hits into a variable and testing it. Under `set -o pipefail`, a `{ producers; } | grep -q .` form is silently skipped whenever an inner producer matches nothing and exits 1 — the guard reports clean while doing nothing.
**Verify**: five poison vectors each exit 2; a clean config exits 0; prose mentions do not trip it.

**C-06 status note:** superseded by C-09. EX-02 fixed the filename-vs-line bug inside the old `grep -ril` form; EX-03 then replaced that form entirely with assignment-position matching, under which the bug cannot occur. The detector reports SUPERSEDED rather than PENDING — a correction whose detection pattern legitimately disappears when a better fix subsumes it must not read as regression.

## Working note — detectors must test code, not comments
Four separate red gates in this build came from a check matching text that *documents* the thing being checked rather than the thing itself: the validator's own absolute-path pattern, a Plan.md sentence quoting it, the rule file documenting the fable prohibition, and this detector matching a stale comment in `apply-models.sh`. The lesson generalises: **any check that greps for a defect signature must strip comments and must not scan prose files.** A guard that trips on its own documentation trains people to ignore it, and a guard that goes green because its target moved into a comment is worse than none.

## Working note — `set -o pipefail` and exit-2 guards
Three separate failures in this build came from testing a pipeline's status when a stage legitimately exits nonzero:
1. `apply-models.sh`'s HC-2 guard used `{ producers; } | grep -q .`; a non-matching inner producer exited 1, pipefail marked the pipeline failed, and the guard was skipped entirely while reporting clean.
2. `check-plan-corrections.sh` passed JSON as printf's *format string*; `\"` escapes were eaten, the payload became invalid JSON, and a working guard looked broken.
3. `run-crew-tests.sh`'s `denies()` piped into `grep -q`; the guard's deliberate `exit 2` poisoned the pipeline and every denial test reported failure.

**Rule: capture into a variable, then test it.** Never branch on the exit status of a pipeline containing a stage whose nonzero exit is meaningful. And pass JSON payloads as printf *arguments* (`printf '%s' "$json"`), never as the format.

## C-10 — a binding rule that no phase step ever writes (F3)
**Plan says**: `CLAUDE.md` (§4.1, byte-pinned) declares "every agent obeys .claude/rules/fallback-protocol.md", and §5.2.1 supplies that file's payload verbatim.

**Reality**: no step in §6 writes it. F0 step 3 writes the §4 payloads only; F3's step list is explicitly "rules 5.2.2–5.2.4". §5.2.1 falls between the two assignments and was never allocated to a phase, so the file did not exist through F0, F1 and F2 while CLAUDE.md and every agent contract referenced it as binding.

**Why it matters**: a binding rule absent from disk is a dangling contract — agents are instructed to obey a file they cannot read, and the FALLBACK block, which is the mechanism this entire build uses *instead of guessing*, has no definition to point at. Nothing failed loudly only because no agent existed yet to dereference it. F3 is the first phase where that stops being true, which is why it is corrected here rather than deferred.

**Apply**: extract §5.2.1 verbatim to `.claude/rules/fallback-protocol.md`, Bash-only — the payload's numbered anti-skip items are prose-sensitive and a formatter pass would renumber or rewrap them.

**Verify**: the file exists and carries the FALLBACK block schema.

## C-11 — the broker pattern is unexecutable as specified (F3, P0, BLOCKING G-F3)
**Plan says**: §5.1.1 (verbatim) grants the arbiter `tools: Read, Grep, Glob, Write`, and its body states "Leads send you DISPATCH blocks; you fan work out to specialists". §5.2.2 makes the arbiter the *sole* permitted dispatcher: "Leads MUST NOT invoke the Task tool on any specialist directly."

**Reality**: no agent in `.claude/agents/` holds `Agent` or `Task` — measured, not assumed. The arbiter is contractually the only component allowed to dispatch and is provisioned with no tool capable of dispatching. Leads are forbidden from dispatching and also lack the tool. **Every hop of `lead → arbiter → specialist` has zero dispatch capability.**

**Why it matters**: the broker is this build's central design bet — CLAUDE_DESIGN item 2 ("specialists' outputs are never consumed raw by leads") and the entire §5.4 discourse pipeline rest on it. As written, the crew can define agents but cannot route work through the architecture that justifies them. Nothing failed loudly through F0–F2 because no dispatch had ever been attempted.

**Proven live at G-F3**: the arbiter received a well-formed DISPATCH, passed ORDER CHECK, then returned a FALLBACK at confidence 0.97 stating it could not execute the fan-out, and explicitly refused to fabricate specialist packets. It recorded the dispatch to `logs/arbiter-audit.jsonl` with `original_sha256: UNAVAILABLE(no-hash-tool…)` rather than inventing a plausible digest. The agent behaved exactly to contract; the contract is what is broken.

**Apply (operator decision — this is a permission-boundary change)**: `.claude/rules/security.md` forbids widening a grant without a gate, and §5.1.1 is a verbatim payload, so a fix needs a logged exception in the EX-01 style. Option A: add `Agent` to the arbiter's tools line ONLY, leaving every lead and specialist without it — which converts the dispatch law from an assertion into a structural guarantee, since the arbiter would become the only component physically able to dispatch. Option B: the orchestrator performs fan-out and the arbiter normalises returned packets — proves normalisation and audit but NOT the interception boundary, and must be recorded as partial G-F3 evidence.

**Verify**: `grep '^tools:.*Agent' .claude/agents/arbiter.md` matches, and no other agent file does.

## Working note — the coverage check is live, and it caught the orchestrator
The arbiter also reported that C-05's coverage check passes vacuously at `0 >= 0` because no agent can dispatch. That reasoning was sound but incomplete: it could only see crew agents. The **orchestrator session** dispatches too, and those calls are logged as `"tool":"Agent"` in `logs/tooluse-audit.jsonl`. Measured immediately after the G-F3 attempt the check reported `FAIL: 2 dispatches, 1 arbiter lines` — a true positive against the orchestrator, which had to bypass the arbiter precisely because C-11 makes arbiter-routed dispatch impossible. The check works. The vacuity risk is real only in the case where dispatch count is genuinely zero, and it should be re-examined once C-11 is resolved.
