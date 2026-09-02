#!/usr/bin/env bash
# UserPromptSubmit — machine-stamped receipt of the turn's entry (CORPUS-SDKPY candidate #2).
# DERIVED FIELDS ONLY, by law: the prompt body is NEVER persisted — prompts are where secrets
# arrive, and shape-based scrubbing is incomplete; the only redaction that cannot miss is not
# storing. prompt_sha256 lets a later dispute verify byte-identity without a body on disk.
# MUST print NOTHING to stdout (some builds inject UserPromptSubmit stdout as context).
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  SID=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null || true)
  PRM=$(printf '%s' "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || true)
  TRIM=$(printf '%s' "$PRM" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  TOK=""
  grep -qE '^APPROVE [A-Za-z0-9-]+$' <<<"$TRIM" && TOK="$TRIM"
  RPP=false
  case "$PRM" in "REMOTE PROMPT PROTOCOL v1"*) RPP=true ;; esac
  NCH=$(printf '%s' "$PRM" | wc -c | tr -d ' ')
  case "$NCH" in ''|*[!0-9]*) NCH=0 ;; esac
  PTMP=$(mktemp); printf '%s' "$PRM" > "$PTMP"
  PSH=$(_sha256 "$PTMP" 2>/dev/null || true); rm -f "$PTMP"
  jq -cn --arg ts "$(now)" --arg s "$SID" --arg k "$TOK" --argjson r "$RPP" \
         --argjson n "$NCH" --arg h "${PSH:-}" --arg p "$PHASE" \
     '{ts:$ts,session_id:$s,starts_with_approve_token:$k,is_remote_preamble:$r,prompt_chars:$n,prompt_sha256:$h,phase:$p}' \
     >> "$ROOT/logs/prompt-receipts.jsonl"
} 2>/dev/null
exit 0
