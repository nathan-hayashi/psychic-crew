#!/usr/bin/env bash
# PreToolUse[Bash] — deny destructive commands and the HC-5/HC-7 prohibited set.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -n "$CMD" ] || exit 0
case "$CMD" in
  *"rm -rf /"*|*"rm -rf ~"*|*'rm -rf $HOME'*|*"dd if="*|*":(){"*)
      deny "HC-5 destructive command blocked" ;;
  *"git clone"*)        deny "HC-5: git clone is prohibited - this build is from scratch" ;;
  *"npx "*)             deny "HC-5: npx fetches packages at run time - prohibited" ;;
  *"npm install -g"*)   deny "HC-5: global npm install prohibited" ;;
  *"sudo "*)            deny "HC-5: sudo prohibited" ;;
  *"curl "*"|"*"sh"*|*"wget "*"|"*"sh"*) deny "HC-5: curl-pipe-to-shell prohibited" ;;
  *"terraform destroy"*|*"kubectl delete namespace"*) deny "destructive infrastructure command blocked" ;;
  *codex*|*chatgpt*)    deny "HC-7: this build is Claude-only - no Codex/ChatGPT invocation" ;;
esac
exit 0
