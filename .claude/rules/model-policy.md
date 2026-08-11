---
paths: [".claude/**", "models.config.json", "scripts/**"]
---
# Model Policy (binding)

## HC-4 — one file, one command
`models.config.json` is the ONLY source of truth for model identity, version, and effort. Change it, then run `./scripts/apply-models.sh`. No other file may define model identity.

**Stamp-only rule:** agent frontmatter `model:` and `effort:` lines are written by the script, never by hand. A new agent is authored with the placeholder `model: {{APPLY}}`; the script fills it and adds `effort:` from config. Hand-editing either line is a policy violation that `validate-crew.sh` fails on, because the stamped value will no longer match config.

## HC-2 — no fable, anywhere in this repo
No agent, subagent, or session created under this build may run on any `fable` model. Fable 5 exists only as the operator's separate web-chat escalation channel; a human may use it, no agent may run on it.

Enforced in three places: `forbidden_substrings` in `models.config.json`; the scan in `apply-models.sh`, which refuses to stamp anything while a forbidden substring is present in the config surface; and `model-guard.sh` (F2), which blocks writes introducing one.

**Live hazard:** `model: fable` is an explicitly valid frontmatter alias — the platform will run a fable subagent without complaint. Nothing but these guards prevents it, so a broken guard is a silent HC-2 breach, not a loud one.

## HC-3 — scope determines model
Judgment that compounds gets Opus; narrow lenses get Sonnet.

| Model | Agents |
|---|---|
| opus | lead-planner, lead-executor, arbiter, fixer |
| sonnet | security-reviewer, quality-reviewer, test-runner, integration-runner |
| haiku | permitted only for future trivial batch lanes — none in this plan |

## Mode
`alias` (default) resolves through the vendor aliases `opus`/`sonnet`/`haiku`, which track the current generation and are structurally immune to dated-ID staleness. `pinned` freezes exact IDs from `.pinned` for reproducibility runs.

**Known gap (OQ-2):** the orchestrator session may run a context-variant ID such as `claude-opus-5[1m]`, which `.pinned` cannot express. Alias mode is unaffected; a pinned-mode reproducibility run would not reproduce the variant.

## Contract
A configured model that cannot be applied MUST produce a structured `[WARN]` — never a silent skip. Per-agent `effort` is supported and stamped (confirmed F0 step 6): `low|medium|high|xhigh|max`, overriding session effort.
