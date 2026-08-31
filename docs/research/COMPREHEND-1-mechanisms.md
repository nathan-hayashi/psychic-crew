# COMPREHEND-1 — the comprehension layer: mechanisms, costs, drift risks

**The problem, in the operator's words:** "hard to understand what the code does since the user's
role is just prompt engineering with inputs, decision making and planning BUT the hard part is the
review of everything engineered… Need a way to create the same result but an easy way to understand
what each line of code does and why… trust… established from paranoia of not being able to take the
code and knowing it all (context loading a human brain at this scale is not feasible)."

**Scope already decided (operator, 2026-08-31): forward-only.** The past is covered by the
CHANGE-PLANE chronicle + index; this gate chooses the mechanism for every gate from adoption on.
Nothing is built here — the choice is the operator's at this STOP; COMPREHEND-2 implements it.

## What the field does (dated fetches, 2026-08-31)

- **Google eng-practices, CL descriptions:** every change carries a description written for a
  future reader — "Reading source code may reveal what the software is doing but it may not reveal
  why it exists, which can make it harder for future developers to know whether they can move
  Chesterton's fence." The unit of explanation is the CHANGE, and the why outranks the what.
- **Architecture Decision Records:** one decision per record, with context, trade-offs and
  consequences — "ADR can help you understand the reasons for a chosen architectural decision,
  along with its trade-offs and consequences." The unit is the DECISION. (This build's Plan.md +
  D-changelog already are ADRs in the expert voice — dense, ID-laden, written for the auditor.)
- **CodeTour (Microsoft):** guided walkthroughs as JSON steps anchored to files/lines; tours
  "make it easier to onboard (or re-board!) to a new project/feature area" — and the docs concede
  tours ROT, so CI "detect[s] 'tour drift' in response to PRs/commits." Independent confirmation of
  this repo's own INDEX-1 lesson: an unbound map rots, so anchors must be mechanically checked.

## What this estate already has, honestly assessed

STOP reports, Plan.md entries, the D-changelog, GATES rows, the CHANGE-PLANE — a complete WHY
record, but written in the expert voice: dense with IDs (C-xx, CR-xxx, R-_, HC-_), assuming the
reader holds the whole doctrine. GETTING-STARTED covers setup, not change review. **The gap is a
plain-language, per-change, verify-it-yourself layer** — the manager's-altitude explanation that
costs the operator no doctrine to read.

## The mechanisms

| #   | Mechanism                                                                                                                                                                                                               | What the operator gets                                                                                   | Cost per gate                                                                 | Drift risk                                                                                                                                                               | Verdict                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| A   | **Per-gate explainer** (`docs/explainers/<gate>.md`): plain language, fixed sections — _what changed / why / what each piece does / how to verify it yourself (commands to run) / what could break and what catches it_ | the "overview after each gated phase" they asked for, at management altitude, with runnable trust checks | one short doc (~60–100 lines), written at the STOP alongside the ledger entry | **LOW** — an explainer describes a FROZEN commit; history doesn't rot. The binding guards existence-per-gate (epoch anchor + vacuity guard + fire-probe, CR-024 pattern) | **RECOMMEND as the standing rule**                                    |
| B   | **Per-line/per-block inline annotations** (the literal "what each line does" reading)                                                                                                                                   | maximal granularity                                                                                      | very high — every edit narrated                                               | **HIGH** — comments rot with edits (the unbound-map class in its worst form), and the house comment law forbids narration comments for exactly this reason               | **RECOMMEND AGAINST as a standing rule**; superseded by D on demand   |
| C   | **Anchored code tours** (CodeTour shape, but bound with the INDEX-1 anchor machinery — no extension needed, tours as tracked markdown with suite-checked anchors)                                                       | subsystem-level walkthroughs ("how does the gate machine work end-to-end") for onboarding/re-boarding    | moderate, but per-SUBSYSTEM not per-gate; only when a subsystem changes shape | **MEDIUM, mechanically caught** — anchors bind both ways like the chronicle index                                                                                        | **OFFER per-subsystem, on demand**                                    |
| D   | **On-demand explanation as a routed skill** ("explain this file/change to me plainly") — no artifact, answers built live from the frozen record                                                                         | zero standing cost; any altitude on request                                                              | zero until asked                                                              | none (nothing persisted to rot)                                                                                                                                          | **ADOPT alongside A** (lands as a ROUTE-1 routing entry, not a build) |

## The recommendation, stated

**A + D: the per-gate explainer as the standing rule, with on-demand plain-language explanation
routed as a skill.** A gives the trust artifact the operator described — short, plain, per-gate,
with commands they can run themselves so trust rests on _verification they can perform_, not on
belief. D covers the "what does this line do" need at any depth without planting narration comments
that rot. B is rejected for the same reason the house comment law exists. C stays available when a
subsystem deserves a tour.

**The binding COMPREHEND-2 would build (if A is chosen):** `docs/explainers/INDEX.md` declares the
epoch as the adoption gate's NAME; the suite asserts every GATES row _after_ that name has an
explainer file (row-position binding — the ledger's ISO column is empty on recent rows, so dates
cannot anchor), a vacuity guard proves the post-epoch set is non-empty, and a fire-probe plants a
missing-explainer fixture. Explainer sections are fixed so a reader always knows where "how do I
verify this myself" lives.

## The decision (operator's, at this STOP)

Pick A+D (recommended), A alone, C-flavored, or something else — COMPREHEND-2 builds exactly the
choice and nothing more.
