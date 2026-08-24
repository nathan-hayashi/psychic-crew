#!/usr/bin/env bash
# PreToolUse[Write|Edit] — HC-2: block any write ASSIGNING a forbidden model into the config surface.
# EX-03: assignment positions only. A substring scan would block this repo's own rule file and
# would make this very script unwriteable, since it must contain the string to match it.
set -uo pipefail
. "$(dirname "$0")/_common.sh"
INPUT=$(cat 2>/dev/null || true)
F=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
C=$(printf '%s' "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || true)
[ -n "$F" ] || exit 0
case "$F" in
  */.claude/*|*/models.config.json|*models.config.json) ;;
  *) exit 0 ;;
esac
BAD=$(jq -r '.forbidden_substrings[]' "$ROOT/models.config.json" 2>/dev/null || echo fable)

# R-SEC-1 red-team probe, SECURITY-1: the assignment-position scan below catches a DIRECT write of
# a forbidden model and MISSES every indirection — `aliases.opus`, `pinned.opus` and `session.model`
# all resolve agents onto a forbidden family without any line matching `model:`. Measured: three
# probes beat this guard while the direct one was denied.
#
# It was contained, not exploitable: apply-models.sh refuses to stamp (exit 2, HC-2) and
# validate-crew fails, so no agent could actually run on it. But containment downstream is not the
# job of a WRITE-TIME guard, and psychic-crew-lite's equivalent already resolved the proposed config
# — the child was ahead of the parent on its own constraint. Ported back here.
#
# Resolution over the PROPOSED content, exactly as apply-models would read it.
case "$F" in
  *models.config.json)
    if printf '%s' "$C" | jq -e . >/dev/null 2>&1; then
      for b in $BAD; do
        hit=$(printf '%s' "$C" | jq -r --arg b "$b" '. as $r
          | [ (($r.aliases // {}) | to_entries[] | .value),
              (($r.pinned  // {}) | to_entries[] | .value),
              (($r.agents  // {}) | to_entries[] | .value.model // ""),
              (($r.session // {}).model // "") ]
          | map(select(type == "string" and (ascii_downcase | contains($b)))) | .[0] // ""' 2>/dev/null)
        [ -z "$hit" ] || deny "HC-2: this config makes a forbidden ($b) model reachable - resolved value '$hit'"
      done
    fi ;;
esac
for b in $BAD; do
  if grep -qiE "^[[:space:]]*\"?model\"?[[:space:]]*:[[:space:]]*\"?[^\",}]*${b}" <<<"$C"; then
    deny "HC-2: write assigns a forbidden ($b) model into the config surface"
  fi
done
exit 0
