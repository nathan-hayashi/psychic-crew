#!/usr/bin/env bash
# gate-guard.sh "<exact token>" — refuse to proceed unless the gate is actually approved.
#
# WHY THIS EXISTS (ruling H0a). At LITE-SYNC-2 a session — this one — committed and pushed BEFORE
# the operator's token, by folding the commit into the same step as the stability proof. It was
# self-disclosed, ledgered, and approved after the fact. One breach of a constitutional control
# earns a mechanical guard rather than a promise to be more careful, because "approval is never
# inferred" had been written down for weeks and was still inferred from momentum.
#
# Usage in every gated close ritual, from this session onward:
#     scripts/gate-guard.sh "APPROVE SOMETHING" && git commit …
# The `&&` is the point: no token line in the ledger, no commit.
#
# STATED LIMIT, carried from the ruling rather than discovered later: this defeats ORDERING
# MISTAKES, not forgery. A session that writes a fabricated APPROVED line into GATES.md and then
# calls this guard will pass it. Detecting that class is the ledger-versus-operator-memory audit,
# not a script, and pretending otherwise would make this the eleventh proxy control in a build that
# has recorded ten.
#
# Repo-agnostic by construction: it reads ./GATES.md in the current working directory and knows
# nothing about either repo's layout, because it is MIRRORED byte-identical into psychic-crew-lite.
#
# Its own code obeys R-SD-1 v2: capture-then-test, no count-then-default composite, and no
# status-consumed pipeline with a signal-able producer.
set -uo pipefail

TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then
  printf 'gate-guard: REFUSED — no token given.\n  usage: %s "<exact token>"\n' "$0" >&2
  exit 1
fi

LEDGER="GATES.md"
if [ ! -f "$LEDGER" ]; then
  printf 'gate-guard: REFUSED — no %s in %s; there is no ledger to approve anything.\n' "$LEDGER" "$PWD" >&2
  exit 1
fi

# Capture, then test. The row must carry BOTH the approval marker and the exact token, on the same
# line — a row that merely awaits the token, or narrates it, is not an approval.
LEDGER_BODY=$(cat "$LEDGER" 2>/dev/null)
NEEDLE="**APPROVED** \`${TOKEN}\`"
MATCH=$(grep -cF -- "$NEEDLE" <<<"$LEDGER_BODY")
case "$MATCH" in ''|*[!0-9]*) MATCH=0 ;; esac

if [ "$MATCH" -gt 0 ]; then
  printf 'gate-guard: ok — "%s" is APPROVED in %s (%s row(s)).\n' "$TOKEN" "$LEDGER" "$MATCH"
  exit 0
fi

# Refusal is plain and says what would fix it. A guard whose failure is cryptic gets worked around.
printf 'gate-guard: REFUSED — "%s" has no APPROVED row in %s.\n' "$TOKEN" "$LEDGER" >&2
PENDING=$(grep -cF -- "awaiting \`${TOKEN}\`" <<<"$LEDGER_BODY")
case "$PENDING" in ''|*[!0-9]*) PENDING=0 ;; esac
if [ "$PENDING" -gt 0 ]; then
  printf '  the row exists and is still awaiting the operator. Stop and ask; do not commit.\n' >&2
else
  printf '  no row mentions that token at all. Check the exact spelling, then stop and ask.\n' >&2
fi
exit 1
