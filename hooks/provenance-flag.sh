#!/usr/bin/env bash
# PostToolUse[Write|Edit] — C-13. FLAG, never block (operator decision).
#
# Detects RELAY BY SOURCE CORRELATION, not keywords. The keyword route was measured and rejected:
# "ignore" occurs 7x in Plan.md and 6x in context/plan-corrections.md as ordinary prose, and a
# keyword list would also trip on this build's own §0.2d rule text and on C-13's registry entry —
# which would have been the seventh instance of a guard firing on its own documentation.
#
# A ledger write is compared against the known untrusted corpus (specialist packets under
# logs/rounds/). Shared verbatim text means third-party material was relayed into a continuity
# file that later sessions read as authoritative. Flagged unless the write carries attribution —
# the convention already in organic use at Plan.md's "Handling note (§0.2d)" entry.
#
# Spans are split at sentence boundaries before matching. Matching whole field values only was
# tried first and a partial paste evaded it, which is the likelier relay: people quote a sentence,
# not a whole findings field.
#
# Honest limits: verbatim text only — paraphrase is not detected, because paraphrase already
# implies a judgement was applied. And this FLAGS AFTER the write, by design.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
  [ -n "$F" ] || exit 0
  case "$F" in
    */Plan.md|*/PROGRESS.md|*/context/*) ;;
    *) exit 0 ;;
  esac
  C=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || true)
  [ -n "$C" ] || exit 0
  CORPUS="$ROOT/logs/rounds"
  [ -d "$CORPUS" ] || exit 0

  # Attribution already present means the writer did the required marking. Checked first so the
  # common, correct case costs nothing.
  printf '%s' "$C" | grep -qE '0\.2d|Handling note|relayed|quoted from|source=|untrusted:' && exit 0

  spans=$(
    for pf in "$CORPUS"/*/*.json "$CORPUS"/*.json; do
      [ -f "$pf" ] || continue
      # Well-formed packets yield string leaves. A malformed packet carries the same text and is
      # exactly the kind that gets pasted around after a quarantine, so fall back rather than skip.
      { jq -r '.. | strings' "$pf" 2>/dev/null || grep -oE '"[^"]{40,}"' "$pf" 2>/dev/null | sed 's/^"//;s/"$//'; }
    done | sed 's/\([.;]\) /\1\
/g' | sort -u
  )
  hits=0; sample=""
  while IFS= read -r span; do
    [ "${#span}" -ge 60 ] || continue
    if printf '%s' "$C" | grep -qF -- "$span" 2>/dev/null; then
      hits=$((hits+1)); [ -n "$sample" ] || sample=$(printf '%s' "$span" | cut -c1-90)
    fi
  done <<SPANEOF
$spans
SPANEOF

  if [ "$hits" -gt 0 ]; then
    mkdir -p "$ROOT/logs"
    jq -cn --arg ts "$(now)" --arg f "$F" --arg n "$hits" \
           --arg s "$(scrub "$sample" 2>/dev/null || printf '%s' "$sample")" --arg p "$PHASE" \
      '{ts:$ts,event:"ProvenanceFlag",file:$f,verbatim_spans:($n|tonumber),sample:$s,phase:$p,
        note:"third-party text relayed into a continuity file without attribution; §0.2d requires relayed text be marked as data"}' \
      >> "$ROOT/logs/provenance-flags.jsonl"
    printf '[provenance] %s carries %s verbatim span(s) from a specialist packet, unattributed. §0.2d: mark relayed text as data (e.g. a "Handling note (§0.2d)" line). FLAG ONLY — the write succeeded.\n' "$F" "$hits"
  fi
} 2>/dev/null
exit 0
