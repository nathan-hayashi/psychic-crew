#!/usr/bin/env bash
# setup.sh — wire a fresh clone of this repo to a verified-green state.
#
# Installs nothing (HC-5: no installs, no clones, no npx, no MCP servers). Every dependency below is
# either already on the machine or the setup fails and says which one is missing. The repo has zero
# runtime dependencies by design, so "setup" here means: check the toolchain, recreate the gitignored
# runtime directories, verify model routing, and prove the checkout is green.
#
# Idempotent: safe to run any number of times. Exit 0 = ready, nonzero = a stated reason.

set -eu

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

FAIL=0
ok ()   { printf '  [ok]   %s\n' "$1"; }
warn () { printf '  [warn] %s\n' "$1"; }
bad ()  { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }

printf '\n== 1. toolchain ==\n'

if command -v git >/dev/null 2>&1; then ok "git $(git --version | awk '{print $3}')"
else bad "git not found — required"; fi

if command -v node >/dev/null 2>&1; then
  nv=$(node -v | sed 's/^v//')
  nmaj=${nv%%.*}
  if [ "${nmaj:-0}" -ge 22 ]; then ok "node v$nv"
  else bad "node v$nv is below the v22 floor in stress-project/package.json engines"; fi
else bad "node not found — required"; fi

if command -v npm >/dev/null 2>&1; then ok "npm $(npm -v)"
else bad "npm not found — required to run the app suite"; fi

# jq is load-bearing: validate-crew, the audit hooks and the corrections check all parse JSON with it.
if command -v jq >/dev/null 2>&1; then ok "jq $(jq --version | sed 's/^jq-//')"
else bad "jq not found — required by validate-crew.sh and the audit hooks"; fi

command -v gh >/dev/null 2>&1 && ok "gh $(gh --version | head -1 | awk '{print $3}') (optional)" \
                              || warn "gh not found (optional — only needed for repo operations)"

printf '\n== 2. runtime directories ==\n'
# These are gitignored, so a fresh clone has none of them. Hooks append to logs/ on their first call
# and a missing directory would make a hook fail silently at exactly the wrong moment.
for d in logs logs/metrics logs/rounds .claude/state/checkpoints stress-project/tmp; do
  if [ -d "$d" ]; then ok "$d (present)"
  else mkdir -p "$d" && ok "$d (created)"; fi
done

printf '\n== 3. executable bits ==\n'
# git preserves the exec bit, so this is a repair step for checkouts that lost it (zip export,
# some Windows checkouts, a filesystem mounted without exec).
fixed=0
for f in hooks/*.sh scripts/*.sh; do
  [ -f "$f" ] || continue
  [ -x "$f" ] || { chmod +x "$f"; fixed=$((fixed + 1)); }
done
[ "$fixed" = 0 ] && ok "all hooks and scripts already executable" || ok "restored exec bit on $fixed file(s)"

printf '\n== 4. model routing (HC-4) ==\n'
# models.config.json is the single source of truth; apply-models.sh stamps every agent from it. On a
# clean checkout this is a no-op that verifies the stamps still match config — and it is the check
# that refuses to proceed if a forbidden model string (HC-2) is present anywhere.
if [ -x scripts/apply-models.sh ]; then
  if out=$(./scripts/apply-models.sh 2>&1); then
    w=$(printf '%s\n' "$out" | grep -c '\[WARN\]' || true)
    if [ "${w:-0}" -eq 0 ]; then ok "apply-models.sh clean"
    else ok "apply-models.sh clean, $w structured warning(s) — see its output"; fi
  else
    printf '%s\n' "$out" | sed 's/^/         /'
    bad "apply-models.sh exited nonzero — model routing is not in a valid state"
  fi
else
  bad "scripts/apply-models.sh missing or not executable"
fi

printf '\n== 5. crew validation ==\n'
if [ -x scripts/validate-crew.sh ]; then
  if out=$(./scripts/validate-crew.sh 2>&1); then
    ok "$(printf '%s' "$out" | tail -1 | sed 's/^== //;s/ ==$//')"
  else
    printf '%s\n' "$out" | grep -E '\[FAIL\]' | sed 's/^/         /'
    bad "$(printf '%s' "$out" | tail -1 | sed 's/^== //;s/ ==$//')"
  fi
else
  bad "scripts/validate-crew.sh missing or not executable"
fi

printf '\n== 6. app suite (zero dependencies) ==\n'
if [ -f stress-project/package.json ]; then
  if out=$(cd stress-project && npm test 2>&1); then
    # The default reporter is `spec`, which prints "ℹ pass 18" — NOT the TAP "# pass 18". Matching
    # only the TAP form here would report an empty count on a perfectly green suite.
    counts=$(printf '%s\n' "$out" | grep -E '^[^ ]* ?(tests|pass|fail) [0-9]+$' | tr '\n' ' ' || true)
    ok "app suite green ${counts:-(exit 0)}"
  else
    printf '%s\n' "$out" | tail -20 | sed 's/^/         /'
    bad "stress-project app suite failed"
  fi
else
  warn "stress-project/ not present — skipping the app suite"
fi

printf '\n== authentication ==\n'
cat <<'NOTE'
  This repo holds no secrets and needs none to run the checks above.

  Claude Code auth is per-machine, not per-repo: run `claude auth status` (or `/status` inside a
  session) to confirm. If you intend to use the GitHub lanes, `gh auth status` must be green too.

  Nothing here writes credentials. .env, .env.* and secrets/ are gitignored AND blocked by
  hooks/sensitive-guard.sh; that guard is a backstop, not a licence to put secrets in the tree.
NOTE

printf '\n== result ==\n'
if [ "$FAIL" = 0 ]; then
  printf '  READY — %s\n\n' "$(git rev-parse --short HEAD 2>/dev/null || printf 'no git HEAD')"
  printf '  Next: ./scripts/run-crew-tests.sh   (full crew suite; needs the runtime logs a live session produces)\n'
  printf '        ./scripts/check-plan-corrections.sh   (plan-vs-reality registry)\n\n'
  exit 0
else
  printf '  NOT READY — %s check(s) failed above.\n\n' "$FAIL"
  exit 1
fi
