# AUDIT-RUBRIC — the auto-audit's rubric, queue, and laws (ARC4-1; nothing autonomous)

## What "autonomous" means here, first

Autonomous means UNATTENDED ANALYSIS, never unattended scheduling. The runner (ARC4-2) is
invoked by the operator, or by a session acting on a staleness line — no cron, no daemon, no
self-starting anything. This gate ships rubric, queue, schemas, and laws; it runs nothing.

## The findings schemas — three dive obligations, discharged by name

The dive ladder filed three shapes with this gate; each is adopted into the record schemas
below, citing its dive:

**RUN records** (one per runner invocation, `logs/audit/runs.jsonl`):
`{ts, status, is_explicit, reason, repos_scanned, findings_count, errors}`
- `status` ∈ {completed, terminated, part-timeout, crashed} — the termination vocabulary from
  CORPUS-CONDUCTOR (`is_explicit` separates a chosen stop from a death; explicit stops carry
  their structured `reason`) and CORPUS-TAKT (`part-timeout` is the typed stale-channel state,
  never a generic crash).
- **Coherence rule, from CORPUS-ZEROSHOT:** `errors` is EMPTY if and only if
  `status == completed` — a run record claiming success while carrying errors (or failure
  while carrying none) is incoherent and any consumer must treat it as broken.

**FINDING records** (zero or more per run, `logs/audit/findings.jsonl`):
`{ts, run_ts, repo, axis, value, baseline, band, severity, claim}`
- `severity` reuses security.md's vocabulary exactly (low/med/high/crit) — no second scale.

## The axes and bands — from S0's EARLY baseline, deliberately

Bands were born from the S0-RECONCILE baseline (2026-08-31, pre-drift, per the anti-trough
ruling) and RECALIBRATED at `APPROVE ARC4-RECAL` (2026-09-01, after arc 5, as that gate was
named from birth): the large plan's growth landed — every repo grew, none shrank, the audit's
first live runs read zero findings against the birth bands — so the floors now hold the NEW
plateau (floor = the post-program measured count; a shrink from TODAY's reality is the
signal) and ceilings stay 3x. The S0 birth values remain durable in Plan.md; the next
recalibration is on the operator's word, not a schedule.

**Axis A — tracked-file count, PER-REPO** (an aggregate band over six repos of wildly
different density is meaningless): floor = the S0 baseline (a repo shrinking below its
birth-measured footprint is an investigate-now signal), ceiling = 3× baseline (runaway-growth
signal).

**Axis B — docs older than the newest gate** (ADVISORY, never red): the parent's baseline 62
is dominated by HISTORY — chronicle and audit documents frozen BY DESIGN — so a band that
punished old docs would punish the archive for existing. Axis B is reported for review only.

**Axis C — suite totals** (floor only): a suite may grow without bound; shrinking below the
S0 floor is the signal. Honest limit, stated per the CR-027/C-28 lesson: totals are NOT
environment-invariant (an archive extract and a primary checkout legitimately differ), so
axis C findings state which environment produced the number, and only primary-checkout
figures compare against these floors.

```text
# ARC4-BANDS v1
psychic-crew	183	549	254
psychic-crew-lite	62	186	67
psychic-templates	21	63	44
psychic-sidekick	22	66	64
psychic-repurpose	28	84	78
psychic-plugins	18	54	36
```

Columns: repo · axisA_floor · axisA_ceiling (3×) · axisC_floor. Axis B carries no band by
design (see above).

## The honest-limit paragraph (axis B and the whole instrument)

Staleness is never wrongness: an old document can be perfectly true (most of the parent's old
docs are frozen history and SHOULD not churn). The rubric flags for a reader's judgment; it
proves nothing about content. And per shell-discipline rule 4: everything under `logs/audit/`
is RUNTIME, machine-local BY DESIGN — this signal does not travel off this machine, and no
answer derived from it should be presented as if it did.

## The queue — durable, token-gated, empty-legal

```text
# AUDIT-QUEUE v1
```

Columns when rows exist: `qid · ts · repo · axis · severity · claim · status · cr_id`.
`status` ∈ {OPEN, ACCEPTED, REJECTED, CLOSED}. The vacuity guard is NON-STANDARD and that is
the point: an EMPTY queue is legal (a healthy estate audits clean; the suite must not demand
findings exist) — but a queue whose HEADER fails to parse is a broken instrument and fails
loudly. Emptiness and brokenness are different states and the guard distinguishes them.

## The runtime → durable bridge

Findings are born runtime (`logs/audit/findings.jsonl`, machine-local). PROMOTION is a human
act at a gate: an operator or session performing "triage the audit queue" READS the runtime
findings and WRITES AUDIT-QUEUE rows above — under that gate's token, like any other tracked
change. Nothing promotes itself.

## The mechanical gated-fixes law

A queue row may only carry `status` ACCEPTED or CLOSED if BOTH hold: its `cr_id` appears in
`Plan.md` (the decision is chronicled) AND the row's fix rode a gate with an APPROVED row in
`GATES.md`. The suite enforces the first half mechanically (cr_id findable in Plan.md) and
fire-probes it; the second half is procedural and stated here. Findings-only-gated-fixes is
the arc's ruling: the audit may LOOK autonomously; it may CHANGE nothing without a token.
