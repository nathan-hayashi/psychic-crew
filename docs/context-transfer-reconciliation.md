# context-transfer-reconciliation.md — the upstream channel export, checked against repo truth

Written at CONTEXT-TRANSFER-1 (2026-08-25). Subject: the six-file `Context-Transfer/` bundle the
operator exported from the Claude.ai web project on 2026-08-25. Labels follow the bundle's own
convention — `[E]` established, `[I]` inferred, `[S]` speculative, `[V?]` verify before reliance.

## Why this file exists, and what it may not contain

**The bundle is never edited.** It is a record of an upstream channel, and it says so itself: "a
RECORD of the upstream web channel, not a new execution authority … where this bundle and repo state
disagree, ESCALATE to the operator — do not guess." Corrections therefore live here rather than in
the source, for the same reason `MASTER_FIFO_PLAN_CLAUDE.md` is never edited locally and
`context/plan-corrections.md` exists instead. The bundle is gitignored under `Context-Transfer*/`
and backed up outside the repo; this file is the tracked half of that pair.

**The crossing rule, stated because nothing mechanical would otherwise enforce it.** The bundle is
fenced precisely because its contents must not reach a public repo. A tracked file that quotes it
back would defeat that fence, and no existing control would notice: `save-context.sh`'s hygiene
checks cover `context/` only, and the threat model's residual row records that no check reads prose
for confidentiality.

- **May cross:** claim identifiers, repo-side ground truth, file and line citations, counts.
- **May not cross:** verbatim bundle prose beyond the short authority quotation above, `claude.ai`
  conversation URLs, memory-export content, and employer or personal identifiers.

That rule is asserted, not promised — `scripts/validate-crew.sh` fails if this file ever carries a
conversation URL. R-SEC-1 rule 3's standard applied to prose.

**Scope note.** This corrects an _external_ record, which is a shape the build had no convention
for. `plan-corrections.md` corrects the execution authority; `docs/audit/CHANGE_REQUESTS.md` prices
this repo's own defects; `docs/audit/` records one dated audit. The closest precedent is
`docs/security/threat-model.md` — a single parent-side document describing both repos — and that is
why this record is parent-side and singular rather than duplicated into Lite.

## Verdicts

`CORRECTED` the bundle is wrong · `PRECISION` right in substance, wrong in detail ·
`ALREADY DONE` open item the repo has since closed · `CONFIRMED` checked and accurate ·
`LOST` referenced artifact that does not exist here.

---

## X-01 — the standing `1 SKIP` in validate-crew — **CORRECTED**

**Bundle says** the skip is probably the environment-conditional class, "C-22 detached-worktree
lineage", flagged `[V?]` with a note that if it is something new it is a silent-skip regression.

**Repo ground truth** it is **C-25**: `scripts/validate-crew.sh` skips because no specialist subagent
start has been recorded yet, so identity coverage has nothing to test. It is neither C-22 nor a
regression — and `context/session-summary.md` already named it before the bundle was written.

**Verify** `./scripts/validate-crew.sh | grep SKIP`

## X-02 — open item #2, "PACK-1 LIVE" — **ALREADY DONE**

**Bundle says** the first live run of the Confluence pack on a real exported document is still
pending, and was the declared next action at the v3.5 close.

**Repo ground truth** it ran on 2026-08-24. A real operator document was processed end to end,
routed `INTERNAL-IT`, and produced its four artifacts in the pack workspace. The
own-documents-only caution the bundle attaches to it was lifted when `APPROVE LITE-SECURITY-1`
closed green.

**Verify** in the Lite repo, `jq -c 'select(.doc_slug|test("it-helpdesk"))' logs/pack-confluence-docs.jsonl`

**Caveat, recorded rather than hidden.** The artifacts in that workspace are a **re-derivation**.
The originals were destroyed by an adversarial drill run against the live pack, and the regeneration
finds one more `med` finding than the original audit line recorded. Lite's `docs/security/redteam-1.md`
carries the full account as F-L2.

## X-03 — closure of the two security gates — **CORRECTED**

**Bundle says** both read as closed by inference `[I]`, because the pasted reconciliation did not
show the tokens, and states that everything downstream inherits that inference.

**Repo ground truth** both tokens are on disk `[E]`. `APPROVE SECURITY-1` is in this repo's
`GATES.md`; `APPROVE LITE-SECURITY-1` is in Lite's, stamped 2026-08-24T01:36:16Z. The inference
resolves to established fact, and so does everything the bundle hangs off it.

