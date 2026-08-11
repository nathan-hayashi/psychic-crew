# Plan.md — Live Debugging, Fixes & Review Log
Append-only within a phase; entries: `[Fn|ISO-time] AREA — what happened → root cause → fix → files touched`.
## Baseline (F0 verification results)
[F0|2026-08-11T03:24:59Z] §2.2 re-verification — all checks GREEN. Host: WSL2 (Linux 6.6.87.2-microsoft-standard-WSL2 x86_64), Ubuntu 24.04.4 LTS.

| Check | Required (§2.1/§2.2) | Observed | Verdict |
|---|---|---|---|
| node | >= 20 | v24.14.0 | PASS |
| npm | >= 9 | 11.9.0 | PASS |
| git | present | 2.43.0 | PASS |
| jq | present | jq-1.7 | PASS |
| gh | present (checked, never installed — HC-5) | 2.45.0 | PASS |
| Claude Code | >= 2.1.92 | 2.1.224 | PASS |
| Claude auth | authenticated | loggedIn=true, claude.ai / firstParty, subscription=max | PASS |
| gh auth | authenticated | nathan-hayashi, HTTPS, scopes gist/read:org/repo/workflow | PASS |
| desktop notify | platform command present | ~/bin/wsl-notify-send.exe (executable) | PASS |
| session model | writable, no error | Opus 5 (1M ctx), id `claude-opus-5[1m]`, no error | PASS [V?] see OQ-2 |
| repo root | exactly 5 seed files pre-F0 | 5/5, unchanged | PASS |

Resolved [V?] from §2.2: `claude auth status` still exists in Claude Code 2.1.224 and emits JSON on exit 0 — the documented fallback (launch `claude`, observe state) was not needed.
NOT discharged by this step: hook-event schema names, agent frontmatter `tools:` vs `allowed-tools:`, Stop-hook JSON contract, per-agent effort support, and the `claude -p --resume` flag all remain owned by F0 step 6.

## Q0-Answers
[F0|2026-08-11T03:41:25Z] Q0 answered by operator; recorded verbatim per §3. All seven answered — operator item 6 ("accept, pre-authorize") carried both Q6 and Q7.

