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
# Kill-switch (G-F2 stress): the authority on what must exist is settings.json itself. If a hook
# is WIRED, its script must be present and valid — otherwise deleting hooks/ would silently SKIP
# and the enforcement layer could be removed without any check noticing.
WIRED=$(jq -r '[.hooks[]?[]?.hooks[]?.command] | .[]' .claude/settings.json 2>/dev/null \
        | grep -oE 'hooks/[a-z-]+\.sh' | sort -u)
if [ -n "$WIRED" ]; then
  for w in $WIRED; do
    [ -f "$w" ] || fail "wired hook missing from disk: $w (kill-switch)"
  done
fi
n=$(ls -1 hooks/*.sh 2>/dev/null | wc -l)
if [ "$n" = 0 ]; then
  if [ -n "$WIRED" ]; then fail "hooks/ is empty but settings.json wires $(printf '%s' "$WIRED" | wc -w) hooks (kill-switch)"
  else skip "no hook scripts yet (F2 owns hooks/)"; fi
else
  for h in hooks/*.sh; do
    [ -x "$h" ] || fail "$h not executable"
    bash -n "$h" 2>/dev/null || fail "$h fails syntax check"
    # `[[:space:]]` etc. are POSIX character classes, not bash conditionals — match `[[` only
    # when NOT followed by ':'. Fifth instance of a check tripping on legitimate text.
    grep -qE '\[\[[^:]' "$h" && fail "$h uses non-POSIX [[ (§9 minimal-shell)" || pass "$h ok"
  done
fi

echo "== arbiter dispatch coverage (§5.2.2) =="
echo "== tier lock + router (HC-1, §5.3) =="
# What is machine-checkable here is the MECHANISM, not the behaviour: that the skill exists at the
# path DIRECTORY_GUIDE declares, that it branches on the lock, that it carries the exact
# announcement token, and that the env actually sets the lock. Whether a given session announced
# the tier is transcript evidence and stays manual-eyes at the gate, per §6 F4.
SK=".claude/skills/threshold-router/SKILL.md"
[ -f "$SK" ] && pass "threshold-router skill present at the declared path" \
             || fail "$SK missing — DIRECTORY_GUIDE lists it and §5.3 specifies it"
if [ -f "$SK" ]; then
  grep -q 'CREW_TIER_LOCK' "$SK" && pass "router branches on CREW_TIER_LOCK" \
                                 || fail "router has no lock branch — it would score every prompt"
  # The announcement is a fixed token. A paraphrase is not the token, and the gate greps for it.
  grep -qF '[T3 — LOCKED]' "$SK" && pass "router carries the exact announcement token" \
                                 || fail "router does not carry the exact [T3 — LOCKED] token"
  grep -q 'Else score' "$SK" && pass "router retains the unlocked scoring path (stress-testable)" \
                             || fail "router has no fallback scoring path"
fi
TL=$(jq -r '.env.CREW_TIER_LOCK // empty' .claude/settings.json 2>/dev/null)
[ "$TL" = "T3" ] && pass "CREW_TIER_LOCK=T3 set in project env" \
                 || fail "CREW_TIER_LOCK is '${TL:-unset}' in settings.json; HC-1 requires T3"
grep -qF '[T3 — LOCKED]' CLAUDE.md && pass "CLAUDE.md states the announcement obligation" \
                                   || fail "CLAUDE.md does not state the announcement obligation"

# C-12 / EX-05: counting is not correlating. The previous form compared the COUNT of Agent calls
# against the COUNT of arbiter lines, which the audited party can satisfy by writing any lines at
# all — observed live at G-F3, where two truthful arbiter lines flipped a true-positive FAIL to
# PASS with nothing remediated. Correlate task_id instead: every dispatch to a specialist must be
# covered by an arbiter line carrying the SAME task_id, so surplus lines cannot mask a missing one.
if [ -f logs/tooluse-audit.jsonl ] && [ -f logs/arbiter-audit.jsonl ]; then
  SPEC='security-reviewer|quality-reviewer|fixer|test-runner|integration-runner'
  disp=$(jq -r --arg s "$SPEC" 'select(.tool=="Agent" or .tool=="Task")
           | select((.task_id // "") != "") | select((.target // "") | test($s)) | .task_id' \
         logs/tooluse-audit.jsonl 2>/dev/null | sort -u)
  cov=$(jq -r 'select((.task_id // "") != "") | .task_id' logs/arbiter-audit.jsonl 2>/dev/null | sort -u)
  if [ -z "$disp" ]; then
    skip "no identified specialist dispatch recorded yet (arbiter coverage untestable)"
  else
    unc=$(comm -23 <(printf '%s\n' "$disp") <(printf '%s\n' "$cov") | sed '/^$/d')
    if [ -z "$unc" ]; then
      pass "every specialist dispatch is covered by an arbiter line of the same task_id"
    else
      fail "uncovered specialist dispatch task_id(s): $(printf '%s' "$unc" | tr '\n' ' ')"
    fi
  fi
else
  skip "no audit logs yet (F2/F3 own logs/)"
fi

printf '\n== validate-crew: %s PASS / %s SKIP / %s FAIL ==\n' "$P" "$S" "$F"
[ "$F" = 0 ] || exit 1
