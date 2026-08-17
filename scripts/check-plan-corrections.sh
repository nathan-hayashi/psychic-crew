#!/usr/bin/env bash
# check-plan-corrections.sh — machine-check the plan-vs-reality registry in
# context/plan-corrections.md. The execution authority is never edited, so these
# corrections must be enforced here or they get silently rebuilt from the plan.
#
# Usage: check-plan-corrections.sh [all|F0|F2|F3]
#   no args / all : report every correction, exit 0 (informational)
#   F<n>          : exit 1 if any correction owned by F<n> is still PENDING
set -uo pipefail
cd "$(dirname "$0")/.."
WANT="${1:-all}"
PEND=0; APPL=0; NA=0

report () { # id owner status detail
  case "$3" in
    APPLIED) APPL=$((APPL+1));;
    PENDING) PEND=$((PEND+1)); case "$WANT" in "$2") GATE=1;; esac;;
    *)       NA=$((NA+1));;
  esac
  printf '  %-6s %-3s %-9s %s\n' "$1" "$2" "$3" "$4"
}
GATE=0
S=".claude/settings.json"

echo "== plan corrections (source: context/plan-corrections.md) =="

n=$(jq '[.hooks[]?[]? | select(has("hook"))] | length' "$S" 2>/dev/null || echo -1)
if [ "$n" = 0 ]; then report C-01 F2 APPLIED "no hook entry uses the non-existent 'hook' string key"
else                 report C-01 F2 PENDING "$n hook entries still use \"hook\":<string>; need \"hooks\":[{type,command}]"; fi

if [ "$(jq -r '.hooks | has("PostToolUseFail")' "$S" 2>/dev/null)" = "false" ]; then
  report C-02 F2 APPLIED "no PostToolUseFail event"
else
  report C-02 F2 PENDING "event PostToolUseFail present; real name is PostToolUseFailure"; fi

