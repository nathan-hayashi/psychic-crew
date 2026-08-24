# redteam-1.md — SECURITY-1 red-team pass (parent), 2026-08-23

Every probe below was **executed**, not reasoned about. Outcomes are what the guards actually did.
Three probes beat a guard; all three were fixed in-session because none touched a permission
surface. `.claude/settings.json` was not modified.

Token shapes used are generic (`ghp_` + filler). No real credential exists in either repo (R-SEC-1
rule 1) and none appears here.

## Findings — guards that were beaten

### F-1 · `hooks/error-recovery.sh` wrote tool error text unredacted — **high**

The hook recorded `error: $(printf '%s' "$E" | cut -c1-400)` into `logs/build-errors.jsonl`.
`cut` is a **length limit, not a redaction**. A planted `ghp_`-shaped value inside a tool error
landed in the trail verbatim, while the identical value passed through `deny()` and
`audit-logger.sh` came out `ghp_[REDACTED]`.

This repo had already recorded exactly this defect once — SEC-DG-01, where the old form was
`cut -c1-200` — and fixed it in `_common.sh` only. The third writer kept the original shape. An
instance fix again, where a class was needed.

**Fixed:** the error text is passed through `scrub()`, which redacts by shape first and truncates
second. Re-probe: `ghp_[REDACTED]`. The §9 hint-delivery contract was re-checked and is unchanged.

### F-2 · `hooks/model-guard.sh` was blind to indirection — **high**

Three probes beat it: `aliases.opus`, `pinned.opus` and `session.model` each set to a forbidden
family, none matching an assignment-position `model:` line. Only the direct write was denied.

**Contained, not exploitable.** `apply-models.sh` refuses to stamp a poisoned config (exit 2, HC-2)
and `validate-crew` fails, so no agent could have run on it. But containment downstream is not the
job of a write-time guard, and **`psychic-crew-lite`'s equivalent already resolved the proposed
config** — the child was ahead of the parent on the parent's own constraint.

**Fixed:** the guard now resolves the proposed config as `apply-models` would, over aliases, pinned,
per-agent models and `session.model`. All six probes now behave correctly, including the two that
must NOT deny.

### F-3 · `.gitignore` did not cover what `security.md` claimed — **med**

`.claude/rules/security.md` states that `.env`, `secrets/` and `.ssh/` are "blocked by
`hooks/sensitive-guard.sh` and covered by `.gitignore`". The first half was true. The second was
not: only `.env` and `.env.*` were listed. The guard covers the `Write|Edit` path; a file arriving
by any other route was neither ignored nor guarded, in a repo whose remote is public.

**Fixed by making the artifact match the rule**, not by softening the rule: `secrets/`, `.ssh/`,
`*.pem`, `*.key`, `id_rsa*`, `credentials.json` appended. `README.md` still correctly not ignored,
and the guard still refuses removal of protected entries.

## Probes — guards that held

| # | Probe | Result |
| --- | --- | --- |
| P1 | gate-guard: ledger approves `APPROVE SECURITY-1X`, asked for `APPROVE SECURITY-1` | exit 1 — **superstring does not satisfy**; the backtick delimiter makes it exact |
| P2 | gate-guard: reverse superstring | exit 1 |
| P3 | gate-guard: `**APPROVED**` marker present, token text absent | exit 1 |
| P4 | gate-guard: no ledger at all | exit 1, distinct message |
| P5 | gate-guard: `GATES.md` replaced by a **symlink** to a doctored copy | exit 0 — **guard follows it**. This is the stated forgery residual (S4a), not a new class. Measured mitigation: the swap shows as ` T GATES.md` in `git status`, so the dirty-tree canary sees it. Recorded rather than "fixed", because defeating it means distrusting the filesystem the whole build treats as canonical. |
| P6–P11 | model-guard after F-2: direct, alias, pinned, session, clean config, prose | 1·1·1·1·0·0 — correct in both directions |
| P12–P18 | sensitive-guard: `.env`, `.env.local`, `.env.bak`, nested `.env`, `secrets/`, `.ssh/`, benign | deny 1 for all six sensitive shapes, 0 for `README.md` |
| P19–P25 | bash-blocker compound smuggling: bare, `;`-prefixed, `&&`-chained, subshell, env-prefixed, pipe-then-`;`, `bash -c '…'` | **7/7 denied**; `git status --short` allowed. Whole-string matching holds against the C-class regression |
| P26 | reference-cap: at-cap vs over-cap dispatch | 0 → 1 flag, stdout empty — flag-only contract intact |
| P27 | subagent-trail: hand-written spoof line in the arbiter trail | Set difference names **both** sides: the spoof shows as surplus, the real start still shows as uncovered. A forged coverage line **does not mask** a missing one — C-12's lesson holding under attack |
| P28 | publication probe: sensitive-named files across the tree | after F-3, all shapes ignored; stage-everything stages zero |

## What this pass did not test

Forgery of ledger content by a session with write access (P5's class, stated residual). Anything
requiring a `.claude/settings.json` or deny-list change — out of scope by this session's rule and
registered for its own gate if ever needed. And the injection surface of the pack's document
intake, which is Block 2's subject and until then is contract-only.