**Verify** `grep -c 'APPROVE SECURITY-1' GATES.md`

## X-04 — "S1–S3 tokens" — **CORRECTED**

**Bundle says** the post-audit sessions S1–S3 have gate tokens it could not retrieve `[V?]`, and
characterises their scope as `[I]` — flagging this as the bundle's own weakest claim.

**Repo ground truth** **no `S1`/`S2`/`S3` token exists.** That work is gated as
`APPROVE CR-BATCH-1`, `APPROVE CR-025`, `APPROVE CR-DIAGRAMS` and `APPROVE CR-026`. The session
numbering was working shorthand in the upstream channel and was never gate grammar; searching the
ledger for `S1` finds nothing, which is what produced the `[V?]`.

**Verify** `grep -oE '\`APPROVE [A-Za-z0-9 -]+\`' GATES.md | sort -u`

## X-05 — `APPROVE AUDIT-GATE-A5` in the census — **PRECISION**

**Bundle says** the token was issued through the channel, listing it in the gate census.

**Repo ground truth** the bundle is **right that it was issued and wrong about where it lives.** It
is not in `GATES.md`; it is recorded in `Plan.md`, which states the reason explicitly: audit gates
are kept in `docs/audit/` and `PROGRESS.md` rather than the FIFO ledger, because appending a
different gate series to `GATES.md` would read as reopening a closed plan.

**Verify** `grep -n 'AUDIT-GATE-A5' Plan.md`

**Why this entry is phrased as precision rather than a correction.** An earlier draft of this file
asserted the token was "absent from the parent ledger". That would have published a false claim
inside the document whose purpose is correcting false claims — caught in review before it landed,
and recorded here because it is the entry a future reader is most likely to re-derive wrongly.

## X-06 — completeness of the gate-token census — **CORRECTED**

**Bundle says** its census is the set issued or ratified through the channel.

**Repo ground truth** it omits six tokens that are in `GATES.md`: `PLAN-V3`, `R1D`, `GUIDANCE-2`,
`CR-025`, `CR-BATCH-1`, `CR-DIAGRAMS`. Separately, `GATE-F7` appears **twice** — the F7a and F7b
mid-gates — so a census that counts distinct names and a census that counts rows disagree by one,
and both are defensible only if they say which they are doing.

**Verify** compare `grep -oE '\`APPROVE [A-Za-z0-9 -]+\`' GATES.md | sort -u` against the bundle's list

## X-07 — the five Lite phase tokens — **CONFIRMED**

**Bundle says** five Lite build-phase tokens exist but were not retrieved individually `[V?]`.

**Repo ground truth** confirmed: `APPROVE GATE-L0` through `APPROVE GATE-L4`. Lite's ledger holds
eleven distinct tokens in total, the other six being the sync, ruling, guard, pack and security
gates.

**Verify** in the Lite repo, `grep -oE '\`APPROVE [A-Za-z0-9 -]+\`' GATES.md | sort -u`

## X-08 — the PACK-2 domain order — **CONFIRMED**

**Bundle says** the next skill-pack order follows `ROADMAP.md`'s Q6 sequence, repo-side `[V?]`.

**Repo ground truth** confirmed, and the order is IAM → Compliance → HR-lifecycle → ITSM → Rest.
IAM is first because the joiner-mover-leaver flow is already modelled by `stress-project/`, and its
blocking decision is named in the roadmap: which identity provider, and whether any pack ever gets
write credentials or stays proposal-only under A4a.

**Verify** `sed -n '/## Domain skill-packs/,/## Dormant/p' ROADMAP.md`

## X-09 — `docs/RULINGS.md` as the parent-side counterpart — **CORRECTED**

**Bundle says** the authoritative repo-side counterparts to its ruling register include
`docs/RULINGS.md`.

**Repo ground truth** that file is **Lite-only**. This repo has no rulings register; parent rulings
live in the plan's changelog as numbered D-entries, with `context/plan-corrections.md` carrying the
correction register. A reader following the bundle to `docs/RULINGS.md` here finds nothing.

**Verify** `ls docs/RULINGS.md` here versus in the Lite repo

## X-10 — `ReportforClaudeWeb.txt` — **CORRECTED**

**Bundle says** the file is 51,290 bytes, and places it in the `source_files/` archive.

