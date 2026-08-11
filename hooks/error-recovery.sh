#!/usr/bin/env bash
# PostToolUseFailure[*] — record the failure and emit the §9 corpus hint. Never blocks; exit 0.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  T=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
  E=$(printf '%s' "$INPUT" | jq -r '.tool_response.error // .error // ""' 2>/dev/null || true)
  jq -cn --arg ts "$(now)" --arg t "$T" --arg e "$(printf '%s' "$E" | cut -c1-400)" --arg p "$PHASE" \
     '{ts:$ts,tool:$t,error:$e,phase:$p}' >> "$ROOT/logs/build-errors.jsonl"
  case "$E" in
    *"command not found"*) echo "[hint] §9 minimal-shell: hooks must export PATH; the tool env is not your login shell." ;;
    *"Permission denied"*) echo "[hint] §9: chmod +x the script; hooks are executed, not sourced." ;;
    *"Unexpected token"*|*"parse error"*) echo "[hint] §9 type-strictness: edit JSON via jq, never by hand." ;;
    *"No such file"*)      echo "[hint] §9 phantom deps: nothing is referenced unless verified on disk." ;;
  esac
} 2>/dev/null
exit 0
