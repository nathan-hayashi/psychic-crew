#!/usr/bin/env bash
# measure-dispatch-cost.sh — regenerate per-dispatch token cost from session transcripts (C-21).
#
# Why this exists: F7's Velocity axis, C-18 and C-20 all rest on per-dispatch token numbers that
# lived ONLY in the orchestrator's context window. logs/tooluse-audit.jsonl records that a dispatch
# happened, never what it cost. At F8 the figures had to be recovered from session transcripts, and
# a measurement a human transcribes from a context window is exactly the inversion HC-8 forbids:
# disk is canonical, context is a cache. This script makes the measurement reproducible.
#
# Usage: scripts/measure-dispatch-cost.sh [extra-transcript-dir ...]
#   Writes logs/metrics/dispatch-costs.tsv and prints the roll-up.
#   Transcript dirs are resolved from $HOME and the project path; nothing machine-specific is stored.
set -eu

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# Claude stores a session transcript per project, in a directory whose name is the project path with
# separators replaced by dashes. Derive it rather than hardcoding a machine path (security.md).
slug=$(printf '%s' "$ROOT" | sed 's|/|-|g')
dirs="$HOME/.claude/projects/$slug"
for extra in "$@"; do dirs="$dirs $extra"; done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
: > "$tmp/uses" ; : > "$tmp/costs"

found=0
for d in $dirs; do
  [ -d "$d" ] || continue
  for f in "$d"/*.jsonl; do
    [ -f "$f" ] || continue
    found=$((found + 1))
    # tool_use id -> agent type, task_id (falling back to the dispatch description)
    jq -r '(.message.content? // []) | if type=="array" then .[] else empty end
           | select(.type=="tool_use") | select(.name=="Agent" or .name=="Task")
           | [ .id,
               (.input.subagent_type // "?"),
               ( ((.input.prompt // "") | match("task_id\"?[: =]+\"?([A-Za-z0-9_-]+)").captures[0].string)?
                 // (.input.description // "?") ) ] | @tsv' "$f" 2>/dev/null >> "$tmp/uses" || true
    # tool_result id -> totalTokens, duration
    jq -r 'select((.toolUseResult | type) == "object") | select(.toolUseResult.totalTokens != null)
           | [ ((.message.content? // []) | if type=="array" then .[] else empty end
               | select(.type=="tool_result") | .tool_use_id),
               .toolUseResult.totalTokens,
               (.toolUseResult.totalDurationMs // 0) ] | @tsv' "$f" 2>/dev/null >> "$tmp/costs" || true
  done
done

if [ "$found" = 0 ]; then
  echo "no session transcripts found under: $dirs" >&2
  echo "pass a transcript directory as an argument if the store lives elsewhere" >&2
  exit 1
fi

mkdir -p logs/metrics
# Join on tool_use id, then dedupe on (agent, task, tokens): a project store that was copied during
# a rename holds the same runs twice, and counting them twice would double every total.
awk -F'\t' '
  NR==FNR { agent[$1]=$2; task[$1]=$3; next }
  ($1 in agent) {
    key=agent[$1] SUBSEP task[$1] SUBSEP $2
    if (key in seen) next
    seen[key]=1
    printf "%s\t%s\t%s\t%s\n", agent[$1], task[$1], $2, $3
  }' "$tmp/uses" "$tmp/costs" | sort -t"$(printf '\t')" -k3 -n > logs/metrics/dispatch-costs.tsv

awk -F'\t' '
  { n++; tot+=$3; ms+=$4; if (min==0 || $3<min) min=$3; if ($3>max) max=$3
    rn[$1]++; rt[$1]+=$3
    if ($2 ~ /^F7-/) { f7n++; f7t+=$3 } }
  END {
    if (n==0) { print "no dispatches matched"; exit }
    printf "== all measured dispatches ==\n  n=%d  total=%d  min=%d  mean=%d  max=%d  wall=%.1f agent-hours\n",
           n, tot, min, int(tot/n), max, ms/3600000
    printf "\n== F7 ==\n  n=%d  total=%d  mean=%d\n", f7n, f7t, (f7n?int(f7t/f7n):0)
  }' logs/metrics/dispatch-costs.tsv

printf '\n== per role, dearest first ==\n'
awk -F'\t' '{ rn[$1]++; rt[$1]+=$3 }
  END { for (r in rn) printf "%d\t%s\t%d\t%d\n", int(rt[r]/rn[r]), r, rn[r], rt[r] }' \
  logs/metrics/dispatch-costs.tsv | sort -rn | \
  awk -F'\t' '{ printf "  %-20s n=%-3d mean=%-9d total=%d\n", $2, $3, $1, $4 }'

echo
echo "wrote logs/metrics/dispatch-costs.tsv ($(wc -l < logs/metrics/dispatch-costs.tsv) dispatches)"
echo "NOTE: these are subagent CONTEXT totals, not output produced, and exclude orchestrator tokens."
