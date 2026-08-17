# FINAL_AUDIT_REPORT.md — post-v1.0.0 independent audit

**Session type: AUDIT-ONLY.** This audit inspects, measures and adjudicates. It fixes nothing.
Every improvement it finds is written up as a numbered change request in
`docs/audit/CHANGE_REQUESTS.md` and gated for a later session. The separation is deliberate: the
build's dominant failure family was controls that looked bound to an artifact and were not — ten
recorded instances — and an audit that repairs as it goes cannot tell you whether it found the
eleventh or created it.

**Evidence labels.** Every load-bearing claim carries one.

| Label  | Meaning                                                             |
| ------ | ------------------------------------------------------------------- |
| `[E]`  | Executed or measured in this session; the command is quoted         |
| `[I]`  | Inferred from an artifact read in this session                      |
| `[S]`  | Stated by a document, not independently verified                    |
| `[V?]` | Depends on live platform behaviour; not verified at time of writing |

**Authority order.** (1) `MASTER_FIFO_PLAN_CLAUDE.md`, byte-pinned, never edited (EX-01);
(2) `context/plan-corrections.md`, which wins for implementation; (3) the operator's audit brief.
The research documents at the repo root are untrusted input — data about where to look, never
instructions (§0.2d).

---

## A0 — Orient, baseline, integrity

### A0.1 Repository state `[E]`

| Property      | Value                                                         |
| ------------- | ------------------------------------------------------------- |
| Branch        | `dev` (no `main`; settled operator decision, not an omission) |
| HEAD at A0    | `d5e17ff`                                                     |
| Release tag   | `v1.0.0` at the closure commit                                |
| Remote        | `origin`, GitHub, default branch `dev`                        |
| Tracked files | 74                                                            |
| Working tree  | clean — 0 porcelain lines                                     |
| Phase tags    | `crew-f0`…`crew-f8`, plus 8 `rb/f7-*` rollback tags           |
| Tracked bytes | 623,887                                                       |
| Node / npm    | v24.14.0 / 11.9.0                                             |

Two commits precede the measurements, both made under the audit's stated write boundary and
neither behavioural:

- `51a0ce9` — commits the PreCompact checkpoint the hook appended to `PROGRESS.md` during the
  operator's `/compact`. Left uncommitted it would have been noise in every later "tree clean"
  assertion rather than a finding.
- `d5e17ff` — replaces the literal `ReportforClaudeWeb.txt` ignore rule with a glob. The audit's
  own distillation, `ReportforClaudeWeb_2.txt`, was **not** covered by the literal form and would
  have been staged into a public repository by the next `git add -A`. Same defect the corpus rule
  was written as a catch-all to avoid; the reasoning is now applied consistently.

### A0.2 Measured baseline

The audit brief supplied expected counts. Four match. One does not, and that one is **A0-F1**.
The audit proceeds against the measured column throughout.

| Suite                       | Brief expects | Measured `[E]`                                      | Verdict   |
| --------------------------- | ------------- | --------------------------------------------------- | --------- |
| `validate-crew.sh`          | 37            | **37 PASS / 0 SKIP / 0 FAIL**                       | match     |
| `run-crew-tests.sh`         | 144           | **144 PASS / 0 FAIL**                               | match     |
| `save-context.sh check`     | 20            | **20 PASS / 0 FAIL**                                | match     |
| `stress-project` `npm test` | 18, set-diff  | **18 declared = 18 ran**, intersection 18           | match     |
| `check-plan-corrections.sh` | 23, 0 pending | **20 rows — 18 APPLIED / 0 PENDING / 2 SUPERSEDED** | **A0-F1** |

`models.config.json` was hashed before and after every suite and is byte-identical throughout
`[E]`. This matters because `run-crew-tests.sh` deliberately rewrites that tracked file mid-run
and restores it from a backup; an interrupted suite would leave it mutated.

**The stress-project set difference was made non-vacuous before it was trusted.** The first
extraction of declared case names returned an empty set, against which any comparison is
trivially clean — the precise shape of failure this audit exists to catch. Corrected, then
negative-controlled: 18 names declared in `stress-project/test/*.test.js`, 18 executed,
intersection 18, zero in either difference, and removing one name from the run list provably
surfaces it as missing `[E]`.

### A0-F1 — the corrections registry, its detectors, and its report disagree three ways

**P2 · registry integrity · Failure scenario:** a future session asks "which plan corrections
have living detectors?", reads `check-plan-corrections.sh`'s green summary, and concludes all of
them do. Two corrections with no detector in that script regress silently; one applied correction
cannot be explained at all because nothing describes it.

**The brief's "expect 23" has a traceable source, and the source is itself the finding.** Plan.md's
closing entry states: "23 numbered plan-vs-reality corrections registered, 18 applied and 2
superseded, 0 pending" `[E]`. Correction IDs run C-01 through C-23, so 23 is what you get by
reading the highest identifier and assuming no gaps. C-15 is missing from the registry, so the
set holds 22. **The closing figure was derived from an ID's numeric value rather than counted from
the entries** — the same defect family the build recorded ten times, binding a claim to a proxy
instead of to the artifact, appearing one final time in the sentence that closes the plan. The
applied/superseded/pending half of that sentence is correct.

