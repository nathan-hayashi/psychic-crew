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

echo "== HC-2 forbidden models (assignment positions) =="
# EX-03: a bare substring scan flags any mention, including the rule file that documents the
# prohibition and F2's model-guard.sh, which must contain the string to guard it. HC-2 forbids a
# forbidden model being ASSIGNED, so check assignment positions: model-bearing JSON values, and
# lines that are model assignments. Prose mentions are not configuration.
hc2=0
for bad in $(jq -r '.forbidden_substrings[]' models.config.json 2>/dev/null); do
  h=$( { jq -r --arg b "$bad" '
          [ (.aliases // {} | to_entries[] | "aliases.\(.key)=\(.value)"),
            (.pinned  // {} | to_entries[] | "pinned.\(.key)=\(.value)"),
            ("session.model=" + (.session.model // "")),
            (.agents  // {} | to_entries[] | "agents.\(.key).model=\(.value.model)") ]
          | .[] | select(ascii_downcase | contains($b))' models.config.json 2>/dev/null
        jq -r --arg b "$bad" '"settings.model=" + (.model // "") | select(ascii_downcase | contains($b))' \
          .claude/settings.json 2>/dev/null
        grep -rniE "^[[:space:]]*[\"']?model[\"']?[[:space:]]*:[[:space:]]*[\"']?[^\"',}]*${bad}" \
          .claude/ 2>/dev/null ; } | grep . )
  if [ -n "$h" ]; then fail "HC-2: '$bad' assigned as a model -> $(echo "$h" | tr '\n' ' ')"; hc2=1; fi
done
[ "$hc2" = 0 ] && pass "no forbidden model assigned anywhere in the config surface"

echo "== tier lock =="
[ "$(jq -r '.env.CREW_TIER_LOCK // empty' .claude/settings.json 2>/dev/null)" = "T3" ] \
  && pass "settings.json declares CREW_TIER_LOCK=T3" || fail "CREW_TIER_LOCK not declared as T3"

echo "== .gitignore coverage =="
for e in "logs/" ".env"; do
  grep -qxF "$e" .gitignore 2>/dev/null && pass ".gitignore covers $e" || fail ".gitignore missing $e"
done

echo "== no absolute machine paths in tracked files (§5.2.4) =="
if [ -d .git ]; then
  # Pattern is split so this validator does not match its own check. Excluding the
  # file instead would blind the validator to the one file most worth checking.
  HOMEPAT="/ho""me/"
  hits=$(git grep -l "$HOMEPAT" -- ':!MASTER_FIFO_PLAN_CLAUDE.md' 2>/dev/null | tr '\n' ' ')
  [ -z "$hits" ] && pass "no absolute ${HOMEPAT} literals outside the execution authority" \
                 || fail "absolute ${HOMEPAT} literals in: $hits"
else
  skip "git not initialized yet (F0 step 4)"
fi

echo "== agent model stamping (HC-4) =="
n=$(ls -1 .claude/agents/*.md 2>/dev/null | wc -l)
if [ "$n" = 0 ]; then
  skip "no agent definitions yet (F3 owns .claude/agents/)"
else
  MODE=$(jq -r '.mode // "alias"' models.config.json)
  miss=0
  for a in $(jq -r '.agents | keys[]' models.config.json); do
    f=".claude/agents/$a.md"
    # Not-yet-written agents are F3's, not a failure. Every agent that DOES exist must be
    # correctly stamped; F3's own gate asserts the full roster is present.
    [ -f "$f" ] || { miss=$((miss+1)); continue; }
    want=$(jq -r --arg m "$MODE" --arg a "$a" '.[if $m=="pinned" then "pinned" else "aliases" end][.agents[$a].model]' models.config.json)
    got=$(grep -m1 '^model:' "$f" | sed 's/^model:[[:space:]]*//')
    wante=$(jq -r --arg a "$a" '.agents[$a].effort' models.config.json)
    gote=$(grep -m1 '^effort:' "$f" | sed 's/^effort:[[:space:]]*//')
    if [ "$got" = "$want" ] && [ "$gote" = "$wante" ]; then pass "$a stamped model:$got effort:$gote"
    else fail "$a stamped model:'$got' effort:'$gote', config says model:'$want' effort:'$wante'"; fi
  done
  [ "$miss" = 0 ] || skip "$miss of $(jq '.agents|length' models.config.json) agent definitions not yet written (F3)"
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
