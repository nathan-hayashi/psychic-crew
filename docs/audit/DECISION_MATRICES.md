# DECISION_MATRICES.md — S6, 2026-08-20

The last S6 deliverable: decision aids built from the audit's **measured** data, not from
recollection. Every figure here was read off disk when this was written.

Each matrix carries a **decision** column. A matrix that only presents data is a table; the point
of these is that a reader can act from them.

Evidence labels as in `FINAL_AUDIT_REPORT.md`. Line numbers, as everywhere in `docs/audit/`, are
as of the audit — locate by quoted content (CR-033).

---

## M1 — Constraint enforcement: where is this build actually weakest?

The question every other matrix serves. A constraint with no mechanical enforcement is a comment.

| Constraint | Enforced by | Assertions `[E]` | Decision |
| --- | --- | ---: | --- |
| HC-1 tier lock | `validate-crew` + router skill | 5 | none — covered |
| HC-2 no fable | `validate-crew` assignment scan · `model-guard` hook · `apply-models` scan | 2 + hook | none — three independent layers |
| HC-3 scope→model | stamping comparison against config | 8 | none — covered |
| HC-4 one file, one command | stamping, as above | (shared) | none — covered |
| HC-5 no installs | deny-list integrity by name · `bash-blocker` | 2 + hook | none — C-16 closed this |
| HC-6 interpretation locks | **prose only** | 0 | **accept** — they are readings, not mechanisms; nothing to bind |
| HC-7 Claude-only | content scan (CR-030) · deny test | 2 | none — CR-030 closed the gap the plan claimed was already closed |
| HC-8 continuity | `save-context` incl. **3 fidelity bindings** | 24 | **watch** — fidelity binds 3 claims; every other claim in the summary is unbound |
| §15.2 30-line excerpt cap | `reference-cap` hook, **flag only** | 1 | **decide** — flag-only was the C-13 precedent; promote to deny only with evidence of abuse |
| **stall detection** | **nothing** | **0** | **gap** — gastown's mechanism, Lite §6.1. No answer for a hung agent today |
| **temporal bisect of controls** | **nothing** | **0** | **gap** — ruflo's layer 3, Lite §4. Cannot answer "when did this control stop working" |

**Read this way:** eight constraints are covered, one is unbindable by nature, one is deliberately
soft, and **two are absent entirely**. Both absences are already designed into the Lite plan, which
is the strongest argument for building Lite rather than retrofitting here.

---

## M2 — The correction registry, three ways `[E]`

| Quantity | Count | What the difference means |
| --- | ---: | --- |
| Registered IDs in `plan-corrections.md` | **25** | the full record |
| IDs with a detector | **23** | C-16 is enforced in `validate-crew` instead; C-17 has no enforcement and needs none |
| Rows the checker reports | **22** | C-18 lives only in a comment |

**Decision: leave it, and keep the note.** The gaps are explained in the registry itself and each
is deliberate. What made this dangerous before was that the differences were *undocumented* — the
figure "23" was derived from the highest ID rather than counted, and propagated to four places.

---

## M3 — Failure-family closure: is the lesson actually held?

The build's dominant defect was a control bound to a proxy rather than the artifact — ten recorded
instances, and the audit found the family alive **in the controls written to catch it**.

| Instance | Bound to | Now bound to | Control on the control? |
| --- | --- | --- | --- |
| C-23 absolute-path check | `[ -d .git ]` path shape | `git rev-parse --is-inside-work-tree` | yes — drill asserts it ran |
| C-12 detector | a bare token, comments included | correlation predicate, comment-stripped | yes — negative control shipped |
| C-21 detector | file mode | the script's **output** vs the recorded figure | yes |
| map-vs-tree check | a hardcoded list | the map itself, **both directions** | yes — plus a vacuity guard |
| `Read(` denials | a **count** ≥ 2 | the paths **by name** | yes |
| tools-line check | a pipeline that swallowed absence | capture-then-test | yes |
| diagrams | **nothing** | structural validator over every block | **partial — well-formed, never true** |
| distilled summary | hygiene only | 3 fidelity bindings | **partial — 3 claims of many** |

**Decision: the two "partial" rows are the live risk.** Both are honest about their limit in code,
which is the right handling. Neither should be described as closed.

---

## M4 — Corpus value realised: was the reading worth it? `[E]`

~74M tokens on disk. Read: roughly 30KB targeted plus four Tier-A projects.

| Project | Tokens | Depth | What actually transferred | Decision |
| --- | ---: | --- | --- | --- |
| gastown | 4.3M | targeted, ~30KB | stall detection, watchdog chain, Seance, NDI, attribution | **highest yield per token in the corpus** |
| ruflo | 11M | targeted | the **witness manifest** and three-layer verification | second highest; the map had not spotted it |
| oh-my-claudecode | 4.2M | targeted | one platform `[V?]`, and confirmation the staged loop is F7's | low — mostly confirmed what was known |
| the four Tier-A | ~517K | full | the discourse grammar, skills-as-process, distillation | already spent at build time |
| the other nine | ~58M | README only | nothing yet | **do not read further without a named question** |

**Decision: stop general reading.** The two targeted dives returned more than every prior full
read, because `Project-Explorer.md` named the files. Read again only against a specific question,
and start from the tag index.

---

## M5 — What a decision costs, measured `[E]`

Per-role dispatch cost, from `logs/metrics/dispatch-costs.tsv`:

| Role | n | mean tokens | total |
| --- | ---: | ---: | ---: |
| `arbiter` | 8 | 92,689 | 741,515 |
| `quality-reviewer` | 4 | 130,495 | 521,981 |
| `lead-executor` | 5 | 88,874 | 444,372 |
| `security-reviewer` | 3 | 123,923 | 371,770 |
| `fixer` | 2 | 169,410 | 338,820 |
| `integration-runner` | 1 | 198,302 | 198,302 |

**Decision inputs this gives you.** Lite's second blind adversarial pass costs ~124K per change.
Cross-release costs one arbiter-shaped hop, historically ~93K. Both are affordable against a 2.05M
phase. **The one thing not to optimise:** merging the two review branches is the largest available
saving and F7 proved it is the wrong one — the seeded bug invisible to all 18 tests was found by
the uncontaminated branch at the highest confidence in either packet.

---

## M6 — What is actually open

| Item | Blocked on | Decision |
| --- | --- | --- |
| `APPROVE GATE-L0` | nothing — §8 is answered | **ready** |
| Lite repo + §7.1 correlation map | its own session | scope it as L0's first act |
| CR-003 d2 diagram | no renderer, HC-5 | stays deferred |
| CR-006 Vega-Lite | data sits in gitignored `logs/` | move data to `context/` first |
| CR-027 README requirements | nothing | small; do it when convenient |
| CR-028 / CR-029 | folded into the Lite plan | closed as standalone CRs |
| `ROADMAP.md` staleness | the conditional freeze | **decide** — it contradicts `session-summary` on two closed items |

**The `ROADMAP` row is the live illustration of M1's HC-8 "watch".** `session-summary.md` is bound
by C-24 and stayed true; `ROADMAP.md` is unbound and drifted. Same repository, same week, and the
difference is entirely whether a check was pointed at it.