The measurable quantities are:

| Source                                   | Distinct IDs | Set                                      |
| ---------------------------------------- | ------------ | ---------------------------------------- |
| `context/plan-corrections.md` (registry) | **22**       | C-01…C-14, C-16…C-23 — **no C-15**       |
| `scripts/check-plan-corrections.sh`      | **21**       | C-01…C-15, C-18…C-23 — **no C-16, C-17** |
| Reported rows at runtime                 | **20**       | the 21 above, minus C-18                 |

Four distinct defects sit behind those numbers, and each is worse than the count mismatch `[E]`:

1. **C-15 is applied, reported and undocumented.** It reports `APPLIED — PreCompact carries the
prior next_action forward instead of displacing it`, and the string `C-15` appears **zero**
   times in the registry. The registry's own preamble states that every defect found in the plan
   is "recorded here." This one was corrected and never recorded, so the APPLIED verdict cannot be
   audited — there is no statement of what was wrong, why it mattered, or what was decided.

2. **C-16 and C-17 are documented but produce no row.** Both appear as full `##` sections; neither
   is named anywhere in `check-plan-corrections.sh`, in code or in comments. C-16 does have a
   living check in a different script — `validate-crew.sh:134-152` asserts the HC-5 deny set by
   meaning — so the correction is genuinely enforced and only the registry's report under-states
   it. **C-17 has no enforcement anywhere** `[E]`; a grep for its gate tokens across `scripts/`
   and `hooks/` returns nothing. The steelman holds: C-17 was a one-time plan defect (a mid-gate
   named without a token), the operator issued the tokens, they are recorded verbatim in the
   `G-F7a`/`G-F7b` ledger rows, and F7 is closed, so there is no recurrence to detect. That
   reasoning is sound and should be _stated_ — a correction closed by completion is a different
   thing from one closed by enforcement, and the registry does not distinguish them.

3. **C-18 exists only in a comment.** Comment-stripping `check-plan-corrections.sh` leaves zero
   occurrences `[E]`. It is the reason the detector set (21) and the reported set (20) differ.

4. **C-19 has no section of its own.** It appears once, as a bold paragraph nested inside C-20's
   section after that section's `Verify` line. Anything scanning `^## C-` headers — a reader
   included — misses the correction that fixed the arbiter's timestamp schema entirely.

Separately, **the registry's own index table lists 10 of its 22 IDs** (C-01…C-08, C-10, C-13),
omitting C-09, C-11, C-12, C-14 and every correction from C-16 onward `[E]`. The table has not
been maintained since roughly F4.

### A0-F2 — the only rebrand guard scans the two directories with zero hits

**P2 · control binding · Failure scenario:** the pre-rename project name is reintroduced into
`hooks/`, `scripts/`, `context/` or any root document. Every suite stays green, because the sole
check that looks for it inspects neither location.

`scripts/run-crew-tests.sh:229` is the repo's only rebrand check. It greps `.claude/agents` and
`.claude/rules`, failing when the pre-rename name is found. Measured `[E]`:

| Scope                              | Hits   |
| ---------------------------------- | ------ |
| Inside the guard's scope           | **0**  |
| Outside it, across 5 tracked files | **20** |

The guard is green because it looks where nothing is. Its verdict string is honest about its own
scope, and the targeting is defensible on its own terms: `PROGRESS.md:109` records the specific
"rename trap" it exists to catch — §5.1.1's verbatim `arbiter.md` payload contains the old name,
so writing that payload faithfully would reintroduce it into exactly `.claude/agents/`. As
recurrence prevention for that one trap, the guard is correctly aimed.

The finding is the absence of anything wider. `context/budget-baseline.md` — a tracked,
non-pinned, non-ledger document authored at F8 — acquired the string with no control noticing.

**Classification of all five files carrying the name** `[E]`:

| File                         | Hits | Class                                                     | Verdict                  |
| ---------------------------- | ---- | --------------------------------------------------------- | ------------------------ |
| `MASTER_FIFO_PLAN_CLAUDE.md` | 7    | (a) inside the EX-01 byte-pin                             | expected by construction |
| `Plan.md`                    | 10   | (b) historical ledger — the rename decision record itself | correct to keep          |
| `PROGRESS.md`                | 1    | (b) historical ledger — the "rename trap" checkpoint      | correct to keep          |
| `context/budget-baseline.md` | 1    | (b) load-bearing provenance                               | keep, but uncovered      |
| `scripts/run-crew-tests.sh`  | 1    | **(d) the string is the search term, not a survival**     | not a leak               |

The brief's taxonomy has three classes and needed a fourth. `run-crew-tests.sh` is live code
outside the pin that contains the name, which is class (c) by the letter of the rule — and class
(c) hits become change requests. Acting on that reading would have filed a CR to delete the
repository's only rebrand guard because it contains the string it searches for. This is the
guard-trips-on-its-own-documentation family, recorded seven times in this build, arriving once
more in the audit's own instructions.

`context/budget-baseline.md` is adjudicated **keep**: C-21 recovered F7's token figures by
deduplicating two session stores that hold the same runs, and naming both stores is what makes
that deduplication checkable. A reader who does not know there were two cannot verify the number.
Removing the name would remove the provenance.

