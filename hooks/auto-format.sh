#!/usr/bin/env bash
# PostToolUse[Write|Edit] — prettier when available, silent no-op otherwise (HC-5: no installs).
# Deliberately skips byte-pinned payloads: reformatting them destroys the identity EX-01 checks.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
{
  INPUT=$(cat 2>/dev/null || true)
  F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
  [ -n "$F" ] && [ -f "$F" ] || exit 0
  case "$(basename "$F")" in
    CLAUDE.md|CLAUDE_DESIGN.md|DIRECTORY_GUIDE.md|Plan.md|models.config.json|settings.json|MASTER_FIFO_PLAN_CLAUDE.md|arbiter-protocol.md)
      exit 0 ;;
  esac
  case "$F" in *.md|*.json|*.js|*.ts) command -v prettier >/dev/null 2>&1 && prettier --write "$F" ;; esac
} 2>/dev/null
exit 0
