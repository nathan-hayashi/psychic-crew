#!/usr/bin/env bash
# validate-crew.sh — gate assertions per MASTER_FIFO_PLAN §5.5. Used by every gate.
# Verdicts: PASS | SKIP (artifact owned by a later phase, not yet created) | FAIL.
# Exits nonzero on any FAIL. SKIP never fails a gate.
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; S=0; F=0
pass () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
skip () { S=$((S+1)); printf '  [SKIP] %s\n' "$1"; }
fail () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }

echo "== config parses =="
jq -e . models.config.json    >/dev/null 2>&1 && pass "models.config.json parses" || fail "models.config.json does not parse"
jq -e . .claude/settings.json >/dev/null 2>&1 && pass ".claude/settings.json parses" || fail ".claude/settings.json does not parse"

echo "== HC-2 forbidden model substrings =="
hc2=0
for bad in $(jq -r '.forbidden_substrings[]' models.config.json 2>/dev/null); do
  if grep -ri --exclude-dir=logs --exclude-dir=.git --exclude="MASTER_FIFO_PLAN_CLAUDE.md" \
       "$bad" .claude/ models.config.json 2>/dev/null | grep -v '"forbidden_substrings"' | grep -q .; then
    fail "HC-2: '$bad' present in the config surface"; hc2=1
  fi
done
[ "$hc2" = 0 ] && pass "no forbidden model substrings outside the declaration"

echo "== tier lock =="
[ "$(jq -r '.env.CREW_TIER_LOCK // empty' .claude/settings.json 2>/dev/null)" = "T3" ] \
  && pass "settings.json declares CREW_TIER_LOCK=T3" || fail "CREW_TIER_LOCK not declared as T3"

echo "== .gitignore coverage =="
for e in "logs/" ".env"; do
  grep -qxF "$e" .gitignore 2>/dev/null && pass ".gitignore covers $e" || fail ".gitignore missing $e"
done

echo "== no absolute machine paths in tracked files (§5.2.4) =="
if [ -d .git ]; then
  hits=$(git grep -l "/home/" -- ':!MASTER_FIFO_PLAN_CLAUDE.md' 2>/dev/null | tr '\n' ' ')
  [ -z "$hits" ] && pass "no /home/ literals outside the execution authority" \
                 || fail "/home/ literals in: $hits"
else
  skip "git not initialized yet (F0 step 4)"
fi

echo "== agent model stamping (HC-4) =="
n=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l)
if [ "$n" = 0 ]; then
  skip "no agent definitions yet (F3 owns .claude/agents/)"
else
  MODE=$(jq -r '.mode // "alias"' models.config.json)
  for a in $(jq -r '.agents | keys[]' models.config.json); do
    f=".claude/agents/$a.md"
    [ -f "$f" ] || { fail "$f missing"; continue; }
    want=$(jq -r --arg m "$MODE" --arg a "$a" '.[if $m=="pinned" then "pinned" else "aliases" end][.agents[$a].model]' models.config.json)
    got=$(grep -m1 '^model:' "$f" | sed 's/^model:[[:space:]]*//')
    [ "$got" = "$want" ] && pass "$a stamped $got" || fail "$a stamped '$got', config says '$want'"
  done
fi

echo "== hooks =="
n=$(ls -1 hooks/*.sh 2>/dev/null | wc -l)
if [ "$n" = 0 ]; then
  skip "no hook scripts yet (F2 owns hooks/)"
else
  for h in hooks/*.sh; do
    [ -x "$h" ] || fail "$h not executable"
    bash -n "$h" 2>/dev/null || fail "$h fails syntax check"
    grep -q '\[\[' "$h" && fail "$h uses non-POSIX [[ (§9 minimal-shell)" || pass "$h ok"
  done
fi

echo "== arbiter dispatch coverage (§5.2.2) =="
if [ -f logs/tooluse-audit.jsonl ] && [ -f logs/arbiter-audit.jsonl ]; then
  d=$(grep -cE '"tool":"(Task|Agent)"' logs/tooluse-audit.jsonl 2>/dev/null || echo 0)
  c=$(wc -l < logs/arbiter-audit.jsonl)
  [ "$c" -ge "$d" ] && pass "arbiter lines $c >= dispatches $d" \
                    || fail "uncovered lead->specialist dispatch: $d dispatches, $c arbiter lines"
else
  skip "no audit logs yet (F2/F3 own logs/)"
fi

printf '\n== validate-crew: %s PASS / %s SKIP / %s FAIL ==\n' "$P" "$S" "$F"
[ "$F" = 0 ] || exit 1
