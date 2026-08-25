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

echo "== agent contract shape (PR-F1) =="
# PR-F1 (audit PROMPT_READINESS): lead-planner was 8 lines against a 21-32 line median for the other
# seven — no backstory, no numbered process, and no output schema, while every reviewer had a JSON
# contract and the fixer an enumerated verdict vocabulary. It is also the most expensive agent to
# re-run (opus at max effort) and the one whose output an operator approves at a mid-gate, so a
# malformed plan could not be rejected the way a malformed FINDINGS packet can.
# Assert the CONTRACT declares a schema. A runtime plan is not visible here, but a contract that
# names no schema cannot produce a checkable one — that is the artifact that would differ if the
# defect were real.
LP=".claude/agents/lead-planner.md"
if [ -f "$LP" ]; then
  lpmiss=""
  for k in step paths acceptance rollback_tag budget_tokens; do
    grep -qF -- "\"$k\"" "$LP" || lpmiss="$lpmiss [$k]"
  done
  [ -z "$lpmiss" ] && pass "lead-planner declares a PLAN schema with all five required fields" \
                   || fail "lead-planner PLAN schema missing:$lpmiss — a plan with no declared shape cannot be rejected for having the wrong one"
else
  skip "no lead-planner definition yet (F3 owns .claude/agents/)"
fi

echo "== HC-7 Claude-only content scan (§1) =="
# CR-030 (audit A5-F1): HC-7 states that this validator greps .claude/, hooks/ and scripts/ for
# non-Claude vendor names. It never did — measured zero such occurrences in this file. The only
# coverage was one deny-test in the suite, which proves bash-blocker refuses a COMMAND. That is a
# different property from "no such invocation is written anywhere in the tree", and content being
# clean today is not the same as a control noticing when it stops being.
# The needles are assembled from fragments, and here that is not stylistic: a contiguous literal in
# this file would deny every later command that greps or edits it, and two Bash invocations were lost
# to exactly that hazard during the audit. This file is deliberately NOT allowlisted below — the F0
# precedent is that excluding the validator's own target blinds it, and the fragments are what keep
# it from matching itself.
_v1="cod""ex"; _v2="chat""gpt"; _v3="open""ai"
# Allowlisted by FILE, because in each the vendor name IS the search term rather than an invocation:
# the blocking hook must contain what it blocks, and the suite's negative control must contain what
# it proves is refused. Same class as the rebrand guard that greps for the pre-rename name.
h7=$(grep -rilE "$_v1|$_v2|$_v3" .claude/ hooks/ scripts/ 2>/dev/null \
     | grep -vE '^(hooks/bash-blocker\.sh|scripts/run-crew-tests\.sh)$' | tr '\n' ' ')
[ -z "$h7" ] && pass "HC-7: no non-Claude vendor invocation in .claude/, hooks/ or scripts/" \
             || fail "HC-7: non-Claude vendor name outside the allowlist -> $h7"

echo "== tier lock =="
[ "$(jq -r '.env.CREW_TIER_LOCK // empty' .claude/settings.json 2>/dev/null)" = "T3" ] \
  && pass "settings.json declares CREW_TIER_LOCK=T3" || fail "CREW_TIER_LOCK not declared as T3"

