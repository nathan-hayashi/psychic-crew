#!/usr/bin/env bash
# Notification[*] — desktop toast (Q3: reuse the existing wsl-notify-send.exe). Never fatal.
set -uo pipefail
. "$(dirname "$0")/_common.sh" 2>/dev/null || true
MSG=$(cat 2>/dev/null | jq -r '.message // "psychic-crew"' 2>/dev/null || echo "psychic-crew")
# HARNESS-ROT-1: the dispatch table moved to _common.sh toast() — one table, every caller.
toast "$MSG"
exit 0