# C-03 is checked BEHAVIOURALLY: the deny contract lives in the shared hooks/_common.sh, so
# grepping each guard for the string misses a correct implementation. Feed each guard a real
# denial input and assert the JSON contract actually comes out.
h=$(ls -1 hooks/*.sh 2>/dev/null | wc -l)
if [ "$h" = 0 ]; then
  report C-03 F2 PENDING "hooks/ empty — F2 must emit hookSpecificOutput.permissionDecision, not bare exit 2"
else
  # Payloads are passed as printf ARGUMENTS, never as the format string: printf interprets
  # backslash escapes in the format, which silently corrupts JSON containing \" and makes a
  # working guard look broken. That is exactly what happened on the first attempt here.
  c3=1; c3why=""
  j1='{"tool_input":{"command":"git clone https://example/x"}}'
  j2='{"tool_input":{"file_path":"models.config.json","content":"  \"model\": \"claude-fable-5\""}}'
  j3='{"tool_input":{"file_path":"/x/.env","content":"K=v"}}'
  for pair in "bash-blocker:$j1" "model-guard:$j2" "sensitive-guard:$j3"; do
    g=${pair%%:*}; j=${pair#*:}
    o=$(printf '%s' "$j" | "./hooks/$g.sh" 2>/dev/null || true)
    printf '%s' "$o" | grep -q '"permissionDecision":"deny"' || { c3=0; c3why="$c3why $g"; }
  done
  if [ "$c3" = 1 ]; then report C-03 F2 APPLIED "all three PreToolUse guards emit permissionDecision:deny on a real trigger"
  else report C-03 F2 PENDING "guards not denying via the JSON contract:$c3why"; fi
fi

if git check-ignore -q .claude/state/compact-pending 2>/dev/null; then
  report C-04 F2 APPLIED ".claude/state/ is gitignored"
else
  report C-04 F2 PENDING ".claude/state/ tracked; DIRECTORY_GUIDE says it must be ignored"; fi

v=0
# Was: grep -q 'Task|Agent' — bound to one SPELLING of the check rather than to the check. C-12
# re-expressed the same logic in jq (select(.tool=="Agent" or .tool=="Task")) and this detector
# reported the correction regressed while the behaviour was intact. Test that both tool names are
# actually matched, in whatever form, and strip comments so prose about the rule cannot satisfy it.
CODE_VC=$(sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null)
printf '%s' "$CODE_VC" | grep -q 'Task' && printf '%s' "$CODE_VC" | grep -q 'Agent' || v=1
if [ -f .claude/rules/arbiter-protocol.md ]; then
  grep -q 'Agent' .claude/rules/arbiter-protocol.md || v=1
  [ "$v" = 0 ] && report C-05 F3 APPLIED "both Task and Agent matched in detection and rule" \
               || report C-05 F3 PENDING "dispatch detection does not match the current tool name 'Agent'"
else
  [ "$v" = 0 ] && report C-05 F3 PENDING "validate-crew ok; .claude/rules/arbiter-protocol.md not written yet (F3)" \
               || report C-05 F3 PENDING "detection incomplete and rule not yet written"; fi

# C-06 was EX-02's fix to the filename-vs-line bug inside the old `grep -ril` form. EX-03 replaced
# that form entirely with assignment-position matching, under which the bug cannot occur — so its
# detection pattern legitimately no longer exists. Superseded, not unfixed.
CODE_AM=$(sed 's/#.*//' scripts/apply-models.sh 2>/dev/null)
if printf '%s' "$CODE_AM" | grep -q 'grep -ril'; then
  report C-06 F0 PENDING "HC-2 still uses grep -ril (filenames); the -v filter can never suppress"
elif printf '%s' "$CODE_AM" | grep -q 'ascii_downcase | contains'; then
  report C-06 F0 SUPERSEDED "subsumed by C-09; the grep -ril form no longer exists"
else
  report C-06 F0 PENDING "HC-2 implementation unrecognised — re-verify by hand"
fi

for id in \
          C-07:'session-model jq uses if/then/else':'if \$m=="pinned"' \
          C-08:'agent loop avoids the pipeline subshell':'for a in \$\(jq'; do
  i=${id%%:*}; rest=${id#*:}; desc=${rest%%:*}; pat=${rest##*:}
  if grep -qE "$pat" scripts/apply-models.sh 2>/dev/null; then report "$i" F0 APPLIED "$desc"
  else report "$i" F0 PENDING "$desc — EX-02 fix missing from apply-models.sh"; fi
done

if sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null | grep -q 'ascii_downcase | contains' \
   && printf '%s' "$CODE_AM" | grep -q 'ascii_downcase | contains'; then
  if grep -q 'HITS=' scripts/apply-models.sh 2>/dev/null; then
    report C-09 F1 APPLIED "HC-2 matches assignment positions; guard captures hits (pipefail-safe)"
  else
    report C-09 F1 PENDING "HC-2 narrowed but the guard still tests pipeline status — silently skippable under pipefail"
  fi
else
  report C-09 F1 PENDING "HC-2 is still a bare substring scan; F2 model-guard.sh cannot pass validation"
fi

# C-11: the broker pattern cannot execute. .claude/rules/arbiter-protocol.md makes the arbiter the
# sole permitted dispatcher, but §5.1.1's verbatim frontmatter grants it Read/Grep/Glob/Write and no
# Agent tool — and no other crew agent holds one either. Every hop of lead->arbiter->specialist has
# zero dispatch capability, so the central design bet of this build (CLAUDE_DESIGN item 2) is
# unexecutable as written. Proven live at G-F3: the arbiter returned a FALLBACK rather than fabricate.
# A frontmatter grant is a DECLARATION, not a capability. EX-04 added Agent to arbiter.md and the
# runtime still refused it ("Agent is disabled for this session, in subagents as well as here"), so
# testing the tools line alone would report APPLIED for a fan-out that cannot happen. Require
# evidence of a real RELEASE in the audit log instead of trusting the declaration.
# First cut of this detector grepped the audit log for "RELEASE" and reported APPLIED against the
# line "RELEASE replaced by FALLBACK" — matching prose that DOCUMENTS the failure as though it were
# the success. That is the registry's own documented trap ("detectors must test code, not comments"),
# so test the field, not the file: a mutation that claims a release AND disclaims failure.
released=$(jq -r 'select((.mutation // "") | test("RELEASE"; "i"))
                | select(((.mutation // "") | test("FAIL|FALLBACK|not-executed|quarantin"; "i")) | not)
                | .task_id' logs/arbiter-audit.jsonl 2>/dev/null | head -1)
ndisp=$(grep -l '^tools:.*Agent' .claude/agents/*.md 2>/dev/null | wc -l)
if grep -q '^tools:.*Agent' .claude/agents/arbiter.md 2>/dev/null && [ -n "${released:-}" ]; then
  report C-11 F3 APPLIED "arbiter holds Agent AND completed a real fan-out ending in RELEASE ($released)"
elif grep -q 'EX-05' .claude/rules/arbiter-protocol.md 2>/dev/null && [ "$ndisp" = 0 ]; then
  # EX-05 retires the requirement rather than satisfying it: the arbiter no longer needs to
  # dispatch, so "the arbiter cannot dispatch" stops being a defect. Reporting this PENDING
  # forever would train the reader to ignore a real blocker. Least privilege is asserted too —
  # no agent holds an inert grant that would read as capability on disk.
  report C-11 F3 SUPERSEDED "retired by EX-05: the orchestrator dispatches, coverage is identity-correlated (C-12), no agent holds a dispatch tool"
else
  report C-11 F3 PENDING "fan-out unproven and EX-05 not in force — the broker has neither dispatch capability nor a redesigned law (G-F3 P0)"
fi

# C-12: the bypass detector is satisfiable by the thing it audits. validate-crew compares the COUNT
# of Agent calls against the COUNT of arbiter audit lines, never correlating which dispatch each line
# covers — so the arbiter can turn the check green by writing any lines at all. Observed live at
# G-F3: two failed Agent calls logged nothing (PostToolUse cannot fire for a tool that never ran),
# the arbiter's two honest lines took c from 1 to 3 against d=3, and a true-positive FAIL flipped to
# PASS with no bypass remediated. Third instance of this family after F2 deny() and the self-match.
# CR-009 (audit A2-F2): this WAS `grep -q 'task_id' scripts/validate-crew.sh` — not comment-stripped,
# so the three comments in that file mentioning task_id satisfied it. Demonstrated: strip every
# non-comment task_id line out of validate-crew.sh and this still reported APPLIED against a file
# that correlates nothing. The correction about a control satisfiable by the party it audits had a
# detector satisfiable by prose, while eight siblings in this same file already used $CODE_VC.
# Bind to the three parts the correlation is MADE of: a task_id set drawn from the dispatch log, one
# drawn from the arbiter log, and a set difference between them. Reverting to counting deletes all
# three; a comment cannot supply any of them.
c12=0
for needle in 'tooluse-audit.jsonl' 'arbiter-audit.jsonl' 'task_id' 'comm -23'; do
  printf '%s' "$CODE_VC" | grep -qF -- "$needle" || c12=1
done
if [ "$c12" = 0 ]; then
  report C-12 F3 APPLIED "bypass coverage correlates dispatch identity by set difference over both logs, not raw line counts"
else
  report C-12 F3 PENDING "bypass coverage does not correlate identity — the arbiter can satisfy it by writing any lines (G-F3 P0)"
fi

# C-10: CLAUDE.md binds every agent to .claude/rules/fallback-protocol.md, but no §6 phase step
# writes it — F3 is assigned rules 5.2.2-5.2.4 only, and §5.2.1 sits in the F0 payload section that
# F0's step list never reaches. A binding rule absent from disk is a dangling contract: agents are
# instructed to obey a file they cannot read, and every FALLBACK path silently loses its definition.
if [ -f .claude/rules/fallback-protocol.md ] && grep -q 'FALLBACK' .claude/rules/fallback-protocol.md; then
  report C-10 F3 APPLIED "fallback-protocol.md present; CLAUDE.md's binding reference resolves"
else
  report C-10 F3 PENDING "CLAUDE.md binds all agents to .claude/rules/fallback-protocol.md, which is absent"
fi

# C-13: SEC-DG-03, deferred from F3-D1. DIRECTORY_GUIDE's Navigation rule tells every agent to
# append anomaly text to Plan.md and then act on it, while no hook inspects content bound for the
# continuity files — sensitive-guard matches path globs and three .gitignore strings only.
# Behavioural and deliberately outcome-agnostic: the operator still owns block-vs-flag at G-F4, so
# require only that SOME wired Write|Edit guard reacts mechanically to an injected imperative aimed
# at Plan.md. Testing for a scanner's PRESENCE would report APPLIED for a scanner that exists and
# does nothing, which is the exact trap this registry keeps recording.
# C-13 is tested BEHAVIOURALLY. Grepping for hooks/provenance-flag.sh would report APPLIED for a
# hook that flags nothing — bind the check to the artifact that changes when the defect is real.
# Runs against a mktemp root so the detector does not append flag records to the live trail, which
# is C-14's lesson applied to the detector that came after it.
c13tmp=$(mktemp -d 2>/dev/null)
if [ -x hooks/provenance-flag.sh ] \
   && jq -e '[.hooks.PostToolUse[]?.hooks[]?.command | select(test("provenance-flag"))] | length > 0' "$S" >/dev/null 2>&1 \
   && [ -n "$c13tmp" ]; then
  mkdir -p "$c13tmp/logs"; cp -r logs/rounds "$c13tmp/logs/" 2>/dev/null
  c13span=$(jq -r '.. | strings' logs/rounds/round-1/security-reviewer.json 2>/dev/null | awk 'length>=90{print;exit}')
  c13hit=$(CLAUDE_PROJECT_DIR="$c13tmp" sh -c 'cat | ./hooks/provenance-flag.sh' 2>/dev/null \
            <<<"$(jq -cn --arg f "$c13tmp/Plan.md" --arg c "NOTE: $c13span" '{tool_input:{file_path:$f,content:$c}}')" | grep -c provenance)
  c13ok=$(CLAUDE_PROJECT_DIR="$c13tmp" sh -c 'cat | ./hooks/provenance-flag.sh' 2>/dev/null \
            <<<"$(jq -cn --arg f "$c13tmp/Plan.md" --arg c "Handling note (§0.2d): $c13span" '{tool_input:{file_path:$f,content:$c}}')" | grep -c provenance)
  if [ "${c13hit:-0}" -ge 1 ] && [ "${c13ok:-1}" = 0 ]; then
    report C-13 F4 APPLIED "provenance hook flags an unattributed relay and stays silent when attributed"
  else
    report C-13 F4 PENDING "provenance hook wired but not behaving (flag=$c13hit on relay, $c13ok on attributed)"
  fi
else
  report C-13 F4 PENDING "no hook inspects content bound for Plan.md/PROGRESS.md/context/*, yet DIRECTORY_GUIDE says append anomaly text there then act (SEC-DG-03)"
fi
rm -rf "$c13tmp" 2>/dev/null

# C-15: the PreCompact parachute degraded the field it exists to protect. It appended a hardcoded
# pointer as "Next action:", which then became the newest such line — so §15.4's cold reader, and
# the snapshot's own declared-next_action grep, both recovered the pointer instead of the real
# instruction. Tested BEHAVIOURALLY under a temp root: fire the hook and assert the prior action
# survives as the newest one.
c15tmp=$(mktemp -d 2>/dev/null)
if [ -n "$c15tmp" ] && [ -x hooks/pre-compact-checkpoint.sh ]; then
  mkdir -p "$c15tmp/.claude/state"
  printf '# P\n\n## [F9|t] checkpoint\n- **Next action:** SENTINEL-CARRY-FORWARD\n' > "$c15tmp/PROGRESS.md"
  : > "$c15tmp/GATES.md"; : > "$c15tmp/Plan.md"
  printf '%s' '{"trigger":"auto"}' | CLAUDE_PROJECT_DIR="$c15tmp" ./hooks/pre-compact-checkpoint.sh >/dev/null 2>&1
  c15last=$(grep -E '^- \*\*Next action:' "$c15tmp/PROGRESS.md" 2>/dev/null | tail -1)
  case "$c15last" in
    *SENTINEL-CARRY-FORWARD*) report C-15 F5 APPLIED "PreCompact carries the prior next_action forward instead of displacing it" ;;
    *) report C-15 F5 PENDING "PreCompact overwrites next_action with a pointer; a cold reader recovers the pointer, not the instruction" ;;
  esac
  rm -rf "$c15tmp"
else
  report C-15 F5 PENDING "PreCompact hook missing or temp root unavailable"
fi

# C-19: C-12 restored identity correlation, but a retrospective self-issued arbiter line satisfies
# it exactly as a contemporaneous one does — the arbiter itself escalated this against its own
# interest after emitting four such lines at B7. Coverage now proves an id was recorded, not that
# it was recorded before the packet was consumed. Detect whether the check distinguishes them.
# Root cause found at F8: arbiter.md specified {"ts",...} without a FORMAT, and the arbiter wrote
# date-only, so no arbiter line could be ordered against the full-ISO dispatch records. Bound to the
# two things that actually prevent recurrence - the writer mandating the format, and the validator
# enforcing it - not to the word "retrospective" appearing in a comment, which is the proxy-binding
# family this registry has now recorded nine times.
c19w=$(grep -c 'YYYY-MM-DDTHH:MM:SSZ' .claude/agents/arbiter.md 2>/dev/null || true)
c19v=$(sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null | grep -c 'undecidable' || true)
if [ "${c19w:-0}" -ge 1 ] && [ "${c19v:-0}" -ge 1 ]; then
  report C-19 F8 APPLIED "arbiter.md mandates a full ISO-8601 ts and validate-crew fails any post-F7 line lacking one; F0-F7 lines stay grandfathered and disclosed as ordering-undecidable"
else
  report C-19 F8 PENDING "a retrospective arbiter line satisfies C-12 identically to a contemporaneous one; green proves an id exists, not that it preceded consumption"
fi

# C-20: the plan's per-phase token budgets were never calibrated to multi-agent cost. The whole
# nine-phase build is budgeted 319K; F7's subagents alone measured 1,922K. §7's token axis was
# unsatisfiable for the pipeline §6 mandates - 18 dispatches x the cheapest observed dispatch is
# already 4x the denominator. Closed when a measured baseline exists that a future phase can be
# judged against, rather than inheriting numbers no execution could meet.
# Bound to measured ROWS, not to a phrase: the defect is "no calibrated numbers exist", so the check
# counts per-role cost rows. A file that merely discusses budgeting does not close this.
c20n=$(grep -cE '^\| *(lead-planner|lead-executor|arbiter|security-reviewer|quality-reviewer|fixer|test-runner|integration-runner) *\|' context/budget-baseline.md 2>/dev/null || true)
if [ "${c20n:-0}" -ge 5 ]; then
  report C-20 F8 APPLIED "measured per-dispatch cost recorded for $c20n agent roles in context/budget-baseline.md"
else
  report C-20 F8 PENDING "phase budgets uncalibrated: 319K for the whole build vs 2,045K measured in F7 alone; no measured per-role baseline on disk"
fi

# C-21: the F7 token measurement was never persisted. The Velocity axis, C-18 and C-20 all rest on
# per-dispatch numbers that existed ONLY in the orchestrator's context window - logs/tooluse-audit
# .jsonl records dispatches but not their cost. They were recoverable at F8 only from session
# transcripts outside the repo, which is precisely the "disk is canonical, context is a cache"
# inversion HC-8 exists to prevent, discovered at handover. Closed when a script regenerates the
# measurement from disk rather than a human transcribing it from a context window.
# CR-010 (audit A2-F4): this was `[ -x scripts/measure-dispatch-cost.sh ]` — a file-mode test,
# satisfied by a two-line executable stub containing only a shebang, demonstrated. The registry's own
# Verify line for C-21 is materially stronger and was simply never implemented: "exits 0 and its F7
# total matches the figure in context/budget-baseline.md". Implement the stated Verify. It runs in
# about a second, so it costs nothing to run at every gate, and it binds to the script's OUTPUT
# rather than to whether the file exists and is executable.
if [ -x scripts/measure-dispatch-cost.sh ]; then
  c21out=$(./scripts/measure-dispatch-cost.sh 2>/dev/null); c21rc=$?
  c21got=$(printf '%s\n' "$c21out" | awk '/^== F7 ==/{f=1;next} f&&/total=/{sub(/.*total=/,"");sub(/ .*/,"");print;exit}')
  c21want=$(grep -E '^\| *total *\|' context/budget-baseline.md 2>/dev/null | grep -oE '[0-9][0-9,]+' | tr -d ',' | head -1)
  if [ "$c21rc" = 0 ] && [ -n "$c21got" ] && [ "$c21got" = "$c21want" ]; then
    report C-21 F8 APPLIED "measure-dispatch-cost.sh exits 0 and reproduces the recorded F7 total ($c21got) from disk"
  else
    report C-21 F8 PENDING "measure-dispatch-cost.sh did not reproduce the recorded F7 total (exit=$c21rc got='${c21got:-none}' want='${c21want:-none}')"
  fi
else
  report C-21 F8 PENDING "per-dispatch cost is not derivable from repo state; F7's figures were recovered from session transcripts outside the repo (HC-8 inversion)"
fi

# C-22: the plan's G-F8 demo mandates a fresh-clone drill, which this build's own HC-5 guard blocks.
# The guard is right - it cannot distinguish self-cloning from pulling in external code. Resolved by
# proving the same property without one: git archive (tracked bytes only) plus a detached worktree
# (keeps .git so repo-dependent assertions actually run). The search pattern is assembled from
# fragments for the same reason the absolute-path pattern is: a guard that trips on the prose
# documenting it trains people to ignore it, and this one already cost a silently discarded commit.
CLONEPAT="git ""clone"
c22c=$(sed 's/#.*//' scripts/portability-drill.sh 2>/dev/null | grep -c "$CLONEPAT" || true)
if [ -x scripts/portability-drill.sh ] && [ "${c22c:-1}" -eq 0 ]; then
  report C-22 F8 APPLIED "scripts/portability-drill.sh proves portability by archive + detached worktree, no clone"
else
  report C-22 F8 PENDING "the G-F8 portability demo is unexecutable under HC-5 and no clone-free equivalent is on disk"
fi

# C-23: the absolute-path assertion tested [ -d .git ], false in a worktree where .git is a FILE, so
# the check named by the G-F8 stress requirement silently skipped in the very checkout the drill
# uses - reporting "git not initialized yet", which was untrue. Ask git instead of reading a path.
c23=$(sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null | grep -c 'is-inside-work-tree' || true)
if [ "${c23:-0}" -ge 1 ]; then
  report C-23 F8 APPLIED "validate-crew asks git for work-tree status instead of testing [ -d .git ]"
else
  report C-23 F8 PENDING "the absolute-path assertion skips silently in a git worktree (.git is a file there)"
fi

# C-14: tests must never write to the artifact they audit. Fixtures once appended fabricated Agent
# dispatch records to the live trail, and the coverage check correctly failed on events that never
# happened. A trail with invented records is worse than one with gaps: every gate reads it as truth.
# The first pattern here matched any task_id containing "regression|fixture|test-", and the real
# F7 build step F7-A2-fixtures tripped it — a legitimate dispatch record read as test pollution,
# which would have failed the F3 gate spuriously. That is a NAMING proxy, not the artifact: what
# indicates pollution is a record bearing an id that only the test harness ever generates, not a
# record whose id happens to contain an English word real work also uses.
# Bind to the enumerated fixture ids instead. A new fixture id MUST be added here when introduced —
# that coupling is deliberate: it makes the guard's scope explicit rather than guessable.
FIXTURE_IDS='scrub-regression|ccs02-probe|provenance-probe|c16-probe'
fixt=$(jq -r --arg ids "$FIXTURE_IDS" 'select((.task_id // "") | test("^(" + $ids + ")$"; "i")) | .task_id' \
       logs/tooluse-audit.jsonl 2>/dev/null | head -1)
if [ -z "${fixt:-}" ]; then
  report C-14 F3 APPLIED "no fixture-shaped task_id in the audit trail; fixtures run under a temp root"
else
  report C-14 F3 PENDING "audit trail carries fixture-written records (task_id=$fixt) — tests polluting the artifact they audit"
fi

printf '\n== %s APPLIED / %s PENDING / %s SUPERSEDED ==\n' "$APPL" "$PEND" "$NA"
case "$WANT" in
  all) echo "(informational; run with a phase id, e.g. 'F2', to gate on it)"; exit 0;;
  *)   if [ "$GATE" = 1 ]; then echo "GATE $WANT: FAIL — corrections owned by $WANT are still pending"; exit 1
       else echo "GATE $WANT: PASS — all $WANT-owned corrections applied"; exit 0; fi;;
esac
