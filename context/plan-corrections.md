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
| C-13 | DIRECTORY_GUIDE Navigation rule vs §0.2d | F4 | hooks/*.sh behaviour |

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

**C-11 RESOLVED as EX-04 (operator-approved, 2026-08-11).** `Agent` added to `.claude/agents/arbiter.md` and to no other agent. This is deliberately the *narrowest* possible widening: because the arbiter is now the only component holding a dispatch tool, §5.2.2's "leads MUST NOT invoke the Agent tool on any specialist directly" changes from a rule a lead could break into one it physically cannot. The plan's self-declared weakest enforcement point — audit-based bypass detection — is upgraded to structural prevention. `cases_F3` asserts the exclusivity, so a future phase that grants `Agent` to a second agent fails the gate rather than silently re-opening the hole.

## C-11 REOPENED — EX-04 is inert; nested dispatch is disabled at runtime (F3, P0)
EX-04 added `Agent` to `.claude/agents/arbiter.md` with operator approval. The runtime refused it: **"No such tool available: Agent. Agent is disabled for this session, in subagents as well as here."** The orchestrator session can dispatch; a subagent cannot, at any depth.

**A frontmatter grant is a declaration, not a capability.** The disk state now looks correct and the fan-out still cannot happen — precisely the failure mode that is invisible to file inspection. C-11's detector was therefore changed to require evidence of a real RELEASE in `logs/arbiter-audit.jsonl`, not the presence of the tools line.

Consequence: **Option A (arbiter as sole dispatcher) is not implementable in this environment.** The broker cannot be structurally enforced by tool exclusivity, because the only component permitted to dispatch is a subagent, and subagents cannot dispatch. This is a platform constraint, not a configuration error, and no exception can lift it.

## C-12 — the bypass detector is satisfiable by the thing it audits (F3, P0)
`scripts/validate-crew.sh` compares the COUNT of `Agent` tool calls in `logs/tooluse-audit.jsonl` against the COUNT of lines in `logs/arbiter-audit.jsonl`. It never correlates *which* dispatch each arbiter line covers, so any N arbiter lines satisfy any N dispatches — **the audited party can turn its own auditor green by writing lines.**

Observed live at G-F3, not theorised: the arbiter's two failed `Agent` calls produced zero `tooluse-audit` entries, because PostToolUse cannot fire for a tool that never executed. `d` stayed 3 while the arbiter's two truthful lines took `c` from 1 to 3, and the coverage check flipped from a true-positive FAIL to PASS with nothing remediated. The arbiter flagged this against its own interest rather than exploiting it.

This is the third instance of one family in this build: F2's `deny()` blocking without a record, the validator matching its own documentation, and now a counter-based control satisfiable by the audited party. **Counting is not correlating.**

**Apply**: key each arbiter audit line to the `task_id` it covers, and match dispatches to lines by identity. Additionally log tool-call ATTEMPTS rather than only PostToolUse successes, so a dispatch that never executes remains visible to the auditor instead of vanishing from the denominator.

**Verify**: `scripts/validate-crew.sh` correlates on `task_id`; a synthetic extra arbiter line does not turn an uncovered dispatch green.

## C-13 — nothing inspects CONTENT bound for the continuity files (F4, operator decision; DEFERRED from F3-D1)

**Source**: SEC-DG-03, arbiter-released at F3-D1, severity `med` (§ security.md: untrusted input reaching a position where it can influence control flow, no demonstrated exploit). Deferred by the fixer, not rejected.

**DIRECTORY_GUIDE.md says** (Navigation rule, L21): "any fix or anomaly -> append to Plan.md first (what/where/why/fix), then act."

**Reality**: `Plan.md`, `PROGRESS.md` and `context/*` are re-read as authoritative continuity at every session start and every post-compaction turn (CLAUDE.md HC-8, §15.4). Text that arrives as *data* — a specialist packet, ETL source material, a build tool's error string, relayed cross-session output — is quoted into Plan.md by that rule and, on the next read, is indistinguishable from the build's own directives. `hooks/sensitive-guard.sh` is the only PreToolUse guard that looks at `tool_input` beyond the model surface, and it matches **path globs** (`*.env`, `*/secrets/*`, `*/.ssh/*`) plus three `.gitignore` removal strings. **No hook reads content bound for the continuity files.** §0.2d forbids treating such text as commands, but a rule is precisely what an injected imperative attacks, and this build's own standing lesson is that a control must bind to the artifact.

**Why it is deferred rather than fixed at F3**: both available fix paths leave F3's scope.
1. Annotating DIRECTORY_GUIDE.md is blocked by **EX-01**, which permits exactly one line of delta and is asserted by `cases_F0`. (The blocked second half of SEC-DG-01 — the `logs/` annotation — is blocked by the same rule and rides here.) Both belong to EX-01's retire path: a v2.4 re-export with the rename applied upstream.
2. Adding or rewiring a PreToolUse hook in `.claude/settings.json` changes the enforcement layer mid-gate; `.claude/rules/security.md` makes that an operator decision at a gate, never a quiet commit.

**Apply (operator decision at G-F4, two axes)**:
- *Block or flag.* A denying check is the stronger control and the more dangerous one: an imperative-shaped-text rule aimed at Plan.md would block the Fix Ledger entries that quote findings verbatim, which is a self-inflicted outage on the live log. A flagging check that writes a `PreToolUse.flag` audit record preserves the trail and the append rule.
- *Provenance or keywords.* A keyword list will trip on this very entry, on the arbiter's quarantine notes and on the §0.2d rule text — the sixth instance of the guard-trips-on-its-own-documentation family already recorded here. Prefer binding to structure: require quoted untrusted material to be fenced and attributed, and flag unfenced imperative text that arrives in the same write as a source citation.

**Verify**: a Write payload aimed at `Plan.md` carrying an unfenced injected imperative produces a mechanical reaction from some wired Write|Edit guard — a deny JSON or an audit record. The detector asserts the reaction, not the presence of a scanner, so a scanner that exists and does nothing still reports PENDING.

## C-14 — tests wrote to the artifact they audit (F3)
Sixth instance of one family. The fixer's C-12 regression fixtures fed synthetic `Agent` payloads to `hooks/audit-logger.sh` with the **live** repo as `ROOT`, appending four fabricated dispatch records (`task_id: scrub-regression`) to `logs/tooluse-audit.jsonl`. Those records described dispatches that never happened, and the coverage check correctly failed on them — the guard was right, the data was fiction. Its mutation testing (reverting both writers to pre-fix bytes, re-running, restoring) additionally wrote unscrubbed synthetic tokens into the same live trail; the fixer disclosed the fabricated dispatches but not this second half.

**Why it matters beyond tidiness:** an evidence trail containing invented events is worse than one with gaps, because every downstream check and every gate report treats it as ground truth. The same fixtures could equally have written *convenient* records.

**Applied**: the fixer moved all six fixtures to a `mktemp -d` root. The four fabricated records were removed by the orchestrator and the removal was itself written to the trail as an `AuditRedaction` event — a redaction that is not recorded is indistinguishable from tampering. Genuine records were retained, including the mutation-test commands whose tokens are synthetic.

**Verify**: no audit record carries a fixture-shaped `task_id`.

**C-13 RESOLVED (F4, operator-directed: FLAG + PROVENANCE).** `hooks/provenance-flag.sh`, wired PostToolUse[Write|Edit], never blocks.

Keywords were rejected on measurement, not principle: "ignore" occurs 7× in `Plan.md` and 6× in this file, "skip" 9/3/5 — a keyword guard would have fired ~35 times on legitimate prose and, inevitably, on the §0.2d rule text and on this entry. That would have been the seventh instance of a guard tripping on its own documentation.

Provenance is implemented as **source correlation**: a ledger write is compared against the untrusted corpus on disk (`logs/rounds/`), and shared verbatim text means third-party material was relayed into a continuity file that later sessions read as authoritative. Attribution suppresses the flag, using the convention already in organic use at `Plan.md`'s "Handling note (§0.2d)" entry — the guard enforces a practice the build had already invented by hand.

Two defects were found by testing rather than reasoning: matching whole *written* lines against the corpus found nothing, because relayed text arrives embedded in a sentence (the comparison direction was backwards); and matching whole field values let a partial paste evade it, which is the likelier relay. Spans are now split at sentence boundaries. Measured: 5/5 behavioural cases pass, 0 false positives across all five real ledger files.

**Honest limits:** verbatim text only — paraphrase is not detected, because paraphrase already implies a judgement was applied. And it flags *after* the write, by design.

## Working note — `set -o pipefail`, fourth instance (F5)
An F5 assertion ran `./scripts/save-context.sh prepare | grep -q 'DISTILL INSTRUCTION'`. `grep -q` exits on the first match and SIGPIPEs its producer, so `pipefail` reported a *failed* pipeline for a pattern that had matched — the assertion declared a working script broken. Identical in shape to the three already recorded (apply-models' HC-2 guard, check-plan-corrections' printf-as-format JSON, `denies()` in the suite).

The rule was already written in this file and was still violated while adding a test. That is the useful datum: a documented rule does not enforce itself. **Capture into a variable, then test it.**

## C-16 — the deny-list had no integrity check (F6, found by the G-F6 mutation test)
The G-F6 stress removed one entry from `.claude/settings.json` `permissions.deny`. The suite reported a failure — but the failure was **"working tree dirty"**. `validate-crew` itself reported zero. The mutation was caught by the dirty-tree canary noticing a file had changed, not by anything that understood what changed. Committed, the removal would have been invisible to every check in the build.

That is "caught for the wrong reason", the same family as the six already recorded. A permission boundary with no integrity assertion is not a boundary; it is a comment.

**Applied**: `validate-crew.sh` now asserts the HC-5 deny set is present by meaning — clone, global install, npx, sudo, the destructive removals and the raw-device write — plus at least two secret-path `Read(` denials. Re-running the mutation now yields `deny-list missing: [<entry>]` by name.

**Implementation note worth keeping**: the needles are assembled from fragments because `bash-blocker` matches the *whole command string*, so a contiguous literal in this check would deny any command that greps or edits the file containing it. Two attempts at this edit were denied before the fragments went in. Also: `$S` is validate-crew's SKIP counter, not a settings path — reusing the other script's convention made `jq` read a file named `0` and report every entry missing.

## C-17 — the mid-gate has a name but no token (F7, blocking G-F7a)
**Plan says**: §6 F7 names a mid-gate `G-F7a` and a final gate `G-F7b`, and §0.2 requires the exact token `APPROVE GATE-Fn` — case-sensitive, no substitutes, no inference of approval.

**Reality**: `n` is an integer everywhere in the grammar. Verified by enumeration: the only literal tokens the plan defines are `APPROVE GATE-F0` and `APPROVE GATE-F8`, plus the generic `APPROVE GATE-Fn`. No token for `G-F7a` or `G-F7b` exists anywhere in the plan, CLAUDE.md, or GATES.md. §6 invented two gate names its own token grammar cannot express.

**Why it matters**: §0.2 forbids inferring approval. An agent that guesses the token has invented a gate control — the single thing the FIFO machinery exists to prevent. lead-planner correctly refused to infer it and returned a FALLBACK at confidence 0.45.

**Apply**: the operator defines both tokens; they are recorded verbatim in the `G-F7a`/`G-F7b` ledger rows exactly as issued. Recommended for consistency with the gate names already in §6: `APPROVE GATE-F7a` and `APPROVE GATE-F7b`.

**Verify**: the `G-F7a` row's operator-token column contains the token verbatim, and it matches what the operator typed.

## C-18 — §7 judges F7 against a ceiling smaller than F7's own budget (F7)
**Plan says**: §7's numeric rubric includes `token spend ≤ Q5 ceiling`. Q5's ceiling is 150K tokens (or 45 min, whichever first).

**Reality**: §6 budgets F7 at **200K** and states it may span two sessions. So the phase's own authorised budget exceeds the ceiling the same plan judges it against — F7 fails that rubric axis before a line is written, regardless of execution quality.

**Why it matters**: a rubric axis that cannot be satisfied is not a bar, it is noise, and noise trains a reader to discount the whole rubric. It also invites the convenient fix — quietly scoring against the larger number at gate time — which would make Velocity self-scoring, the exact wrong-reason failure family recorded seven times in this build.

**Apply**: the phase-specific budget in §6 supersedes Q5's generic default for F7 (a specific provision beats a general one). The rubric denominator is F7's §6 budget as adjusted by the operator, recorded in `logs/metrics/f7.json` and the GATES.md row before the run, never chosen after the number is known.

**Verify**: the denominator appears in the ledger row and in the metrics JSON, and both were written before B10 computed the spend.

**C-18 RESOLVED (operator decision, recorded pre-run).** For F7: the wall ceiling is per SESSION and breaching it triggers an early gate rather than failing the phase (Q5's own wording is "hard ceiling per phase before mandatory early gate" — a gate trigger, not a pass/fail bar). The token denominator for §7's `token spend ≤ Q5 ceiling` is F7's §6 phase budget as adjusted by the operator, **207K**, superseding Q5's generic 150K. Both were fixed in the ledger before execution began; choosing either after the spend was known would have made Velocity self-scoring, which is the wrong-reason failure family this registry exists to catch.

**C-14 NARROWED (F7 A2).** The detector matched any `task_id` containing `regression|fixture|test-`, and the legitimate build dispatch `F7-A2-fixtures` tripped it — a genuine dispatch record read as test pollution, which failed the F3 gate spuriously. That is a NAMING proxy: it binds to an English word real work also uses, not to what actually indicates pollution. Now bound to an enumerated set of fixture ids (`scrub-regression|ccs02-probe|provenance-probe|c16-probe`). A new fixture id must be added to that list when introduced — the coupling is deliberate, it makes the guard's scope explicit rather than guessable. Negative control confirms a real `scrub-regression` record is still caught. Eighth instance of the over-broad-control family.

## C-20 — §7's token axis is unsatisfiable for the pipeline §6 mandates (F7)
**Plan says**: §7 requires `token spend <= Q5 ceiling`, and §6 budgets F7 at 200K (207K after the operator-accepted overrun).

**Reality**: §6 *also* mandates the full pipeline — 8 agents, lead-planner plan, six lead-executor build steps, two-round discourse with two parallel branches, arbiter compiles, fixer, test-runner, integration-runner. That is 18 dispatches, and §5.2.1 rule 6 makes the branch count a floor that may not be merged down. The cheapest dispatch observed in the whole phase was 46,388 tokens (test-runner, which mostly ran shell commands rather than reading source). **18 × 46,388 = 834,984 — 4.0× the denominator in the best conceivable case.** No execution, however efficient, could have satisfied the axis.

This is C-18 one layer deeper. C-18 was a rubric ceiling smaller than the phase's own budget; C-20 is the phase's own budget smaller than the floor of the pipeline the same section mandates. Two parts of one plan contradict each other, and the contradiction is only visible once you multiply the mandated dispatch count by a measured per-dispatch cost.

**Second, independent defect — the meter is the wrong unit.** `subagent_tokens` sums per-agent context, so the same ~27K of artifact source is counted once per reading agent (~8 of them, ~214K, 11% of the total) and it is INPUT, not work produced. A per-phase "budget" reads as single-session output — §10's own report template says "token spend est", singular. Summing multi-agent context against a single-session budget compares two different quantities.

**Applied**: none yet — operator decision. The available resolutions are (a) apply Q5's own wording consistently, (b) re-baseline the denominator from measured data, (c) accept the FAIL and gap-register per §6.

**The consistency argument for (a), stated because it is the operator's own prior ruling**: Q5 reads "hard ceiling per phase **before mandatory early gate**" — a gate TRIGGER, not a pass/fail bar. At G-F7a the operator already ruled exactly this for the wall-clock limb: breaching triggers an early gate rather than failing the phase. §7 converted the same ceiling into a threshold for the token limb only. F7 did gate repeatedly — a plan mid-gate at G-F7a, an HC-2 hold, a Stage A/B split, and ten checkpoints — so the mechanism the ceiling exists to trigger did fire.

**Verify**: the denominator recorded in `logs/metrics/f7.json` is reachable by the mandated dispatch count at the measured per-dispatch floor.

**C-19 RESOLVED (F8).** Root cause found at closure, and it was not where the correction assumed. `.claude/agents/arbiter.md` specified the audit line as `{"ts",...}` **without a format**, so the arbiter wrote a date-only `ts` while dispatch records in `logs/tooluse-audit.jsonl` carry full ISO-8601. Ordering was therefore undecidable by construction — not because coverage lacked a rule, but because the writer was never told to emit a comparable timestamp. Applied: `arbiter.md` now mandates `YYYY-MM-DDTHH:MM:SSZ` and names `task_id` in the schema (it was absent despite EX-05 requiring it); `validate-crew.sh` fails any arbiter line outside F0–F7 lacking the full form, with F0–F7 grandfathered by enumeration per the C-14 precedent. Negative control confirms a post-F7 date-only line fails. **Stated honestly: F7's own coverage stays ordering-undecidable forever** — the granularity was never captured and cannot be recovered. This closes recurrence, not the F7 gap.

**C-20 RESOLVED (F8) — operator ruling, option A, plus a measured baseline.** The operator applied Q5's own wording consistently: the ceiling is a gate TRIGGER, not a pass/fail bar, exactly as ruled for the wall-clock limb at G-F7a. Velocity passes on the ground that the mechanism fired. Separately, `context/budget-baseline.md` now records measured per-dispatch cost for 8 agent roles so a future phase is budgeted against observation rather than an authored guess. **Correction to the recorded figure:** F7's spend is **2,045,319 across 18 dispatches (9.88×)**, not 1,922,184 across 17 (9.3×). The 17-dispatch figure was explicitly labelled a lower bound with one dispatch unreported; that dispatch is recovered — `arbiter / F7-P1-jml-simulator-plan`, 123,135. The G-F7b verdict is unaffected; the number is now complete rather than partial. The unsatisfiability finding is unchanged: 18 × the cheapest dispatch observed (46,388) = 834,984, still 4.03× the 207,000 denominator.

## C-21 — the measurement the whole Velocity axis rests on was never written to disk (F8)
**Reality**: `logs/tooluse-audit.jsonl` records that a dispatch happened, never what it cost. Per-dispatch token counts existed only in the orchestrator's context window. C-18, C-20 and every §7 Velocity number descend from figures that no repo artifact could reproduce — at F8 they had to be recovered from session transcripts outside the repo.

**Why it matters**: this is the exact inversion HC-8 exists to prevent — disk is canonical, context is a cache — and it survived undetected to the handover phase inside the build whose central doctrine is that inversion. It also silently degraded the record: the roll-up carried "17 dispatches, one unreported" because the orchestrator was transcribing from memory of its own turns rather than reading a file. Recovery changed the headline number by 123,135 tokens.

**Applied**: `scripts/measure-dispatch-cost.sh` regenerates per-dispatch cost from the session transcripts, deduplicates the copied project store, writes `logs/metrics/dispatch-costs.tsv`, and is idempotent. It reproduces 18/2,045,319 for F7 independently of the ad-hoc recovery that found the number.

**Verify**: `./scripts/measure-dispatch-cost.sh` exits 0 and its F7 total matches the figure in `context/budget-baseline.md`.

**Residual, stated**: the source is still a transcript outside the repo, not a repo artifact. A dispatch cost is not knowable at dispatch time, so a hook cannot record it; the honest structure is a phase-end regeneration step, which is what this script is. F8 does not claim to have closed that gap, only to have made the measurement reproducible instead of transcribed.