echo "== .gitignore coverage =="
# CR-019 (audit A3-F7): this grepped .gitignore for the exact rule TEXT, so three of four
# functionally equivalent spellings (/logs/, logs, logs/**) failed the gate while ignoring perfectly.
# C-04's detector already asks git for the effective state. Ask git here too: the artifact that would
# differ if the defect were real is what git actually ignores, never how the rule happens to be spelt.
# Guarded on work-tree membership for the C-23 reason — the portability drill runs this in a `git
# archive` extract with no .git at all, where check-ignore cannot answer. That is a genuine SKIP, and
# announcing it is what C-23 punished the absence of.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # The probe paths DO NOT EXIST on disk, deliberately. A rule that only works on files already
  # present is a rule that arrives after the leak.
  for p in "logs/probe.log" ".env" "Context-Transfer/probe-does-not-exist.md"; do
    git check-ignore -q "$p" 2>/dev/null && pass ".gitignore effectively ignores $p" \
                                         || fail ".gitignore does not ignore $p"
  done

  # PUBLICATION SAFETY, asserted rather than claimed. DIRECTORY_GUIDE.md, GATES.md, Plan.md and
  # docs/audit/FINAL_AUDIT_REPORT.md have all reported "stage-everything probe: 0 paths" since F8,
  # and until now NOTHING checked it — the figure was a gate-time measurement someone typed. That is
  # SECURITY-1's F-3 shape exactly, a document describing coverage the artifact did not provide, and
  # Lite has carried this assertion since PACK-CONFLUENCE-1 while the parent went without.
  #
  # STATED LIMIT: this alternation is ENUMERATIVE, not structural. Lite's probe binds to a shape every
  # future pack satisfies by construction; the parent's fences share no shape, so this lists today's
  # and will report ZERO for tomorrow's unfenced drop — the one case the probe exists to catch.
  # Extend it with every new fence. Recorded as a limit rather than left to be discovered.
  fenced='(^|/)(Context-Transfer[^/]*|[^ ]*-main|secrets|\.ssh)/|\.(pdf|pem|key)$|(^|/)(deep-research-report\.md|Project-Explorer\.md|PSYCHIC-CREW-LITE-PLAN\.md|credentials\.json|id_rsa[^ ]*|ReportforClaudeWeb[^ ]*)$'
  # Vacuity guard FIRST. Where git cannot answer, every count below is 0 and the probe reports a
  # confident pass having measured nothing — this build has recorded that class four times.
  gtracked=$(git ls-files | grep -c .)
  case "$gtracked" in ''|*[!0-9]*) gtracked=0 ;; esac
  if [ "$gtracked" -lt 50 ]; then
    fail "publication probe is VACUOUS — git ls-files returned $gtracked tracked files; the counts below would prove nothing"
  else
    # Capture, then count, then validate (R-SD-1 rule 2). The composite `$(… | grep -c … || echo 0)`
    # is rule 1 and the class scanner in run-crew-tests would name this file for it.
    # NORMALISE FIRST. `git add -A -n` prints `add '<path>'`, not a bare path, so a regex anchored
    # on (^|/) can never match — it is preceded by a quote. Built that way, the probe reported ZERO
    # regardless of what was staged and the negative control caught it: removing the fence left this
    # assertion green. Stripping the wrapper lets ONE regex serve both this probe and the tracked
    # companion below, which is also why they cannot drift apart.
    stage_out=$(git add -A -n 2>/dev/null | sed -E "s/^add '(.*)'$/\\1/")
    staged_fenced=$(printf '%s\n' "$stage_out" | grep -cE "$fenced")
    case "$staged_fenced" in ''|*[!0-9]*) staged_fenced=0 ;; esac
    [ "$staged_fenced" = 0 ] \
      && pass "stage-everything probe stages ZERO fenced paths ($gtracked tracked files scanned)" \
      || fail "PUBLICATION RISK — stage-everything would stage $staged_fenced fenced path(s)"
    # The companion the probe above is BLIND to: `git add -A -n` reports what WOULD be staged and says
    # nothing about what already IS. One `git add -f` makes a fenced file tracked and the probe then
    # reports ZERO forever after — the blind spot that defeated a live control at PACK-CONFLUENCE-1.
    tracked_fenced=$(git ls-files | grep -cE "$fenced")
    case "$tracked_fenced" in ''|*[!0-9]*) tracked_fenced=0 ;; esac
    [ "$tracked_fenced" = 0 ] \
      && pass "no TRACKED file under any fenced path (a force-add is caught here, not by the probe above)" \
      || fail "PUBLICATION RISK — $tracked_fenced fenced path(s) are TRACKED"
  fi
else
  skip ".gitignore effectiveness needs a work tree (archive extract has no .git)"
fi

echo "== no absolute machine paths in tracked files (§5.2.4) =="
# C-23: this tested [ -d .git ], which is FALSE in a git worktree, where .git is a file pointing at
# the parent. The G-F8 portability drill runs in exactly such a checkout, so the one assertion that
# gate's stress requirement names — and the one that produced two red gates at F0 — silently skipped
# there while reporting "git not initialized yet", which was not true. Ask git, do not guess from a
# path shape. Tenth instance of the proxy-binding family.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
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