### A0-F3 — the distilled entry point disagrees with both sources it distils

**P3 · continuity fidelity · Failure scenario:** a cold session reads `context/session-summary.md`
as instructed by HC-8 §15.4, and takes from it a fact that neither source document supports.
Nothing detects the divergence, because the distillation checker verifies hygiene, not fidelity.

The `APPROVE GATE-F8` approval timestamp `[E]`:

| Artifact                        | Timestamp                  |
| ------------------------------- | -------------------------- |
| `GATES.md:15`                   | `2026-08-14T01:54:54Z`     |
| `PROGRESS.md:362`               | `2026-08-14T01:54:54Z`     |
| `context/session-summary.md:61` | **`2026-08-14T01:58:11Z`** |

Two sources agree; the distillation carries the odd value, and it is the file HC-8 designates as
the first thing a cold session reads.

**The divergence is not a typo — it is a conflation, which is what makes it instructive.**
`Plan.md`'s last two entries are adjacent `[E]`: `[F8|2026-08-14T01:54:54Z] G-F8 APPROVED — PLAN
CLOSED`, then `[F8|2026-08-14T01:58:11Z] BRANCH LAYOUT SETTLED`. The distillation attached the
second entry's timestamp to the first entry's event. Every individual fact in the summary
sentence is true of _something_ in the source; the sentence assembled from them is not true of
anything. A fidelity check comparing distilled claims against their sources would catch this
class. A hygiene check cannot, by construction.

The timestamp itself is inconsequential — three minutes, no behavioural consequence, which is why
this is P3. The finding is the gap it reveals: `save-context.sh check` returns 20 PASS / 0 FAIL
against this file `[E]`, asserting it is free of absolute machine paths, carries no raw logs or
diffs, and declares a Next action. All twenty assertions are hygiene properties of the distilled
file considered alone. **None compares a distilled claim against the source it was distilled
from.** A §15.5 distillation whose entire purpose is to be the authoritative cold-start read is
checked for tidiness and not for truth.

### A0.3 Corpus fencing `[E]`

The stage-everything probe stages **0 paths**. Enforcing rules in `.gitignore`:

| Rule                      | Covers                                                                       |
| ------------------------- | ---------------------------------------------------------------------------- |
| `*-main/`                 | all 16 reference project trees (~864 MB, ~83,100 files)                      |
| `*.pdf`                   | the three research PDFs at the root                                          |
| `deep-research-report.md` | enumerated, not globbed — every other root `.md` is tracked and load-bearing |
| `ReportforClaudeWeb*.txt` | both local reports (globbed this session, `d5e17ff`)                         |
| `Project-Explorer.md`     | the corpus navigation map                                                    |

Verified with both control directions: six paths that must be ignored are, and three that must
remain trackable — including `docs/audit/`, where this report lives — are.

### A0.4 Carried forward to later phases

Recorded here because they were observed during A0 measurement; adjudicated where the brief
assigns them.

| Observation                                                                                                                     | Phase |
| ------------------------------------------------------------------------------------------------------------------------------- | ----- |
| Two fenced mermaid blocks exist, not three; the plan mandates a diagram it never contains                                       | A1    |
| `F7 README: … 14 arrows` — a count-bound assertion on a diagram                                                                 | A1/A3 |
| `F7 auditing the artifact did not modify it (tree 1 -> 1)` — count-bound, not identity-bound                                    | A3    |
| The registry index table is stale at 10 of 22 IDs                                                                               | A2    |
| `.claude/settings.json` wires a `PostToolUseFailure` hook; C-02 established `PostToolUseFail` is not real — is this one? `[V?]` | A3    |

---

## A3 — Function and code audit

Scope: 9 scripts · 12 hooks · 8 agent bodies · 4 rules · `stress-project/` (22 files) ·
`models.config.json` · `.claude/settings.json`.

### A3.1 Mechanical sweep — clean `[E]`

| Check                                      | Result                                                  |
| ------------------------------------------ | ------------------------------------------------------- |
| `bash -n` over 9 scripts + 12 hooks        | 21/21 parse                                             |
| `node --check` over stress-project JS      | 14/14 parse                                             |
| `jq -e .` over every tracked JSON          | 8/8 valid                                               |
| Executable bits on scripts and hooks       | 21/21 set                                               |
| Absolute machine paths in tracked scripts  | **none** — only `/usr/local/bin` inside a `PATH` export |
| JSON passed as a `printf` format string    | **none** — 82 uses of the safe `printf '%s'` form       |
| A commit chained behind a deny-listed verb | **none** in any tracked script                          |

**Shell-option discipline is deliberate, not accidental.** Scripts that must not abort mid-run use
`set -uo pipefail`; one-shot tools use `set -eu`. `hooks/_common.sh` carries no `set` line because
it is sourced, which is correct — its options would leak into every caller.

### A3.2 Pipeline sweep (lesson 6.2) — one real finding

Every `| grep -q` under `pipefail` was examined. All but three have `printf` as the producer, which
cannot meaningfully exit nonzero — that is the capture-then-test pattern the registry mandates, and
it is applied consistently. Two script-producer pipelines were checked directly:
`restore-context.sh latest` and `error-recovery.sh` both exit 0 `[E]`, so neither poisons its
pipeline.

The third is a real defect and is filed as A3-F4 below.

### A3-F1 — the C-14 fix was applied to one audit trail and not its sibling

**P2 · evidence integrity · Failure scenario:** any analysis of `logs/build-errors.jsonl` — an
error-rate trend, a §9 corpus review, a gate report citing failure counts — is computed over a file
that is 95% synthetic, describing command failures that never occurred.

`scripts/run-crew-tests.sh:165-167` feeds fixture payloads into `./hooks/error-recovery.sh` **with
no `CLAUDE_PROJECT_DIR` override and no `mktemp` root** — measured: zero occurrences of either in
that block `[E]`. The hook therefore appends to the live trail.

**Negative control, executed** `[E]`: one fixture invocation moved `logs/build-errors.jsonl` from
187 to 188 lines, adding
`{"ts":"…","tool":"Bash","error":"bash: AUDITPROBE: command not found","phase":"F7"}`.

**179 of 188 records — 95% — are fixture fiction** `[E]`, every one a `bash: foo: command not
found` that never happened.

C-14 is precisely this defect: "tests wrote to the artifact they audit … an evidence trail
containing invented events is worse than one with gaps, because every downstream check and every
gate report treats it as ground truth." Its fix moved six fixtures to a `mktemp -d` root — for
`logs/tooluse-audit.jsonl`. The identical pattern against `logs/build-errors.jsonl` was never
migrated, and C-14's detector only inspects `tooluse-audit.jsonl`, so nothing looks.

A second, smaller defect sits in the same block. Line 166 asserts
`[ -f logs/build-errors.jsonl ] && ok "error-recovery wrote build-errors.jsonl"` — immediately
after the line above it caused that file to be written. The assertion creates the condition it
tests. On a fresh checkout, where `logs/` does not exist, it passes because the fixture made it
pass.

### A3-F2 — every hook-written record since F7 closed carries the wrong phase, and the error is self-sustaining

**P2 · control binding · Failure scenario:** C-19's grandfather list exempts phases F0–F7 from the
ISO-8601 timestamp requirement, because their granularity was already lost. Records written today
are stamped `F7`. Any writer taking its phase from this derivation inherits an exemption that was
meant to close when F7 did.

`hooks/_common.sh:7` derives the phase by reading the **last `^## \[F[0-9]` heading in
`PROGRESS.md`**. `hooks/pre-compact-checkpoint.sh:24` **writes a heading in exactly that format**,
stamped with the phase it just read.

