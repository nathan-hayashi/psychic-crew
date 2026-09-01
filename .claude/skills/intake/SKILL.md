---
name: intake
description: Turn a free-text request into a task contract before any dispatch. Use PROACTIVELY on every user request in this repo that asks for work rather than an answer.
---

Every agent in this crew has a contract — a goal, a context, requirements, a process, an output
shape and a verification clause. The human side had none, so every contract in this system was
authored by the orchestrator from an unstructured request. That asymmetry was invisible while the
plan supplied the objectives; it is the weakest link the moment it does not.

Mode is **R3a hybrid**: blocking only at `high` and `crit`, advisory below.

## 1. Guided goal capture

Restate the request as a goal with an **observable completion condition** — something a later
session could check without asking anyone what was meant.

- "Make the tests better" is not a goal. "Every hook wired in settings.json has at least one
  assertion that fails when the hook is removed" is.
- **If the restatement cannot be written, that is the signal to clarify — never to proceed.** This
  is `.claude/rules/fallback-protocol.md` discipline turned to face the user: below 0.6 confidence
  on a load-bearing step, return a question, not a guess.

## 2. Bounded clarification — at most THREE questions

The bound is the design, not a budget. Unbounded clarification is how an intake layer becomes an
interrogation and then gets bypassed.

- Each question must be one whose **different answers produce materially different work**. If every
  answer leads to the same next step, it is not a question, it is a courtesy.
- Multiple-choice, with a recommended option first.
- **Anything answerable from `CLAUDE.md`, `Plan.md`, `PROGRESS.md`, `GATES.md`,
  `context/plan-corrections.md` or the repository itself is answered from there and NEVER asked.**
  That is `fallback-protocol.md` rule 4, and it is the rule that keeps this layer from becoming a
  tax on the operator for facts already on disk.
- Three is a ceiling, not a quota. Zero questions is the correct outcome for an unambiguous request.

## 3. Risk-classed confirmation

Reuses the severity vocabulary from `.claude/rules/security.md` exactly. **There is no second
scale** — a class here means the same thing it means in a FINDINGS packet.

| Class  | What it means here                                                                  | Confirmation                                                              |
| ------ | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `low`  | Read-only, or writes confined to `logs/` and scratch                                | none — proceed silently                                                   |
| `med`  | Writes tracked files; no permission or gate surface touched                         | show the contract, proceed on acknowledgement                             |
| `high` | Touches `.claude/settings.json`, a byte-pinned seed, or removes a `.gitignore` rule | **explicit operator approval, quoted back. No dispatch until it arrives** |
| `crit` | Changes a gate rule, a deny-list entry, or model identity                           | **exact gate token, as phases require**                                   |

`low` and `med` never block. `high` and `crit` always do (R3a).

### The classifier, in a form a check can read

First matching row wins, evaluated top to bottom. This table is extracted and exercised by the
suite, so it is data, not decoration — if you change a row, a test changes with it.

```text
# INTAKE-CLASSIFIER v1
crit	gate token
crit	gate rule
crit	permissions.deny
crit	deny-list
crit	models.config.json
high	.claude/settings.json
high	hooks/
high	.gitignore
high	byte-pinned seed
med	scripts/
med	.claude/agents/
med	.claude/rules/
med	write
low	*
```

### Specialist fit — a separate lookup (SIDE-3)

Who WOULD do the work if dispatched is not a classification question and does not live in
the table above: it is a typed lookup in `.claude/skills/army-selector/SKILL.md`. That skill
returns advice, never a license to dispatch — the zero-dispatch default stands.

## 4. Emit the contract

Append exactly one JSON line to `logs/intake-contracts.jsonl` (gitignored) **via Bash `>>`, never the
Write tool** — the append-only guard (CORRECTIONS-2 #7, `hooks/sensitive-guard.sh`) denies a
whole-file Write to this trail, and a Bash append is the correct single-line form regardless:

`{"ts","goal","completion_condition","class","questions_asked","approval"}`

`approval` is `"none"` for `low`, the acknowledgement text for `med`, the operator's quoted words
for `high`, and the exact token for `crit`. A `high` or `crit` contract written with
`approval: "none"` is a breach of this skill, not a shortcut.

## 5. What is mechanically checked, and what is not

Stated plainly because the alternative is worse. This repository has recorded ten instances of a
control bound to a proxy rather than the artifact, and a check that grepped this file's prose and
called the result a behavioural test would be the eleventh.

**Mechanically asserted by `run-crew-tests.sh`:** that this file exists at the path the §4.3 map
names · that the four class tokens match `security.md`'s vocabulary exactly · that the classifier
table above classifies fixture requests correctly, including the three the CR names — a read-only
request as `low`, a `.claude/settings.json` request as `high`, a gate-rule request as `crit`.

**NOT mechanically asserted, because it is model-interpreted:** whether a restatement's completion
condition is genuinely observable · whether a question's answers would really produce different
work · whether a request that names no path nevertheless implies one. Those are judgment, and no
grep decides them.

### Manual drills — run these when this skill changes

Each has a stated expected outcome. They are drills, not tests, and this section is the honest
record that they are executed by a person rather than by the suite.

1. **High-class blocks.** Ask for a change to `.claude/settings.json`. Expect: a contract emitted,
   class `high`, **no dispatch**, and an explicit demand for approval quoted back. Failure looks
   like work starting before the approval arrives.
2. **Low-class is silent.** Ask to read and summarise a tracked file. Expect: class `low`, **zero**
   questions, zero blocking, and no contract ceremony in the reply.
3. **The ceiling holds.** Ask something genuinely ambiguous on four independent axes. Expect: **at
   most three** questions. Failure looks like a fourth question, or like three questions plus a
   trailing "also, did you mean…".
4. **On-disk answers are not asked.** Ask something whose answer is written in `Plan.md` or
   `GATES.md` — for example which gate tokens have already been approved. Expect: **zero**
   questions and the answer read from disk.

## 6. Pulling a blueprint (RPG-2)

When a request matches one of the pinned triggers below, the orchestrator MAY pull the named
blueprint from the repurpose gallery — BY PATH, never by pasting the body. The sibling checkout
resolves via `PSYCHIC_REPURPOSE_PATH` (default `../psychic-repurpose`, the sidekick precedent).
A pull takes the blueprint plus its `requires` closure as the sibling index precomputes it.

The pin is a VENDORED copy — the vendored-vocabulary blueprint applied to its own gallery: the
full id list plus three named triggers, bound unconditionally by the suite against this block
and diffed against the live sibling only when a checkout is present (absence is announced, never
silent). The drift control mutates the pin in memory and must be seen doing it.

```text
# REPURPOSE-PIN v1
ids	assembled-needles,commit-straddle,count-binding,explainer-epoch,gate-machine,negative-control,observer-fence,pair-edit-delta-zero,unknown-fields,vendored-vocabulary,witness-manifest
trigger	unbound-figure-drift	a readme states a number the repo can recompute
trigger	never-seen-failing	a checker has never been seen failing
trigger	opaque-gate-change	non-author comprehension is a requirement
```

This section is deliberately CAPPED: the suite fails it beyond 40 lines or a second fenced
block. A pasted-in blueprint body cannot fit under either bound — that is the path-not-body
control the gallery's PULL-PROTOCOL names as landing here.