echo "== deny-list integrity (HC-5, §4.6) =="
# C-16: the G-F6 mutation removed a deny entry and the ONLY thing that noticed was the dirty-tree
# canary — validate-crew itself reported zero failures, so once committed the removal would have
# been invisible. A permission boundary with no integrity check is not a boundary.
# Needles are assembled from fragments because bash-blocker matches the WHOLE command string: a
# contiguous literal here would deny any command that merely greps or edits this file.
# NOTE: $S is the SKIP counter in this script, not a settings path — reference the file literally.
SETTINGS=".claude/settings.json"
_c="git"; _n1="$_c clone"
_m="npm"; _n2="$_m install -g"
_r="rm -rf"; _n3="$_r /"; _n4="$_r ~"
_d="dd"; _n5="$_d if="
DENY=$(jq -r '.permissions.deny[]?' "$SETTINGS" 2>/dev/null)
dmiss=""
for needle in "$_n1" "$_n2" "npx" "sudo" "$_n3" "$_n4" "$_n5"; do
  grep -qF -- "$needle" <<<"$DENY" || dmiss="$dmiss [$needle]"
done
[ -z "$dmiss" ] && pass "all HC-5 deny entries present ($(printf '%s\n' "$DENY" | grep -c .) rules)" \
                || fail "deny-list missing:$dmiss — a removed prohibition is invisible once committed"
# CR-015 (audit A3-F3): this counted `Read(` entries and required >= 2. Demonstrated: swap both for
# Read(/tmp/nothing) and Read(/tmp/alsonothing) and it passes with neither secret path denied. Ten
# lines above, every HC-5 Bash prohibition is asserted BY NAME — that is the C-16 fix, and C-16's own
# text says a permission boundary with no integrity assertion is not a boundary. The Bash half got
# that treatment; the Read half kept a count. Assert these by name too.
# No fragment assembly needed here, unlike the needles above. bash-blocker matches whole command
# strings, but only against the HC-5 verb set, and neither of these two paths is in it. Note the
# enumeration is deliberately NOT written out: a contiguous literal of those verbs in a tracked file
# denies any command that later quotes this region, which is the C-22 trap and cost real work twice
# during the audit. Describe the set, never spell it.
rmiss=""
for needle in ".env" "secrets"; do
  grep -qF -- "$needle" <<<"$(printf '%s\n' "$DENY" | grep '^Read(')" || rmiss="$rmiss [$needle]"
done
[ -z "$rmiss" ] && pass "secret-path Read denials retained by name (.env, secrets)" \
                || fail "secret-path Read denial missing:$rmiss — a removed prohibition is invisible once committed"

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
  # CR-022 hardening: the coverage set must contain only genuine arbiter coverage. The
  # reference-cap hook now also writes into this trail, and any line carrying a task_id used to
  # count as coverage regardless of who wrote it — so a hook could have satisfied the arbiter's own
  # obligation. That is precisely C-12's defect arriving through a new writer. Excluded BY FIELD,
  # not by pattern (the C-14 and C-24 precedent); existing lines carry no `event` and are unaffected.
  cov=$(jq -r 'select((.event // "") != "FLAG") | select((.task_id // "") != "") | .task_id' \
        logs/arbiter-audit.jsonl 2>/dev/null | sort -u)
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

