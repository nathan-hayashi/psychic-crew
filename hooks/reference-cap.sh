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
exec 3>&2   # preserve the real stderr for the #2 warning; the block below suppresses fd 2
{
  INPUT=$(cat 2>/dev/null || true)
  # CORRECTIONS-2 (#2): WARN (never deny, exit 0) when lead-executor is dispatched with a STAGED
  # index — the STRESS-1 root cause was a staged plan file swept into its per-step commit. Flag-only,
  # per this hook's contract. git is pinned to $ROOT and fail-open on any non-repo/error (so the
  # temp-root fire-probes and the C-16 fixture never false-warn), exit status used directly (rule 5).
  if [ "$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null)" = "lead-executor" ] \
     && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
     && ! git -C "$ROOT" diff --cached --quiet 2>/dev/null; then
    printf 'WARNING (CORRECTIONS-2 #2): dispatching lead-executor with a STAGED index; these paths may be swept into its commit: %s\n' \
      "$(git -C "$ROOT" diff --cached --name-only 2>/dev/null | tr '\n' ' ')" >&3
  fi
  P=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null || true)
  [ -n "$P" ] || exit 0
  BIG=$(printf '%s\n' "$P" | awk '
    /^[[:space:]]*```/ { if (inf) { if (n > m) m = n; n = 0; inf = 0 } else { inf = 1 } ; next }
    inf { n++ }
    END { if (n > m) m = n; print m + 0 }')
  # HOOK-1: unconditional delivery evidence — this is the ONLY PreToolUse[Agent] hook, and no
  # live row had ever proven the matcher fires (66 dispatches, zero trail lines). One append
  # before the early exit turns delivery from an assumption into a readable fact; HOOK-2's
  # deny hook has a hard precondition on at least one of these rows existing.
  { mkdir -p "$ROOT/logs"
    jq -cn --arg ts "$(now)" --arg p "$PHASE" \
       '{ts:$ts,event:"PreToolUse.observed",tool:"Agent",phase:$p}' \
       >> "$ROOT/logs/tooluse-audit.jsonl"
  } >/dev/null 2>&1
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
