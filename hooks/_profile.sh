#!/usr/bin/env bash
# hooks/_profile.sh — repo-class resolver (R-PR-1, HARNESS-CONV-1). Sourced, never executed.
# MIRRORED: this file is byte-identical in psychic-crew and psychic-crew-lite — a resolver that
# disagrees between the repos is a defect generator, so divergence FAILS the twin's sync check.
#
# Classes: harness-build (build constraints bind) · node-app · generic (universal safety only).
# LAW (HARNESS-SPEC §2): harness-build requires CORROBORATION — the gate ledger AND the repo's own
# blocker must both exist. A marker file alone can only TIGHTEN (declare node-app/generic where
# inference would be wrong); it can never mint harness-build and it can never loosen a corroborated
# checkout — an unauthenticated JSON file must not be an off-switch for an enforcement layer.
profile_of () {
  _pr_root=${1:?profile_of: root required}
  if [ -f "$_pr_root/GATES.md" ] && [ -f "$_pr_root/hooks/bash-blocker.sh" ]; then
    printf '%s' 'harness-build'; return 0
  fi
  _pr_marker="$_pr_root/.claude/harness-profile.json"
  if [ -f "$_pr_marker" ]; then
    _pr_p=$(jq -r '.profile // empty' "$_pr_marker" 2>/dev/null || true)
    case "$_pr_p" in
      node-app|generic) printf '%s' "$_pr_p"; return 0 ;;
      *) : ;;  # malformed, or an uncorroborated harness-build claim: not authority — fall through
    esac
  fi
  if [ -f "$_pr_root/package.json" ]; then printf '%s' 'node-app'; else printf '%s' 'generic'; fi
}
