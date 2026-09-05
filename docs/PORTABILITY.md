# PORTABILITY — running the crew suite on macOS/BSD

Status: HARNESS-1 (2026-08-27). The suite was authored against GNU coreutils on WSL/Linux and had
never been exercised on BSD/macOS userland until a MacBook (VSCode) setup ran it. That run reported
16 failures against a recorded green — every one a GNU-vs-BSD portability defect, not a real property
violation. This gate fixed the defects, added scanners that keep the class out, and documents the
one step only a Mac can complete.

## What was wrong, and what fixed it

| GNU-ism                                    | Symptom on macOS/BSD                                                                                                  | Fix                                                                                                                                       |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `wc -l` left-pads its count (`"       0"`) | a count reaching a **string** test `[ "$n" = 0 ]` takes the failure branch on a genuine zero — 13 false failures      | every such site uses a **numeric** test (`-eq`/`-ge`), which strips the padding; enforced by the **rule-2 scanner**                       |
| `sed -i` with no suffix                    | BSD consumes the script as the backup-suffix operand and edits nothing — the HC-2 poison-plant became a no-op control | the `-i.bak … && rm -f ….bak` idiom (both userlands accept it), plus an **assert-planted** meta-check; enforced by the **rule-7 scanner** |
| `sha256sum` is GNU-only                    | absent on macOS → both byte-pin hashes empty → guard passes on `"" = ""` — a **silent false-pass**, worse than a red  | a `_sha256` helper falling back to `shasum -a 256`; callers treat an empty hash as failure; enforced by the **rule-7 scanner**            |
| `paste -sd \| bc`                          | BSD `paste` needs an explicit stdin operand; `bc` is marginal on macOS                                                | `awk '{s+=$1} END{print s+0}'` — no `paste`, no `bc`                                                                                      |

## What the scanners guarantee (regression prevention)

`run-crew-tests.sh` now carries two class assertions beside the existing R-SD-1 rule-1 and rule-5
scanners, each with a live fire-probe proving it catches its shape:

- **rule-2** — no `wc -l` count reaches an inline string comparison in tracked shell.
- **rule-7** — no bare `sed -i`, no `sha256sum` outside the `_sha256` helper, no `paste -sd` without
  a stdin operand, in tracked shell.

Stated honestly (the house discipline of naming a scanner's blind spot): the rule-2 line scanner
catches the inline `wc -l)" =` form, not the two-step `n=$(wc…); [ "$n" = 0 ]` across lines — those
were swept by hand at HARNESS-1 and gain a needle when evidence produces a fresh instance.

## Deny-list integrity (unrelated to userland, found in the same review)

The old deny-integrity check compared the deny-list against a **hand-maintained subset of seven
needles** — half the fourteen entries. Removing an unlisted entry (the fork-bomb row, terraform,
kubectl, either `Read()` rule) passed silently. It is now a tracked golden manifest
(`.claude/deny-manifest.txt`) compared by **set difference both ways**: a removal fails as
manifest-not-in-settings, an addition fails as settings-not-in-manifest and forces a matching gated
manifest edit. No deny entry changed at this gate.

## The one step only your Mac can complete

The scanners prevent regressions; they do not prove the suite green on BSD, because this repo is
developed on Linux. **Certification is an operator run on real macOS userland:**

```bash
cd ~/projects && git -C psychic-crew pull        # onto a CURRENT checkout, not a stale one
cd psychic-crew && ./scripts/setup.sh            # expect: READY
./scripts/run-crew-tests.sh                      # expect: the recorded green
```

Requirements on macOS: `git`, `node ≥ 22`, `jq`, and either `sha256sum` (via coreutils) or the
built-in `shasum` — the suite now uses whichever is present. If `setup.sh` does not end `READY`,
paste its output into a session in the repo and the gate law handles it.

## Not covered here (named, not silently skipped)

- **The twin repo (psychic-crew-lite)** gets the rule-2/rule-7 scanners at its own portability gate,
  not this one — its suite is separate (`validate-lite.sh`) and was not part of the MacBook run.
  **SUPERSEDED at LITE-PARITY-1 (2026-09-02): the scanners are PORTED** — with the twin's corrected
  comment-stripper on both sides, and the port's pre-sweep caught three real direct-sha256sum sites
  (check-sync's byte-compare and check-witness's attestations — the exact silent-false-pass class
  this document warns about), swept through a `_sha256` helper in the same gate. The operator's BSD
  certification run on the lite suite remains the one step only the Mac can complete.
- Other early-exit consumers (`head -n`, `grep -m`, `sed q`) remain R-SD-1 rule-5 prose until an
  instance appears.

## BSD-CERT run 1 finding (2026-09-05, the operator's Mac)

The first live certification run caught what the scanners could not: **bash 3.2 (macOS's
stock /bin/bash) cannot parse `case` inside `$(...)` command substitution** — a parser
limitation fixed in bash 4, invisible on every Linux run, and fatal to `bash -n` on Darwin.
`hooks/session-start.sh` carried six such guards inside its context substitution; the fix
wraps the body in a top-level function (parsed where 3.2 is fine) and substitutes the
function, guards byte-identical. Rule 7 gains the class in prose; a reliable scanner for
case-inside-substitution is a multiline parse this suite does not attempt — stated gap,
needle-on-next-evidence. The certification proceeds: setup green, then `./scripts/attest.sh
run` writes the Darwin/BSD row that IS the artifact.
