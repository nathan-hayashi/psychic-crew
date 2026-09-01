#!/usr/bin/env bash
# portability-drill.sh — the G-F8 portability proof, reproducible.
#
# The plan's G-F8 demo says "fresh-clone drill in a temp dir -> setup.sh green". This build's own
# HC-5 guard blocks the clone verb (hooks/bash-blocker.sh), and that guard is correct — it cannot tell
# a self-clone from pulling in external code, and the rule it enforces is the one that keeps this
# build from-scratch. So the drill proves the same property by two mechanisms that are not clones,
# registered as C-22:
#
#   A. git archive  -> the exact tracked byte-set a consumer receives, with no .git and no local
#                      config. This is the STRICTER test: it proves the shipped files are complete
#                      and self-contained, which a clone of a dirty working copy would not.
#   B. git worktree -> a separate checkout directory that still carries .git, so the assertions
#                      that need a repo (notably the absolute-path check named by the G-F8 stress)
#                      actually run instead of skipping.
#
# Usage: scripts/portability-drill.sh [tmpdir]   Exit 0 = portable.

set -eu

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

TMP="${1:-$(mktemp -d)}"
mkdir -p "$TMP"
WT="$TMP/worktree"
AR="$TMP/archive"
FAIL=0

cleanup () {
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  [ -n "${1:-}" ] || rm -rf "$AR"
}
trap 'cleanup keep' EXIT

printf '\n== A. git archive — tracked bytes only, no .git ==\n'
rm -rf "$AR"; mkdir -p "$AR"
git archive --format=tar HEAD | tar -x -C "$AR"
want=$(git ls-files | wc -l)
got=$(find "$AR" -type f | wc -l)
if [ "$want" -eq "$got" ]; then
  printf '  [ok]   %s tracked files extracted\n' "$got"
else
  printf '  [FAIL] extracted %s files, expected %s\n' "$got" "$want"; FAIL=$((FAIL + 1))
fi
if ( cd "$AR" && ./scripts/setup.sh ) > "$TMP/a.out" 2>&1; then
  printf '  [ok]   setup.sh green — %s\n' "$(grep -E 'validate-crew:' "$TMP/a.out" | tail -1 | sed 's/^ *\[ok\] *//')"
else
  printf '  [FAIL] setup.sh exited nonzero:\n'; sed 's/^/         /' "$TMP/a.out" | tail -20; FAIL=$((FAIL + 1))
fi

printf '\n== B. git worktree — separate checkout, .git present ==\n'
git worktree remove --force "$WT" >/dev/null 2>&1 || true
git worktree add -q --detach "$WT" HEAD
if ( cd "$WT" && ./scripts/setup.sh ) > "$TMP/b.out" 2>&1; then
  printf '  [ok]   setup.sh green — %s\n' "$(grep -E 'validate-crew:' "$TMP/b.out" | tail -1 | sed 's/^ *\[ok\] *//')"
else
  printf '  [FAIL] setup.sh exited nonzero:\n'; sed 's/^/         /' "$TMP/b.out" | tail -20; FAIL=$((FAIL + 1))
fi
# C-23: the absolute-path assertion must RUN here, not skip. It tested [ -d .git ], which is false in
# a worktree (.git is a file), so the G-F8 stress requirement silently skipped in the very checkout
# this drill uses. A skip here is a failure of the drill, not a neutral result.
# Bind to validate-crew's OWN output, not setup.sh's one-line summary — the summary reports totals
# and would say nothing about which assertions ran, so grepping it could never see this regression.
( cd "$WT" && ./scripts/validate-crew.sh ) > "$TMP/b-validate.out" 2>&1 || true
if grep -qE '\[(PASS|FAIL)\].*absolute .* literals' "$TMP/b-validate.out"; then
  printf '  [ok]   absolute-path assertion ran in the worktree (C-23)\n'
else
  printf '  [FAIL] absolute-path assertion did not run in the worktree — C-23 has regressed\n'
  grep -iE 'skip|absolute' "$TMP/b-validate.out" | sed 's/^/         /'
  FAIL=$((FAIL + 1))
fi
# setup.sh must not dirty a clean checkout: apply-models is a stamp, and a stamp that changes tracked
# files on a clean tree means config and stamps have drifted.
d=$(cd "$WT" && git status --porcelain | wc -l)
if [ "$d" -eq 0 ]; then printf '  [ok]   setup.sh left the checkout clean (apply-models idempotent)\n'
else printf '  [FAIL] setup.sh dirtied %s file(s) in a clean checkout\n' "$d"; FAIL=$((FAIL + 1)); fi

printf '\n== C. clone-shaped consumer — .git is a DIRECTORY and trails are empty ==\n'
# ONBOARD-1 (2026-08-26). An operator's first real clone on a new laptop failed setup while both
# legs above stayed green, because both dodge the environment a consumer actually has: the extract
# carries no .git at all, and a worktree's .git is a FILE. A genuine clone has a .git DIRECTORY
# plus the empty runtime trails, and validate-crew's binding guards misclassified exactly that.
# HC-5 forbids this drill from cloning, so the clone's shape is built instead: the tracked
# byte-set, its own git history, no trails. setup.sh must reach READY here or a consumer's first
# ten minutes are a red herring.
CS="$TMP/clone-shaped"
rm -rf "$CS"; mkdir -p "$CS"
git archive --format=tar HEAD | tar -x -C "$CS"
( cd "$CS" && git init -q -b dev && git add -A \
  && git -c user.email=drill@local -c user.name=drill commit -qm "clone-shaped" ) >/dev/null 2>&1
if ( cd "$CS" && ./scripts/setup.sh ) > "$TMP/c.out" 2>&1; then
  printf '  [ok]   setup.sh READY in the clone-shaped checkout — %s\n' "$(grep -E 'validate-crew:' "$TMP/c.out" | tail -1 | sed 's/^ *\[ok\] *//')"
  if ( cd "$CS" && bash hooks/session-start.sh >/dev/null 2>&1 ); then
    printf '  [ok]   session-start silent-exit-0 with no logs/ (ARC4-2: the no-audit branch, leg C)\n'
  else
    printf '  [FAIL] session-start died in the clone-shaped checkout (the no-audit branch broke)\n'
  fi
else
  printf '  [FAIL] setup.sh NOT READY in the clone-shaped checkout (the operator-laptop class):\n'
  grep -E '\[FAIL\]|NOT READY' "$TMP/c.out" | sed 's/^/         /' | tail -6; FAIL=$((FAIL + 1))
fi
# Probe the construct, not a compression of it (R-SD-1 rule 6, caught by this leg's own first
# committed run): setup.sh swallows validate's detail into a one-line summary, so the announced
# non-primary passes never appear in c.out. Run validate directly, as leg B already does for C-23.
( cd "$CS" && ./scripts/validate-crew.sh ) > "$TMP/c-validate.out" 2>&1 || true
grep -qE 'primary checkout' "$TMP/c-validate.out" \
  && printf '  [ok]   binding guards announced the non-primary environment instead of firing\n' \
  || { printf '  [FAIL] no announced non-primary pass — the guards bound where they must not\n'; FAIL=$((FAIL + 1)); }

printf '\n== result ==\n'
if [ "$FAIL" -eq 0 ]; then
  printf '  PORTABLE — all three mechanisms green at %s\n\n' "$(git rev-parse --short HEAD)"
  exit 0
else
  printf '  NOT PORTABLE — %s check(s) failed\n\n' "$FAIL"
  exit 1
fi
