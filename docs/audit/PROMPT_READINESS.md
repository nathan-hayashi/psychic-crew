# PROMPT_READINESS.md — A5.2b

Two questions. Do the **agent-side** contracts meet the task-contract rubric — goal, context,
requirements, process, output, verification? And does a **user-facing** intake layer exist that
turns a vague human request into one of those contracts?

The answers are yes with one exception, and no.

---

## 1. Agent-side contracts — measured against the rubric

Eight agent bodies, each scored on the six rubric elements `[E]`.

| Agent                | Lines | Goal | Context (backstory) | Requirements | Process (numbered) | Output shape | Verification      |
| -------------------- | ----- | ---- | ------------------- | ------------ | ------------------ | ------------ | ----------------- |
| `security-reviewer`  | 32    | ✅   | ✅                  | ✅           | dimensions         | ✅ FINDINGS  | ✅                |
| `test-runner`        | 32    | ✅   | ✅                  | ✅           | do / do-not lists  | ✅ explicit  | ✅                |
| `quality-reviewer`   | 30    | ✅   | ✅                  | ✅           | dimensions         | ✅ FINDINGS  | ✅                |
| `fixer`              | 29    | ✅   | ✅                  | ✅           | ✅ 5 steps         | ✅ verdicts  | ✅ runs the suite |
| `lead-executor`      | 25    | ✅   | ✅                  | ✅           | ✅ 5 laws          | ✅ commits   | ✅ gates          |
| `integration-runner` | 22    | ✅   | ✅                  | ✅           | ✅ 4 laws          | ✅ paths     | ✅                |
| `arbiter`            | 21    | ✅   | ❌                  | ✅           | ✅ 5 steps         | ✅ FINDINGS  | ⚠️ no self-check  |
| **`lead-planner`**   | **8** | ✅   | ❌                  | partial      | **❌ none**        | **❌ none**  | ⚠️ FALLBACK only  |

**Seven of eight are genuinely good contracts**, and better than most agent definitions in the
wild. Three features stand out as worth copying:

- **A backstory that names the failure mode the agent exists to prevent.** `test-runner`: "you
  exist because interpreted test results are how a red suite becomes a green summary." That is a
  behavioural constraint disguised as characterisation, and it is more actionable than a rule.
- **Explicit do-not lists.** `test-runner` forbids compressing a failure into a phrase, re-running
  until green, and omitting a failure that looks unrelated. Each is a real observed behaviour, named.
- **A verification clause that is falsifiable.** `fixer` must run the suite after every change and
  revert any fix that breaks it. `quality-reviewer`'s dismissal standard requires a mitigation
  **located and read** — an assumption leaves the finding standing.

### PR-F1 — `lead-planner` is the thinnest contract and the most consequential

**P2 · contract asymmetry · Failure scenario:** a plan comes back in a shape nobody specified,
missing a rollback tag or an acceptance assertion. The gap is invisible until the operator reads it
at a mid-gate, and the cost of the re-iteration is a full opus-max dispatch.

`lead-planner` is **8 lines, one paragraph**, against a 21–32 line median for the other seven. It
has no backstory, no numbered process, and — most consequentially — **no output schema**, while
every reviewer has a JSON contract and the fixer has an enumerated verdict vocabulary.

The body does name the required elements in prose: "numbered, gate-structured plans with explicit
file paths, acceptance assertions, rollback tags, and token budgets." That is the contract, written
as a sentence rather than as a checkable shape.

Two things make the asymmetry matter rather than being a style point:

1. **It is the most expensive agent to re-run.** `effort: max` on opus. Measured mean 48,935 tokens
   over 2 dispatches `[E]` — the cheapest per-dispatch of any lead, but a re-iteration costs a
   fresh one, and its output is what an operator approves at a mid-gate.
2. **Its output has no machine-checkable shape**, so a malformed plan cannot be rejected the way a
   malformed FINDINGS packet can. The arbiter's fallback rule catches specialist packets below
   confidence 0.6; nothing performs the equivalent check on a plan.

C-17 is the historical evidence: the planner correctly refused to invent a gate token and returned
a FALLBACK at confidence 0.45. It behaved well — but it behaved well because the _agent_ was
careful, not because the _contract_ made the failure detectable.

