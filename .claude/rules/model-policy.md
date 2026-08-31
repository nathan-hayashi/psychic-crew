---
paths: [".claude/**", "models.config.json", "scripts/**"]
---
# Model Policy (binding)

## HC-4 — one file, one command
`models.config.json` is the ONLY source of truth for model identity, version, and effort. Change it, then run `./scripts/apply-models.sh`. No other file may define model identity.

**Stamp-only rule:** agent frontmatter `model:` and `effort:` lines are written by the script, never by hand. A new agent is authored with the placeholder `model: {{APPLY}}`; the script fills it and adds `effort:` from config. Hand-editing either line is a policy violation that `validate-crew.sh` fails on, because the stamped value will no longer match config.

## HC-2 — no fable, anywhere in this repo
No agent, subagent, or configuration surface under this build may carry any `fable` model. The operator's own interactive session is governed by the session-model ruling below.

Enforced in three places: `forbidden_substrings` in `models.config.json`; the scan in `apply-models.sh`, which refuses to stamp anything while a forbidden substring is present in the config surface; and `model-guard.sh` (F2), which blocks writes introducing one.

**Live hazard:** `model: fable` is an explicitly valid frontmatter alias — the platform will run a fable subagent without complaint. Nothing but these guards prevents it, so a broken guard is a silent HC-2 breach, not a loud one.

**Session-model ruling (operator practice, recorded 2026-08-25 at gate CLEANUP-1).** The orchestrator session's model is the operator's decision, set interactively, and may be a Fable model at the operator's discretion. Precedent: at G-F6 (Plan.md, 2026-08-13) a session-model conflict HELD F7 with zero work executed until the operator lifted it, and the blast-radius analysis recorded there stands — subagents run their stamped frontmatter models regardless of the session model, so the session's model changes no agent's model. What this ruling does NOT change: `.claude/settings.json` stays stamped from this config, `forbidden_substrings` stays enforced on every configuration surface, and no agent or subagent ever runs on a forbidden model. Until this paragraph the practice lived only outside the filesystem — the breach class Lite's RULINGS preamble names — which is why it is recorded here (PROJECT-AUDIT-1, R2-02).

## HC-3 — scope determines model
Judgment that compounds gets Opus; narrow lenses get Sonnet.

| Model | Agents |
|---|---|
| opus | lead-planner, lead-executor, arbiter, fixer |
| sonnet | security-reviewer, quality-reviewer, test-runner, integration-runner |
| haiku | permitted only for future trivial batch lanes — none in this plan |

## Mode
`alias` (default) resolves through the vendor aliases `opus`/`sonnet`/`haiku`, which track the current generation and are structurally immune to dated-ID staleness. `pinned` freezes exact IDs from `.pinned` for reproducibility runs.

**Platform-fallback note (MODEL-1, 2026-08-31).** When the serving platform's safeguards flag a
session message it may switch that session to a fallback model of the PLATFORM'S choosing (observed:
"Switched to Opus 4.8"). No local file selects that target and none can — it is not a config
surface. What alias mode guarantees is everything local: every agent and the session default track
the latest generation the moment the vendor ships it. The machine-side stale pins found at the
additions-program audit (a shell-profile `ANTHROPIC_MODEL` export and a stale user-global doc line)
were removed at this gate; the user-global session default (`settings.json`, a fable variant at the
time of writing) is the operator's interactive choice under the session-model ruling above.

**Known gap (OQ-2):** the orchestrator session may run a context-variant ID such as `claude-opus-5[1m]`, which `.pinned` cannot express. Alias mode is unaffected; a pinned-mode reproducibility run would not reproduce the variant.

## HC-7 skills ruling (ROUTE-1, 2026-08-31)
Five user-scope skills exist solely to invoke non-Claude models (the two named after the barred
vendor's CLI, the consult pair, and peer-review, which delegates to them — the census names them
in `docs/research/ROUTE-1-skills.md`; this file describes rather than spells them, per the same
rule that keeps the abs-path prose clean). Inside this estate they are **never
auto-routed and never invoked** — `bash-blocker.sh` refuses the underlying commands mechanically,
and this paragraph is the recorded ruling so no later gate relitigates the question. The files
themselves stay installed: they are the operator's own toolchain for repos outside this estate,
and deleting another context's tools is not this repo's call.

## Contract
A configured model that cannot be applied MUST produce a structured `[WARN]` — never a silent skip. Per-agent `effort` is supported and stamped (confirmed F0 step 6): `low|medium|high|xhigh|max`, overriding session effort.
