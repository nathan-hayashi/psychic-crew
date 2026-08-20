# DIAGRAM_AUDIT.md — A1

Scope: every diagram in the repository, in any format. Validity, accuracy against the artifact
each one depicts, and a coverage matrix over the concepts a reader needs pictures for.

Evidence labels as defined in `FINAL_AUDIT_REPORT.md`.

> **Line numbers in this document are as of the audit, 2026-08-17, and have since moved.**
> Sessions S1–S4 edited the files they cite, so a `file.sh:NNN` reference lands elsewhere today.
> They are left unchanged deliberately: each records where a defect *was found*, and re-pointing it
> at current code would describe a present it was never about. Locate by the quoted content, which
> is stable. (CR-033, 2026-08-20.)

---

## A1.0 Inventory — ground truth

The audit brief's pre-scan reported "exactly three fenced mermaid blocks —
`MASTER_FIFO_PLAN_CLAUDE.md`, `README.md`, `stress-project/README.md`". Measured, there are
**two** `[E]`.

| File                             | Fenced blocks | Note                                                                |
| -------------------------------- | ------------- | ------------------------------------------------------------------- |
| `README.md:52`                   | 1             | `flowchart LR` — the dispatch law                                   |
| `stress-project/README.md:15`    | 1             | `sequenceDiagram` — the leaver path                                 |
| `MASTER_FIFO_PLAN_CLAUDE.md:308` | **0**         | an inline triple-backtick span inside a prose sentence, not a block |
| Anything else                    | 0             | zero `.mmd`, zero `.d2`, zero Vega-Lite anywhere in the tree        |

The miscount is instructive rather than trivial. `grep -c '\`\`\`mermaid'`returns 3 and confirms
the brief; anchoring the pattern to line start returns 2. The repository's own validator at`scripts/run-crew-tests.sh:539`anchors correctly and would not have made this mistake. The count
was confirmed a second time by an independent structural parser written for this audit, which
reports 0 blocks in the plan`[E]` — two methods, one answer.

### A1-F1 — the execution authority mandates a diagram it does not contain

**P3 · documentation completeness · Failure scenario:** a reader looking for the plan's own
picture of the pipeline finds a sentence promising one, and there is nothing to find.

`MASTER_FIFO_PLAN_CLAUDE.md:308` requires of the stress project: "README + a `mermaid` sequence
diagram (GitHub-native render — zero local render deps, HC-5 safe)". The plan specifies the
artifact, the format, and the reason for the format. Across 391 lines it contains **no diagram of
its own** — not of the gate FSM it defines, not of the dispatch law, not of the phase sequence.

This is disclosed, not repaired: the plan is byte-pinned under EX-01 and is never edited locally.
It is recorded because A1's brief asked for "plan diagram vs the plan's own text", and the honest
answer is that the comparison has no subject — the finding is one level up from the one the brief
anticipated.

---

## A1.1 Validity `[E]`

Parse-checked with a structural reader written for this audit using the Node standard library
only — no `mermaid-cli`, no install, HC-5 intact. The reader resolves the graph rather than
counting lines: it extracts each fenced block, parses node/participant declarations and every edge
form mermaid accepts, then asserts that every edge endpoint resolves to a declared node, that no
declared node is left unconnected, and that the block is terminated.

Counts below are **reported, not asserted.** The build already shipped one arrow-count proxy
failure (a line-based count returned 0 against a real 14), and repeating the shape while auditing
for it would be its own finding.

| Block                         | Kind              | Nodes | Edges | Endpoints resolve | Orphans | Terminated |
| ----------------------------- | ----------------- | ----- | ----- | ----------------- | ------- | ---------- |
| `README.md:52`                | `flowchart LR`    | 5     | 5     | PASS              | none    | yes        |
| `stress-project/README.md:15` | `sequenceDiagram` | 8     | 14    | PASS              | none    | yes        |

**0 structural failures.** Both blocks are well-formed and will render. Every edge in both carries
a label — no bare arrows.

---

## A1.2 Accuracy — each diagram against the artifact it depicts

Validity says a diagram renders. Accuracy asks whether what it renders is true. Both blocks are
valid; **both are inaccurate**, in different ways and with different severity.

### A1-F2 — the dispatch diagram draws the routing law the build proved unexecutable

**P2 · documentation-vs-reality drift · Failure scenario:** a reader takes `README.md`'s picture
as the architecture, looks for the arbiter receiving specialist output directly, and builds or
reviews against a topology this runtime cannot provide. The finding it would reproduce is C-11,
which cost a P0 and a blocked gate.

The block as parsed `[E]`:

```
O[orchestrator] -->|DISPATCH + task_id| S[specialist]
S              -->|findings|            A[arbiter]
A              -->|audit line …task_id| L[(arbiter-audit.jsonl)]
A              -->|RELEASE|             O
L              -.->|coverage …identity| V[validate-crew]
```

**Defect 1 — the `S --> A` edge does not exist at runtime.** `.claude/agents/arbiter.md:9` states
it directly: "Nested dispatch does not exist at runtime, so the orchestrator dispatches specialists
on your behalf (EX-05) **and routes every returned packet to you** unread-upon." A specialist's
output returns to the orchestrator, which then hands it to the arbiter. The true path is
`S → O → A`, and the diagram omits the mediating hop entirely — there is no edge showing the
orchestrator receiving anything from the specialist.

What makes this more than pedantry is where it sits. The paragraph immediately above the diagram
reads: "Nested dispatch does not exist in this runtime — a subagent cannot spawn another agent at
any depth. The law that _can_ be enforced is therefore about consumption, not routing." The prose
retracts the routing claim; the picture underneath reasserts it. C-11 and C-11 REOPENED exist
precisely because the original design assumed that edge and the runtime refused it.

**Defect 2 — coverage is drawn with one input and requires two.** `scripts/validate-crew.sh:161`
gates on `[ -f logs/tooluse-audit.jsonl ] && [ -f logs/arbiter-audit.jsonl ]`, then extracts
`task_id` sets from **both** and correlates them `[E]`. The diagram shows only
`arbiter-audit.jsonl` reaching `validate-crew`. The dispatch-side log, and
`hooks/audit-logger.sh` which writes it, appear nowhere.

The label on that edge is "coverage correlated by identity" — the exact property C-12 was opened
to establish. Correlation needs two sets. A diagram showing one input cannot express the thing its
own label claims, and a reader cannot see what the dispatch side of the correlation even is.

### A1-F3 — the sequence diagram is right about every message and wrong about nine of fourteen actors

**P3 · documentation-vs-reality drift · Failure scenario:** a reader traces the IAM call into
`src/lifecycle.js`, does not find it, and concludes either that the diagram is stale in some
unknown way or that `lifecycle.rollback()` is dead code. It is not dead; it is the mechanism the
diagram's own arrow direction would make unnecessary.

**Content: verified correct against a live run** `[E]`. Executing the exact scenario the diagram
depicts produces precisely the four audit lines it claims, in order, with the claimed stages and
outcomes, and the lifecycle detail reads `NONE -> SUSPENDED via iam.suspend`:

```
{"seq":1,"stage":"intake","outcome":"ACCEPTED"}
{"seq":2,"stage":"lifecycle","outcome":"APPLIED"}
{"seq":3,"stage":"ticketing","outcome":"TICKET_CREATED"}
{"seq":4,"stage":"notify","outcome":"NOTIFIED"}
```

`NONE to SUSPENDED` looked wrong on first reading — the corresponding test is named
`terminate-active-to-suspended-emits-suspend` — and it is **correct**.
`stress-project/src/lifecycle.js:63-67` makes `NONE + TERMINATE → SUSPENDED` a deliberate
asymmetry, documented at lines 42-53: a MOVE for an unknown employee parks because acting would
grant access nobody authorised, while a TERMINATE for one suspends anyway because declining would
retain access until a human noticed. Erring toward less access is the stated rule. The diagram has
this right.

**Actors: wrong for 9 of 14 edges.** Measured by grep against the source rather than read off the
diagram `[E]`: all five `audit.append` call sites are in `bin/jml.js` and **none is in `src/`**;
the only real `iam.apply` call is `bin/jml.js:292` (the single hit in `src/lifecycle.js:96` is
inside a comment).

| #   | Diagram edge  | Reality            | Anchor       |
| --- | ------------- | ------------------ | ------------ |
| 1   | `HRIS->>CLI`  | correct            | —            |
| 2   | `CLI->>IN`    | correct            | `jml.js:354` |
| 3   | `IN->>IN`     | correct (internal) | `intake.js`  |
| 4   | `IN-->>AUD`   | **`CLI-->>AUD`**   | `jml.js:358` |
| 5   | `IN->>LC`     | **`CLI->>LC`**     | `jml.js:386` |
| 6   | `LC->>IAM`    | **`CLI->>IAM`**    | `jml.js:292` |
| 7   | `IAM-->>LC`   | **`IAM-->>CLI`**   | `jml.js:292` |
| 8   | `LC-->>AUD`   | **`CLI-->>AUD`**   | `jml.js:272` |
| 9   | `LC->>TK`     | **`CLI->>TK`**     | `jml.js:304` |
| 10  | `TK-->>AUD`   | **`CLI-->>AUD`**   | `jml.js:309` |
| 11  | `TK->>NT`     | **`CLI->>NT`**     | `jml.js:322` |
| 12  | `NT->>NT`     | correct (internal) | `notify.js`  |
| 13  | `NT-->>AUD`   | **`CLI-->>AUD`**   | `jml.js:337` |
| 14  | `CLI-->>HRIS` | correct            | `jml.js:407` |

