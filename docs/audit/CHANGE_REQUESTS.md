# CHANGE_REQUESTS.md — the priced backlog

Every improvement this audit found, as a numbered change request. **Nothing here has been
implemented.** Fixes begin only when the operator approves specific CRs at a future gate.

Columns: **Effort** is a working estimate in hours for one focused session. **Risk** is the chance
the change breaks something green. **Gate** marks a CR that alters a permission boundary, a
byte-pinned file, or a gate rule, and therefore cannot be a quiet commit under
`.claude/rules/security.md`.

---

## Ranked by value

| CR      | What                                                      | Value     | Effort | Risk | Gate    |
| ------- | --------------------------------------------------------- | --------- | ------ | ---- | ------- |
| **009** | Bind the C-12 detector to code, not comments              | very high | 0.5h   | low  | no      |
| **024** | Make the map-vs-tree check actually read the map          | high      | 1h     | low  | no      |
| **014** | Stop the phase stamp from being self-reinforcing          | high      | 1h     | med  | no      |
| **015** | Assert secret-path `Read` denials by identity, not count  | high      | 0.5h   | low  | no      |
| **013** | Move the error-recovery fixture to a temp root            | high      | 0.5h   | low  | no      |
| **025** | C-05 structural bypass prevention (re-scoped)             | high      | 3h     | med  | **yes** |
| **023** | DIRECTORY_GUIDE routing decision                          | high      | —      | —    | **yes** |
| **022** | Enforce or retire the 30-line reference-passing cap       | high      | 2h     | low  | no      |
| **016** | Distinguish "declared read-only" from "declared nothing"  | med-high  | 0.5h   | low  | no      |
| **010** | Implement C-21's own stated Verify                        | med-high  | 0.5h   | low  | no      |
| **031** | Add `.gitattributes` with `eol=lf`                        | med       | 0.2h   | none | no      |
| **034** | Correct the distilled summary and bind more of its claims | med       | 1h+    | low  | no      |
| **033** | Re-anchor audit citations; decide historical vs forward-looking | low-med   | 1-2h   | low  | no      |
| **030** | Add the HC-7 content scan the plan says validate-crew has | med       | 0.5h   | low  | no      |
| **021** | Enforce `task_id` presence on arbiter lines               | med       | 0.5h   | low  | no      |
| **017** | Add a fixture that makes `REPLAYED` reachable             | med       | 1h     | low  | no      |
| **007** | Write C-15's missing registry entry                       | med       | 0.5h   | none | no      |
| **012** | Correct the "23 corrections" figure in four places        | med       | 0.5h   | none | no      |
| **001** | Correct the README dispatch diagram                       | med       | 0.5h   | none | no      |
| **005** | Draw the JML state machine                                | med       | 1h     | none | no      |
| **026** | User-facing intake / task-contract layer                  | med       | 6h     | med  | no      |
| **018** | Error hints: `exit 2` + stderr, or delete them            | med       | 0.5h   | low  | no      |
| **008** | Detector or explicit closed-by-completion for C-16/C-17   | med       | 1h     | low  | no      |
| **027** | README hardware / OS / plan-requirements section          | med       | 1h     | none | no      |
| **011** | C-19 section header; refresh the registry index table     | low-med   | 0.5h   | none | no      |
| **019** | Bind the gitignore assertion to `git check-ignore`        | low-med   | 0.5h   | low  | no      |
| **002** | Gate FSM diagram                                          | low-med   | 1h     | none | no      |
| **003** | Hook pipeline diagram                                     | low-med   | 2h     | none | no      |
| **029** | Capability-class layer over `models.config.json`          | low-med   | 2h     | low  | no      |
| **004** | §15 continuity-layers diagram                             | low       | 1h     | none | no      |
| **006** | Dispatch-cost distribution chart                          | low       | 1.5h   | low  | no      |
| **020** | Move the README clone-verb disclosure next to the command | low       | 0.2h   | none | no      |
| **028** | Psychic-Crew-Lite derivation seams                        | low       | 4h     | low  | no      |

