#!/usr/bin/env bash
# attest.sh — SUITE-ATTEST-1: the dated proof-of-run record (the vector program's convergent
# take: orca's evidence-run ledger + ruflo's per-platform temporal history, one artifact).
#
# THE H2A LESSON, HONORED BY DESIGN: appends are DELIBERATE ACTS, never suite side-effects.
# The suites verify and write nothing tracked; THIS script runs them and, only on all-green,
# appends one row to docs/ATTEST-HISTORY.md (tracked, append-only) and the full per-section
# vector to logs/attest/ (runtime detail, rule-4 split). Lite's law, same doctrine:
# re-verification is deliberate rather than automatic.
#
# Subcommands:
#   run                  execute the five suites; on ALL green, append the attestation row
#   list                 print every row (ts, head, platform/userland, totals)
#   summary              latest row vs previous (what moved)
#   timeline --section S one section's count across all rows (flapping = brittle needle)
#   regressions          sections whose count DROPPED or that VANISHED vs the prior row
#
# Row: ts · head · platform · userland · crew · validate · save · matrices · envelope · sections
# (sections = comma-joined name:okcount pairs from the crew run's own output — the same
# section identity the reliability registry binds). Drift vs regression, orca's split: counts
# GROWING is drift (gates legitimately add arms); a count DROPPING or a section VANISHING is
# the regression alarm. Bisect granularity == attest cadence, stated (finer than a release,
# as often as the act is performed).
set -uo pipefail
# NO global LC_ALL export: the child suites parse UTF-8 records (the guide's box-drawing),
# and a C-locale leak broke their CR-024 extraction on this script's first live run — the
# refusal control caught it. attest's own logic is locale-independent (no sorts).
cd "$(dirname "$0")/.."
HIST="docs/ATTEST-HISTORY.md"

