# DIVE-W1-GA-1 — gastown, under the liveness question

**Gate:** DIVE-W1-GA-1 (wave dive 3). **Source:** `gastown-main/` (census `DIVED`, re-opened by this
named question). **Question (fixed at SOURCE-MAP-1):** what is the minimal liveness/stall
vocabulary this estate could adopt from gastown's three-store design without adopting
propulsion — and does NDI deserve a name here? **Prediction on record:** TAKE-FEW.

## Read manifest (measured; sidecar exclusion applies; nothing else was opened)

| artifact | lines | how read |
|---|---|---|
| `internal/polecat/heartbeat.go` | 133 | FULL — states, thresholds, grace semantics |
| `internal/witness/handlers.go` | targeted: :1530-1580 (zombie classifications) + :1740-1800 (the decision path) | the stuck verdict logic |
| `docs/glossary.md` NDI entry | 3 | FULL — the definition under judgment |
| witness/polecat file census | dedup/handlers/manager + tests present; not line-read beyond targets | measured |

## The answer — the minimal adoptable vocabulary

Gastown's liveness design, at implementation depth, splits into exactly two planes:

1. **Agent-reported state** — `working | idle | exiting | stuck`, written by the agent itself
   into its heartbeat. **The witness makes exactly ONE inference: is the heartbeat fresh?**
   (their comment, twice in code). Everything else trusts the report.
2. **Typed stall CLASSIFICATION, distinct from lifecycle state** — nine reasons
   (stuck-in-done, agent-dead-in-session, bead-closed-still-running, done-intent-dead,
   idle-dirty-sandbox, session-dead-active, agent-self-reported-stuck, never-heartbeated,
   submitted-still-running), each naming the DETECTION REASON; downstream verdicts derive
   from the typed classification, never a separately-computed boolean.

Guard rails their incidents bought: an ABSENT signal is never stuck (missing heartbeat
returns false + fall-through to other checks — the multi-store rule mechanized);
`never-heartbeated` needs a startup GRACE and takes NO auto-action ("auth errors don't
self-heal — flagged for review"); a stale signal falls through to legacy checks rather than
verdicting directly; and a TOCTOU re-check runs before any action (the session may have
exited between check and act).

**The minimal estate-side form** (no resident watchdogs here — our agents are subagents in
sessions; our "heartbeat" already exists as the last trail event per dispatch in
subagent-starts/stops and tooluse-audit): (a) the two-plane rule as doctrine — a stall
verdict requires the self-reported plane AND the one freshness inference to agree, absent
signals never verdict, grace before first-signal judgments; (b) the typed classification
vocabulary for whenever the arbiter's trail ever declares a stall. Both land as ONE shape in
the successor's arbiter-schema gate (the ARC4-1 earmark family, where PART_TIMEOUT already
waits), with an announce-plane freshness arm over live trails as its first mechanical form.

## NDI — judged, and declined a name

Glossary definition read: "useful outcomes through orchestration of potentially unreliable
processes… guarantee eventual workflow completion even when individual operations may fail."
NDI names an EVENTUAL-COMPLETION property that presumes autonomous retry until done — the
propulsion philosophy this estate rejected at S6 by ruling. Our practice is
bounded-fallback-then-human: a FALLBACK block below confidence, an ESCALATE at exhaustion, a
gate before every phase. Those already have names. Adopting NDI's name would import
semantics our gate law contradicts. The S6 question ("what the FALLBACK protocol is groping
toward") closes with the honest answer: it gropes toward FALLBACK and ESCALATE, which exist.

## Verdicts

```text
# DIVE-GA-1-VERDICTS v1
1	two-plane-liveness-rule	TAKE-PATTERN	GR-041	heartbeat.go:14-56 + handlers.go:1740-1770 (one-inference comment)
2	typed-stall-classification-vocabulary	TAKE-PATTERN	GR-041	handlers.go:1530-1578 (reason-not-state; ImpliesActiveWork derived)
3	self-stuck-escalate-never-restart	VALIDATE-AGAINST	GR-041	handlers.go:1752-1760; converges with ARB-ORCA-1's escalate-never-replan
4	toctou-recheck-before-action	VALIDATE-AGAINST	GR-041	handlers.go gt-0pst guard; TICK-1's re-assertion philosophy, independently arrived
5	ndi-as-named-doctrine	REJECT	GR-086	glossary.md:13-14; eventual-completion contradicts gate law - declined with reason
```

Roll-up: **2 TAKE-PATTERN · 0 MODULATE-OURS · 2 VALIDATE-AGAINST · 1 REJECT** — measured
outcome **2 TAKE-class** (TAKE-FEW; the prediction held, three for three).

## Landing shapes

| mechanism | landing shape | future gate | register rows closed |
|---|---|---|---|
| two-plane rule + typed classification | one STALL-VOCAB shape into the successor's arbiter-schema gate (joins the ARC4-1 earmark family beside PART_TIMEOUT): the doctrine paragraph + the classification vocabulary + an announce-plane freshness arm over live dispatch trails (never a hard fail at birth - the C-25b lesson) | the successor's schema gate | GR-041 |

## Register delta

- GR-086 → **RESOLVED:DIVE-W1-GA-1** (flip logged) — resolved BY DECISION: NDI is declined a name
  here, with the reason in this record; the question the row carried is answered.
- GR-041 stays OPEN: specified is not built; the landing is queued.
- No new rows.

## Weakest claims, flagged

`[I]` The witness decision path was read at its two load-bearing regions, not all of
handlers.go (~1800+ lines); a third detection plane elsewhere would be missed — the zombie
classification enum argues against one existing. `[E-limits]` The watchdog CHAIN
(Deacon/Witness/Boot the Dog) was deliberately not re-read: the S6 record already holds it,
and the question asked for the minimal vocabulary, not the daemon topology.

Evidence census: [E] 9 · [I] 2 · [S] 0 · [V?] 0