**If only three are approved: CR-009, CR-024, CR-013.** All three restore a control that currently
reports green while testing nothing, all three are under an hour, and none touches a permission
boundary.

---

## The detail

### CR-009 — bind the C-12 detector to code, not comments

**Why.** `scripts/check-plan-corrections.sh:145` is `grep -q 'task_id' scripts/validate-crew.sh`,
not comment-stripped. Demonstrated: a copy of `validate-crew.sh` with every non-comment line
mentioning `task_id` deleted still reports `C-12 APPLIED`, because three comments survive. C-12 is
the correction about a control satisfiable by the party it audits; its detector is satisfiable by
prose. Eight sibling detectors in the same file already comment-strip.

**Where.** `scripts/check-plan-corrections.sh:145-149`.

**How.** Reuse the existing `$CODE_VC` (already computed at line 69, already comment-stripped) and
bind to the correlation predicate rather than the bare token — the `comm -23` set difference over
`task_id` sets is the artifact that would differ if the defect were real.

**Negative control it must pass.** Against a `validate-crew.sh` whose coverage block is reverted to
count comparison with comments intact, the detector must report `PENDING`. The scratch file used to
demonstrate this is reproducible in one `awk` line and should ship as the test fixture.

**Effort** 0.5h · **Risk** low · **Gate** no.

### CR-024 — make the map-vs-tree check read the map

**Why.** `scripts/run-crew-tests.sh:422-427` reports `every script named by the map exists on disk`
and never opens `DIRECTORY_GUIDE.md` — zero references in that block. It iterates six hardcoded
paths. The two enumerations have already drifted apart in both directions: the map names
`setup.sh`, which the check omits; the check names `check-plan-corrections.sh`, which the map omits.
This is the answer that was given to QR-DG-2, which reported exactly this class of gap.

**Where.** `scripts/run-crew-tests.sh:415-427`.

**How.** Parse the paths out of `DIRECTORY_GUIDE.md` and assert each exists. Assert the converse
too — every `scripts/*.sh` on disk appears in the map — since QR-DG-4 is the converse direction and
is currently unmapped for three scripts.

**Interaction.** Passing this immediately fails on QR-DG-1 and QR-DG-4, which are real drift. Land
CR-023's routing decision first, or land this with the known failures enumerated as a
grandfathered set, following the C-14 and C-19 precedent for explicit exemption lists.

**Effort** 1h · **Risk** low, but it will go red until CR-023 lands · **Gate** no.

### CR-014 — stop the phase stamp from being self-reinforcing

**Why.** `hooks/_common.sh:7` reads the last `^## \[F[0-9]` heading in `PROGRESS.md`;
`hooks/pre-compact-checkpoint.sh:24` writes a heading in that exact format. The hook reads what it
wrote, so the phase can never advance past `F7`, and headings dated `2026-08-14` and `2026-08-17`
were both written after F7 closed. Every hook-written record in this audit session is stamped `F7`.

**Compounding risk.** C-19 grandfathers `^(F0|…|F7)$`. Demonstrated with both controls: a date-only
line stamped `F7` passes unflagged; stamped `A3` it is FLAGGED. A permanent `F7` means a permanent
exemption for anything taking its phase from this derivation.

**Where.** `hooks/_common.sh:7-8`, `hooks/pre-compact-checkpoint.sh:24`.

**How.** Two options, and the choice is a design decision worth making explicitly rather than
patching:

1. Derive the phase from the gate ledger (`GATES.md`'s last approved row) — an artifact that only
   the operator advances, so it cannot self-feed.
2. Have PreCompact write a heading in a format `_common.sh` does not read, breaking the loop while
   leaving the derivation alone.

Option 1 is the better binding; option 2 is the smaller change.

**Effort** 1h · **Risk** medium — the phase appears in every audit record, so a mistake mislabels
the trail · **Gate** no.

### CR-015 — assert secret-path `Read` denials by identity

**Why.** `scripts/validate-crew.sh:153-154` counts `Read(` entries and requires ≥ 2. Demonstrated:
`Read(/tmp/nothing)` plus `Read(/tmp/alsonothing)` passes with neither secret path denied. Ten
lines above, every Bash prohibition is asserted **by name** — that is the C-16 fix, and C-16's own
text says a permission boundary with no integrity assertion is not a boundary.

**Where.** `scripts/validate-crew.sh:153-154`.

**How.** Assert the specific needles (`.env`, `secrets`) the way `$_n1…$_n5` already do in the same
block, assembled from fragments for the same reason.

**Effort** 0.5h · **Risk** low · **Gate** no.

### CR-013 — move the error-recovery fixture to a temp root

**Why.** `scripts/run-crew-tests.sh:165-167` pipes fixtures into `./hooks/error-recovery.sh` with
no `CLAUDE_PROJECT_DIR` override, so each suite run appends fabricated failure records to the live
`logs/build-errors.jsonl`. Measured: **178 of 188 records — 95% — describe failures that never
happened.** This is C-14 exactly; C-14's fix moved six fixtures to a `mktemp -d` root for
`tooluse-audit.jsonl` and never covered this sibling, and C-14's detector inspects only the other
file.

**Second defect, same block.** Line 166 asserts `[ -f logs/build-errors.jsonl ]` immediately after
the line above caused that file to exist. The assertion creates the condition it tests.

**Where.** `scripts/run-crew-tests.sh:165-167`.

**How.** Wrap in `CLAUDE_PROJECT_DIR=$(mktemp -d)`, matching the C-13 and C-15 fixtures which
already do this. Re-point the existence assertion at the temp root. Optionally extend C-14's
detector to cover `build-errors.jsonl`, which would have caught this.

**Note on the existing trail.** The 178 synthetic records are already there. Removing them is a
separate decision, and C-14's precedent applies: record any redaction, because an unrecorded one is
indistinguishable from tampering.

**Effort** 0.5h · **Risk** low · **Gate** no.

### CR-025 — C-05 structural bypass prevention, re-scoped

**This CR corrects the repository's own premise in five places.** `context/plan-corrections.md`
C-05, `.claude/rules/arbiter-protocol.md`, `README.md:114`, `context/session-summary.md:41` and
`ROADMAP.md` all state that `SubagentStart`/`SubagentStop` would turn bypass detection "from
after-the-fact detection into **prevention at the call**."

**Verified against the platform reference `[V]`:** `SubagentStart` receives `session_id`,
`transcript_path`, `cwd`, `hook_event_name`, `agent_id` and `agent_type`; `SubagentStop` receives
`agent_id`, `agent_type`, `agent_transcript_path` and `last_assistant_message`; both support
matchers filtering on agent type. **And `SubagentStart` cannot block subagent creation** — it can
inject context via `additionalContext`, nothing more.

So the deterministic-attribution half of the claim is correct and the prevention half is not
achievable with these events. What this CR can actually deliver:

| Claimed                       | Achievable                                                                                    |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| Deterministic attribution     | **yes** — `agent_type` is supplied, not inferred                                              |
| Prevention at the call        | **no** — `SubagentStart` cannot block                                                         |
| Detection at the moment       | **yes, and this is the real win** — fires at creation, not at the gate                        |
| Coverage of failed dispatches | **yes** — closes the C-12 hole where `PostToolUse` cannot fire for a tool that never executed |

That last row is the substantive gain and it is not currently claimed anywhere. C-12's live
observation was that two failed `Agent` calls produced zero `tooluse-audit` entries, so the
denominator silently shrank. A `SubagentStart` hook records the attempt independently of whether
the tool succeeded.

**How.** Wire `SubagentStart` to append `{ts, agent_id, agent_type, session_id}` to a new
`logs/subagent-starts.jsonl`. Extend `validate-crew.sh`'s coverage block to correlate that file
against `arbiter-audit.jsonl` by `agent_id`, alongside the existing `task_id` correlation.

**Negative control it must pass.** Dispatch a specialist and suppress the arbiter line: the check
must FAIL naming that `agent_id`. Then write a surplus arbiter line with an unrelated id: the check
must still FAIL, proving the set difference and not a count.

**Prerequisite.** Adding a hook event to `.claude/settings.json` changes the enforcement layer.
`.claude/rules/security.md` makes that an operator decision at a gate.

**Effort** 3h · **Risk** medium · **Gate** **yes**.

### CR-023 — DIRECTORY_GUIDE routing decision (operator)

**Why.** Three of the four owed G-F3 findings anchor here, and all three are still live. The map's
`context/` line and the real directory share **exactly one name out of six each**; three scripts on
disk are unmapped. The file is byte-pinned under EX-01.

**The choice is the operator's, and the F4 precedent does not settle it.** That precedent — route
around the pin by creating what the map claims — would mean authoring five documents
(`architecture.md`, `decisions.md`, `open-items.md`, `runbook.md`, `troubleshooting.md`) to satisfy
a stale map, and it cannot fix QR-DG-4 at all, because there the map would have to _gain_ names.

Options: (a) create the five, accept the map as the spec; (b) retire EX-01 for this one file under
a logged exception and regenerate the map from the tree; (c) supersede it with a generated map at a
new path and mark the pinned one historical.

**Effort** — depends entirely on the option · **Gate** **yes**.

### CR-022 — enforce or retire the 30-line reference-passing cap

**Why.** `.claude/rules/arbiter-protocol.md:16` caps DISPATCH payload excerpts at 30 lines. Nothing
in `scripts/` or `hooks/` enforces it. This is the lever HC-8 names as "the compounding driver", and
C-20 measured the counter-case: the same ~27K of source counted once per reading agent, ~214K, 11%
of F7's spend, pure input.

**How.** A `PreToolUse` matcher on `Agent` can inspect the prompt payload and flag or deny an
over-cap inline body. Flag-first is consistent with the C-13 precedent, where a denying check was
rejected because it would have blocked legitimate quoting.

**Alternative worth pricing.** If enforcement proves brittle, retire the number and keep the
principle — an unenforced numeric cap that everyone believes is enforced is worse than a stated
practice.

**Effort** 2h · **Risk** low · **Gate** no (flag-only); **yes** if it denies.

### CR-016 — distinguish "declared read-only" from "declared nothing"

**Why.** `scripts/run-crew-tests.sh:221` reports `is read-only` for an agent file with no `tools:`
line. Omitting the line means the subagent inherits every tool, so the most permissive declaration
produces the safest verdict. Green today only because all eight agents declare one.

**Where.** `scripts/run-crew-tests.sh:219-223`.

**How.** Capture the `tools:` line into a variable first; fail explicitly when it is absent, which
is a different failure from "declares a mutating tool". This is the registry's own
capture-then-test rule applied to a pipeline whose first stage exits nonzero meaningfully.

**Effort** 0.5h · **Risk** low · **Gate** no.

### CR-010 — implement C-21's own stated Verify

**Why.** The detector is `[ -x scripts/measure-dispatch-cost.sh ]`. The registry's Verify line says
"exits 0 and its F7 total matches the figure in `context/budget-baseline.md`". Demonstrated: a
two-line executable stub satisfies the detector. The assertion is already written; only the
implementation is missing.

**Effort** 0.5h · **Risk** low — the script takes time to run, so consider a cached mode · **Gate** no.

### CR-017 — make `REPLAYED` reachable

**Why.** The parked MOVE belongs to `EMP-30442`; the only HIREs across all six fixtures are
`EMP-10041` and `EMP-30518`. No pair of shipped fixtures, in any order, sharing any `--out`, can
drain that parking lot. The repository states this as "never demonstrated live"; it is
_unreachable_, which is a different and more fixable thing.

**How.** One fixture: a HIRE for `EMP-30442`. Then an end-to-end assertion that two runs sharing an
`--out` produce a `REPLAYED` outcome in `audit.jsonl`. This also converts a standing "not proven"
item into a proven one.

**Effort** 1h · **Risk** low · **Gate** no.

### CR-034 — the distilled summary's live numbers are stale, and its open-items list is wrong

**Registered at S2, not fixed** — outside the enumerated scope of this gate.

**Why.** `context/session-summary.md` is the file HC-8 §15.4 designates as the first thing a cold
session reads. Three of its claims are now false:

- the live-numbers line still reads `144 PASS` / `37 PASS` / `20 rows` / `80 tracked files`, against
  an actual 151+ / 42 / 22 / 84;
- it states that "two detectors (C-12, C-21) report APPLIED while testing nothing" — both were
  repaired in S1 (CR-009, CR-010) with executed negative controls;
- it states the four quarantined G-F3 findings are "still owed", in the same paragraph that
  elsewhere records them as adjudicated.

**Why this is worth its own CR rather than a quiet edit.** C-24 exists because this file was checked
for hygiene and never for fidelity, and it binds exactly **one** claim today — the GATE-F8 approval
timestamp. Everything above is precisely the class C-24 cannot see. The fix is not only to correct
the numbers but to decide which further claims get bound, because a summary that is corrected by
hand and unbound by check will drift again the moment someone stops looking.

**Where.** `context/session-summary.md`; optionally extend `save-context.sh`'s fidelity block.

**Effort** 1h for the corrections, plus whatever binding is chosen · **Risk** low · **Gate** no.

### CR-033 — the audit's line-number citations are stale, and half of them should stay that way

**Registered at S4. This registration is itself the fix for a §15.1 breach**, independent of the
item: CR-033 was referenced as an open item in `GATES.md`, in `PROGRESS.md` twice, and in session
memory, and it appeared **nowhere in this file** — the register that IS the backlog. Anyone reading
the backlog to decide what to work on could not have seen it. An item that exists only in ledgers
and close-out messages is not registered; it is remembered, and remembering is what disk exists to
replace.

**The item.** `docs/audit/*.md` carries **28 line-number citations** into `scripts/` and `hooks/`
`[E]`. Every S1, S2 and S3 edit shifted those lines. Spot-checked: `scripts/run-crew-tests.sh:221`
now lands on an unrelated `awk` block; `scripts/validate-crew.sh:153` lands on a bare `else`.

**Why this is not a sweep, which is the part the original framing missed.** The citations divide
into two classes and they want opposite treatment:

- **Forward-looking** — the ones in this file. They tell a future session where to make a change,
  so they must point at code as it is now. Content anchors are strictly better: they survive edits,
  and they state *what* to look for rather than *where* it happened to sit.
- **Historical** — the ones in `FINAL_AUDIT_REPORT.md`, `DIAGRAM_AUDIT.md` and `DECISION_AUDIT.md`.
  Those record what was found on 2026-08-17 at the lines it was found at. Rewriting them would
  edit a record to match a present it was never describing — the same instinct R1d refused for
  `PLATFORM_GAP_POWERSHELL.md`, and the same reason `Plan.md`'s wrong G-F8 figure was corrected by
  an appended entry rather than a rewrite.

**Proposed shape, needing an operator decision rather than a mechanical pass:** convert this file's
citations to content anchors; leave the audit reports' citations intact and add one dated
as-of-audit note per report saying the line numbers were accurate at the audit and have since
moved, with the content anchor given alongside.

**Where.** `docs/audit/CHANGE_REQUESTS.md` (convert) · `FINAL_AUDIT_REPORT.md`, `DIAGRAM_AUDIT.md`,
`DECISION_AUDIT.md` (annotate, do not rewrite).

**Effort** 1–2h · **Risk** low · **Gate** no.

**DEFERRED at S4, and the reason is the reframing above, not the size.** The session's instruction
was to implement if ≤1h and gate:no. It is gate:no, but a blanket re-anchor would rewrite three
historical records, and which citations are historical is a judgment the operator should make
rather than one I should make inside a session scoped to four other items. Registered here so the
next reader of the backlog sees it, which is the breach actually closed today.

### CR-031 — add `.gitattributes` with `eol=lf`

**Why.** No end-of-line normalisation is declared anywhere. On any checkout with
`core.autocrlf=true` — the Git for Windows default — every `.sh` file gains CRLF endings and
shebangs become `#!/usr/bin/env bash\r`. The damage is not limited to scripts failing to start:

- `validate-crew.sh:43` matches with `grep -qxF "logs/"`, and `logs/\r` is not `logs/`
- the fenced-payload byte comparison behind **EX-01** would report drift on every seed, failing the
  exception the entire build rests on
- `bash-blocker.sh`'s whole-string `case` patterns would see a trailing `\r`

**Why it is worth doing now rather than as part of a Windows port.** It costs one line, it is a
no-op on Linux, and it protects the byte-identity guarantee that is this repository's most
load-bearing single property. Doing it later means doing it _after_ the first CRLF checkout has
already produced a mystifying red gate.

**Where.** New `.gitattributes` at the repository root: `* text=auto eol=lf`, plus explicit
`*.sh text eol=lf`.

**Note.** Two adjacent Windows traps are already absent and should stay that way — zero symlinks in
tracked files, and all 20 shebangs identical. Full analysis in `PLATFORM_GAP_POWERSHELL.md`.

**Effort** 0.2h · **Risk** none on Linux · **Gate** no.

### CR-030 — add the HC-7 content scan the plan says exists

**Why.** HC-7 states that `validate-crew` greps `.claude/`, `hooks/` and `scripts/` for non-Claude
vendor names. Measured: **zero** such occurrences in `validate-crew.sh`. The only coverage is one
deny-test in `run-crew-tests.sh`, which proves `bash-blocker` denies a _command_ — a different
property from "no such invocation is written anywhere in the tree". Content is clean today, verified
independently in this audit; nothing would notice a regression.

**Implementation note that is not optional.** The check must assemble its needles from fragments.
This audit had **two** Bash invocations denied outright while running exactly this conformance
query — once on the grep itself, once on a line quoting HC-7's own sentence — and each denial killed
every other command in the invocation. That is the C-22 lesson, live, twice.

**Effort** 0.5h · **Risk** low, given the fragment rule · **Gate** no.

---

## The remaining CRs, briefly

**CR-021 — enforce `task_id` presence.** `validate-crew` checks `ts` granularity and nothing checks
that `task_id` exists; 3 of 19 lines lack one, and C-12's correlation silently ignores them.
Grandfather the three existing F3 records by enumeration, per the C-14 precedent. _0.5h, low, no._

**CR-007 — write C-15's registry entry.** C-15 is reported `APPLIED` and appears zero times in
`context/plan-corrections.md`. Its detector describes the defect; the registry does not.
_0.5h, none, no._

**CR-008 — C-16/C-17 detectors, or explicit closure.** C-16 is enforced in `validate-crew` but has
no row; C-17 has no enforcement anywhere. C-17's steelman is sound — a one-time plan defect, tokens
issued, F7 closed — but _closed by completion_ and _closed by control_ should be distinguishable in
the registry. _1h, low, no._

**CR-011 — C-19 section header and index refresh.** C-19 exists only as a bold paragraph nested
inside C-20's section; anything scanning `^## C-` misses it. The registry's index table lists 10 of
its 22 IDs. _0.5h, none, no._

**CR-012 — correct the "23".** The count appears in `Plan.md`'s closing entry, `README.md:28`,
`README.md:117` and `ReportforClaudeWeb.txt` §5.3. It was derived from the highest correction ID
rather than counted; the registry holds 22 and the checker reports 20. Two of the four are in the
public README.

**Same CR, second figure (A0-F3).** `context/session-summary.md` dated `APPROVE GATE-F8` to
`01:58:11Z`; `GATES.md` and `PROGRESS.md` both say `01:54:54Z`. Not a typo — a conflation. The two
adjacent `Plan.md` entries are `[F8|…01:54:54Z] G-F8 APPROVED` and `[F8|…01:58:11Z] BRANCH LAYOUT
SETTLED`, and the distillation attached the second entry's timestamp to the first entry's event.
Deliberately left uncorrected by this audit, since repairing a finding is a fix. _0.5h, none, no._

**The gap this second figure exposes is the more valuable half.** `save-context.sh check` returns
20 PASS against that file, and all twenty assertions are hygiene properties of the distilled file
considered alone — no absolute paths, no raw logs, a declared Next action. **None compares a
distilled claim against the source it was distilled from.** A fidelity check would catch this whole
class; a hygiene check cannot, by construction. Worth pricing separately if CR-012 is approved.

**CR-018 — error hints.** `hooks/error-recovery.sh` writes its §9 hints to stdout with `exit 0` and
discards stderr; the reference requires `exit 2` so Claude sees stderr. The suite asserts emission,
not delivery. Either deliver them properly or remove them and the assertion. _0.5h, low, no._

**CR-019 — gitignore assertion.** `validate-crew.sh:42-44` greps rule text; C-04's detector asks
`git check-ignore`. Three of four functionally equivalent spellings fail the text grep. Same
property, two methods, weaker one in the gate validator. _0.5h, low, no._

**CR-020 — README disclosure placement.** The Quickstart's first command is denied by this build's
own guard; the disclosure is 93 lines later. Move it adjacent. _0.2h, none, no._

**CR-001, CR-002, CR-004, CR-005 — DELIVERED at S3 (2026-08-19), per ruling R2a.** All four
mermaid, all renderable in-repo, plus a structural validator over every fenced block inline in
`run-crew-tests.sh`. See `DIAGRAM_AUDIT.md` for what the validator does and does not check.
**CR-003 and CR-006 remain deferred** for the reasons ruled: no d2 renderer under HC-5, and
CR-006's data still sits in the gitignored `logs/`.

**CR-001 to CR-006 — diagrams.** Specified in full in `DIAGRAM_AUDIT.md` §A1.3, including the
DIAGRAM-WORTH reasoning for each and the two concepts deliberately **not** recommended. CR-003
carries a real constraint: there is no d2 renderer here and HC-5 forbids installing one, so a `.d2`
file ships as source nobody in this repo can render. CR-006 requires moving the data out of the
gitignored `logs/` into `context/`, following `context/f7-metrics.md`.

**CR-026 — user-facing intake layer.** Specified in `PROMPT_READINESS.md`. _6h, medium, no._

**CR-027 — README requirements section.** Specified in the A5 section of
`FINAL_AUDIT_REPORT.md`, with the facts drawn from measured data. _1h, none, no._

**CR-027 facts CORRECTED by ruling R1d (2026-08-19), for when this lands.** The C2a floors recorded
in the rulings register assumed a native-Windows target and named PowerShell 7.4+ as a runtime
requirement. R1d makes this project bash-native permanently, so the Windows section reads:

- **Windows 10 22H2 or Windows 11**, with hardware virtualization enabled.
- **WSL2 with Ubuntu 24.04 LTS** — the measured build host, not merely a supported option.
- **Node ≥ 20 inside WSL** (the build ran v24.14.0), together with `git`, `npm` and `jq`.
- **PowerShell's only role is `wsl --install`.** It is not a runtime for anything in this repo, and
  the README must not imply a native-Windows path exists.
- **`.gitattributes` (CR-031) stays regardless.** It is not a PowerShell concession — it protects
  mixed-editor checkouts on the Windows side, where a CRLF write would fail the §4 seed
  byte-identity check.

Linux and macOS requirements are unchanged, and the plan-tier and token-economics facts in the A5
draft are unaffected by this ruling.

**CR-028 — Psychic-Crew-Lite seams.** Coupling report in the A5 section. _4h, low, no._

**CR-029 — capability classes over `models.config.json`.** Feasibility note in the A5 section.
_2h, low, no._