The diagram draws a **peer-to-peer relay** in which each stage hands off to the next and writes its
own audit line. The code is **hub-and-spoke**: `bin/jml.js` calls every module, receives every
result, and is the sole writer to the audit log. The modules never call each other.

The steelman — that a sequence diagram may elide the orchestrator for readability — does not hold
here, because `CLI` **is** a declared participant and is used in edges 1, 2 and 14. The diagram
has the hub, uses it at the boundaries, and bypasses it through the middle. That is a specific
claim about who calls whom, not an abstraction.

**Why edge 7 in particular matters.** `bin/jml.js:385` snapshots employee state _before_
`lifecycle.apply()`, and `:391-393` rolls it back when the IAM chain failed. That design exists
only because the CLI owns the IAM call and learns its outcome _after_ lifecycle has optimistically
moved state — the reasoning is spelled out at `lifecycle.js:296-304`. Edge 7 draws lifecycle
learning the IAM outcome directly, a topology under which `lifecycle.rollback()` would never need
to exist.

### A1-F4 — the guarding assertion binds to the diagram's shape, never to its meaning

**P3 · control binding · Failure scenario:** the sequence diagram is edited into something
describing a different system entirely. The suite stays at 144 PASS, because nothing compares any
arrow to any code.

`scripts/run-crew-tests.sh:538-546` is the only automated check on any diagram in the repository.
Read fairly, it is **better built than it first appears**: its own comment records that arrows are
counted by token rather than by line because "a line-based proxy reported 0 against a real 14 at
A5", and it asserts floors — `>= 4` participants, `>= 6` arrows — rather than exact values, so the
diagram can evolve without a spurious failure. The displayed "8 participants, 14 arrows" is the
measured value echoed into the pass message, not the bound. An earlier note in this audit called it
count-bound; that was wrong and is corrected here.

The finding is what it cannot see. It asserts: one fence, the token `sequenceDiagram` present, at
least four participants, at least six arrows. A diagram with eight participants and fourteen arrows
depicting an entirely different system passes identically — which is exactly the state A1-F3 found
it in. The check binds to the diagram's shape; nothing in the repository binds to its meaning.

This is the proxy-binding family one level up. The build learned to bind a check to the artifact
that would change if the defect were real. For a diagram, that artifact is the code it claims to
depict, and no check crosses that gap.

---

## A1.3 Coverage matrix

Columns are formats. `—` means absent. DIAGRAM-WORTH is a judgment about whether a picture earns
its place, given that every diagram is a second source of truth that can drift — as two of two
already have.

| Concept                                     | mermaid            | d2  | Vega-Lite | DIAGRAM-WORTH                                                                                                                                                         |
| ------------------------------------------- | ------------------ | --- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| dispatch → arbiter-release → consumption    | **present, wrong** | —   | n/a       | **yes** — exists; correct it (A1-F2) → **CR-001**                                                                                                                     |
| gate FSM (PASS/FAIL/ESCALATE, exact tokens) | —                  | —   | n/a       | **yes** — 10 gates, three verdicts, exact-token guard; the build's central control, and prose-only → **CR-002**                                                       |
| hook pipeline (12 hooks)                    | —                  | —   | n/a       | **yes** — 12 hooks over 8 events with matchers; which fires when is readable only from `settings.json` → **CR-003**                                                   |
| model routing (alias / pinned)              | —                  | —   | n/a       | **no** — an 8-row agent→model table plus a two-mode switch. `README.md:37-46` and `models.config.json` already say it better than a picture would                     |
| §15 continuity layers                       | —                  | —   | n/a       | **yes** — disk-canonical / context-cache / PreCompact / §15.9 snapshot / §15.5 distill is a flow with triggers, currently prose spread across four files → **CR-004** |
| JML lifecycle incl. parked replay           | **partial**        | —   | n/a       | **yes** — the sequence diagram covers one happy path; the 3×3 transition table and the park-and-replay path have no picture at all → **CR-005**                       |
| review discourse rounds                     | —                  | —   | n/a       | **no** — two rounds and a four-token grammar with a scoring rule. `README.md:65` states it in one sentence; a diagram would restate a sentence                        |
| dispatch-cost distribution                  | n/a                | n/a | —         | **yes** — the only place in this repository with real quantitative data to plot → **CR-006**                                                                          |

### Notes on the "yes, absent" cells