# C-25 (CR-025): identity coverage from the platform's own attribution, correlated as a SET
# DIFFERENCE alongside the task_id correlation above — never a count.
#
# What this adds that task_id correlation cannot: C-12 observed live that two FAILED Agent calls
# produced zero PostToolUse records, because that hook cannot fire for a tool that never executed.
# The coverage denominator silently shrank and a true-positive FAIL flipped to PASS with nothing
# remediated. SubagentStart fires at CREATION, independently of whether the call then succeeds, so
# a failed dispatch stays visible to the auditor instead of vanishing from the denominator.
#
# Stated plainly and matching plan v3.0.1: this is attribution and detection-at-creation. It is NOT
# prevention — SubagentStart cannot block subagent creation [V] — and nothing here claims it is.
if [ -f logs/subagent-starts.jsonl ] && [ -f logs/arbiter-audit.jsonl ]; then
  SPEC25='security-reviewer|quality-reviewer|fixer|test-runner|integration-runner'
  sstart=$(jq -r --arg s "$SPEC25" 'select((.agent_id // "") != "")
             | select((.agent_type // "") | test($s)) | .agent_id' \
           logs/subagent-starts.jsonl 2>/dev/null | sort -u)
  scov=$(jq -r 'select((.event // "") != "FLAG") | select((.agent_id // "") != "") | .agent_id' \
         logs/arbiter-audit.jsonl 2>/dev/null | sort -u)
  if [ -z "$sstart" ]; then
    skip "C-25: no specialist subagent start recorded yet (identity coverage untestable)"
  else
    sunc=$(comm -23 <(printf '%s\n' "$sstart") <(printf '%s\n' "$scov") | sed '/^$/d')
    if [ -z "$sunc" ]; then
      pass "C-25: every specialist subagent start is covered by an arbiter line of the same agent_id"
    else
      fail "C-25: specialist subagent start(s) with no arbiter coverage: $(printf '%s' "$sunc" | tr '\n' ' ')"
    fi
  fi
else
  skip "C-25: no subagent-starts trail yet (SubagentStart hook owns logs/subagent-starts.jsonl)"
fi

# C-19: coverage that cannot be ORDERED is coverage that cannot be trusted. A task_id match proves
# a line exists, not that it was written before the output it covers was consumed — so a line added
# after the fact is indistinguishable from one written at the time. Dispatch records carry full ISO
# timestamps; the arbiter's schema did not require one, and it wrote date-only, which is exactly what
# made F7's ten arbiter lines ordering-undecidable. arbiter.md now requires the full form. The F0-F7
# lines are grandfathered by enumeration (the C-14 precedent: an explicit set, not a guessable rule)
# because their granularity is already lost and a closed phase must not fail retroactively.
if [ -f logs/arbiter-audit.jsonl ]; then
  # CR-021 (audit A4-F2): this enforced `ts` GRANULARITY and nothing enforced `task_id` PRESENCE.
  # arbiter.md names task_id as a MUST, and C-12's correlation counts only lines that have one — so a
  # line without it is invisible in both directions at once: it covers no dispatch and registers as
  # no gap. Three existing lines have none. All three are F3 records of dispatches that FAILED, which
  # is arguably the honest record, and all three predate F8's schema tightening, so they are
  # grandfathered by ENUMERATION of their mutation text — the C-14 precedent that an explicit set
  # beats a guessable rule, because a phase-shaped rule would exempt anything later stamped F3.
  GF_MUT='dispatch-not-executed|dispatch ATTEMPTED and FAILED at the tool layer'
  noid=$(jq -r --arg g "$GF_MUT" 'select((.task_id // "") == "")
           | select(((.mutation // "") | test($g)) | not)
           | "\(.phase // "?"):\(.ts // "?")"' logs/arbiter-audit.jsonl 2>/dev/null | sort -u)
  [ -z "$noid" ] && pass "every arbiter line carries a task_id (3 grandfathered F3 failed-dispatch records, enumerated)" \
                 || fail "arbiter line(s) with no task_id — invisible to coverage correlation in both directions (C-12): $(printf '%s' "$noid" | tr '\n' ' ')"

  ISO='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$'
  GRANDFATHERED='^(F0|F1|F2|F3|F4|F5|F6|F7)$'
  bad=$(jq -r --arg iso "$ISO" --arg g "$GRANDFATHERED" '
          select(((.ts // "") | test($iso)) | not)
          | select(((.phase // "") | test($g)) | not)
          | "\(.phase // "?"):\(.task_id // "?")"' logs/arbiter-audit.jsonl 2>/dev/null | sort -u)
  undec=$(jq -r --arg iso "$ISO" 'select(((.ts // "") | test($iso)) | not) | .task_id // "?"' \
          logs/arbiter-audit.jsonl 2>/dev/null | sort -u | sed '/^$/d' | wc -l)
  if [ -n "$bad" ]; then
    fail "arbiter audit line(s) without a full ISO-8601 ts, so coverage order is undecidable (C-19): $(printf '%s' "$bad" | tr '\n' ' ')"
  else
    pass "arbiter ts granularity enforced; $undec grandfathered date-only line(s), ordering-undecidable and disclosed (C-19)"
  fi
else
  skip "no arbiter audit log yet (F3 owns logs/arbiter-audit.jsonl)"
fi

# ONE shared total for both closing bindings. Each previously did its own +1 arithmetic, which
# broke twice: once when the C-14 canary was added after the README binding, and again when the
# C-28 binding was moved last and the README binding stopped counting it. The +2 is the two
# assertions below, which are the last things this script emits.
SUITE_TOTAL=$((P + S + F + 2))
# CR-027 — this script's own count in the README, bound here for the reason given at the foot of
# run-crew-tests.sh. SKIP is included because this suite reports one and the README's figure is the
# number of assertions, not the number that happened to pass today.
# ENVIRONMENT GUARD, added after this binding broke the portability drill on its first run.
# The total is NOT invariant: several blocks here are gated on optional artifacts and several loop
# over files, so a git-archive extract runs 42 assertions, a detached worktree 43, and the primary
# checkout 44. Binding an equality to a number that legitimately varies by environment is the
# equality-on-a-growing-count mistake this build has now made three times (S3's mermaid block, S4's
# fixture count, and here). The README's figure describes the primary checkout, so the comparison is
# scoped to it and ANNOUNCED elsewhere rather than skipped quietly.
if [ ! -d .git ] || [ ! -d logs ]; then
  pass "CR-027 README count describes the primary checkout; this is not one (assertions vary with which optional artifacts exist)"
else
# Every claim, for the reason given at the foot of run-crew-tests.sh.
vct=$SUITE_TOTAL
vcall=$(grep -oE '[0-9]+ structural assertions' README.md 2>/dev/null | grep -oE '^[0-9]+' | sort -u)
vcn=$(printf '%s\n' "$vcall" | grep -c . || true)
if [ "${vcn:-0}" = 0 ]; then
  fail "CR-027 README states no structural-assertion count to bind — the claim was removed, not updated"
else
  vcbad=$(printf '%s\n' "$vcall" | grep -vxF "$vct" | tr '\n' ' ')
  [ -z "$vcbad" ] && pass "CR-027 every structural-assertion claim in README agrees ($vcn distinct value(s)) and matches this run ($vct)" \
                  || fail "CR-027 README carries stale structural-assertion count(s):[$vcbad] — this run has $vct"
fi
fi

# ENVIRONMENT GUARD — the same one the README binding already carries, and which I failed to apply
# here. The assertion total is NOT invariant: a git-archive extract runs 38+5, a detached worktree
# 41+3, and the primary checkout 44+1, because blocks are gated on optional runtime artifacts. The
# summary's figure describes the primary checkout, so the comparison is scoped to it and ANNOUNCED
# elsewhere. Caught by the portability drill immediately after the gate — the fourth appearance of
# equality-on-a-varying-count in this build, and the second in this session.
if [ ! -d .git ] || [ ! -d logs ]; then
  pass "C-28 summary figure describes the primary checkout; this is not one"
else
  # C-28 — this script also binds its own claim in context/session-summary.md. save-context cannot
  # compute it: check-plan-corrections runs save-context under a temp root, so a call back into a
  # suite would recurse. The suite is the only component that knows its own total.
  ssum="context/session-summary.md"
  ssgot=$(grep -oE 'validate-crew \*\*([^*]+)\*\*' "$ssum" 2>/dev/null | head -1 | sed -E 's/^validate-crew \*\*//; s/\*\*$//')
  sswant="$((SUITE_TOTAL - S)) PASS / $S SKIP / 0 FAIL"
  if [ -z "$ssgot" ]; then
    pass "C-28 summary makes no validate-crew claim — nothing to bind"
  elif [ "$ssgot" = "$sswant" ]; then
    pass "C-28 summary's validate-crew figure matches this run ($sswant)"
  else
    fail "C-28 summary says validate-crew '$ssgot', this run is '$sswant'"
  fi
fi

printf '\n== validate-crew: %s PASS / %s SKIP / %s FAIL ==\n' "$P" "$S" "$F"
[ "$F" = 0 ] || exit 1