hist_rows () { awk '/^# ATTEST-HISTORY v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$HIST"; }

case "${1:-run}" in
  run)
    plat=$(uname -s)
    if sed --version >/dev/null 2>&1; then ul="GNU"; else ul="BSD"; fi
    crew_out=$(./scripts/run-crew-tests.sh all 2>&1); crew_rc=$?
    crew=$(printf '%s\n' "$crew_out" | grep -oE 'run-crew-tests: [0-9]+ PASS / 0 FAIL' | grep -oE '^run-crew-tests: [0-9]+' | grep -oE '[0-9]+$')
    val=$(./scripts/validate-crew.sh 2>&1 | grep -oE 'validate-crew: [0-9]+ PASS / [0-9]+ SKIP / 0 FAIL' | grep -oE '[0-9]+' | head -1)
    sav=$(./scripts/save-context.sh check 2>&1 | grep -oE 'save-context: [0-9]+ PASS / 0 FAIL' | grep -oE '[0-9]+' | head -1)
    mat=$(./scripts/check-decision-matrices.sh 2>&1 | grep -oE 'check-decision-matrices: [0-9]+ PASS / 0 FAIL' | grep -oE '[0-9]+' | head -1)
    env_=$(./scripts/check-envelope.sh 2>&1 | grep -oE 'check-envelope: [0-9]+ PASS / 0 FAIL' | grep -oE '[0-9]+' | head -1)
    if [ "$crew_rc" != 0 ] || [ -z "${crew:-}" ] || [ -z "${val:-}" ] || [ -z "${sav:-}" ] || [ -z "${mat:-}" ] || [ -z "${env_:-}" ]; then
      echo "attest: REFUSED - a suite is red or a total unparseable (crew='$crew' val='$val' sav='$sav' mat='$mat' env='$env_'); nothing appended" >&2
      exit 1
    fi
    secs=$(printf '%s\n' "$crew_out" | awk '
      /^== / && $0 !~ /run-crew-tests:/ { if (name != "") printf "%s:%d,", name, cnt
        name=$0; sub(/^== /,"",name); sub(/ ==.*$/,"",name); gsub(/[^A-Za-z0-9._-]/,"-",name); gsub(/-+/,"-",name); cnt=0; next }
      /\[PASS\]/ { cnt++ }
      END { if (name != "") printf "%s:%d", name, cnt }')
    tsr=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    head_sha=$(git rev-parse --short HEAD)
    row=$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' "$tsr" "$head_sha" "$plat" "$ul" "$crew" "$val" "$sav" "$mat" "$env_" "$secs")
    tmpf=$(mktemp)
    awk -v r="$row" '/^```$/ && f { print r; f=0 } /^# ATTEST-HISTORY v1$/ { f=1 } { print }' "$HIST" > "$tmpf"
    mv "$tmpf" "$HIST"
    rb=$(hist_rows | tail -1)
    [ "$rb" = "$row" ] || { echo "attest: append READ-BACK FAILED" >&2; exit 1; }
    mkdir -p logs/attest
    printf '%s\n' "$crew_out" > "logs/attest/$tsr-crew.txt"
    echo "attest: recorded $tsr @ $head_sha ($plat/$ul) crew=$crew val=$val sav=$sav mat=$mat env=$env_"
    ;;
  list)
    hist_rows | awk -F'\t' '{printf "%s  %s  %s/%s  crew=%s val=%s sav=%s mat=%s env=%s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9}'
    ;;
  summary)
    n=$(hist_rows | grep -c .); case "$n" in ''|*[!0-9]*) n=0 ;; esac
    [ "$n" -ge 1 ] || { echo "summary: no attestations yet"; exit 0; }
    cur=$(hist_rows | tail -1); prev=$(hist_rows | tail -2 | head -1)
    printf 'entries: %s\nlatest:  %s\n' "$n" "$(printf '%s' "$cur" | cut -f1-9 | tr '\t' ' ')"
    [ "$n" -ge 2 ] && [ "$prev" != "$cur" ] && printf 'previous: %s\n' "$(printf '%s' "$prev" | cut -f1-9 | tr '\t' ' ')"
    ;;
  timeline)
    [ "${2:-}" = "--section" ] && [ -n "${3:-}" ] || { echo "usage: attest.sh timeline --section <name>" >&2; exit 2; }
    hist_rows | while IFS="$(printf '\t')" read -r t1 h1 _p _u _c _v _s _m _e sec; do
      hit=$(printf '%s' "$sec" | tr ',' '\n' | awk -F: -v s="$3" '$1==s' | head -1)
      printf '%s  %s  %s\n' "$t1" "$h1" "${hit:-ABSENT}"
    done
    ;;
  regressions)
    prev_secs=""
    prev_head=""
    found=0
    while IFS="$(printf '\t')" read -r t1 h1 _p _u _c _v _s _m _e sec; do
      if [ -n "$prev_secs" ]; then
        while IFS= read -r pentry; do
          [ -n "$pentry" ] || continue
          pname="${pentry%%:*}"; pcnt="${pentry##*:}"
          centry=$(printf '%s' "$sec" | tr ',' '\n' | grep -E "^$(printf '%s' "$pname" | sed 's/[][\.*^$/]/\\&/g'):" | head -1)
          if [ -z "$centry" ]; then
            printf 'REGRESSION: section VANISHED: %s (last seen %s @ %s)\n' "$pname" "$pcnt" "$prev_head"; found=1
          else
            ccnt="${centry##*:}"
            if [ "$ccnt" -lt "$pcnt" ] 2>/dev/null; then
              printf 'REGRESSION: %s dropped %s -> %s in window (%s .. %s]\n' "$pname" "$pcnt" "$ccnt" "$prev_head" "$h1"; found=1
            fi
          fi
        done <<<"$(printf '%s' "$prev_secs" | tr ',' '\n')"
      fi
      prev_secs="$sec"; prev_head="$h1"
    done <<<"$(hist_rows)"
    [ "$found" = 0 ] && echo "regressions: none across $(hist_rows | grep -c .) attestation(s)"
    exit 0  # a QUERY reports; it never fails on what it finds (the third chain-death taught this)
    ;;
  *)
    echo "usage: attest.sh [run|list|summary|timeline --section S|regressions]" >&2; exit 2 ;;
esac
