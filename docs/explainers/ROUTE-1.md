# ROUTE-1, explained plainly

## What changed

You no longer need to memorize slash commands. Claude Code already picks skills automatically by
matching your plain request against each skill's description — this gate curated that surface so
the matching actually works for you: your four personal skills got explicit trigger phrases, a new
`explain-plainly` skill answers "what does this do?" at any depth, and the five skills that call
non-Claude AI tools are recorded as never-auto-invoked inside this project.

## Why

You said you'd forget slash commands — reasonable, there were 68. The platform's own mechanism
(description matching) makes slashes optional; what was missing was curation: trigger phrases on
the skills you actually use, and a hard line around the ones this project's Claude-only rule bars.

## The pieces

- Four personal skills (`architecture-review`, `mermaid-diagrams`, `terraform-iac`,
  `threshold-router`) each gained a `when_to_use:` line — plain phrases that route to them.
- One new personal skill, `explain-plainly` — ask "explain X plainly" about anything; it answers in
  plain words, ends with commands you can run to verify, and writes nothing (so nothing goes
  stale).
- The 61 vendor-managed skills were inventoried but not edited — their updater would silently
  overwrite any hand edit.
- The five non-Claude AI skills are listed in the model rules file as barred inside this project;
  the project's command blocker already refuses them mechanically.
- A short note in your global instructions says: describe what you want; slashes remain for
  ceremonies (gates, review pipelines) where being explicit is the point.

## Verify it yourself

```
ls ~/.claude/skills/explain-plainly/            # the new skill exists
grep when_to_use ~/.claude/skills/mermaid-diagrams/SKILL.md   # a trigger line, e.g. "diagram"
grep -A2 'HC-7 skills ruling' ~/projects/psychic-crew/.claude/rules/model-policy.md
```

Then just try it: ask "explain the gate guard plainly" in any session — no slash — and watch the
routing happen.

## What could break, and what catches it

If a vendor update ever adds auto-routing to a barred skill, the project's command blocker still
refuses the invocation itself (that's enforced by tests). If a trigger phrase stops routing, the
slash form still works — routing is a convenience layer on top, never the only path.
