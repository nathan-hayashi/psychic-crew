#!/usr/bin/env bash
# Notification[*] — desktop toast (Q3: reuse the existing wsl-notify-send.exe). Never fatal.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
MSG=$(cat 2>/dev/null | jq -r '.message // "psychic-crew"' 2>/dev/null || echo "psychic-crew")
if grep -qi microsoft /proc/version 2>/dev/null && command -v wsl-notify-send.exe >/dev/null 2>&1; then
  wsl-notify-send.exe "psychic-crew" "$MSG" >/dev/null 2>&1 || true
elif command -v notify-send >/dev/null 2>&1; then
  notify-send "psychic-crew" "$MSG" >/dev/null 2>&1 || true
elif command -v osascript >/dev/null 2>&1; then
  osascript -e "display notification \"$MSG\" with title \"psychic-crew\"" >/dev/null 2>&1 || true
fi
exit 0
