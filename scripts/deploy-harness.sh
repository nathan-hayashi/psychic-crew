#!/usr/bin/env bash
# scripts/deploy-harness.sh — project harness governance into an EXPLICIT target repo
# (HARNESS-BUILD-1, per the ratified HARNESS-SPEC §3–§4).
#
#   deploy-harness.sh <target-repo-path>            # DRY RUN (default): print the projection
#   deploy-harness.sh <target-repo-path> --apply    # write it
#   deploy-harness.sh <target-repo-path> --remove   # remove exactly what a deploy wrote
#   deploy-harness.sh <target-repo-path> --apply --force   # overwrite a drifted region (prints diff first)
#   deploy-harness.sh --remove-user                 # tier-1 inverse: unwire ~/.claude/settings.json
#
# LAWS (each refusal is a distinct predicate; nothing is inferred from directory nesting):
#   target must be a git work tree · never the harness repo or its twin · tree must be clean ·
#   a drifted managed region refuses without --force · writes land ONLY inside managed regions or
#   files this script owns outright · NEVER permissions.allow / permissions.deny / model keys ·
#   the target's own suite is never touched. What a deploy places: the UNIVERSAL trio copied into
#   $TARGET/.claude/harness-hooks/ (self-contained — governance survives this checkout moving; the
#   copies carry no build-constraint arms, so nothing here can enforce HC-5 in a foreign repo),
#   wiring in .claude/settings.local.json (entry signature: the harness-hooks path), a marked
#   CLAUDE.md note, a marked .gitignore block, and the manifest .claude/harness-profile.json.
set -uo pipefail
SELF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
USER_HARNESS="$HOME/.claude/harness/hooks"
MARK_OPEN='>>> harness-deploy v1'
MARK_CLOSE='<<< harness-deploy'
SIG='/.claude/harness-hooks/'
TRIO="_common.sh _profile.sh bash-blocker.sh sensitive-guard.sh"

usage () { sed -n '3,10p' "$0"; exit 1; }
refuse () { printf 'deploy-harness REFUSED: %s\n' "$1" >&2; exit 3; }

_sha256 () { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
             elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1; fi; }

audit_line () {
  # Rule 3: append, then read back. Redaction: paths only pass through here, scrubbed anyway.
  _al_dst="$SELF_DIR/logs/deploy-audit.jsonl"
  mkdir -p "$SELF_DIR/logs" 2>/dev/null || return 0
  _al_line=$(jq -cn --arg ts "$(date -u +%FT%TZ)" --arg act "$1" --arg tgt "$2" \
    '{ts:$ts,event:"deploy-harness",action:$act,target:$tgt}' 2>/dev/null)
  [ -n "$_al_line" ] || return 0
  printf '%s\n' "$_al_line" >> "$_al_dst" 2>/dev/null || { echo "deploy-audit append failed" >&2; return 1; }
  grep -qF -- "$_al_line" <<<"$(tail -1 "$_al_dst" 2>/dev/null)" || { echo "deploy-audit read-back failed" >&2; return 1; }
}

# ---------- tier-1 inverse ----------
if [ "${1:-}" = "--remove-user" ]; then
  S="$HOME/.claude/settings.json"
  [ -f "$S" ] || refuse "no user settings file"
  cp "$S" "$S.harness-backup.$(date -u +%Y%m%dT%H%M%SZ)"
  jq --arg sig "$HOME/.claude/harness/hooks/" '
    if .hooks then .hooks |= with_entries(.value |= map(select((.hooks // [] | map(.command // "") | join(" ")) | contains($sig) | not))) else . end
  ' "$S" > "$S.tmp" && mv "$S.tmp" "$S"
  echo "user-scope harness wiring removed (backup written beside it); files left inert on disk"
  exit 0
fi

TARGET_ARG="${1:-}"; [ -n "$TARGET_ARG" ] || usage
MODE="dry-run"; FORCE=0
for a in "${@:2}"; do case "$a" in --apply) MODE=apply ;; --remove) MODE=remove ;; --force) FORCE=1 ;; *) usage ;; esac; done

TARGET="$(cd "$TARGET_ARG" 2>/dev/null && pwd)" || refuse "target does not exist: $TARGET_ARG"
git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1 || refuse "target is not a git work tree"
TGT_TOP="$(git -C "$TARGET" rev-parse --show-toplevel)"
[ "$TGT_TOP" = "$TARGET" ] || refuse "target must be the repo root (got a subdirectory of $TGT_TOP)"
for HR in "$SELF_DIR" "$(cd "$SELF_DIR/../psychic-crew-lite" 2>/dev/null && pwd)"; do
  [ -n "$HR" ] && [ "$TARGET" = "$HR" ] && refuse "target is a harness repo — it is its own authority"
done
[ -d "$USER_HARNESS" ] || refuse "user-scope harness files not installed (tier 1 first)"

