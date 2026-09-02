# POLICY-RULES — the escalation policy, as written prose (TEI-1)

This is the SOURCE the compiled rules in `config/escalation-rules.json` derive from — the
RSCH-3 §C tier table, one vocabulary, no second scale. Each row cites the rule id that
compiles it (rules beside data). Changing a rule is a GATE: the compiled file is byte-pinned
by the suite, so an edit is red until a gate updates the pin.

| Rule id | Policy (as §C states it) | Tier |
|---|---|---|
| `R-READ` | Read-only summarization and analysis — log and proceed | `low` |
| `R-REVERSIBLE` | Reversible internal change — proceed on acknowledgement; suites verify | `med` |
| `R-EXTERNAL` | External communication or material impact — BLOCKING: explicit approval quoted back before work (R3a) | `high` |
| `R-CRITICAL` | Financial / legal / security / employment action — exact gate token; dual-gate; specialist review | `crit` |
| `R-PROHIBITED` | Prohibited or unverifiable surface — mechanically refused; no in-session override | `deny` |
| `R-DEFAULT-DENY` | Anything no rule covers — policy must gain a row at a gate before it can be tiered | `deny` |

The engine (`scripts/route-tier.sh`) is deterministic: first matching rule wins, in file
order — and the ORDER IS THE POLICY: most-restrictive first (deny, crit, high, med, low, then
the catch-all deny), because a reversible-looking action on a critical surface must route by
the surface, never the action (the fail-open the first compilation had, caught by smoke and
fixed before any arm existed). A model may RECOMMEND a
classification; the recommendation is LOGGED BESIDE the verdict and never consulted — proven
behaviorally by the suite's recommendation-ignored control, not promised in prose.