The hook reads the heading it writes. Once the last matching heading said `F7`, every subsequent
PreCompact writes another `F7` heading, and the value can never advance. Evidence `[E]`:

| Heading in `PROGRESS.md` | Written                                     |
| ------------------------ | ------------------------------------------- |
| `## [F7\|2026-08-13…]`   | during F7 — correct                         |
| `## [F7\|2026-08-14…]`   | **after `APPROVE GATE-F7b` @ 00:56:07Z**    |
| `## [F7\|2026-08-17…]`   | three days later, during this audit session |

Every `logs/tooluse-audit.jsonl`, `logs/build-errors.jsonl` and denial record written in this
session is stamped `phase:"F7"` `[E]` — a phase that closed on 2026-08-14.

**The C-19 interaction, demonstrated with both controls** `[E]`. Running C-19's exact `jq`
predicate against a synthetic date-only arbiter line:

| Synthetic line                        | C-19 verdict                    |
| ------------------------------------- | ------------------------------- |
| `{"ts":"2026-08-17","phase":"F7", …}` | **not flagged** — grandfathered |
| `{"ts":"2026-08-17","phase":"A3", …}` | `FLAGGED: A3:AUDIT-PROBE`       |

Stated precisely, because the scope matters: `_common.sh` supplies the phase for **hook-written**
records. The arbiter writes its own audit lines and declares its own phase, so `arbiter-audit.jsonl`
is not stamped by this code path today. The exposure is that the repository's one automated answer
to "what phase is it?" has been wrong for three days and cannot self-correct, and that a
phase-keyed exemption exists a few files away.

### A3-F3 — a permission boundary asserted by count, inside the block C-16 fixed by asserting meaning

**P2 · control binding · Failure scenario:** the two secret-path `Read` denials are replaced with
any two other `Read(` entries. `validate-crew` reports "secret-path Read denials retained", the
gate passes, and `.env` and `secrets/` are no longer denied.

`scripts/validate-crew.sh:153-154`:

```sh
RD=$(printf '%s\n' "$DENY" | grep -c 'Read(' || true)
[ "${RD:-0}" -ge 2 ] && pass "secret-path Read denials retained" || fail "..."
```

**Negative control, executed** `[E]`: a deny-list containing `Read(/tmp/nothing)` and
`Read(/tmp/alsonothing)` yields a count of 2 and passes, with neither secret path denied.