DIRTY=$(git -C "$TARGET" status --porcelain 2>/dev/null | grep -c . || true)
case "$DIRTY" in ''|*[!0-9]*) DIRTY=0 ;; esac
[ "$MODE" = "dry-run" ] || [ "$DIRTY" -eq 0 ] || refuse "target tree is dirty ($DIRTY entries) — commit or stash first"

MANIFEST="$TARGET/.claude/harness-profile.json"
HHOOKS="$TARGET/.claude/harness-hooks"
CMD_FILE="$TARGET/CLAUDE.md"; GI_FILE="$TARGET/.gitignore"; SL_FILE="$TARGET/.claude/settings.local.json"

region_hash () { # current bytes of our marked region in $1 ('' if absent)
  [ -f "$1" ] || { printf ''; return 0; }
  _rh_t=$(mktemp)
  awk -v o="$MARK_OPEN" -v c="$MARK_CLOSE" 'index($0,o){f=1} f{print} index($0,c){f=0}' "$1" > "$_rh_t"
  _sha256 "$_rh_t"; rm -f "$_rh_t"
}

drift_check () { # refuse (unless --force) when live regions differ from the manifest
  [ -f "$MANIFEST" ] || return 0
  for f in CLAUDE.md .gitignore; do
    want=$(jq -r --arg f "$f" '.deploy.regions[$f] // empty' "$MANIFEST" 2>/dev/null)
    [ -n "$want" ] || continue
    have=$(region_hash "$TARGET/$f")
    if [ "$have" != "$want" ]; then
      printf 'drift in %s managed region (manifest %s, live %s)\n' "$f" "${want:0:12}" "${have:0:12}" >&2
      [ "$FORCE" = 1 ] || refuse "managed region drifted — a human edited it; re-run with --force to overwrite after reviewing"
    fi
  done
}

snapshot () {
  SNAPD="$TARGET/.claude/harness-backups/$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$SNAPD"
  for f in "$CMD_FILE" "$GI_FILE" "$SL_FILE"; do [ -f "$f" ] && cp "$f" "$SNAPD/"; done
  printf 'snapshots: %s\n' "$SNAPD"
}

strip_region () { # remove our marked region from $1 in place (no-op if absent), then normalize
  [ -f "$1" ] || return 0
  awk -v o="$MARK_OPEN" -v c="$MARK_CLOSE" 'index($0,o){f=1} !f{print} index($0,c){f=0}' "$1" > "$1.hdtmp" && mv "$1.hdtmp" "$1"
  # collapse trailing blank lines to a single terminating newline so --remove restores the
  # original bytes exactly (the apply path appends the block after one separator line)
  printf '%s\n' "$(cat "$1")" > "$1.hdtmp" && mv "$1.hdtmp" "$1"
}

PROFILE_VAL="generic"; [ -f "$TARGET/package.json" ] && PROFILE_VAL="node-app"

CMD_BLOCK="<!-- $MARK_OPEN -->
## Harness governance (deployed — do not edit inside these markers)

