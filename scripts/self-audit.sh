#!/usr/bin/env bash
# self-audit.sh — ARC4-2: the audit lane. Measures the estate against docs/AUDIT-RUBRIC.md
# bands and writes ONLY under logs/audit/ (runs.jsonl + findings.jsonl). It NEVER schedules
# itself: invocation is the operator, or a session acting on the staleness line (the ARC4-1
# bridge — "autonomous" means unattended ANALYSIS, never unattended scheduling).
#   --measure-only : counts and bands only, no suite invocations — the mode the suite's
#                    no-write tree-hash control exercises on every run.
#   full (default) : also reads each repo's suite total. The parent suite runs with
#                    PSYCHIC_SELF_AUDIT=1 so the seven check-plan-corrections sites are
#                    skipped — the chain rct -> corrections -> metrics-generator writes the
#                    TRACKED docs/metrics-snapshot.json, and an audit that dirties its
#                    subject is the observer-fence defect. Every other suite is read-only.
set -uo pipefail
cd "$(dirname "$0")/.."
MODE="${1:-full}"
mkdir -p logs/audit
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NF=0; ERRS=""
emit_finding () { # repo axis value baseline band severity claim
  NF=$((NF+1))
  jq -cn --arg ts "$TS" --arg repo "$1" --arg axis "$2" --arg value "$3" --arg baseline "$4" \
        --arg band "$5" --arg severity "$6" --arg claim "$7" \
        '{ts:$ts,run_ts:$ts,repo:$repo,axis:$axis,value:$value,baseline:$baseline,band:$band,severity:$severity,claim:$claim}' \
        >> logs/audit/findings.jsonl
}
BANDS=$(awk '/^# ARC4-BANDS v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/AUDIT-RUBRIC.md 2>/dev/null)
bn=$(grep -c . <<<"$BANDS"); [[ "$bn" =~ ^[0-9]+$ ]] || bn=0
if [ "$bn" -ne 6 ]; then
  jq -cn --arg ts "$TS" --arg e "ARC4-BANDS parse: $bn rows (want 6)" \
    '{ts:$ts,status:"crashed",is_explicit:false,reason:"bands unparseable",repos_scanned:0,findings_count:0,errors:[$e]}' \
    >> logs/audit/runs.jsonl
  echo "self-audit: bands unparseable ($bn rows) — run recorded as crashed" >&2
  exit 1
fi
SCANNED=0
while IFS="$(printf '\t')" read -r repo afloor aceil cfloor; do
  [ -n "${repo:-}" ] || continue
  if [ "$repo" = "psychic-crew" ]; then RPATH="."; else RPATH="../$repo"; fi
  if [ ! -e "$RPATH/.git" ]; then
    echo "self-audit: $repo absent from this checkout — leg skipped, stated"
    continue
  fi
  SCANNED=$((SCANNED+1))
  tcount=$(git -C "$RPATH" ls-files | grep -c .); [[ "$tcount" =~ ^[0-9]+$ ]] || tcount=0
  if [ "$tcount" -lt "$afloor" ]; then
    emit_finding "$repo" A "$tcount" "$afloor" floor high "tracked count fell below the birth-measured floor"
  elif [ "$tcount" -gt "$aceil" ]; then
    emit_finding "$repo" A "$tcount" "$aceil" ceiling med "tracked count beyond 3x baseline (runaway-growth signal)"
  fi
  if [ "$MODE" != "--measure-only" ]; then
    total=""
    case "$repo" in
      psychic-crew)
        total=$(PSYCHIC_SELF_AUDIT=1 ./scripts/run-crew-tests.sh all 2>/dev/null | tail -1 | grep -oE '[0-9]+ PASS' | head -1 | grep -oE '[0-9]+') ;;
      psychic-crew-lite)
        total=$( (cd "$RPATH" && ./scripts/validate-lite.sh 2>/dev/null | tail -1 | grep -oE '[0-9]+ PASS' | head -1 | grep -oE '[0-9]+') ) ;;
      *)
        total=$( (cd "$RPATH" && ./scripts/validate-*.sh 2>/dev/null | tail -1 | grep -oE '[0-9]+ PASS' | head -1 | grep -oE '[0-9]+') ) ;;
    esac
    if [[ "${total:-}" =~ ^[0-9]+$ ]]; then
      if [ "$total" -lt "$cfloor" ]; then
        emit_finding "$repo" C "$total" "$cfloor" floor high "suite total below the S0 floor (this machine; parent in skip-mode)"
      fi
    else
      ERRS="$ERRS ${repo}:suite-unreadable"
    fi
  fi
done <<BEOF
$BANDS
BEOF
STATUS=completed; EXPL=false; REASON="clean run"
if [ -n "$ERRS" ]; then
  STATUS=terminated; EXPL=true; REASON="suite leg(s) unreadable:$ERRS"
fi
# Coherence law (CORPUS-ZEROSHOT): errors is EMPTY iff status == completed.
if [ "$STATUS" = "completed" ]; then
  jq -cn --arg ts "$TS" --arg r "$REASON" --argjson n "$SCANNED" --argjson f "$NF" \
    '{ts:$ts,status:"completed",is_explicit:false,reason:$r,repos_scanned:$n,findings_count:$f,errors:[]}' \
    >> logs/audit/runs.jsonl
else
  jq -cn --arg ts "$TS" --arg r "$REASON" --arg e "$ERRS" --argjson n "$SCANNED" --argjson f "$NF" \
    '{ts:$ts,status:"terminated",is_explicit:true,reason:$r,repos_scanned:$n,findings_count:$f,errors:[$e]}' \
    >> logs/audit/runs.jsonl
fi
rb=$(tail -1 logs/audit/runs.jsonl | jq -r '.ts' 2>/dev/null)
[ "$rb" = "$TS" ] || { echo "self-audit: run record READ-BACK FAILED" >&2; exit 1; }
echo "self-audit: $STATUS — $SCANNED repo(s) scanned, $NF finding(s), mode=$MODE (findings are machine-local; promotion is a human act at a gate)"
