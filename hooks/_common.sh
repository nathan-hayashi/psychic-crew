# shellcheck shell=bash
# Shared hook preamble. R2: never depend on $CLAUDE_PROJECT_DIR alone — it is unset in some
# contexts, and a hook resolving to an empty path fails silently, which is the worst outcome
# for an enforcement layer. Derive from the script's own location as the fallback.
export PATH="$HOME/bin:/usr/local/bin:/usr/bin:/bin"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
PHASE=$(grep -oE '^## \[F[0-9]' "$ROOT/PROGRESS.md" 2>/dev/null | tail -1 | grep -oE 'F[0-9]' || true)
[ -n "${PHASE:-}" ] || PHASE="F?"
now () { date -u +%Y-%m-%dT%H:%M:%SZ; }
# SEC-DG-01: every audit target passes through scrub() before it is written. The old form was
# `cut -c1-200`, which is a LENGTH limit and not a redaction — a credential inside the first 200
# bytes went into logs/tooluse-audit.jsonl verbatim, and that file is durable, is read at every
# gate and is pasted into gate evidence. Redact by SHAPE first and truncate second: truncating
# first can sever a token and leave a usable prefix behind. Note the truncation bounds each LINE
# to 200 (cut is line-oriented), which is the pre-existing behaviour and is NOT a size cap on a
# multi-line command; redaction is per line too, so every line is still scrubbed.
# Matches assignment/flag/header POSITIONS and known credential prefixes, never bare mentions —
# the same discipline EX-03 forced on the HC-2 scan, so `grep -n token GATES.md` stays readable
# in the trail while `TOKEN=<value>` does not. Fails CLOSED: if the scrubber cannot run, emit a
# sentinel, because a lost audit target is recoverable and a leaked key is not.
SCRUB_KEY='[A-Za-z0-9_.-]*(password|passwd|secret|token|api[_-]?key|access[_-]?key|secret[_-]?key|private[_-]?key|credentials?|client[_-]?secret|auth[_-]?token|authorization)[A-Za-z0-9_.-]*'
SCRUB_SEP="[\"']?[[:space:]]*[=:][[:space:]]*"
scrub () {
  _sc_in=${1:-}
  [ -n "$_sc_in" ] || { printf ''; return 0; }
  _sc_out=$(printf '%s' "$_sc_in" | sed -E \
    -e "s#(-----BEGIN[A-Z ]*PRIVATE KEY-----).*#\1[REDACTED]#g" \
    -e "s#([A-Za-z][A-Za-z0-9+.-]*://)[^/@[:space:]]+@#\1[REDACTED]@#g" \
    -e "s#(^|[^A-Za-z0-9_-])(gh[pousr]_|github_pat_|glpat-|xox[abopsr]-|sk-|sk_live_|pk_live_|AKIA|ASIA|AIza|ya29\.)[A-Za-z0-9_.-]{8,}#\1\2[REDACTED]#g" \
    -e "s#(^|[^A-Za-z0-9_-])eyJ[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]+#\1[REDACTED-JWT]#g" \
    -e "s#(bearer[[:space:]]+)[A-Za-z0-9._~+/=-]{6,}#\1[REDACTED]#gI" \
    -e "s#($SCRUB_KEY$SCRUB_SEP)\"[^\"]*\"#\1\"[REDACTED]\"#gI" \
    -e "s#($SCRUB_KEY$SCRUB_SEP)'[^']*'#\1'[REDACTED]'#gI" \
    -e "s#($SCRUB_KEY$SCRUB_SEP)[^[:space:]\"';|&\`]+#\1[REDACTED]#gI" \
    -e "s#(--?(password|passwd|token|api[_-]?key|secret|access[_-]?key|client[_-]?secret|auth[_-]?token)[[:space:]]+)[^[:space:]]+#\1[REDACTED]#gI" \
    2>/dev/null | cut -c1-200)
  if [ -z "$_sc_out" ]; then printf '%s' '[REDACTED-SCRUB-UNAVAILABLE]'; else printf '%s' "$_sc_out"; fi
}
# C-03: PreToolUse denial is JSON on stdout. A bare exit 2 does NOT block. Emit both — the JSON
# denies, the exit code is belt-and-braces and matches the working local hook.
deny () {
  # A denial is the single event a SOC2 reader most wants to see, and PostToolUse never fires for
  # a tool that was blocked — so the guard must write its own record or the block leaves no trace.
  # G-F2's stress requires six denials AND six audit entries; without this it yielded six and zero.
  # Must not touch stdout: the deny JSON below is the only thing the dispatcher may read.
  # The denied call is the WORST case for verbatim logging: the commands a guard blocks are the
  # ones most likely to carry a credential, so the target is scrubbed here too (SEC-DG-01).
  { mkdir -p "$ROOT/logs"
    dt=$(printf '%s' "${INPUT:-}" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo unknown)
    dg=$(printf '%s' "${INPUT:-}" | jq -r '.tool_input.file_path // .tool_input.command // ""' 2>/dev/null || true)
    jq -cn --arg ts "$(now)" --arg t "$dt" --arg g "$(scrub "$dg")" \
           --arg r "$1" --arg p "$PHASE" \
       '{ts:$ts,event:"PreToolUse.deny",tool:$t,target:$g,reason:$r,phase:$p}' \
       >> "$ROOT/logs/tooluse-audit.jsonl"
  } >/dev/null 2>&1
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}' "$1"
  exit 2
}
