#!/usr/bin/env bash
# PostToolUseFailure[*] — record the failure, then DELIVER the §9 corpus hint. Never blocks.
#
# CR-018 (audit A3-F6): the hint half was decorative. It wrote to stdout and exited 0, inside a block
# that discarded stderr besides — and the hooks reference is explicit that a PostToolUse or
# PostToolUseFailure hook surfaces a warning to Claude by exiting 2, so that Claude sees STDERR. No
# artifact anywhere in logs/, Plan.md, PROGRESS.md or context/ ever recorded a hint reaching anyone.
# The suite asserted the hint was EMITTED, which is a correct test of the wrong property: emission is
# not delivery.
#
# The logging half always worked — it captured the audit's own blocked calls within seconds — and is
# unchanged. Now the hint is captured, and when there is one it goes to real stderr with exit 2.
# When there is none, exit 0: this event cannot block either way, so exit 2 costs nothing beyond
# surfacing the text, while staying at 0 keeps the common case quiet instead of tagging every
# unrecognised failure with an empty warning.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
HINT=""
{
  INPUT=$(cat 2>/dev/null || true)
  mkdir -p "$ROOT/logs"
  T=$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
  E=$(printf '%s' "$INPUT" | jq -r '.tool_response.error // .error // ""' 2>/dev/null || true)
  jq -cn --arg ts "$(now)" --arg t "$T" --arg e "$(printf '%s' "$E" | cut -c1-400)" --arg p "$PHASE" \
     '{ts:$ts,tool:$t,error:$e,phase:$p}' >> "$ROOT/logs/build-errors.jsonl"
  # A brace group, not a subshell: HINT set here survives past the closing brace.
  case "$E" in
    *"command not found"*) HINT="[hint] §9 minimal-shell: hooks must export PATH; the tool env is not your login shell." ;;
    *"Permission denied"*) HINT="[hint] §9: chmod +x the script; hooks are executed, not sourced." ;;
    *"Unexpected token"*|*"parse error"*) HINT="[hint] §9 type-strictness: edit JSON via jq, never by hand." ;;
    *"No such file"*)      HINT="[hint] §9 phantom deps: nothing is referenced unless verified on disk." ;;
  esac
} 2>/dev/null
[ -n "$HINT" ] || exit 0
printf '%s\n' "$HINT" >&2
exit 2
