#!/usr/bin/env bash
# PreToolUse[Bash] — deny destructive commands and the HC-5/HC-7 prohibited set.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -n "$CMD" ] || exit 0
case "$CMD" in
  *"rm -rf /"*|*"rm -rf ~"*|*'rm -rf $HOME'*|*"dd if="*|*":(){"*)
      deny "destructive command blocked" ;;
  *"sudo "*)            deny "elevated execution prohibited" ;;
  *"terraform destroy"*|*"kubectl delete namespace"*) deny "destructive infrastructure command blocked" ;;
esac

# R-PR-1 (HARNESS-CONV-1): everything ABOVE this line is UNIVERSAL SAFETY — it ran already, before
# any profile logic, so no marker, no resolver failure and no session-root confusion can make a
# destructive command reachable. Everything BELOW binds only a harness-build checkout.
#
# Two-root law: the profile is resolved from THIS SCRIPT'S OWN repo (a session rooted elsewhere
# must not disable these arms — CLAUDE_PROJECT_DIR is the SESSION root and is only ever the log
# destination). A missing resolver fails CLOSED to harness-build: enforcing build constraints in a
# repo that is not a harness is an inconvenience; not enforcing them in one is a breach.
_bb_self="$(cd "$(dirname "$0")/.." && pwd)"
if [ -f "$(dirname "$0")/_profile.sh" ]; then
  . "$(dirname "$0")/_profile.sh"
  _bb_profile="$(profile_of "$_bb_self")"
else
  _bb_profile="harness-build"
fi
[ "$_bb_profile" = "harness-build" ] || exit 0

case "$CMD" in
  *"git clone"*)        deny "HC-5: git clone is prohibited - this build is from scratch" ;;
  *"npx "*)             deny "HC-5: npx fetches packages at run time - prohibited" ;;
  *"npm install -g"*)   deny "HC-5: global npm install prohibited" ;;
  *"curl "*"|"*"sh"*|*"wget "*"|"*"sh"*) deny "HC-5: curl-pipe-to-shell prohibited" ;;
  *codex*|*chatgpt*)    deny "HC-7: this build is Claude-only - no Codex/ChatGPT invocation" ;;
esac
exit 0
