# HARNESS-SPEC — the ratifiable universalization design (HARNESS-SPEC-1)

**Provenance.** Input: the fenced MacBook handoff report (`harness-universalization-report.md`,
gitignored; sha256 `a8599dcd…38a2` **asserted equal to the FENCE-2 pin before this document was
written** — these are provably the bytes hard-checked below). Platform facts re-fetched **dated
2026-08-31** from the Claude Code docs (settings, memory, hooks pages) — current-docs-never-memory.
Verdict vocabulary for report claims: `CONFIRMED-HERE` · `FALSE-HERE` (true on the authoring macOS
machine, false on this one) · `REFINED` (docs add a material fact the report lacked) ·
`OWNED-BY-MODEL-1`. This document is the build contract for HARNESS-ROT-1, HARNESS-CONV-1 and
HARNESS-BUILD-1; nothing in it executes.

## 1 — Hard check of the report, claim by claim

### 1.1 Platform mechanics (report §3.1)

| Report claim                                                                                                  | Verdict (2026-08-31)                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| settings.json has exactly five scopes; **no ancestor-directory walk**                                         | **CONFIRMED** — the docs enumerate managed → CLI → project-local (`.claude/settings.local.json`) → shared project (`.claude/settings.json`) → user (`~/.claude/settings.json`); no ancestor mechanism exists in the enumeration                                                                                                                                                                                                                                      |
| CLAUDE.md **walks up** — cwd and every directory above, ordered root-down                                     | **CONFIRMED**, quoted: "loads `CLAUDE.md` and `CLAUDE.local.md` from your current working directory and every directory above it"; closest-to-cwd is read last                                                                                                                                                                                                                                                                                                       |
| —                                                                                                             | **REFINED (new fact 1):** CLAUDE.md files in **subdirectories** of the cwd are discovered too, loaded **on demand** "when Claude reads files in those subdirectories" — so a harness checkout nested inside a target repo gets its own CLAUDE.md injected once files in it are read, WITHOUT projection. Governance-at-launch still requires projection; mid-session leakage of harness instructions into target sessions is now a designed-for fact, not a surprise |
| Hooks **merge** across scopes                                                                                 | **CONFIRMED**, quoted: "Hook entries merge across settings levels rather than replacing each other"                                                                                                                                                                                                                                                                                                                                                                  |
| `$CLAUDE_PROJECT_DIR` = project root **where the session started**                                            | **CONFIRMED**, quoted — and in worktrees it "stays put" at the main checkout                                                                                                                                                                                                                                                                                                                                                                                         |
| —                                                                                                             | **REFINED (new fact 2):** hook settings edits are "normally picked up automatically by the file watcher" — **immediately, not at session start**. Consequences: the FENCE-2 amend-hook removal was live the moment it was written (consistent with the stable-HEAD observation at that gate's close); and HARNESS-BUILD-1's wiring goes live the instant it lands, which is why the install order in §7 puts wiring LAST                                             |
| `--add-dir` does not load that directory's CLAUDE.md without `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` | **CONFIRMED**                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `claudeMdExcludes` skips ancestor CLAUDE.md by glob                                                           | **CONFIRMED** — patterns match absolute paths, arrays merge across layers, symlink-reachable rules matchable by either path                                                                                                                                                                                                                                                                                                                                          |
| `@`-imports resolving outside the working directory trigger a one-time approval dialog                        | **REFINED (new fact 3):** the dialog protects against files _other people commit_ — it applies to **project-level** memory files. **User-scope** files (`~/.claude/CLAUDE.md`, `~/.claude/rules/`) load their imports **without the dialog** (trusted as personal configuration), except in Cowork desktop sessions. Tier-1 design may therefore use imports freely at user scope                                                                                    |

### 1.2 Baselines (report §4.4 property 2)

| Claim                         | Verdict                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Parent `run-crew-tests` = 166 | **STALE** — 209 today (post-FENCE-2, all four parent suites green: 209/0 · 53/0/0 · 33/0 · 13/0/15)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| Lite `validate-lite` = 64/1/0 | **CURRENT for layer 1** — but the report's implied "Lite is green" is **FALSE TODAY**: `verify.sh` returns `SIGNAL: FAIL` because the **sync plane is 60/1**                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| —                             | **NEW FINDING F-1:** `check-sync` reports `MIRRORED DIVERGED — .claude/rules/shell-discipline.md differs from parent`. Cause: CORRECTIONS-2 (08-28) added **rule 8** to the parent's byte-pinned rule file; the MIRRORED Lite copy was never re-synced. A real two-repo defect predating this program, found by running the twin's own suite rather than trusting the report's figure. **Fix owned by HARNESS-ROT-1** (byte-identical copy + witness re-stamp), and its end-state tuple is corrected accordingly: Lite must close at `layer1 64/1/0 · sync 61/0 · distill 12/0 · stress 14/0 · layer2 48/0/0 · SIGNAL: PASS` |

### 1.3 Migration-rot table (report §7), per-row verdicts

| Row                                                      | Report says                                                                                                                                                                                                                                                                                         | Verdict here |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| #1 portfolio `.claude/rules` symlink dangling            | **FALSE-HERE** — it resolves on this machine (target exists); dangling only where the home prefix is the macOS one. No repair here. The report's second half (make the config repo's setup script verify its own symlinks) is **DEFERRED deliberately** — that repo is outside this program's gates |
| #2 `stop.sh` has no macOS notification path (both repos) | **CONFIRMED-HERE** — `grep -c osascript` = 0 in both repos' `hooks/stop.sh`. Fix: HARNESS-ROT-1, by reusing `notify.sh`'s existing three-way dispatch, never a second table                                                                                                                         |
| #3 user CLAUDE.md declares the wrong environment         | **FALSE-HERE / INVERTED** — the line reads "WSL 2 Ubuntu 24.04 … `~/projects/`", which is **correct on this machine**; applying the report's fix here would invert truth. The model half of that file (`Model:` line) is **OWNED-BY-MODEL-1**                                                       |
| #4 `scrub()` ends in a line-oriented `cut -c1-200`       | **CONFIRMED-HERE, both repos** — a multi-line denied payload logs essentially whole. Fix: HARNESS-ROT-1, bound the whole payload, planted multi-line control                                                                                                                                        |

## 2 — Profile design (the report's §4, hardened per the 52 review findings)

**Three rule classes, two fail directions** (unchanged from the report, ratified as R-PR-1 on
approval): universal safety (ON everywhere, fail closed) · build constraints HC-5/HC-7
(`harness-build` only, fail OPEN elsewhere — deliberately against the house default, recorded so it
is not later "fixed" into a defect) · project-specific (the target repo's own settings).

**Two-root law.** One `ROOT` cannot serve both needs. Every profile-aware hook distinguishes:

- `HARNESS_SELF` — where the hook's own machinery lives. For repo-local hooks: derived from the
  script's own location (`dirname "$0"/..`), **never** from `$CLAUDE_PROJECT_DIR`. For the
  user-scope copies: a fixed install path baked at install time.
- `TARGET_ROOT` — the repo being governed: `$CLAUDE_PROJECT_DIR`, falling back to `$PWD`, and if
  both are empty the hook **refuses and logs** (fail closed) — never a silent `generic`.

Repo-local blockers resolve the profile **from `HARNESS_SELF`** (their own repo is what they
enforce) and write `$ROOT/logs/` unconditionally — Lite's `mktemp`-root fixtures stay green with
zero fixture edits, re-deriving the report's property 2 for the repo-local case.

**Marker law.** The universal deny set executes and audits **before any profile logic** — enforced
by a fire-probed order detector in BOTH suites (asserts the universal arm fires in a fixture where
profile resolution is sabotaged), not by comment order. `harness-build` classification requires
**corroboration**: the marker file alone is never sufficient — `GATES.md` AND the repo's own
`hooks/bash-blocker.sh` must both exist (a self-declared marker can only _tighten_, never loosen).
The user-scope layer's defer-to-local keystone is conditional on the target's own blocker **existing
and being executable**, so a renamed or deleted harness checkout degrades to universal-safety
coverage instead of silence. Missing `_profile.sh` at source time = fail closed.

## 3 — Deploy topology (`deploy-harness.sh`)

**Naming:** "harness repo" (psychic-crew) / "Lite twin" / "**target repo**" — the word "parent" is
retired from the design (it meant two things).

- **Explicit argument, no inference:** `deploy-harness.sh <target-repo-path> [--apply|--remove]`.
  Default with no mode flag is **`--dry-run`** (prints the full projection, writes nothing).
- **Refusals** (each a predicate with a distinct message): target is not a git work tree · target
  is the harness repo or the Lite twin · target's tree is dirty · target already carries managed
  regions whose stored hashes mismatch live content (drift — see §4) · the harness checkout cannot
  locate its own hooks.
- **Transport for the nested case:** no ordinary transport into a nested position exists under
  HC-5 (the clone verb is denied, correctly). The fixture and the documented mechanism are
  `git archive | tar -x` into the target — the portability drill's own idiom. The deploy works
  identically whether the harness sits beside or inside the target; **nesting is never inferred**.
- **Wiring form:** hook commands in the target's settings are written
  `$CLAUDE_PROJECT_DIR/<relative-harness-path>/hooks/…` — correct because the variable resolves to
  the target root in that repo's sessions; never a bare relative path (hook cwd is not
  contractually the project root).
- **Arbitration with the user-scope layer:** the deploy marker sets the target's profile
  (`node-app` or `generic` — **never** `harness-build`, which requires the corroboration in §2), and
  the user-scope hooks' defer rule keys on _the target's own wired blocker existing_: deployed
  target ⇒ user-scope defers ⇒ exactly one guard, one audit record. `~/projects/CLAUDE.md` has
  **one writer** (the user-scope install); the deploy never touches it.

**The walk-up blast radius, enumerated.** `~/projects/CLAUDE.md` loads into every session under
`~/projects/` (18 directories today): the two harness repos (their own CLAUDE.md wins on conflict;
content must not contradict them), the four psychic siblings, `portfolio`, `Hiya`,
`hiya-crew-context`, `aws-spotify`, `claude-config`, `codex-plugin-cc`, `diagram-test`,
`mermaid-hybrid-stack-guide`, `open-code-review`, `turbo`, `claude-agent-orchestration-guide`
(RETIRE-1's target), **and the operator's barred repo** — which this program never touches, but
whose sessions would still load a `~/projects/CLAUDE.md`. The file is therefore written inert:
≤60 lines, no imperatives that could alter unrelated work, an explicit "repo-local instructions
win" line. **Escalation at this STOP:** if even inert loading into the barred repo's sessions is
unwanted, the operator can decline tier-1's CLAUDE.md half (hooks still work without it) or set
`claudeMdExcludes` there themselves; the spec defaults to SHIPPING it inert.

## 4 — Managed-region write law (the deploy's only write authority)

Every write into a target lands inside `# >>> harness-deploy v1` / `# <<< harness-deploy` markers
(JSON targets get a single `"harness_deploy"` top-level key instead). The manifest —
`.claude/harness-profile.json` in the target — records every touched file, the exact region
content hash at write time, and the deploy's source version. Semantics:

- **Re-run (idempotent):** regions whose live hash matches the manifest are rewritten only if the
  harness content changed; a second identical run is byte-idempotent (control: `diff -r` empty).
- **Drift:** live region hash ≠ manifest hash ⇒ a human edited it ⇒ **refuse loudly**, print the
  diff; `--force` overwrites only after printing. Content _outside_ regions is never read, never
  written, never removed.
- **`--remove`:** deletes exactly the marked regions + the manifest; refuses on drift the same
  way. Control predicate: post-remove, the three target files hash-equal their pre-deploy
  snapshots AND `git -C <target> status --short` is empty.
- **Snapshots:** before any mutating run, timestamped copies of every file about to be touched,
  path printed.
- **Never written, ever:** `permissions.allow`, `permissions.deny`, model identity keys. Where
  `settings.json` is absent, the deploy writes `settings.local.json` instead (no new tracked file
  in the target).
- **Audit:** every mutating run appends one line to the harness repo's own `logs/` trail (existing
  writers, existing redaction proof). No new central trail is created by the deploy.

## 5 — User-scope layer (tier 1) and its audit trail

Installed at `~/.claude/harness/hooks/` (fixed `HARNESS_SELF`), wired by absolute path in
`~/.claude/settings.json`: `bash-blocker` (universal arms only) + `sensitive-guard` (universal
paths only) + `_profile.sh` + an adapted `_common.sh` (third variant of an ADAPTED file, recorded:
fixed self-location; `TARGET_ROOT` per §2; **audit destination override** to
`~/.claude/harness/audit/deny-audit.jsonl`). That trail is a NEW ledger writer, so secrets-contract
rule 3 applies in full: the `scrub()` port ships **with the HARNESS-ROT-1 payload-bound fix** (never
the per-line cut), appends are `O_APPEND` single-line writes with a read-back confirm, a size bound
rotates at 5 MB, and HARNESS-BUILD-1's controls include a **redaction fire-probe** (planted
ghp\_-shaped token through the user-scope deny path must come out redacted) plus a **single-record
probe** (a deny inside the harness repo with the user layer live yields exactly one record, in the
repo's trail, none centrally — the defer keystone observed, not assumed).

## 6 — Sync law and map cascade

- `hooks/_profile.sh`: **ADAPTED with a MIRRORED core** — the classification `case` block is
  byte-identical between repos (divergent resolvers are a defect generator); the surrounding
  plumbing may differ per repo. Sync row added at HARNESS-CONV-1; `check-sync` re-run; witness
  re-stamped with the touched-file list verified first (F-1 taught exactly why).
- §4.3 pair-edits, enumerated now: HARNESS-CONV-1 adds `hooks/_profile.sh` (plan v3.13, D28, hooks
  count 14→15, guide delta 0); HARNESS-BUILD-1 adds `scripts/deploy-harness.sh` (v3.14, D29,
  scripts count +1). Both authored under their gate's token per R-CH-1.
- Lite integration point is **`verify.sh`** (it has no `setup.sh`); the Lite deploy twin is ADAPTED
  (four-agent wording, L-series phases), same flags, same UX.

## 7 — Install order (tier 1) and rollback

1. Files into `~/.claude/harness/` (hooks + `_profile.sh` + adapted `_common.sh`); 2. exec bits;
2. self-test: each hook run standalone on a benign fixture exits 0, and the sabotage fixture
   proves the universal arm fires; 4. **wiring last** into `~/.claude/settings.json` via narrow Edit
   (never whole-file Write — model-guard denies a whole-file write of a file carrying the session
   model pin); 5. verify with a live benign command; 6. print the restore one-liner. Rollback: the
   FENCE-2 snapshot (settings sha `caee9798…`) plus `--remove-user`, which deletes the wiring block
   and leaves files inert on disk. The file-watcher fact (new fact 2) means wiring is live the moment
   it is written — hence its position at the end.

## 8 — Expected end-state tuples (no "return to baseline")

| Gate                       | Parent (crew/validate/save/matrices/tracked)                | Lite                                                                                                                                                                                      |
| -------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| HARNESS-SPEC-1 (this STOP) | 209/0 · 53/0/0 · 33/0 · 13/0/15 · **131** (this doc)        | unchanged (sync 60/1 red stands, owned by the next gate)                                                                                                                                  |
| HARNESS-ROT-1              | 209+? (stop.sh regex fire-probe added) · others green · 131 | layer1 64/1/0 · **sync 61/0** · distill 12/0 · stress 14/0 · layer2 48/0/0 · **PASS**; witness re-stamped (stop.sh, \_common.sh, shell-discipline.md rows STALE→refreshed, list verified) |
| HARNESS-CONV-1             | +R-PR-1 detector & probes; hooks 15; v3.13/D28              | +`_profile.sh` row; sync 62/0; witness refreshed                                                                                                                                          |
| HARNESS-BUILD-1            | +deploy controls; scripts +1; v3.14/D29; tracked +1         | +deploy twin; sync +1 row; witness refreshed                                                                                                                                              |

Any divergence from a declared tuple is a gate failure needing an operator ruling — never a note
the executor absorbs.

## 9 — Stated limits

The `mktemp`-root interaction (§2's repo-local unconditional-logging rule) is designed, not yet
demonstrated — HARNESS-CONV-1's controls prove it. The 18-directory walk-up enumeration is a
snapshot of today's `~/projects/`; a future sibling changes the blast radius silently
(`~/projects/CLAUDE.md` carries its own "list is as-of" line). The user-scope self-test cannot
simulate every shell environment hooks run under; the live benign-command verification partially
covers that. And nothing here proves a model produces good findings under any of this — the
machinery is what is under test (the report's own closing disclaimer, carried forward).