What makes this a finding rather than a nitpick is its neighbourhood. Ten lines above, the Bash
prohibitions are asserted **by name** — `git clone`, `npm install -g`, `npx`, `sudo`, `rm -rf /`,
`rm -rf ~`, `dd if=` — each needle assembled from fragments so the check does not trip
`bash-blocker`. That is the C-16 fix, and C-16's own text is unambiguous: "A permission boundary
with no integrity assertion is not a boundary; it is a comment." The Bash half of the deny-list
received that treatment. The `Read` half, in the same block, kept a count.

### A3-F4 — an agent file that declares no tools at all reports as read-only

**P2 · control binding · Failure scenario:** an agent definition is authored or edited without a
`tools:` line. Omitting it means the subagent inherits every tool. `run-crew-tests.sh` reports it
"is read-only", and the reviewer-cannot-mutate contract — the thing that keeps a review trail
honest — is silently void.

`scripts/run-crew-tests.sh:221`:

```sh
grep -m1 '^tools:' ".claude/agents/$a.md" | grep -qE 'Write|Edit|Bash' \
  && no "$a holds a mutating tool — read-only by contract" || ok "$a is read-only"
```

Under `pipefail`, a file with no `tools:` line makes the first `grep` exit 1; the second receives
empty input and also exits 1; the pipeline fails; control falls to `|| ok`.

**Negative control, executed** `[E]`: a synthetic agent file with frontmatter `name`/`model` and no
`tools:` line returns `PASS — "is read-only"`.

The check is **green today for the right reason** — all eight agent bodies declare a `tools:` line
`[E]`, and the three audited ones are genuinely `Read, Grep, Glob`. The defect is the failure mode,
which is inverted: the most permissive possible declaration produces the safest possible verdict.

### A3-F5 — `REPLAYED` is not merely undemonstrated, it is unreachable from the shipped fixtures

**P2 · coverage gap · Failure scenario:** a reader follows `stress-project/README.md:114-117`,
reuses one `--out` across two deliveries, and observes no replay. The mechanism described is real;
no shipped input can exercise it.

The repository states this open item as "the parked-replay path is green in tests but was never
demonstrated in a live end-to-end run" (`README.md:111`, `context/session-summary.md:47`). That is
true and understates it.

**Measured across all six fixtures** `[E]`:

| Fixture                       | Events                   |
| ----------------------------- | ------------------------ |
| `edge-mover-before-hire.json` | `MOVE:EMP-30442` ← parks |
| `joiner-charmander.json`      | `HIRE:EMP-10041`         |
| `edge-duplicate-webhook.json` | `HIRE:EMP-30518` ×2      |
| `leaver-bulbasaur.json`       | `TERMINATE:EMP-10047`    |
| `mover-squirtle.json`         | `MOVE:EMP-10043`         |

The parking lot is keyed by `employee_id`. The parked event belongs to `EMP-30442`; **no fixture
contains a HIRE for that employee.** No pair of shipped fixtures, in any order, sharing any `--out`,
can drain that parking lot.

Executed live to confirm `[E]`: run 1 (`edge-mover-before-hire`) exits 1 with `seq 2 lifecycle
PARKED` and `state.json` holding the parked event under `EMP-30442`. Run 2 (`joiner-charmander`,
same `--out`) exits 0 and correctly does _not_ drain it — a different employee. `REPLAYED` occurs
**0 times** in the artifact.

The unit test `parked-move-replays-after-hire` (`test/lifecycle.test.js:127`) constructs its events
in-process and never touches `fixtures/`. So the path is proven at the unit level and structurally
unreachable at the CLI level. This converts an open item from "nobody got round to it" into a
one-fixture change request.

### A3-F6 — the error hints are written to the channel that does not reach the model

**P3 · dead code · Failure scenario:** none operationally. The §9 corpus hints the hook exists to
surface have never been seen by anything.

`hooks/error-recovery.sh` does two jobs. The logging half **works** — see A3-F1; it captured this
audit's own `WebFetch` failures within seconds `[E]`. The hint half emits `[hint] §9 …` to
**stdout** and then `exit 0`, with the whole block wrapped in `{ … } 2>/dev/null`.

The hooks reference states that to surface a warning to Claude from a `PostToolUse` or
`PostToolUseFailure` hook you must **exit 2, so Claude sees stderr** `[V]`. This hook exits 0 and
writes to stdout, and discards stderr besides. No artifact anywhere in `logs/`, `Plan.md`,
`PROGRESS.md` or `context/` records a hint having been surfaced `[E]`.