Universal-safety guards are wired for this repo at \`.claude/harness-hooks/\` (destructive commands
and credential-home writes are denied; nothing else is constrained — this repo's profile is
\`$PROFILE_VAL\`). Re-running \`deploy-harness.sh\` from the harness checkout refreshes them;
\`--remove\` takes exactly this block, the wiring, and the copies back out.
<!-- $MARK_CLOSE -->"

GI_BLOCK="# $MARK_OPEN
logs/
.claude/state/
.claude/harness-backups/
.claude/harness-hooks/
.claude/harness-profile.json
.claude/settings.local.json
.env
# $MARK_CLOSE"

show_plan () {
  printf 'DRY RUN — deploy-harness would write into %s:\n' "$TARGET"
  printf '  profile marker: %s (never harness-build by deploy)\n' "$PROFILE_VAL"
  printf '  copies: .claude/harness-hooks/{%s}\n' "$(printf '%s' "$TRIO" | tr ' ' ',')"
  printf '  wiring: .claude/settings.local.json hooks.PreToolUse entries (signature: %s)\n' "$SIG"
  printf '  CLAUDE.md + .gitignore: one marked block each\n'
  printf '  manifest: .claude/harness-profile.json · snapshots under .claude/harness-backups/\n'
}

if [ "$MODE" = "dry-run" ]; then drift_check; show_plan; exit 0; fi

if [ "$MODE" = "remove" ]; then
  [ -f "$MANIFEST" ] || refuse "no manifest at the target — nothing a deploy wrote can be identified"
  drift_check
  snapshot
  RM_CREATED="$(jq -r '.deploy.created // ""' "$MANIFEST" 2>/dev/null)"
  strip_region "$CMD_FILE"; strip_region "$GI_FILE"
  for _rm_f in $RM_CREATED; do
    _rm_p="$TARGET/$_rm_f"
    # the deploy created this file; if nothing but whitespace remains after stripping our region,
    # true restore is its absence
    if [ -f "$_rm_p" ] && [ -z "$(tr -d '[:space:]' < "$_rm_p")" ]; then rm -f "$_rm_p"; fi
  done
  if [ -f "$SL_FILE" ]; then
    jq --arg sig "$SIG" '
      if .hooks then .hooks |= with_entries(.value |= map(select((.hooks // [] | map(.command // "") | join(" ")) | contains($sig) | not))) else . end
    ' "$SL_FILE" > "$SL_FILE.hdtmp" && mv "$SL_FILE.hdtmp" "$SL_FILE"
    [ "$(jq -r '(.hooks // {}) | [.[]] | map(length) | add // 0' "$SL_FILE")" = 0 ] && [ "$(jq 'keys | length' "$SL_FILE")" = 1 ] && rm -f "$SL_FILE"
  fi
  rm -rf "$HHOOKS"; rm -f "$MANIFEST"
  audit_line "remove" "$TARGET"
  echo "removed. verify: git -C $TARGET status --short (backups retained under .claude/harness-backups/)"
  exit 0
fi

# ---------- apply ----------
drift_check
snapshot
CREATED=""
[ -f "$CMD_FILE" ] || CREATED="$CREATED CLAUDE.md"
[ -f "$GI_FILE" ]  || CREATED="$CREATED .gitignore"
[ -f "$MANIFEST" ] && CREATED="$(jq -r '.deploy.created // ""' "$MANIFEST" 2>/dev/null)"
mkdir -p "$HHOOKS" "$TARGET/.claude"
for f in $TRIO; do cp "$USER_HARNESS/$f" "$HHOOKS/$f"; done
chmod +x "$HHOOKS/bash-blocker.sh" "$HHOOKS/sensitive-guard.sh"

strip_region "$CMD_FILE"; printf '%s\n%s\n' "$( [ -f "$CMD_FILE" ] && cat "$CMD_FILE" )" "$CMD_BLOCK" | sed '/./,$!d' > "$CMD_FILE.hdtmp" && mv "$CMD_FILE.hdtmp" "$CMD_FILE"
strip_region "$GI_FILE";  printf '%s\n%s\n' "$( [ -f "$GI_FILE" ] && cat "$GI_FILE" )" "$GI_BLOCK" | sed '/./,$!d' > "$GI_FILE.hdtmp" && mv "$GI_FILE.hdtmp" "$GI_FILE"

[ -f "$SL_FILE" ] || printf '{}' > "$SL_FILE"
jq --arg bb "\$CLAUDE_PROJECT_DIR/.claude/harness-hooks/bash-blocker.sh" \
   --arg sg "\$CLAUDE_PROJECT_DIR/.claude/harness-hooks/sensitive-guard.sh" --arg sig "$SIG" '
  .hooks = (.hooks // {}) |
  .hooks.PreToolUse = ((.hooks.PreToolUse // []) | map(select((.hooks // [] | map(.command // "") | join(" ")) | contains($sig) | not))) |
  .hooks.PreToolUse += [
    {matcher:"Bash",          hooks:[{type:"command", command:$bb}]},
    {matcher:"Write|Edit",    hooks:[{type:"command", command:$sg}]}
  ]' "$SL_FILE" > "$SL_FILE.hdtmp" && mv "$SL_FILE.hdtmp" "$SL_FILE"

RH_CMD=$(region_hash "$CMD_FILE"); RH_GI=$(region_hash "$GI_FILE")
MF_NEW=$(jq -cn --arg p "$PROFILE_VAL" --arg ts "$(date -u +%FT%TZ)" --arg hp "$SELF_DIR" \
  --arg cr "$CREATED" \
  --arg rc "$RH_CMD" --arg rg "$RH_GI" \
  --arg h1 "$(_sha256 "$HHOOKS/_common.sh")" --arg h2 "$(_sha256 "$HHOOKS/_profile.sh")" \
  --arg h3 "$(_sha256 "$HHOOKS/bash-blocker.sh")" --arg h4 "$(_sha256 "$HHOOKS/sensitive-guard.sh")" '
  {profile:$p,
   deploy:{version:"v1", ts:$ts, source:$hp, created:$cr,
           regions:{"CLAUDE.md":$rc, ".gitignore":$rg},
           hooks:{"_common.sh":$h1,"_profile.sh":$h2,"bash-blocker.sh":$h3,"sensitive-guard.sh":$h4}}}')
# TRUE idempotency (spec predicate): a re-run that changes nothing WRITES nothing — the manifest
# is rewritten only when it differs beyond its own timestamp, so back-to-back applies are
# byte-identical regardless of the clock (the ts-only rewrite was a time-dependent flake).
if [ -f "$MANIFEST" ] && [ "$(jq -c 'del(.deploy.ts)' "$MANIFEST" 2>/dev/null)" = "$(printf '%s' "$MF_NEW" | jq -c 'del(.deploy.ts)')" ]; then
  :
else
  printf '%s\n' "$MF_NEW" > "$MANIFEST"
fi

audit_line "apply" "$TARGET"
printf 'deployed into %s (profile %s). re-run is idempotent; --remove restores; backups under .claude/harness-backups/\n' "$TARGET" "$PROFILE_VAL"
exit 0
