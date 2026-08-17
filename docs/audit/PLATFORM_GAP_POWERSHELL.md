# PLATFORM_GAP_POWERSHELL.md — A5.2c

Feasibility of running this build on **native Windows 10/11 with zero WSL**. Report only — no port
is proposed here, and the target folder is a next-phase build.

---

## The question that decides everything

**How does Claude Code invoke hooks on native Windows?** Verified against the platform reference
`[V]`:

> On Windows, the shell form passes the command string to **Git Bash**, or to **PowerShell when Git
> Bash isn't installed**. Git for Windows is recommended on native Windows so Claude Code can use
> the Bash tool; without it, Claude Code runs shell commands via the PowerShell tool.

That splits the analysis into two entirely different projects, and the split is not a detail — it
is the whole decision.

| Scenario                            | Port scope                              |
| ----------------------------------- | --------------------------------------- |
| **A. Git for Windows present**      | 1 dependency to solve, 2 files to adapt |
| **B. Pure PowerShell, no Git Bash** | all 21 shell files rewritten            |

---

## Scenario A — Git for Windows present

Git Bash ships the POSIX core this build uses: `sed`, `grep`, `awk`, `cut`, `tr`, `find`, `xargs`,
`mktemp`, `date`, `diff`, `comm`, `sha256sum`. Measured against the actual dependency set, the
scripts and hooks would run essentially as-is.

**One blocker, and it is the same one everywhere:** Git for Windows does **not** ship `jq`.

| Dependency                                                        | Used by                  | Git Bash ships it?         |
| ----------------------------------------------------------------- | ------------------------ | -------------------------- |
| **`jq`**                                                          | **16 of 21 files** `[E]` | **no**                     |
| `grep`                                                            | 18                       | yes                        |
| `sed`                                                             | 12                       | yes                        |
| `awk`                                                             | 4                        | yes                        |
| `mktemp`                                                          | 4                        | yes                        |
| `git`                                                             | 7                        | yes                        |
| `node`/`npm`                                                      | 4                        | separate, already required |
| `sha256sum`, `comm`, `diff`, `find`, `xargs`, `cut`, `tr`, `date` | various                  | yes                        |

Breakdown of the `jq` dependency `[E]`: **10 of 12 hooks** (all but
`pre-compact-checkpoint.sh` and `stop.sh`) and **6 of 9 scripts** (all but `portability-drill.sh`,
`restore-context.sh`, `save-context.sh`).

This is not incidental coupling. Every `PreToolUse` hook parses its stdin payload with `jq` and
several emit their deny JSON the same way, so `jq` sits on the enforcement path itself. HC-5
permits base toolchain "already present from the corpus environment" — `jq` is listed in §2.1
alongside `git` and `node`, so requiring it on Windows is consistent with the existing posture
rather than a new install. **That is an operator call, not an audit finding.**

### The two files that are genuinely WSL-specific

Exactly two, and both are already defensive `[E]`:

- `hooks/notify.sh:6` — gated on `grep -qi microsoft /proc/version` **and** `command -v`, so on a
  non-WSL host the condition is simply false.
- `hooks/stop.sh:29` — `command -v … && … || true`, never fatal.

Both degrade to silence rather than failure. A Windows port replaces the notifier with `BurntToast`
or `msg.exe` behind the same guard. **Effort: under an hour.**

### PG-F1 — no `.gitattributes`, and that is the real Windows trap

**P2 for any Windows port · portability · Failure scenario:** the repository is checked out on
Windows with `core.autocrlf=true`, the default for Git for Windows. Every `.sh` file gains CRLF
line endings. Shebangs become `#!/usr/bin/env bash\r`, and every script fails with an obscure
interpreter error.

`.gitattributes` is **absent** `[E]`. Nothing declares end-of-line normalisation for any file type.

The blast radius goes past shebangs, because this build greps for exact lines:

- `validate-crew.sh:43` uses `grep -qxF "logs/"` — `logs/\r` does not match `logs/`, so the gate
  fails on a correct `.gitignore` (compounding A3-F7, which already found that check text-bound).
- `run-crew-tests.sh` extracts fenced payload blocks and compares them byte-for-byte for EX-01
  identity. CRLF makes **every** seed report drift, failing the exception the whole build rests on.
- `hooks/_common.sh`'s `scrub()` regexes and `bash-blocker`'s whole-string `case` patterns both see
  a trailing `\r` that was not there when they were written.

**One line fixes it** — `* text=auto eol=lf`, plus explicit `*.sh text eol=lf` — and it costs
nothing on Linux, where it is a no-op. It is worth doing **before** any Windows work starts, not as
part of it. Filed as a change request in its own right rather than a port task.

