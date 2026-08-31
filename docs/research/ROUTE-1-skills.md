# ROUTE-1 — invocation by intent: the skill surface, classified and routed

**The problem (operator):** "There would be too many slash commands… how can it be invoked
naturally based on user prompts…? Im open to doing small amounts of slash commands but will forget
using it."

**The invocation contract (dated fetch, 2026-08-31, Claude Code docs):** natural invocation is the
PLATFORM'S OWN mechanism, not something to build — "Claude uses skills when relevant, or you can
invoke one directly with `/skill-name`"; the `description` frontmatter drives it ("Claude uses this
to decide when to apply the skill. Put the key use case first"), and a dedicated **`when_to_use`**
field exists for "trigger phrases or example requests." `disable-model-invocation: true` makes a
skill slash-only; `user-invocable: false` makes it model-only. So the work is CURATION: give the
right skills intent triggers, record what must never auto-route, and keep the slash surface for
ceremony.

## Census (script-derived, 2026-08-31)

| Scope                                                        | Count                                                                                                        | Disposition                                                                                                                                                                                                                                    |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User, vendor-managed (name-matched to the turbo source tree) | **61**                                                                                                       | **READ-ONLY for this gate** — the vendor updater overwrites hand edits silently; they already carry descriptions and auto-route today. Recorded, not edited.                                                                                   |
| User, custom                                                 | **4** (architecture-review, mermaid-diagrams, terraform-iac, threshold-router)                               | KEEP; each gains a `when_to_use` intent-trigger line (additive frontmatter — no description rewrite, nothing an updater reverts)                                                                                                               |
| Project (this repo)                                          | **3** (intake, army-selector, threshold-router)                                                              | KEEP as-is — already routed by repo law (intake runs on every request; army-selector is data; the tier lock governs)                                                                                                                           |
| **HC-7-BARRED class**                                        | **5** (the two codex-named skills, the consult pair, peer-review — each exists to invoke a non-Claude model) | files STAY (the operator's own toolchain outside this estate); NEVER auto-routed or invoked inside the estate — enforced mechanically by the repo blockers, now also recorded as a ruling in `model-policy.md` so no later gate relitigates it |

One new user skill lands: **`explain-plainly`** — the D half of the COMPREHEND-1 choice. Its
description IS its intent trigger ("when the user asks what something does in plain words…"); it
answers from the frozen record at reading altitude and persists nothing, so nothing rots.

## What changed at this gate

1. `when_to_use` intent triggers on the four custom user skills (e.g. mermaid-diagrams: "when the
   user asks for a diagram, flowchart, or architecture picture" — plain requests route without a
   slash).
2. The `explain-plainly` skill created (user scope).
3. The HC-7 skills ruling recorded in `.claude/rules/model-policy.md` (no new rules file — HC-7 is
   model law and lives where model law lives).
4. A short **natural-invocation note** in the user-global CLAUDE.md: describe intent, don't memorize
   slashes; the deliberate slash surface that remains is the ceremony set (gate reviews, plan
   pipeline) where explicit invocation is the point.

## Proof and stated limits

The mechanism is proven by the platform contract (quoted above, dated) and exercised by this very
build — the review pipeline's skills auto-route from descriptions today. What is NOT claimed: a
mechanical assertion that a given phrase will trigger a given skill (trigger behavior is
model-judged per session; the docs' own framing). Deliberately NOT built: any standing suite
assertion reading the user scope — the parent suite must stay green from a bare clone, and a check
that reads `~/.claude` would break exactly there. The one-off post-change verification (every skill
named by the plan and the global CLAUDE.md still resolves on disk; settings still parse) ran at
this gate's STOP and is recorded in the ledger, not the suite.
