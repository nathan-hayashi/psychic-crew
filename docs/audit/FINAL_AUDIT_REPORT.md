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
