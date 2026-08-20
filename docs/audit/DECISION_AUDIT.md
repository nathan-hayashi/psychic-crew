# DECISION_AUDIT.md — A2

What was decided, why, what was weighed and dropped, and whether a living control still enforces
it. Evidence labels as defined in `FINAL_AUDIT_REPORT.md`.

> **Line numbers in this document are as of the audit, 2026-08-17, and have since moved.**
> Sessions S1–S4 edited the files they cite, so a `file.sh:NNN` reference lands elsewhere today.
> They are left unchanged deliberately: each records where a defect *was found*, and re-pointing it
> at current code would describe a present it was never about. Locate by the quoted content, which
> is stable. (CR-033, 2026-08-20.)

---

## A2.1 The decision register

### Q0 — the seven opening answers (operator, 2026-08-11T03:41:25Z) `[E]`

Recorded verbatim in `Plan.md §Q0-Answers`, as §3 requires.

| Q   | Operator answer (verbatim)                      | Decision                                                                           | Still holds?         |
| --- | ----------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------- |
| Q1  | "Name it the "Psychic Crew" and make it public" | PUBLIC, renamed. Overrode the plan's private default. Name scope escalated as OQ-5 | yes                  |
| Q2  | "Defer the secrets"                             | Secrets backend deferred post-build; env + `.gitignore` discipline                 | yes — still deferred |
| Q3  | "Yes re-use desktop hooks"                      | Reuse the existing notify command                                                  | yes                  |
| Q4  | "joiner mover leaver … pokemon theme"           | JML simulator with a fixture-level persona overlay; semantics unchanged            | yes                  |
| Q5  | **"45 min"**                                    | 45-minute wall ceiling per phase                                                   | **see A2-F1**        |
| Q6  | "accept"                                        | Roadmap order IAM → Compliance → HR-lifecycle → ITSM → rest                        | yes, unexercised     |
| Q7  | "pre-authorize"                                 | §11 soft-ETL transforms pre-authorised for their phases                            | yes, spent           |

### A2-F1 — the axis that produced two operator rulings was never affirmatively chosen

**P2 · decision provenance · Failure scenario:** a future phase inherits the 150K token ceiling as
though it were a considered budget, fails against it exactly as F7 did, and consumes another two
rounds of operator adjudication to resolve a default nobody selected.

Q5 asked for "hard ceiling per phase before mandatory early gate — default 150K tokens or 45 min,
whichever first. Accept/override?" The operator answered **"45 min"** — the wall limb only.
`Plan.md` records the consequence explicitly `[E]`: "§3's default pairs that with 150K tokens
'whichever first'; **the token limb is retained as co-limit since it was not overridden — say the
word to drop it.**"

The offer to drop it was made and never taken. The token limb therefore entered the build as an
un-chosen default, and it became:

