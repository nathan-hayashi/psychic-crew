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
if grep -q 'no absolute .* literals outside the execution authority' "$TMP/b.out"; then
  printf '  [ok]   absolute-path assertion ran in the worktree (C-23)\n'
else
  printf '  [FAIL] absolute-path assertion did not run in the worktree — C-23 has regressed\n'; FAIL=$((FAIL + 1))
fi
# setup.sh must not dirty a clean checkout: apply-models is a stamp, and a stamp that changes tracked
# files on a clean tree means config and stamps have drifted.
d=$(cd "$WT" && git status --porcelain | wc -l)
if [ "$d" -eq 0 ]; then printf '  [ok]   setup.sh left the checkout clean (apply-models idempotent)\n'
else printf '  [FAIL] setup.sh dirtied %s file(s) in a clean checkout\n' "$d"; FAIL=$((FAIL + 1)); fi

printf '\n== result ==\n'
if [ "$FAIL" -eq 0 ]; then
  printf '  PORTABLE — both mechanisms green at %s\n\n' "$(git rev-parse --short HEAD)"
  exit 0
else
  printf '  NOT PORTABLE — %s check(s) failed\n\n' "$FAIL"
  exit 1
fi
