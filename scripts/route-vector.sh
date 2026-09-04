#!/usr/bin/env bash
# route-vector.sh — VECTOR-1: the amelioration router. Maps every OPEN GAP-REGISTER row to its
# resolving process (the operator's "vectors that point to the right processes"), FIRST-MATCH-WINS
# over config/vector-rules.json. NEVER calls a model.
#
# Stated divergences from route-tier.sh, deliberate (the plan names all three):
#   - BATCH over the register fence (--all), not per-request stdin;
#   - EQUALITY matching on typed fields, never regex over free text;
#   - NO timestamp and NO trail write in --all output — the emitted queue is a PURE FUNCTION of
#     (register, rules), so the committed docs/research/VECTOR-QUEUE.md is byte-diffed against its
#     own derivation by the suite every run. Recovery if that arm ever reds:
#       scripts/route-vector.sh --all > docs/research/VECTOR-QUEUE.md
#     The queue is never hand-edited.
#
# default mode: one TSV register row on stdin -> "resolution<TAB>priority<TAB>rule_id" on stdout.
# --all: emit the COMPLETE VECTOR-QUEUE.md document on stdout (redirect it into place).
# Unmatched rows fall to ENGINE-ESCALATE even if the compiled catch-all is deleted — two
# independent layers, both escalating to the operator: a router with no policy fails toward the
# human, never toward a silent bin.
set -uo pipefail
export LC_ALL=C
cd "$(dirname "$0")/.."
RULES="config/vector-rules.json"
GR="docs/research/GAP-REGISTER.md"

_sha256 () { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1; fi; }

route_row () {
  local id cls uc mech disp v
  IFS="$(printf '\t')" read -r id cls _ _ disp mech uc _ _ <<<"$1"
  v=$(jq -rn --arg uc "${uc:-}" --arg mech "${mech:-}" --arg cls "${cls:-}" --arg disp "${disp:-}" --slurpfile r "$RULES" '
    [ $r[0][] | select(
        (((.if.uncertainty_class // null) == null) or (.if.uncertainty_class == $uc))
        and (((.if.mechanical // null) == null) or (.if.mechanical == $mech))
        and (((.if.class // null) == null) or (.if.class == $cls))
        and (((.if.disposition // null) == null) or (.if.disposition == $disp))
      ) ] | first
      // {"id":"ENGINE-ESCALATE","resolution":"ESCALATE","priority":1}
    | [.resolution, (.priority|tostring), .id] | @tsv' 2>/dev/null)
  [ -n "${v:-}" ] || v="$(printf 'ESCALATE\t1\tENGINE-ESCALATE')"
  printf '%s\n' "$v"
}

if [ "${1:-}" != "--all" ]; then
  IN=$(cat 2>/dev/null || true)
  [ -n "$IN" ] || { echo "route-vector: no row on stdin (or use --all)" >&2; exit 1; }
  route_row "$IN"
  exit 0
fi

rows=$(awk '/^# GAP-REGISTER v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$GR")
open_rows=$(printf '%s\n' "$rows" | awk -F'\t' '$5=="OPEN"')
queue=$(while IFS= read -r line; do
  [ -n "$line" ] || continue
  rid=$(printf '%s' "$line" | cut -f1)
  v=$(route_row "$line")
  printf '%s\t%s\n' "$rid" "$v"
done <<<"$open_rows" | sort -t "$(printf '\t')" -k3,3n -k1,1)
qn=$(printf '%s\n' "$queue" | grep -c .); case "$qn" in ''|*[!0-9]*) qn=0 ;; esac
rsha=$(_sha256 "$RULES")
rollup=$(printf '%s\n' "$queue" | cut -f2 | sort | uniq -c | awk '{printf "| %s | %s |\n", $2, $1}')

cat <<QEOF
# VECTOR-QUEUE — the ordered process queue (derived; never hand-edited)

**This file is generated**: \`scripts/route-vector.sh --all > docs/research/VECTOR-QUEUE.md\`.
It is a pure function of (GAP-REGISTER OPEN rows, config/vector-rules.json) — no timestamp, no
trail, no model. The suite re-derives it every run and byte-diffs this committed copy; if that
arm ever reds, run the command above and re-verify — the queue is repaired by derivation, never
by hand. Rules provenance: sha256 \`$rsha\` ($qn OPEN rows routed).

Routing policy prose lives beside the rules ids in the fence below and in
config/vector-rules.json's own why fields; the mapping lives ONLY there — this queue never
states destinations of its own.

## The queue (priority, then id)

\`\`\`text
# VECTOR-QUEUE v1
$queue
\`\`\`

## Roll-up (per resolution class)

| resolution | rows |
|---|---|
$rollup

## Weakest claims, flagged

[I] The routing is only as good as the register's uncertainty_class labels — a mislabeled row
routes confidently to the wrong process, and no arm can see that; the calibration roll-up at
SYNTH-1 is where systematic mislabeling would surface. [E-limits] ESCALATE rows (engine or
catch-all) are the operator's bin by design; zero today means the policy covers the current
register, not that it covers tomorrow's rows.
QEOF