The suite asserts the hint is _emitted_ (`run-crew-tests.sh:167`, grepping the hook's stdout) — a
correct test of the wrong property. Emission is not delivery.

### A3-F7 — the gitignore assertion binds to rule text where the repo elsewhere binds to state

**P3 · control binding · Failure scenario:** mostly noise, not risk. `.gitignore` is rewritten with
an equivalent but differently-spelled rule and the gate fails while the ignore works correctly.

`scripts/validate-crew.sh:42-44` uses `grep -qxF "$e" .gitignore`. C-04's detector in
`check-plan-corrections.sh:59` asks `git check-ignore -q` — the effective state. Same property, two
methods, and the gate validator has the weaker one. Measured `[E]`: of four functionally equivalent
spellings of the same rule (`logs/`, `/logs/`, `logs`, `logs/**`), **three fail the text grep**
while all four ignore correctly.

Recorded as P3 because the failure direction is safe — it produces false FAILs, which are loud.

### A3-F8 — the README's first command is one this repository's own guard forbids

**P3 · documentation · Failure scenario:** an agent working in this repository is asked to follow
the Quickstart and is denied at the first line, with the explanation 93 lines further down.

`README.md:10` opens the Quickstart with the clone verb. `hooks/bash-blocker.sh:12` denies any Bash
command whose **whole string** contains it. `README.md:103` discloses this honestly — "The in-repo
deny-list blocks the clone verb during agent work" — but it is under a later heading.

Related and worth recording as an operating constraint rather than a defect: **six tracked files
carry that adjacency** `[E]` — `.claude/settings.json`, `MASTER_FIFO_PLAN_CLAUDE.md`, `README.md`,
`hooks/bash-blocker.sh`, `scripts/check-plan-corrections.sh`, `scripts/run-crew-tests.sh`. Any Bash
command quoting their content is denied outright. This is the C-22 lesson still live, and it was
encountered twice during this audit, both times resolved by assembling patterns from fragments.

### A3-F9 — resolved and refuted: `PostToolUseFailure` is a real event

Raised in A2 as a `[V?]` that could void an entire hook. **Refuted, three ways** — recorded because
a finding that dissolves under evidence should be reported as clearly as one that survives.

1. The hooks reference documents `PostToolUseFailure` as a real event that fires after a tool call
   fails `[V]`.
2. `logs/build-errors.jsonl` is 188 lines and was last written **during this audit session**,
   capturing this audit's own blocked `WebFetch` calls seconds after they failed `[E]`.
3. The operator's live global configuration wires the same event name `[E]`.

C-02's correction is right, its detector is right about what it can test, and `error-recovery.sh`
demonstrably fires. Only the hint-delivery half is defective (A3-F6).

### A3.3 Execution checks

**Portability drill: PORTABLE** `[E]`, both mechanisms green with the three new audit documents
tracked. `git archive` extracted **77** tracked files with `setup.sh` green at 34 PASS / 3 SKIP /
0 FAIL; the detached worktree ran 35 PASS / 2 SKIP / 0 FAIL with the C-23 absolute-path assertion
**confirmed running**, and `setup.sh` left that checkout byte-clean. The drill computes its expected
file count from `git ls-files` rather than a literal, so adding tracked files did not break it —
verified by observation, not assumption.

**End-to-end against README claims** `[E]`. Every claim tested held except the replay path:

| Claim                                                    | Observed                                |
| -------------------------------------------------------- | --------------------------------------- |
| `--fail-iam` opens a ticket with status `Failed`, exit 1 | exit 1, status `Failed`                 |
| Delivery from stdin via `-`                              | exit 0, all four artifact kinds written |
| `--now` + `--seed` gives byte-identical runs             | identical                               |
| Without them, runs differ                                | differ — the falsification holds        |
| Reusing `--out` replays a parked event                   | **see A3-F5**                           |

---

## A4 — Flow, integration, and the four owed findings

### A4.1 The release law, traced by identity

Correlated by `task_id`, never by count `[E]`:

| Quantity                                                | Value |
| ------------------------------------------------------- | ----- |
| Distinct dispatch `task_id`s in `tooluse-audit.jsonl`   | 16    |
| Distinct arbiter `task_id`s in `arbiter-audit.jsonl`    | 11    |
| Arbiter audit lines total                               | 19    |
| **Specialist dispatches with no matching arbiter line** | **0** |

The law holds. Surplus arbiter lines exist — 19 lines across 11 ids — and surplus is exactly what
C-12 made harmless: because coverage is a set difference on identity, extra lines cannot mask a
missing one. This is the correction working as designed, verified against the artifacts rather than
against the checker's own report.

### A4-F1 — the C-19 fix has never been exercised, and A3-F2 would exempt the first line that could exercise it

**P2 · latent control · Failure scenario:** the first post-F7 arbiter line is written, is stamped
`F7` by a stale phase derivation, and is grandfathered out of the very requirement C-19 added.

Measured across all 19 arbiter lines `[E]`:

| Property                           | Count                           |
| ---------------------------------- | ------------------------------- |
| Full ISO-8601 `ts` (`…THH:MM:SSZ`) | **0**                           |
| Date-only `ts`                     | 19                              |
| Phases present                     | `F3`, `F7` — both grandfathered |

The C-19 fix is real and correctly built: `arbiter.md` mandates the format, and
`validate-crew.sh:188-203` enforces it with a genuine regex and an enumerated grandfather list. But
**no line in the repository satisfies it**, so the enforcement path has never executed against a
conforming record. It is prospective only, which the repository does state.

What the repository does not state is the interaction with A3-F2. The grandfather predicate is
`^(F0|F1|F2|F3|F4|F5|F6|F7)$`, and `hooks/_common.sh` can no longer emit anything but `F7`. Any
future writer taking its phase from that derivation produces records that are permanently exempt.
The two defects are individually modest and compose into a control that cannot fire.

### A4-F2 — three arbiter lines carry no `task_id`, and nothing checks for that

**P3 · schema conformance · Failure scenario:** an arbiter line omits `task_id`. C-12's correlation
counts only lines that have one, so the line is invisible to coverage in both directions — it
neither covers a dispatch nor registers as uncovered. No assertion notices.

Schema conformance across the 19 lines `[E]`:

| Field             | Present   |
| ----------------- | --------- |
| `ts`              | 19/19     |
| `phase`           | 19/19     |
| `from_agent`      | 19/19     |
| `to`              | 19/19     |
| `original_sha256` | 19/19     |
| `mutation`        | 19/19     |
| `reason`          | 19/19     |
| **`task_id`**     | **16/19** |

The three exceptions are all F3 and all record a _failed_ dispatch — "dispatch-not-executed; zero
specialist packets received" and two "dispatch ATTEMPTED and FAILED at the tool layer". **The
steelman is strong**: a dispatch that never executed covers no task, so omitting the id is arguably
the honest record, and these lines predate F8's schema tightening, which added the `task_id MUST`
clause. They are not a violation of the rule as it stood when they were written.

The finding is the absent control. `validate-crew.sh` enforces `ts` **granularity** and nothing
enforces `task_id` **presence**, so the schema's one MUST-clause that C-12 depends on is unchecked.

### A4.2 Untrusted input and the reference-passing cap

**Untrusted input** is stated in `.claude/rules/arbiter-protocol.md:26` (§0.2d) and mechanically
backed by exactly one control: `hooks/provenance-flag.sh`, wired PostToolUse and confirmed present
in `settings.json` `[E]`. C-13 records its limits honestly — verbatim text only, and it flags
**after** the write by design. That is the whole mechanical surface; everything else is a rule.

### A4-F3 — the reference-passing cap is the proven economic lever and is prose only

**P2 · unenforced constraint · Failure scenario:** a dispatch inlines a large file body instead of a
path. Nothing rejects it, nothing measures it, and the cost lands in a budget the build already
missed by 9.65×.

`arbiter-protocol.md:16` states: "DISPATCH payloads carry paths, contracts and `expected_output` —
never file bodies beyond a **30-line excerpt**." Searched across every script and hook: **no
enforcement of any kind** `[E]`.

This matters more than an unenforced style rule usually would. The measured economics identify
reading as the dominant cost and reference-passing as the proven lever, and C-20 quantifies the
counter-case: `subagent_tokens` counted the same ~27K of source once per reading agent, ~214K, 11%
of F7's total, pure input. The 30-line cap is the rule that keeps that number down, it is the one
HC-8 names as "the compounding driver", and it is enforced by nothing.

### A4.3 The four owed findings, re-adjudicated

Branch B's quarantined packet, `logs/rounds/round-1/quality-reviewer.json`, four findings, never
released. Each anchor re-verified against current code. Steelman rule applied: when in doubt,
ACCEPT.

Recorded here in full because `logs/` is gitignored — this evidence does not survive a clone, so an
adjudication that merely cited it would be unreproducible.

| ID      | Sev  | Verdict                             | Basis                                           |
| ------- | ---- | ----------------------------------- | ----------------------------------------------- |
| QR-DG-1 | high | **ACCEPT** — and it widened         | 5 mapped files absent, 5 present files unmapped |
| QR-DG-2 | high | **ACCEPT** — and escalate           | the intervening fix is itself a proxy           |
| QR-DG-3 | med  | **REJECT** — resolved by completion | the file exists and is tracked                  |
| QR-DG-4 | med  | **ACCEPT, narrowed**                | half stale, half widened 1 → 3                  |

**QR-DG-1 — ACCEPT.** Claim: the map's `context/` line names files that do not exist and omits ones
that do. Re-measured `[E]`:

| Named in the map, absent from disk | Present on disk, absent from the map |
| ---------------------------------- | ------------------------------------ |
| `architecture.md`                  | `budget-baseline.md`                 |
| `decisions.md`                     | `f2-readiness.md`                    |
| `open-items.md`                    | `f7-metrics.md`                      |
| `runbook.md`                       | `f7-plan.md`                         |
| `troubleshooting.md`               | `plan-corrections.md`                |

Six names on each side and **exactly one overlap**, `session-summary.md`. At F3 two existing files
were unmapped; there are now five. The failure scenario is intact and more likely: a
post-compaction session following HC-8 opens `context/decisions.md`, the read fails, and the map
offers no pointer to `plan-corrections.md` — which is authority #2 for implementation.

**QR-DG-2 — ACCEPT, severity escalated.** Claim: no check verifies `DIRECTORY_GUIDE.md` against the
real tree; the EX-01 loop is doc-vs-doc and "passes identically whether or not the map matches the
filesystem."

An assertion has since appeared that reports `corpus/§9 every script named by the map exists on
disk`. **It does not read the map.** `scripts/run-crew-tests.sh:422-427` iterates a list of six
paths hardcoded into the test; `DIRECTORY_GUIDE.md` appears **zero** times in that block `[E]`.

The hardcoded list has itself drifted from the map in both directions `[E]`: the map names
`setup.sh`, which the check omits; the check names `check-plan-corrections.sh`, which the map omits.
Two enumerations that were presumably once transcribed from each other, now disagreeing, with a
green assertion whose text claims one is validated against the other.

This is worse than the original finding. QR-DG-2 reported an absent control; there is now a present
control that asserts the property in its message and does not test it. The whole build's dominant
lesson — bind the check to the artifact that would differ — applied to a check written in response
to a finding about exactly that.

**QR-DG-3 — REJECT.** Claim: `.claude/skills/threshold-router/SKILL.md` is listed with no phase
qualifier and does not exist. The file exists, is tracked, and is asserted by `validate-crew.sh:117`
`[E]`. The premise is false today; the map line is accurate. Resolved by completion, not by fix.

**QR-DG-4 — ACCEPT, narrowed.** Claim had two halves. The first — `setup.sh` is listed but unwritten
— is **stale**: F8 delivered it. The second — `check-plan-corrections.sh` exists and is omitted from
the map — **stands, and widened** `[E]`: three scripts on disk are now unmapped
(`check-plan-corrections.sh`, `measure-dispatch-cost.sh`, `portability-drill.sh`).

**Common constraint on all three accepted findings.** Every one anchors to `DIRECTORY_GUIDE.md`,
which is byte-pinned under EX-01. The F4 precedent is to route around the pin by creating what the
map claims rather than editing the map. That precedent does not resolve QR-DG-4 (the map would have
to _gain_ names) and resolves QR-DG-1 only by creating five documents to satisfy a stale map. This
is the "DIRECTORY_GUIDE drift needs an operator routing decision" open item, and these three
findings are its concrete content.

### A4.4 Pattern-flow narrative — one event, end to end

The integration ground truth. Every function named below was located in the source, not inferred
`[E]`. Tracing `fixtures/leaver-bulbasaur.json` — one `TERMINATE` for `EMP-10047`.

**Setup.** `bin/jml.js:186` `resolveClock({now, seed, stepMs})` returns a fixed or stepping clock;
determinism lives here and nowhere else. `:191` `clock.newId("run")` mints the run id. `:220`
`parseDelivery(raw, {taskId, source})` (`src/intake.js`) parses the envelope — on failure the run
ends at `:226` via `emitFallbackAndExit`, writing exactly one audit line and exiting 2. `:229-243`
construct the four collaborators: `loadState`, `createAuditLog`, `createIntake`, `createLifecycle`,
`createIamAdapter`.

**Per event, the loop at `:353`.**

1. `:354` `intake.admit(rawEvent, {delivery, taskId})` — validates via `validateEvent`, computes a
   `fingerprintEvent` hash, and returns `ACCEPTED`, `DUPLICATE` or `REJECTED`. Dedupe is
   outcome-aware: a redelivery of a _failed_ attempt is re-admitted as `retry_of`.
2. `:358` **the CLI** calls `audit.append(STAGES.INTAKE, …)` — seq 1.
3. `:371-380` `REJECTED` → exit 1 path; `DUPLICATE` → counted and skipped, no ticket.
4. `:385` `lifecycle.stateOf(employee_id)` snapshots state **before** the transition. This line is
   the reason the rollback at `:392` can exist.
5. `:386` `lifecycle.apply(event)` → `applyEvent` reads `TRANSITIONS[NONE].TERMINATE`
   (`src/lifecycle.js:63`) → `{to: SUSPENDED, emission: iam.suspend, outcome: APPLIED}`. It
   **decides** the emission and does **not** call the provider.
6. `:271` `settle(event, result)` — a CLI closure, and the hub the diagram misses (A1-F3):
   - `:272` `audit.append(STAGES.LIFECYCLE, …)` — seq 2
   - `:290` `shouldOpenTicket(result)` gates the rest
   - `:292` **`iam.apply({action, employeeId, event})`** — the only real provider call in the
     program, made by the CLI
   - `:301` `iamRetryable(iamResult)` → `intake.markFailed(event)`, so a redelivery is re-admitted
     rather than deduped
   - `:304-308` `buildTicket(...)` → `writeTicket(ticket, outDir/tickets)`
   - `:309` `audit.append(STAGES.TICKETING, …)` — seq 3
   - `:322` `buildNotification(...)`, which runs `scrubSecrets` / `findSecretShapes`
     (`src/notify.js`) before serialisation
   - `:337` `audit.append(STAGES.NOTIFY, …)` — seq 4
   - returns `iamFailed(iamResult)` as `chainFailed`
7. `:388-390` any events drained from the parking lot settle through the same closure, reporting
   `REPLAYED` rather than `APPLIED` — the path A3-F5 shows no fixture can reach.
8. `:391-393` if the chain failed, `lifecycle.rollback(employee_id, stateBefore)` un-commits, so
   nothing durable claims an access change the provider refused.

**Close.** `:396` `lifecycle.snapshot()`, `:397` `saveState` merged with `intake.snapshot()`, `:405`
`audit.count()` into the report, `:406` exit code — 0 handled, 1 needs a human, 2 unusable input.

**The load-bearing observation.** Every `audit.append` call site and the single `iam.apply` call
site are in `bin/jml.js`; there are **none** in `src/` `[E]`. The modules are pure decision
functions that never call each other and never write. That is the architecture, it is a good one,
and it is the opposite of what `stress-project/README.md`'s diagram draws.