| Q | Operator answer (verbatim) | Recorded decision |
|---|---|---|
| Q1 | "Name it the "Psychic Crew" and make it public" | Visibility = **PUBLIC** (overrides the plan's private default). Name = "Psychic Crew" — **scope unresolved, see OQ-5**. Repo creation (step 5) and payload writes (step 3) held pending that resolution. |
| Q2 | "Defer the secrets" | **DEFER** secrets backend to post-build; env + `.gitignore` discipline now per §4.7. |
| Q3 | "Yes re-use desktop hooks" | **REUSE** the existing desktop notify hook — `~/bin/wsl-notify-send.exe`, verified present in step 1. notify.sh / stop.sh wrap it in F2. |
| Q4 | "lets do the joiner mover leaver automation simulator but make it fun pokemon theme: joiner is charmander, mover is squirtle and leaver is bulbasaur" | **ACCEPT** the default JML simulator (§6 F7) with a Pokémon persona overlay — joiner = Charmander, mover = Squirtle, leaver = Bulbasaur. Overlay is fixture/naming-level only: lifecycle semantics (create/suspend/transfer), the §7 numeric rubric, the ≥15-case suite floor, and the three injected edge cases are unchanged. Applies at F7; no F0 effect. |
| Q5 | "45 min" | Per-phase ceiling = **45 minutes wall time**, confirmed. §3's default pairs that with 150K tokens "whichever first"; the token limb is retained as co-limit since it was not overridden — say the word to drop it. Breach → mandatory early gate per §0.3. |
| Q6 | "accept" | **ACCEPT** default roadmap order: IAM → Compliance → HR-lifecycle → ITSM → rest. Recorded for ROADMAP.md at F8; no F0–F8 effect. |
| Q7 | "pre-authorize" | **PRE-AUTHORIZE** the §11 soft-ETL transforms for their phases (11.1 at F6, 11.2/11.3 at F3/F5, 11.4 at F2/F5). No per-use approval required. §0.2d untrusted-input rule still applies to all ETL source material. |

## Open Questions / Blind Spots (feeds fallback escalations)
[F0|2026-08-11T03:24:59Z] Opened during step 1; each feeds the G-F0 gate report per §12(3).

- **OQ-1 — ordering defect, F0 internal (resolved, resolution in force).** `Plan.md` is simultaneously the §4.4 payload and the live log written by steps 1–2. A literal step-3 identity check must therefore report drift (false FAIL under §14.5), and a literal verbatim re-write at step 3 would destroy this Baseline block plus the Q0 answers. Resolution: the four-way seed diff was hoisted ahead of step 1 while all seeds were pristine (results under Review Notes per Gate). At step 3 — re-diff only CLAUDE.md / CLAUDE_DESIGN.md / DIRECTORY_GUIDE.md, judge `Plan.md` against recorded sha256 `6f703cb44252b61b`, and do NOT overwrite `Plan.md`.
- **OQ-2 — session model id [V?].** Session runs `claude-opus-5[1m]`, a 1M-context variant. HC-2's verified enumeration lists bare `claude-opus-5`, and §4.5 `.pinned.opus` is `claude-opus-5`. HC-2 compliant (no forbidden substring, not a fable model), but a pinned-mode reproducibility run would not reproduce the `[1m]` variant. Confirm at F1 whether the suffix is expressible in models.config.json or is session-scope only.
- **OQ-3 — G-F0 idempotency stress [V?].** §4.6 seeds `.claude/settings.json` with `"model": "claude-opus-5"`, while apply-models.sh at step 7 (alias mode) stamps `.model` to `opus`. The full steps 3–7 re-run converges, so the stress test's zero-diff assertion holds only when measured after step 7; measuring after step 3 alone shows expected, benign drift. State the measurement point explicitly in the G-F0 stress evidence.
- **OQ-4 — Q0 still owed.** Step 2 (§3) owes seven operator answers before any §4 payload write. Q1's auth path and Q3's notify channel are now evidenced by step 1 (gh authenticated HTTPS; wsl-notify-send.exe present) but remain operator decisions, not inferences. **RESOLVED 2026-08-11T03:46:37Z:** all seven answered; recorded in §Q0-Answers.
- **OQ-5 — project naming scope (BLOCKING step 3; escalated to operator).** Q1 answered "Name it the "Psychic Crew" and make it public". Visibility is unambiguous (public, recorded). The *name* is not. `hiya-crew` is embedded in two byte-locked seed payloads — §4.1 `CLAUDE.md` line 1 and §4.3 `DIRECTORY_GUIDE.md` tree root — and in §0.1's operating path. Renaming the project therefore mutates payloads that §14.5 requires to stay byte-identical, invalidating the four hashes recorded under Review Notes per Gate and requiring either an upstream plan revision (v2.4 re-export via the approved re-seed procedure) or an explicit gated exception logged in GATES.md. Renaming only the GitHub remote (`nathan-hayashi/psychic-crew`, public, local dir and seeds untouched) costs nothing and is the recommended reading. Not guessed per §3 and §0.2b; step 3 and step 5 both held. **RESOLVED 2026-08-11T03:46:37Z:** operator chose full rename; executed under Fix Ledger EX-01.
- **OQ-6 — `apply-models.sh` HC-2 check is self-triggering (BLOCKS F0 step 7).** §5.5's verbatim core logic runs `grep -ril … "$bad" .claude/ "$CFG" | grep -v forbidden_substrings`. `grep -ril` emits **filenames**, so the `-v` filter tests the filename rather than the matching line — and no filename contains that string. `models.config.json` legitimately contains `"forbidden_substrings": ["fable"]`, so the scan always matches, the filter never suppresses it, and the script exits 2 with `[FAIL] HC-2` on a perfectly clean repo. Reproduced live at step 3 against the freshly written config; positive and negative controls both run. Consequence: step 7 cannot pass as written, and F1's stress case ("set an agent to fable-x → apply-models exits 2") would pass for the wrong reason, masking the real check entirely. Fix belongs in the script this repo builds, never in the unedited execution authority: drop `-l` so lines are matched, then filter the declaration line — `grep -ri … "$bad" | grep -v '"forbidden_substrings"'`. Verified: clean repo → PASS; config poisoned with `claude-fable-5` → FAIL. To be applied when step 7 writes the script, logged there as EX-02.
- **OQ-7 — §4.7 `.gitignore` does not cover `.claude/state/`.** DIRECTORY_GUIDE.md states the runtime flag `.claude/state/compact-pending` and the auto-snapshot tree `.claude/state/checkpoints/` are gitignored, but the §4.7 payload lists only `.env`, `.env.*`, `logs/`, `*.log`, `node_modules/`, `stress-project/tmp/`. Written verbatim as required, so both paths are currently **tracked** — once F2 wires §15.9, a snapshot would be committed every turn. validate-crew's `.gitignore` assertion only checks `logs/` and `.env`, so it will not catch this. Owner: F2 (which implements the §15.3/§15.9 mechanics); the fix is an append, which sensitive-guard permits since it blocks removals, not additions.

## Fix Ledger
[F0|2026-08-11T03:46:37Z] NAMING — operator directed a full project rename to "Psychic Crew" (Q1, confirmed by escalation on OQ-5) → root cause: `hiya-crew` embedded in the byte-locked §4.1/§4.3 payloads → fix: renamed the two seed lines, the local directory, and the planned GitHub remote, and re-baselined the §14.5 identity check under logged exception EX-01 instead of editing the execution authority → files touched: `CLAUDE.md` L1, `DIRECTORY_GUIDE.md` L2, dir `~/projects/hiya-crew` → `~/projects/psychic-crew`.

**EX-01 — §14.5 identity exception (scope-bounded, retirable).** `MASTER_FIFO_PLAN_CLAUDE.md` is deliberately NOT edited: `~/.claude/plans/the-context-files-folder-directory-parallel-prism.md` L17 and L143 record a standing operator decision that the execution authority stays identical to the PROJECT canonical copy and that local edits to it are out of scope. Consequence: the §4.1/§4.3 payloads still read `hiya-crew`, so a literal §14.5 check now FAILs by construction. Binding replacement acceptance rule for F0 step 3 and G-F0:

| Seed | Rule | Re-baselined sha256 (first 16) |
|---|---|---|
| CLAUDE_DESIGN.md (§4.2) | unchanged — must stay byte-identical to payload | `8d5c46d5b4263285` |
| CLAUDE.md (§4.1) | payload modulo exactly one L1 substitution `# hiya-crew ` → `# psychic-crew ` | `ecefa6eda96c00ff` |
| DIRECTORY_GUIDE.md (§4.3) | payload modulo exactly one L2 substitution `hiya-crew/` → `psychic-crew/` | `38d1cd51854341b7` |
| Plan.md (§4.4) | live log — identity verified pristine pre-step-1 (`6f703cb44252b61b`), not re-checkable after | n/a |

Gate verification: diff each seed against its fence-extracted payload and assert the changed-line count is exactly 0 / 1 / 1 with the changed line matching the recorded substitution. Any other delta is drift and FAILs.

Retire path: when the operator re-exports the plan as v2.4 with the rename applied upstream, EX-01 is deleted and plain §14.5 byte-identity resumes. Until then EX-01 travels in every G-F0 gate report.

**Residual `hiya-crew` strings left intentionally untouched** (they live inside the unedited execution authority and must be read as `psychic-crew` at execution time): §0.1 operating path (L7, ×2) · §3 Q1 repo name (L35) · §4.1 payload (L47) · §4.3 payload (L75) · §5.1.1 `arbiter.md` payload body (L187) · §5.5 setup.sh description (L272) · §6 F0 step 5 `gh repo create` command (L287). **F3 warning:** L187 is inside a verbatim agent payload — the substitution must be applied when `arbiter.md` is written, or the old name is reintroduced into the build.

## Review Notes per Gate
### G-F0 (in progress)
[F0|2026-08-11T03:24:59Z] §14.5 seed identity verification — four pre-placed seeds vs the §4.1–§4.4 payloads. Method: fence-extraction from MASTER_FIFO_PLAN_CLAUDE.md by section header (awk; Bash-only, because the global Prettier PostToolUse hook corrupts byte identity on any Write/Edit), then `cmp` byte comparison plus sha256. Run pre-step-1 while all four were pristine, per OQ-1.

| Payload | File | Lines/Bytes | sha256 (first 16) | Result |
|---|---|---|---|---|
| §4.1 | CLAUDE.md | 13 / 1535 | `8e53fd3721eb055e` | PASS — byte-identical |
| §4.2 | CLAUDE_DESIGN.md | 8 / 2493 | `8d5c46d5b4263285` | PASS — byte-identical |
| §4.3 | DIRECTORY_GUIDE.md | 21 / 1948 | `60a8c6300e510188` | PASS — byte-identical |
| §4.4 | Plan.md | 12 / 369 | `6f703cb44252b61b` | PASS — byte-identical |

Drift: none (0/4). §0.2b's no-re-run rule suppresses re-*writing* artifacts that already exist, not re-*verifying* them; per operator addendum this check is mandatory at F0 step 3 and is not skipped by forward-resume.


[F0|2026-08-11T03:46:37Z] Seed identity **re-baselined** after the operator-directed rename (Fix Ledger, EX-01). The 4/4 byte-identical result above remains the correct record of the PRE-rename state and is what proves this prep's extraction fidelity; it is superseded as the *acceptance baseline* by EX-01's modulo-rename rule.

| Payload | File | Post-rename sha256 (first 16) | Allowed delta vs payload |
|---|---|---|---|
| §4.1 | CLAUDE.md | `ecefa6eda96c00ff` | 1 line — L1 `# hiya-crew ` → `# psychic-crew ` |
| §4.2 | CLAUDE_DESIGN.md | `8d5c46d5b4263285` | 0 — byte-identical, unchanged by the rename |
| §4.3 | DIRECTORY_GUIDE.md | `38d1cd51854341b7` | 1 line — L2 `hiya-crew/` → `psychic-crew/` |
| §4.4 | Plan.md | n/a — live log | n/a; pristine verified pre-step-1 |

Post-rename hygiene: CR bytes 0/0, trailing newline present on both, line counts unchanged (13 / 8 / 21). Renamed copies stashed outside the root at `hiya-crew-context/renamed-seeds/`; `pristine-seeds/` is deliberately left as the canonical v2.3 set, so a restore from it must be followed by re-applying the two-line EX-01 delta.