**Recommended, not implemented:** bring `lead-planner` to parity — a backstory naming the failure
it prevents, a numbered process, and a plan schema (steps, paths, acceptance assertions, rollback
tags, budgets) that a script could validate. Folded into CR-026's scope or separable.

### PR-F2 — the arbiter has no self-verification step

**P3 · contract completeness · Failure scenario:** the arbiter completes steps 1–5 and releases a
packet whose audit line it never actually wrote, because nothing in its own contract asks it to
confirm the write landed.

`arbiter.md` has an excellent five-step process and the only mandatory-schema language in the
roster (`ts` MUST be full ISO-8601; `task_id` MUST match the dispatch). What it lacks is a step 6:
_confirm the audit line is on disk before releasing._ Steps 4 and 5 are ordered but not
interlocked.

This is not hypothetical. A4 measured that **3 of 19 arbiter lines carry no `task_id`** and **0 of
19 satisfy the `ts` format its own contract mandates** `[E]`. Both are pre-F8 records written
before the schema tightened, so neither is a breach of the rule as it stood — but they demonstrate
that the contract's MUST clauses have never been self-enforced at write time, only checked
afterwards by `validate-crew`, and then only for `ts`.

---

## 2. The user-facing intake layer — confirmed absent

**It does not exist** `[E]`. The complete user-facing surface of this build is:

| Surface                            | What it does                                          |
| ---------------------------------- | ----------------------------------------------------- |
| `CLAUDE.md`                        | standing context, loaded every session                |
| `.claude/skills/threshold-router/` | scores a prompt to a tier; the only skill in the repo |
| Gate tokens                        | `APPROVE GATE-Fn`, exact match                        |
| `.claude/commands/`                | **does not exist**                                    |

There is no guided goal capture, no clarification protocol, and no risk-classed confirmation step.
A request enters as free text and the orchestrator decides what it means.

That was the right call for this build — the plan supplied every objective in advance, so an intake
layer would have had nothing to intake. It stops being the right call the moment the crew is
pointed at work the plan did not pre-specify, which is precisely what the roadmap describes.

### CR-026 — user-facing intake / task-contract layer (specification only)

**What.** A skill that converts a free-text request into a task contract carrying the same six
elements the agent bodies already use, before any dispatch happens.

**Three components:**

1. **Guided goal capture.** Restate the request as a goal with an observable completion condition.
   If the restatement cannot be written, that is the signal to clarify rather than proceed — the
   same discipline `fallback-protocol.md` already applies to agents, turned to face the user.

2. **Bounded clarification — at most three multiple-choice questions.** The bound is the design.
   Unbounded clarification is how an intake layer becomes an interrogation and gets bypassed. Each
   question must be one whose different answers produce materially different work; anything
   answerable from the repo is answered from the repo, not asked. This mirrors
   `fallback-protocol.md` rule 4: never ask for what is already in `CLAUDE.md`, `Plan.md`,
   `PROGRESS.md` or the dispatch packet.

3. **Risk-classed confirmation.** Classify the resulting contract before executing, reusing
   `.claude/rules/security.md`'s existing severity vocabulary rather than inventing a second scale:

   | Class  | Trigger                                                                       | Confirmation                                  |
   | ------ | ----------------------------------------------------------------------------- | --------------------------------------------- |
   | `low`  | read-only, or writes confined to `logs/` and scratch                          | none                                          |
   | `med`  | writes tracked files; no permission or gate surface touched                   | show the contract, proceed on acknowledgement |
   | `high` | touches `.claude/settings.json`, a byte-pinned seed, or `.gitignore` removals | explicit operator approval, quoted back       |
   | `crit` | changes a gate rule, a deny-list entry, or model identity                     | gate token, exactly as phases require         |

**Why it is worth building.** The agent-side contracts are strong and the human-side has none, so
every contract in this system is authored by the orchestrator from an unstructured request. That
asymmetry is invisible while the plan supplies the objectives and becomes the weakest link the
moment it does not.

**Why it is specified and not built.** Out of audit scope, and it needs a decision this audit
cannot make for the operator: whether intake is advisory or blocking. Advisory is safe and
skippable; blocking is real and will be resented on the first low-risk task it interrupts. The
risk-class table above is written so the answer can be _both_ — blocking only at `high` and `crit`.

**Effort** 6h · **Risk** medium · **Gate** no, provided it only classifies and does not itself
widen any permission.
