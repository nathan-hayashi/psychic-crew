---
paths: ["**/*"]
---
# Security Rules (binding)

## Severity definitions
Every FINDINGS entry carries exactly one. These are not adjustable per reviewer — the arbiter recalibrates against this table (§5.1.1 step 3).

| Severity | Definition |
|---|---|
| `crit` | Secret exposure, or widening of destructive capability — a new path by which data or infrastructure can be destroyed. |
| `high` | Weakening of a permission boundary or deny-list: anything that lets a previously blocked operation through. |
| `med` | Injection-adjacent — untrusted input reaching a position where it can influence control flow, without a demonstrated exploit. |
| `low` | Hygiene: naming, dead configuration, inconsistency with no security consequence. |

## Standing prohibitions
- **No absolute machine paths in tracked files.** Resolve through `$HOME` or `$CLAUDE_PROJECT_DIR`. `validate-crew.sh` substring-matches tracked files for an absolute home-directory prefix and is high-recall, low-precision on purpose. Consequence: do not write that literal token in tracked prose either — not even to document this rule. Describe it instead. Two red gates at F0 came from exactly that mistake.
- **No new allow-rules without a gate.** Any addition to `permissions.allow` in `.claude/settings.json` is a permission-boundary change: it needs operator approval at a gate, never a quiet commit.
- **Secrets never enter the repo.** `.env`, `secrets/` and `.ssh/` are blocked by `hooks/sensitive-guard.sh` and covered by `.gitignore`. A guard is not a substitute for not writing them in the first place.
- **A denial must leave a record.** Blocking without an audit line is a silent control. `deny()` writes a `PreToolUse.deny` entry carrying tool, target, reason and phase (established at G-F2, where six live denials produced zero records).

## Dismissal standard
A reviewer may dismiss a suspected issue only with a mitigation it has located and READ. "The framework escapes it" or "the caller validates it" remains an assumption, and the finding stands (§5.4).
