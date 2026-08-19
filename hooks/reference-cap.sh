#!/usr/bin/env bash
# PreToolUse[Agent] — FLAG a dispatch that inlines a file body past the §15.2 excerpt cap.
# NEVER denies: always exit 0, never emits a permissionDecision. Flag-first follows the C-13
# precedent, where a denying check was rejected because it would have blocked legitimate quoting.
#
# CR-022. arbiter-protocol.md caps DISPATCH excerpts at 30 lines and nothing enforced it. That cap
# is the lever HC-8 names as the compounding driver, and C-20 measured the counter-case: the same
# ~27K of source counted once per reading agent, ~214K, 11% of F7's spend, pure input.
#
# WHAT IT MEASURES, stated honestly: the longest FENCED block in the dispatch prompt. An inlined
# file body is overwhelmingly pasted inside a fence, and a fence is checkable. A body pasted with
# no fence at all is NOT detected, and neither is a paraphrase — the same class of limit C-13
# records for the provenance hook. Total prompt length is deliberately not the trigger: a long
# contract is legitimate and flagging it would train people to ignore this.
#
# The line carries event:"FLAG" so the coverage correlation can exclude it. Without that field a
# hook writing into the arbiter's trail would satisfy the arbiter's own coverage obligation, which
# is C-12's defect arriving through a new writer.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
CAP=30
{
  INPUT=$(cat 2>/dev/null || true)
  P=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null || true)
  [ -n "$P" ] || exit 0
  BIG=$(printf '%s\n' "$P" | awk '
    /^[[:space:]]*```/ { if (inf) { if (n > m) m = n; n = 0; inf = 0 } else { inf = 1 } ; next }
    inf { n++ }
    END { if (n > m) m = n; print m + 0 }')
  [ "${BIG:-0}" -gt "$CAP" ] || exit 0
  TO=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // "unknown"' 2>/dev/null || echo unknown)
  ID=$(printf '%s' "$P" | grep -oE '"task_id"[[:space:]]*:[[:space:]]*"[A-Za-z0-9._-]+"' | head -1 \
       | sed 's/.*"\([A-Za-z0-9._-]*\)"$/\1/' || true)
  mkdir -p "$ROOT/logs"
  jq -cn --arg ts "$(now)" --arg i "${ID:-refcap-unattributed}" --arg p "$PHASE" --arg to "$TO" \
         --arg n "$BIG" --arg cap "$CAP" \
     '{ts:$ts,task_id:$i,phase:$p,from_agent:"reference-cap",to:$to,
       event:"FLAG",original_sha256:"n/a",
       mutation:("FLAG reference-cap: dispatch inlines a " + $n + "-line fenced block, over the " + $cap + "-line excerpt cap"),
       reason:"§15.2 reference-passing: DISPATCH payloads carry paths and contracts, not file bodies. Not denied - flag only (C-13 precedent)."}' \
     >> "$ROOT/logs/arbiter-audit.jsonl"
} 2>/dev/null
exit 0