**Repo ground truth** the repo copy is **51,573 bytes** — it diverged when CR-012 corrected
propagated figures inside it. And there is a **second** file the bundle does not mention,
`ReportforClaudeWeb_2.txt` (12,857 bytes), the post-v1.0.0 audit handover. Both are untracked and
gitignored; the glob that covers them exists precisely because the second one arrived after a
literal filename rule had been written for the first.

**Verify** `wc -c ReportforClaudeWeb*.txt` and `git check-ignore -v ReportforClaudeWeb_2.txt`

## X-11 — the memory export's state claims — **CONFIRMED**

**Bundle says** in its memory export that both repos are green at an earlier pair of commits and
that the plan is "v3.6 triple-synced", and annotates both as recency-bias artifacts.

**Repo ground truth** the annotations are correct and the underlying claims are stale. The
post-security reconciliation pair is newer, and the triple is **not** synced: the web leg still
carries v3.0 while repo and upstream carry v3.6. Recorded as confirmed because the bundle already
caught its own memory layer — which is the behaviour that makes the rest of it trustworthy.

## X-12 — open item #1, "SYNC" — **VOID (superseded by R-CH-1, 2026-08-25)**

**Bundle says** the web project's plan pair must be replaced v3.0 → v3.6, that the bundle does not
satisfy this, and that until it lands the escalation channel reasons from an authority missing
R-SD-1's promotion, H0a, and the whole security phase.

**Repo ground truth** the description was accurate when written, and the item is now **void**.
Ruling R-CH-1 retired the upstream channel: there is no web project to sync a plan pair to. SYNC is
not closed by completion — it is closed by the disappearance of its destination, which is a different
thing, and recorded as such so nobody reads a resolved item and assumes an upstream copy exists
somewhere. The plan is authored in this repo now, under its own gate, at v3.7.

---

## Referenced artifacts that do not exist — **LOST**

Two categories, and the difference matters: one was promised and never arrived, the others existed
and are gone from both sides.

### Never delivered

- **`source_files/`** — the bundle's index promises verbatim copies of all 21 project-knowledge
  files. That directory is not present; the drop is six files. This was recorded as a **gap in the
  transfer** rather than a loss, on the ground that the web project still held the files.
  **R-CH-1 removed that ground the same day**: the channel is retired and the archive will not be
  fetched. The category is kept because the distinction remains true and still matters — these
  twenty-one files exist and simply will not be retrieved, where the four below no longer exist
  anywhere. Recorded so nobody reads the bundle's index and assumes the archive is on disk.

### Lost from both sides

- **`AUDIT_TRAIL_R3.md`, `AUDIT_TRAIL_R4.md`, `AUDIT_TRAIL_R5.md`** — the record of the three audited
  plan re-iterations, and the only place the P1–P5 operator-pushback exchanges were written down.
  The plan's own header cites R3, R4 and R5 by name. They are absent from the web project's current
  file listing and absent from `docs/audit/`, which holds eight other documents. A content search
  finds no P1–P5 record anywhere in this repo.
- **`CLAUDE_CODE_FINAL_AUDIT_PROMPT.txt`** — the prompt that drove the final audit session, cited by
  the 2026-08-16 rulings file.

**What survived instead.** `docs/audit/RULINGS_AND_DEPLOYMENT_2026-08-16.md` is tracked here, though
the bundle placed it in the absent `source_files/`. The audit's _findings_ survive in
`docs/audit/FINAL_AUDIT_REPORT.md`, `DECISION_AUDIT.md`, `DIAGRAM_AUDIT.md`, `DECISION_MATRICES.md`
and `CHANGE_REQUESTS.md`. What is unrecoverable is the _argument_ — the pushback exchanges and the
audit prompt's own wording.

**Not chased, by operator decision.** No re-export was requested. Fixed forward, unrecoverable
backward. Nothing to decide, recorded so nobody re-derives it.

## The bundle's own weakest claim, carried forward

The bundle flags its S1–S3 session characterisation as its weakest claim, inferred rather than
established. X-04 resolves it: the sessions are real, the _tokens_ it inferred are not, and the
repo ledger is the check the bundle correctly pointed at.

## Backup location

The fenced bundle is copied to `$HOME/context-transfer-backup/`, verified byte-identical per file at
the time of the fence. Recorded here rather than inside the bundle, because a backup whose only
record lives in the thing being backed up is not a backup.