**Two Windows traps that turned out to be absent** `[E]`, both worth recording because their
presence would have been expensive:

- **No symlinks.** `git ls-files -s` reports zero mode-`120000` entries. Symlinks are the single
  worst Windows portability problem and this repo has none.
- **Shebangs are uniform.** All 20 executable shell files declare `#!/usr/bin/env bash` — no `sh`
  vs `bash` ambiguity to resolve per file.

### Exec bits

`setup.sh` restores executable bits, a concept Windows filesystems do not have. Git for Windows
tracks mode `100755` in the index and Git Bash honours the shebang regardless, so the restore step
becomes a harmless no-op rather than a failure. **No work required; worth a comment so the next
reader does not "fix" it.**

---

## Scenario B — pure PowerShell, no Git Bash

Every one of the 21 shell files is rewritten. This is a port, not an adaptation, and the estimate
below is deliberately coarse because the real cost is in the parts that are not line-for-line
translations.

| Component                               | Count | Translation difficulty | Note                                                                                                                 |
| --------------------------------------- | ----- | ---------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Hooks: stdin JSON → decision            | 12    | **low**                | PowerShell's `ConvertFrom-Json` is a better fit than `jq` here; hooks are short                                      |
| `apply-models.sh`                       | 1     | low                    | pure JSON read + frontmatter stamp                                                                                   |
| `save-context.sh`, `restore-context.sh` | 2     | low                    | file manipulation, minimal `jq`                                                                                      |
| `validate-crew.sh`                      | 1     | **medium**             | `comm`-based set difference → `Compare-Object`; the C-23 `git rev-parse` idiom ports directly                        |
| `check-plan-corrections.sh`             | 1     | **medium**             | several detectors execute hooks and assert on output — needs a PowerShell equivalent of `printf '%s' … \| ./hook.sh` |
| `measure-dispatch-cost.sh`              | 1     | medium                 | `awk` aggregation → `Group-Object`/`Measure-Object`                                                                  |
| `portability-drill.sh`                  | 1     | medium                 | `git archive` + worktree port cleanly; temp-dir handling differs                                                     |
| `setup.sh`                              | 1     | medium                 | exec-bit restore becomes a no-op; toolchain probe changes                                                            |
| **`run-crew-tests.sh`**                 | 1     | **high**               | 144 assertions, 14 external tools, heredocs, process substitution `<(…)`, `mktemp -d` roots, byte-identity `diff`    |

`run-crew-tests.sh` is the whole project. It uses `awk cut date diff find git grep jq mktemp node
sed sha256sum tr xargs` `[E]` — the widest surface in the repo — plus bash process substitution,
which PowerShell has no direct equivalent for and which appears in the C-12 coverage correlation.

**Coarse estimate: 3–5 focused days for Scenario B, of which `run-crew-tests.sh` is roughly half.**
Scenario A is under a day, dominated by deciding the `jq` question.

### The recommendation this report will not make

Which scenario to target is an operator decision with a real trade-off, and the audit's job is to
price both rather than pick:

- **Scenario A** is cheap and keeps one codebase, at the cost of requiring Git for Windows and `jq`
  on the target machine — which is a toolchain assumption, not a project dependency, and consistent
  with §2.1's existing assumptions.
- **Scenario B** is genuinely dependency-free on Windows and produces a second codebase to keep in
  step with the first. Two implementations of 144 assertions will diverge, and the divergence will
  be discovered by a gate failing on one platform and not the other.

If Scenario B is chosen, the honest structural answer is not a translation but a **rewrite of the
assertion layer in Node**, which is already required by the project, already the language of
`stress-project/`, and already cross-platform. That converts a two-codebase problem into a
one-codebase problem and is worth pricing before committing to PowerShell.

---

## What is verified and what is not

| Claim                                                   | Label                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------- |
| Hooks route to Git Bash, or PowerShell without it       | `[V]`                                                         |
| 16 of 21 files depend on `jq`; Git for Windows omits it | `[E]` for the count, `[I]` for the omission                   |
| `.gitattributes` absent; no symlinks; uniform shebangs  | `[E]`                                                         |
| CRLF would break EX-01 byte-identity and `grep -qxF`    | `[I]` — reasoned from the code, **not reproduced on Windows** |
| Effort estimates                                        | `[S]` — no Windows machine was available to this audit        |

**No part of this was executed on Windows.** Every claim is derived from the dependency measurement
and the platform reference. The CRLF analysis in particular deserves an actual Windows checkout
before anyone budgets against it.

Sources for the shell-invocation behaviour: the Claude Code
[hooks reference](https://code.claude.com/docs/en/hooks) and
[advanced setup](https://code.claude.com/docs/en/setup).
