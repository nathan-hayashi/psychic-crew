# CORPUS-TAKT — the dive, against its named question

**The question (named at CORPUS-0):** How does takt encode the pacing of agent turns (cadence,
budgets), and does any mechanism map onto our budget-baseline discipline?

## Identity

TAKT (Agent Koordination Topology) — a CLI turning coding agents into repeatable YAML
workflows: per-step personas/policies/output contracts, review loops that "cannot be silently
skipped," isolated worktrees, many providers. Its stance is ours in different words: "TAKT
treats AI agents as something to be controlled from the outside, not simply trusted." Built
with itself (dogfooding). Nested extract; sidecars excluded.

## Read manifest (M4: targeted)

README (identity + Why) · `docs/configuration.md` — the guards section read directly
(iteration limits, call_timeout semantics, guard profiles, resource limits) · `docs/` listing ·
targeted greps over `docs/repertoire.md`.

## Findings

1. **The budget primitive is LIVENESS, not spend.** `guards.call_timeout_ms` is the maximum
   period WITHOUT an observable provider event; every stream/tool event resets the timer, and —
   verbatim — "cumulative execution time is not capped." A long call is healthy while events
   flow. Pacing is encoded as freshness.
2. **Even the liveness channel's own failure is bounded and TYPED.** During a tool call the
   inactivity check suspends (start→terminal event is in-flight); a missing terminal event goes
   stale at six times the timeout and ends as `PART_TIMEOUT` — a named partial end state, not a
   hang and not a generic crash.
3. **Iteration limits carry a DECLARED bypass.** `iteration_limit` per event, with
   `ignore_exceed` in config and a CLI flag taking precedence — exceeding the cap is a visible,
   flagged act, never a silent edit.
4. **Guard profiles have a MANDATORY floor.** The `minimal` profile disables heuristic loop
   detection ONLY; "time, bounded-resource, integrity, and strict correction guards remain
   mandatory" — configuration can weaken heuristics, never the core.
5. **Resources are bounded per call**: event_limit 500k, text 1 MiB, reasoning 4 MiB.

## The answer

Yes — one mechanism maps, by exposing what our discipline lacks. Our budget-baseline is
PREDICTIVE accounting on ONE axis: cumulative spend (measured means, pre-registered phase
budgets, the STRESS-1 ratification). Takt prices a SECOND, independent axis as primary:
liveness. A phase here can be comfortably under budget and hung forever — the baseline cannot
see it, and this is the gastown stuck-agent gap corroborated a second time, now from a
budgeting angle. The two axes are orthogonal by construction (takt caps neither what we cap,
nor vice versa).

## The transfer — LANDED as a baseline amendment (in-class), plus one earmark

1. `context/budget-baseline.md` gains a dated section naming the second axis and its owner:
   liveness is UNOWNED in this estate today; the SubagentStop candidate (CORPUS-SDKPY) is the
   death-half of any future stall detection; recorded so the baseline states what it does NOT
   measure (the same honesty its unit section already practices).
2. `PART_TIMEOUT` joins the ARC4-1 termination-vocabulary earmark (with CORPUS-ZEROSHOT's
   coherence shape and CORPUS-CONDUCTOR's is_explicit): partial/stale end states are part of
   the vocabulary that findings-run records must carry. ARC4-1 now owes THREE adopted shapes.

## Disposition

- **Adopted:** the two-axis lesson (landed in the baseline); PART_TIMEOUT -> ARC4-1 earmark.
- **Already held:** declared bypass (= SKIP-with-reason / declared-variance idiom); the
  mandatory guard floor (= universal-first blockers, marker-can-tighten-never-mint, held
  STRONGER since HARNESS-CONV-1); externally-controlled agents (the program's whole premise).
- **Rejected:** nothing — the schemes are complementary.

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)
