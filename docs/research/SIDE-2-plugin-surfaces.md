# SIDE-2 — Plugin & Skill Surfaces: what each Claude surface actually exposes today

Status: SIDE-2 research deliverable. All load-bearing rows verified against pages fetched
2026-08-26; nothing below is recalled from memory. Evidence classes per house law.

## Restatement (≤5 lines)

Objective: verify what plugin/skill surfaces Claude Code, claude.ai (web/desktop), and the API
each expose today, from current docs; then decide the minimal useful plugin set for the
Psychic-Plugins sibling and scaffold it if the format verifies. Research-first — the build
follows the evidence, not the other way around.

## A. Sources, dated

| # | Source | Retrieved | Note |
|---|---|---|---|
| 1 | code.claude.com/docs/en/plugins | 2026-08-26 | via 301 from docs.claude.com — **the docs reorganized hosts**: Claude Code docs now live at code.claude.com `[E]` |
| 2 | platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | 2026-08-26 | via 302 from docs.claude.com; platform docs host `[E]` |
| 3 | code.claude.com/docs/en/plugin-marketplaces | 2026-08-26 | full marketplace.json schema `[E]` |

## B. The surface matrix

| Capability | Claude Code | claude.ai web (+desktop, see weakest claim) | Claude API |
|---|---|---|---|
| Custom Skills | Filesystem: `~/.claude/skills/` (personal) or `.claude/skills/` (project); full network access; no upload step `[E]` | Zip upload via Settings > Features; Pro/Max/Team/Enterprise with code execution; **individual to each user — "not shared organization-wide and cannot be centrally managed by admins"** `[E]` | `/v1/skills` endpoints + code-execution container; workspace-wide; **no network, no runtime package installs** `[E]` |
| Pre-built document Skills (pptx/xlsx/docx/pdf) | **Not available** (open-source Claude API skill is bundled instead) `[E]` | Active by default when creating documents `[E]` | `skill_id` in the `container` parameter `[E]` |
| Plugins (skills + agents + hooks + MCP + LSP + monitors + bin + settings) | Full support; manifest `.claude-plugin/plugin.json` (only `plugin.json` lives inside `.claude-plugin/`; every component dir at plugin root); single-skill plugins may put SKILL.md at the root `[E]` | Org-settings distribution to Claude Code sessions (Team/Enterprise, `claude.ai/admin-settings/plugins`): marketplace repo **must be private or internal**, read via the Claude GitHub App; no top-level `bin/` `[E]` | n/a |
| Marketplaces | `.claude-plugin/marketplace.json`; `/plugin marketplace add owner/repo`; **a repo can be its own marketplace via `source: "./"`** `[E]` | Same file consumed by org settings `[E]` | n/a |
| Community reach | `claude-plugins-official` (curated, no application) and `claude-plugins-community` (submission review, SHA-pinned, nightly sync) `[E]` | Submission forms: claude.ai admin (Team/Enterprise) or Console `[E]` | n/a |

**The cross-surface law, quoted:** "Custom Skills do not sync across surfaces." One artifact,
three packagings: a plugin directory for Code, a zip for a claude.ai user upload, a `/v1/skills`
upload for the API. Any Psychic-Plugins design that assumes one install reaching everywhere is
wrong by documentation.

**Constraint worth mechanizing (and now mechanized in the sibling's validator):** skill `name` ≤64
chars, lowercase/numbers/hyphens only, and **may not contain the reserved words "anthropic" or
"claude"**; `description` non-empty, ≤1024, no XML tags `[E]`.

## C. Minimal useful plugin set — the decision matrix

Candidates drawn from proven house patterns only (reuse over invention, the RSCH-3 rule):

| Candidate | Portability across surfaces | Weight | Verdict |
|---|---|---|---|
| `request-contract` skill — walk a session through filling the 10-field minimal contract; doctrine embedded | Prose-only → all three surfaces | none | **SHIP** |
| `gate-machine` skill — install/operate the exact-token gate ritual (GATES row, stamp, guard, STOP) in any repo | Prose + one copyable script | small | **SHIP** |
| `unknown-audit` skill — audit any doc/plan for guessed-in content; emit [E]/[I]/[S] + unknown_fields | Prose-only → all three surfaces | none | **SHIP** |
| validator-scaffold generator | Code-only, script-heavy | large | PARK — wake condition: a second consumer beyond the crews asks for it |
| specialist/army selector | — | — | DEFER — this is SIDE-3's whole scope; preempting it here would skip a gate |
| full 22-field schema as a skill | — | — | REJECT — duplicates the psychic-templates repo; the skill inlines only the minimal core and points outward |

**Scaffold decision: build now, this gate.** The format verified cleanly, the acceptance test the
docs themselves bless (`claude plugin validate`) is runnable locally, and the self-marketplace
pattern means one PRIVATE repo serves both direct installs and a future org-settings path
(which requires private — the plan's default and the platform's requirement coincide).

## D. Weakest claim, flagged

`[I]` Desktop: the fetched pages describe "claude.ai" without splitting web from the desktop app;
the desktop column above is inferred to share the claude.ai skills surface. `[I]` The claude.ai
zip-upload packaging is doc-verified but UNEXERCISED — no upload was performed (it is a per-user
account action). What would settle both: one manual upload of the built zip on the operator's
account, web and desktop. Until then the plugin's claude.ai lane is a documented path, not a
demonstrated one.

## E. Verify

- Matrix rows carry quotes traceable to the three dated fetches; redirect chain stated in §A.
- The sibling's acceptance: `claude plugin validate .` inside psychic-plugins prints
  "Validation passed" (exercised at this gate — see the SIDE-2 Plan.md entry).
- Count binding: 3 SHIP rows ↔ the sibling ships exactly 3 skills; its validator binds README
  and tree to the same number.