**CR-002, gate FSM — mermaid `stateDiagram-v2`.** Ten gates, three verdicts, and an exact-token
transition guard. It is a genuine finite state machine and mermaid is the right tool. `GATES.md`
records outcomes; nothing draws the machine.

**CR-003, hook pipeline — d2.** This is topology, not flow: 8 events × 12 scripts × matcher
predicates, with two events carrying three handlers each. Per the brief's convention, architecture
topology gets d2. Note the constraint honestly — **there is no d2 renderer in this repository and
HC-5 forbids installing one**, so a `.d2` source file would ship as text that no one here can
render. The CR must either accept that (the source is still more readable than `settings.json`) or
choose mermaid and lose the layout quality. This is a real trade-off, not a formality.

**CR-005, JML state machine — mermaid `stateDiagram-v2`.** The strongest of the six. The transition
table at `lifecycle.js:55-106` is nine transitions across three states, and it contains the single
most reviewable decision in the project: the NONE row's deliberate asymmetry, which the source
comment explicitly flags as "the row a reviewer should argue with". It is currently readable only
as a nested JavaScript object literal. `REPLAYED` — an outcome that appears in zero end-to-end
artifacts, per the open items — would become visibly a distinct path rather than a flag.

**CR-006, dispatch-cost distribution — Vega-Lite.** `logs/metrics/dispatch-costs.tsv` holds 30
rows across 8 agent roles with two numeric columns `[E]`, against a measured mean of 102,621
tokens per dispatch and a 46,388 floor. That is a genuine distribution and the only one here.

Two constraints the CR must carry, or it produces an unreproducible artifact:

1. **The data is gitignored.** `logs/` is excluded, so a Vega-Lite spec in a tracked document would
   plot a file absent from a fresh checkout `[E]`. The data, or a derived summary, has to move into
   `context/` — the precedent already exists in `context/f7-metrics.md`, which mirrors the
   gitignored `logs/metrics/f7.json` for exactly this reason.
2. **The TSV has no header row** `[E]`, so column meaning lives only in
   `scripts/measure-dispatch-cost.sh`.

### DELIVERED — S3, 2026-08-19 (appended; the findings above are left as written)

Ruling **R2a** scoped S3 to the four mermaid items. All four landed:

| CR | Where | What |
| --- | --- | --- |
| **001** | `README.md:54` | The dispatch flowchart **corrected**. The specialist → arbiter edge is gone — findings return to the orchestrator, which routes them onward — and coverage now shows all three trails, including `subagent-starts.jsonl` from C-25, which did not exist when A1-F2 was written |
| **002** | `README.md` | Gate FSM as `stateDiagram-v2`, drawn around the point that `PASS` reaches `AwaitingToken` and never the next phase. The self-loop on a near-miss token is the control |
| **004** | `README.md` | §15 continuity layers, closing at forward-resume |
| **005** | `stress-project/README.md` | The nine-transition JML machine, with the deliberate `NONE`-row asymmetry called out as the row to argue with, and `REPLAYED` drawn as the distinct path it is — including its honest gap, unreachable from shipped fixtures (CR-017) |

**Deferred as ruled:** CR-003 (d2 — no renderer here, HC-5 forbids installing one) and CR-006
(Vega-Lite — its data is gitignored and must move to `context/` first).

**A1-F4 is now partly closed.** Nothing had bound any diagram to anything; the only check asserted a
fence, a token, and floor counts, so a diagram of an entirely different system passed identically.
S3 adds a structural validator over **every** fenced block in tracked Markdown — fence integrity, a
recognised type, and referential integrity on every edge endpoint — controlled against an
undeclared node, an unclosed fence, and an unrecognised type.

**Partly, not wholly, and the remainder is stated rather than papered over:** it checks that a
diagram is *well-formed*, never that it is *true*. Binding a picture to the code it depicts is not
mechanically decidable, and a check that claimed to would be the proxy this repository has recorded
ten times. Accuracy remains a review obligation.

The validator lives **inline in `run-crew-tests.sh`**, not in `scripts/`. A tenth script broke
CR-024's map-vs-tree assertion, because `DIRECTORY_GUIDE.md` is the §4.3 payload and must stay at
delta 0 — the map can only gain a name through an operator re-export. CR-024 caught that on the
first attempt, which is the S1 control working on the session that came after it.

### What is deliberately not recommended

Two rows are marked **no**, and the reasoning is the same in both: a diagram is a second source of
truth. Model routing and discourse rounds are each already expressed once, compactly and
correctly, in a form that cannot drift out of step with itself. Adding a picture to either would
create a maintenance obligation and buy nothing. The two diagrams this repository already has are
both inaccurate — that is the base rate this recommendation is calibrated against.