- the denominator of §7's Velocity axis,
- the subject of **C-18** (a rubric ceiling smaller than the phase's own budget),
- the subject of **C-20** (unsatisfiable by construction — 18 mandated dispatches × the 46,388
  cheapest observed = 834,984, still 4.03× the revised 207K denominator),
- and the subject of **two separate operator rulings**, at G-F7a and G-F7b.

Every downstream analysis is sound. What is missing is the record that the number at the bottom of
it was a default carried forward with an open invitation to remove it. That is worth stating
plainly, because the natural reading of "the operator set a 150K ceiling" is not what happened.

### EX-01 … EX-05 — the five exceptions `[I]`

| ID    | What it permits                                                                      | Why                                                                                                                       | Living control                                          |
| ----- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| EX-01 | `MASTER_FIFO_PLAN_CLAUDE.md` never edited; seeds carry exactly one renamed line each | Standing operator decision: the authority stays identical to the canonical copy. The rename could not be applied upstream | `cases_F0` asserts the 0/1/1 changed-line counts        |
| EX-02 | `apply-models.sh` HC-2 scan fixed in the artifact, not the plan                      | The plan's `grep -ril` form fails on a clean repo                                                                         | C-06 detector (now SUPERSEDED)                          |
| EX-03 | HC-2 scan narrowed to assignment positions                                           | A bare substring scan makes `model-guard.sh` unwriteable — the guard must contain the string to guard against it          | C-09 detector                                           |
| EX-04 | `Agent` granted to `arbiter.md` only                                                 | Would have made the broker structural rather than asserted                                                                | **reverted — the runtime refused it**                   |
| EX-05 | The law restated as consumption, not routing                                         | Nested dispatch does not exist; the original law asserted a property the runtime cannot provide                           | C-11 detector + identity coverage in `validate-crew.sh` |

**EX-04 is the one worth carrying forward.** It was proposed, approved, implemented, and then
proven inert — the runtime rejected the tool for subagents at any depth. The recorded lesson is
exact and generalises: _a permission grant the platform ignores is worse than no grant, because
the audit reads as protected._ The detector was rewritten in response to require evidence of a real
`RELEASE` in the audit log rather than the presence of a `tools:` line, which is the correct
response and a model for the rest of the registry.

### The two Velocity rulings `[E]`

| Ruling | When                 | Substance                                                                                                                                                                                        |
| ------ | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| G-F7a  | 2026-08-13T14:39:23Z | The **wall** limb is a gate trigger, not a pass/fail bar. Denominator fixed at **207K** pre-run, superseding Q5's generic 150K (C-18)                                                            |
| G-F7b  | 2026-08-14T00:56:07Z | Option A: apply the same reading to the **token** limb. Velocity PASSES because the ceiling did its job — F7 gated at G-F7a, at the HC-2 hold, at the Stage A/B split and across ten checkpoints |

Both are consistent, and the sequence matters: the denominator was fixed **before** the spend was
known. `Plan.md` records the alternative being refused in writing at the time — scoring against the
larger number after the fact would have made the metric self-scoring. The measurement was not
waived: 2,045,319 tokens across 18 dispatches, 9.88×, stands recorded.

### The branch-layout decision (2026-08-14) `[E]`

No `main` branch exists or will be created. `dev` is the remote default and the only branch in the
repository's history; `v1.0.0` marks the release. Verified still true at A0 — `git branch` shows
`dev` alone. Recorded in four places specifically so a later session does not read the absence as
an oversight and "fix" it.

---

## A2.2 The detectors, audited

`scripts/check-plan-corrections.sh` reports 20 rows `[E]`. Each was audited by the practical test
the build itself established: **name the file that would differ if the defect were real, and
confirm the detector reads that file.** A detector that passes without binding to its artifact is a
finding even when green.

| ID   | Artifact that would differ if the defect were real   | Detector reads it?                                   | Verdict                   |
| ---- | ---------------------------------------------------- | ---------------------------------------------------- | ------------------------- |
| C-01 | `.claude/settings.json` hook entry shape             | yes — `jq` on structure, not text                    | **bound**                 |
| C-02 | `.claude/settings.json` event key                    | yes — `jq … has("PostToolUseFail")`                  | **bound** (but see A2-F3) |
| C-03 | the three guards' emitted JSON                       | yes — **executes** each with a real denial payload   | **bound, exemplary**      |
| C-04 | effective ignore state                               | yes — asks `git check-ignore`, not the file          | **bound**                 |
| C-05 | `validate-crew.sh` + `arbiter-protocol.md`           | yes, comment-stripped for the script                 | **bound**                 |
| C-06 | `apply-models.sh`                                    | yes, comment-stripped                                | **bound**                 |
| C-07 | `apply-models.sh`                                    | yes — **not** comment-stripped                       | weakly bound              |
| C-08 | `apply-models.sh`                                    | yes — **not** comment-stripped                       | weakly bound              |
| C-09 | `apply-models.sh` + `validate-crew.sh`               | mostly; the `HITS=` limb is not comment-stripped     | weakly bound              |
| C-10 | `.claude/rules/fallback-protocol.md`                 | yes — existence and content                          | **bound**                 |
| C-11 | `logs/arbiter-audit.jsonl` `.mutation` field         | yes — field-level `jq`, excludes FAIL/FALLBACK       | **bound, exemplary**      |
| C-12 | `validate-crew.sh` coverage logic                    | **no — see A2-F2**                                   | **PROXY**                 |
| C-13 | the provenance hook's behaviour                      | yes — fires it twice, positive and negative control  | **bound, exemplary**      |
| C-14 | `logs/tooluse-audit.jsonl` task ids                  | yes — `jq` against an enumerated fixture set         | **bound**                 |
| C-15 | `PROGRESS.md` after firing the hook                  | yes — behavioural, sentinel-based, temp root         | **bound, exemplary**      |
| C-19 | `arbiter.md` schema + `validate-crew.sh` enforcement | partly — binds to message strings, not the predicate | weakly bound              |
| C-20 | `context/budget-baseline.md` rows                    | yes — counts per-role rows                           | **bound**                 |
| C-21 | `measure-dispatch-cost.sh` **output**                | **no — see A2-F4**                                   | **PROXY**                 |
| C-22 | `portability-drill.sh`                               | yes, comment-stripped, fragment-assembled pattern    | **bound**                 |
| C-23 | `validate-crew.sh`                                   | yes, comment-stripped                                | **bound**                 |

Fourteen of twenty are properly bound and four of those are exemplary — C-03, C-11, C-13 and C-15
all **execute** the thing under test and assert on its behaviour rather than its text. C-11's and
C-13's comments record that each was rewritten _away_ from a text proxy after the first cut
reported APPLIED against prose. That is the registry working as intended.

Two are proxies, and both were demonstrated rather than argued.

### A2-F2 — the C-12 detector is satisfied by comments, which is the defect C-12 exists to record

**P1 · control binding · Failure scenario:** the identity-correlation logic in `validate-crew.sh` is
reverted to counting — accidentally, or by a future refactor — while the explanatory comments
remain. `check-plan-corrections.sh` reports `C-12 APPLIED`, the gate passes, and the bypass
detection this build calls its weakest enforcement point is silently back to a state the audited
party can satisfy by writing lines.

The detector is one line:

```sh
if grep -q 'task_id' scripts/validate-crew.sh 2>/dev/null; then
  report C-12 F3 APPLIED "bypass coverage correlates dispatch identity, not raw line counts"
```

It is **not comment-stripped**, and it tests only that the string `task_id` occurs somewhere in the
file. Measured `[E]`: 9 raw occurrences, 6 in code, **3 inside comments**.

**Negative control, executed** `[E]`: a copy of `validate-crew.sh` with every non-comment line
mentioning `task_id` removed — 0 code occurrences remaining, the entire correlation gone — still
satisfies the detector, because the 3 comments survive. The detector reports APPLIED against a file
that no longer performs the check.

Three things make this the most serious finding in A2:

1. **C-12 is the correction about exactly this class.** Its registry text reads: "the bypass
   detector is satisfiable by the thing it audits … **Counting is not correlating.**" Its own
   detector is satisfiable by prose.
2. **The registry names the rule and this detector breaks it.** The working note "detectors must
   test code, not comments" states that four separate red gates came from this shape, and mandates
   comment-stripping. Eight other detectors in the same file do strip comments — `$CODE_VC`,
   `$CODE_AM`, and the explicit `sed 's/#.*//'` in C-19, C-22 and C-23. C-12 does not.
3. **The underlying enforcement is genuinely correct.** `validate-crew.sh:161-166` really does
   extract `task_id` sets from both logs and correlate by identity `[E]`. Nothing is broken today.
   What is missing is a detector that would notice if it stopped being true — which is the entire
   purpose of the registry.

### A2-F4 — the C-21 detector checks a file mode, not a measurement

**P2 · control binding · Failure scenario:** `measure-dispatch-cost.sh` is emptied, broken by a
transcript-format change, or made to emit nothing. It remains present and executable, the detector
reports APPLIED, and the HC-8 inversion C-21 was opened to close is quietly reopened.

The detector is `[ -x scripts/measure-dispatch-cost.sh ]`. The registry's own **Verify** line for
C-21 says something materially stronger `[E]`:

> `./scripts/measure-dispatch-cost.sh` exits 0 and its F7 total matches the figure in
> `context/budget-baseline.md`.

The detector does neither. It never invokes the script — 0 invocations in the file `[E]` — and
compares nothing. **Negative control, executed** `[E]`: a two-line executable stub containing only
a shebang satisfies it.

This one is easy to fix and the fix is already written: the registry states the assertion, so
implementing the stated Verify closes it. The gap is between what the registry promises and what
the checker performs.

### A2-F3 — C-02 can only prove the absence of the wrong name, not the presence of a right one

**P2 · correctness, pending verification · Failure scenario:** `PostToolUseFailure` is not a real
hook event either. `hooks/error-recovery.sh` has never executed, C-02 reports APPLIED forever, and
every claim resting on error-recovery behaviour is void.

C-02 recorded that `PostToolUseFail` does not exist and that the real name is `PostToolUseFailure`.
The detector asserts `.hooks | has("PostToolUseFail") == false`. That is a correct test of the
stated correction and it cannot test the corollary: **it never asserts that the replacement name is
valid.** `.claude/settings.json` wires `PostToolUseFailure` to `hooks/error-recovery.sh` `[E]`,
and nothing in the repository confirms the platform recognises it.

Carried to A3 as a named `[V?]` target. If the event name is wrong, this is the same defect C-02
described, surviving its own correction.

### A2.2b Minor binding gaps

**C-07, C-08, and C-09's `HITS=` limb grep the raw file** while C-06 in the same block uses the
comment-stripped `$CODE_AM` `[E]`. Same file, same defect class, inconsistent treatment. Low
severity — the patterns (`if \$m=="pinned"`, `for a in \$\(jq`) are unlikely to appear in a comment
by accident — but the inconsistency is the kind that gets copied.

**C-19 binds to message strings.** Comment-stripping leaves two hits, both inside `fail`/`pass`
message text rather than in the `jq` predicate that does the work. The enforcement it guards is
sound — a real ISO-8601 regex, phase-enumerated grandfathering, both branches present
(`validate-crew.sh:188-203`) — but the detector would survive deletion of the predicate if the
message line were kept.

---

## A2.3 Reverse pass — decisions nobody wrote down

Walked `scripts/`, `hooks/` and `stress-project/` for magic numbers, hardcoded paths and silent
defaults.

**Clean:** no absolute machine paths anywhere in tracked scripts `[E]`. The only absolute path is
`/usr/local/bin` inside a `PATH` export in `hooks/_common.sh`, which is correct. Every other path
resolves through `$HOME` or `$CLAUDE_PROJECT_DIR`.

**Two apparent findings dissolved on reading, and both are recorded because the reasoning is the
point:**

- `hooks/_common.sh:36` — `cut -c1-200` looked like the length-limit-as-redaction defect SEC-DG-01
  named. It is the **fixed** form: five `sed` redaction patterns run first and the truncation is
  second, with a comment stating exactly that, plus a fallback emitting
  `[REDACTED-SCRUB-UNAVAILABLE]` if scrubbing yields nothing `[E]`. Correct and documented.
- `hooks/provenance-flag.sh:52` — `cut -c1-90` is not a threshold at all; it truncates the _sample_
  written into the log message.

### A2-F5 — the provenance hook's span threshold is an undocumented security tuning constant

**P3 · undocumented decision · Failure scenario:** someone tunes the value to reduce noise, or
copies the hook, without knowing the trade-off it encodes — too low and every common phrase flags,
too high and a real relayed span passes unnoticed.

`hooks/provenance-flag.sh:50` is `[ "${#span}" -ge 60 ] || continue`. Sixty characters is the
minimum span length that counts as relayed third-party text. The surrounding comments are unusually
good — they explain the attribution short-circuit, why malformed packets fall back to a regex
instead of being skipped, and why spans are split at sentence boundaries `[E]`. They say nothing
about why 60.

C-13's registry entry records that the value was arrived at empirically: matching whole written
lines found nothing because relayed text arrives embedded in sentences, and matching whole field
values let a partial paste evade, so spans were split at sentence boundaries and measured at 5/5
behavioural cases with 0 false positives across five real ledger files. **That measurement is the
justification for 60 and it is not connected to the number.** A reader at the hook cannot find it;
a reader at the registry cannot tell which constant it produced.

Related, and fair to state: the C-13 detector's fixture selects spans with `length>=90`, above the
hook's 60 `[E]`. The two constants are independent. If the hook's threshold rose past 90 the
fixture would stop triggering and C-13 would report PENDING — **the coupling fails safe**, which is
the right direction and appears to be luck rather than design, since neither number references the
other.

---

## A2.4 Included vs excluded — and whether the reason still holds

`ReportforClaudeWeb.txt` §5 is the only record of what was weighed and dropped, and that file is
gitignored — it does not survive a clone. It is carried into the repository here, with each
exclusion re-checked against today's ground truth.

| Excluded                                     | Recorded reason                                                                                                                                     | Still holds?                                                                                                                                     |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Arbiter dispatch tool** (EX-04)            | Built and approved; runtime refused it for subagents at any depth                                                                                   | **yes, permanently.** Platform constraint, not configuration. No exception can lift it                                                           |
| **Widening the deny-list for the G-F8 demo** | The guard cannot distinguish self-cloning from pulling external code                                                                                | **yes.** `portability-drill.sh` proves the property two stricter ways (C-22)                                                                     |
| **Editing the plan to fix its own defects**  | Standing operator decision; divergences stay visible and counted                                                                                    | **yes.** EX-01 intact; verified byte-pinned at A0                                                                                                |
| **Re-scoring Velocity after the fact**       | Choosing a denominator after seeing the spend makes the metric self-scoring                                                                         | **yes.** Refused in writing before the number was known                                                                                          |
| **A `main` branch**                          | Offered, declined, recorded (decision 4.4)                                                                                                          | **yes.** Verified: `dev` is the only branch `[E]`                                                                                                |
| **Cross-model review tooling**               | Installing it violates HC-5; HC-7 forbids non-Claude invocation                                                                                     | **yes.** Both constraints unchanged                                                                                                              |
| **Event-automation lanes**                   | The runtime is an interactive CLI on a workstation; the human-gate cadence fits that                                                                | **yes**, and the gating facts (separate billing, beta status, retention eligibility) are decision inputs for a future roadmap item, not blockers |
| **A peer-review lane**                       | Designed in full, not built. The hard part is the independence contract — partial or empty peer output must be a FAILURE, never synthesised locally | **yes**, and the design note is the valuable part: this is the failure mode that makes a peer lane worse than none                               |
| **MCP servers / all install-shaped options** | Excluded by HC-5                                                                                                                                    | **yes.** Lifting it changes the constraints, not the roadmap                                                                                     |
| **Secrets backend** (Q2)                     | Deferred to post-build; env + `.gitignore` discipline now                                                                                           | **yes**, still deferred and still unexercised — the repo holds no secrets                                                                        |

### A2-F6 — one exclusion's ground truth has moved, and the repository says so in five places without acting

**P2 · stale premise · Failure scenario:** none immediate. The risk is the opposite of a defect —
a correct decision whose justification has expired stays in force by inertia, and the largest
available upgrade goes unmade because nothing forces a re-decision.

**Hook-enforced bypass detection (C-05).** The plan's §5.2.2 assumed hooks "cannot reliably"
attribute caller identity, so bypass detection is audit-based: caught at the gate, not blocked at
the call. That assumption is recorded as outdated in **five** tracked locations `[E]` —
`context/plan-corrections.md` C-05, `.claude/rules/arbiter-protocol.md` ("Known weakness — stated,
not hidden"), `README.md:114`, `context/session-summary.md:41`, and `ROADMAP.md` — each stating
that `SubagentStart`/`SubagentStop` carry `agent_type`, which would make attribution deterministic.

Every one of those five is honest. None constitutes a decision. The exclusion's stated reason no
longer holds; what holds is a different reason — that adopting it is a permission-boundary change
requiring a gate. Those are not the same, and the documents mostly record the first.

The `agent_type` claim itself is `[S]` throughout — stated by the repository, never verified
against the platform in any artifact here. Carried to A5 as a `[V?]` to resolve before the CR is
drafted, because the entire upgrade rests on it.

---

## A2.5 The count that propagated

`Plan.md`'s G-F8 closing entry says "23 numbered plan-vs-reality corrections registered". A0
established the registry holds 22 IDs and the checker reports 20 rows, and that 23 is what you get
by reading the highest identifier rather than counting entries.

That figure has since propagated into three more tracked or delivered locations `[E]`:

| Location                      | Text                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| `Plan.md` G-F8 entry          | "23 numbered plan-vs-reality corrections registered"         |
| `README.md:28`                | "plan-vs-reality registry, 23 entries"                       |
| `README.md:117`               | "23 numbered places where the plan and reality disagreed"    |
| `ReportforClaudeWeb.txt` §5.3 | "Twenty-three defects were found in the execution authority" |

Two of the four are in the public README, which is the first thing a reader of this repository
sees. The correction is small; that it reached four documents unchallenged is the part worth
recording, and it is why A0-F1 is filed against the registry's integrity rather than as a typo.
