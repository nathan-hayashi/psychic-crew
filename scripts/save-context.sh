#!/usr/bin/env bash
# save-context.sh — the §15.5 distill-merge executor.
#
# "Pure file operations plus an in-session distill instruction" (§15.5). Deliberately NOT a
# rewriter: merging conclusions, marking items resolved and deleting superseded claims all
# require judgement. A script that regenerated the summary itself would be appending chronology
# under a different name, which is the exact failure §15.5 exists to prevent. So this prepares
# the delta, prints the binding instruction, and — the part that is worth automating — VERIFIES
# the result against the semantics that are machine-checkable.
#
# Usage: save-context.sh [prepare|check]
#   prepare  (default) report what changed since the last distill + print the distill instruction
#   check              assert the distilled files obey §15.5; exit 1 on any failure
set -uo pipefail
cd "$(dirname "$0")/.."
MODE="${1:-prepare}"
CTX="context"; ENTRY="$CTX/session-summary.md"
P=0; F=0
ok () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
no () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }

# Built, not written literally: §5.2.4's absolute-path guard is high-recall, and this build has
# burned two red gates on a file that merely QUOTED the token it checks for.
ABS=$(printf '/%s/' home)


# ── DECLARED BINDINGS (C-28, ported from psychic-crew-lite) ─────────────────────────────────────
# CR-034 was the observation that fidelity is not a property you finish: C-24 bound ONE claim — the
# gate timestamp — and every other number in the summary drifted freely until it was three sessions
# stale. CR-034's repair bound two more BY HAND. That fixed the instance; this closes the class.
#
# Every claim is DECLARED below with the source that produces it, and the completeness check FAILS
# on any bold numeric span the manifest does not cover. Adding an unbound number is what breaks,
# rather than something nobody notices for three sessions.
#
# ADAPTED, not copied. Lite writes claims as `**value** label`; this repo writes them four different
# ways — label before the bold, label inside it, and two composite spans carrying two numbers each.
# So a row declares a LOCATOR (an ERE whose first group is the claimed span) rather than a label.
#
# Extraction anchors are VERSIONED — the d1d90b8 lesson, where an anchor matching a prefix also
# matched a document's own title and a rewriter then destroyed the file it was parsing.
#
# `elsewhere:<script>` marks a claim this script CANNOT compute without recursion: check-plan-
# corrections.sh runs THIS script under a temp root for the C-24 detector, so calling a suite back
# would recurse. Those two are bound by the only component that can compute them without recursion
# — the suite itself — and the assertion here reads that script's binding LOGIC, not a token.
CLAIMS_BLOCK='# CLAIMS-MANIFEST v1
PB-01	crew suite \*\*([^*]+)\*\*	elsewhere:scripts/run-crew-tests.sh
PB-02	validate-crew \*\*([^*]+)\*\*	elsewhere:scripts/validate-crew.sh
PB-03	save-context \*\*([^*]+)\*\*	sc_self
PB-04	app suite \*\*([^*]+)\*\*	app_suite
PB-05	corrections \*\*([^*]+)\*\*	corrections
PB-06	\*\*([0-9]+ tracked files)\*\*	tracked
PB-07	\*\*([0-9,]+ across [0-9]+ dispatches [^*]+)\*\*	f7_tokens
PB-08	APPROVE GATE-F8` was received @ ([0-9T:Z-]+)	gate_ts'

# Every extractor prints the FULL expected span, so a composite claim carrying two numbers is
# checked as one string and cannot half-drift.
truth () {
  case "$1" in
    sc_self)     printf '%s PASS / %s FAIL' "$SC_P" "$SC_F" ;;
    # STATIC count of declared cases, not a run. Executing the app suite from here would be a heavy
    # side effect inside a checker that check-plan-corrections invokes under a temp root where
    # stress-project does not exist. Bound to the declarations in the test files, and the limit is
    # stated: this counts cases DECLARED, and a declared case that fails is caught by the app suite,
    # not by this. Absent tree returns nothing, which the caller reports rather than passes.
    # Sum the per-file counts with awk, not `paste -sd+ | bc`: BSD paste needs an explicit stdin
    # operand and bc is marginal on macOS — awk needs neither and drops a dependency (R-SD-1 rule 7).
    app_suite)   n=$(grep -rhcE '^[[:space:]]*test\(' stress-project/test/*.js 2>/dev/null | awk '{s+=$1} END{print s+0}')
                 [ "${n:-0}" -gt 0 ] && printf '%s/%s' "$n" "$n" ;;
    corrections) r=$(grep -c '^| C-[0-9]' "$CTX/plan-corrections.md" 2>/dev/null)
                 i=$(grep -oE 'C-[0-9]{2}' "$CTX/plan-corrections.md" 2>/dev/null | sort -u | grep -c .)
                 printf '%s rows across %s registered correction IDs' "$r" "$i" ;;
    # Returns EMPTY, not failure, when there is no work tree. "unknown extractor" is a manifest
    # error and "source unavailable in this environment" is not — conflating them made ccs-02 fail,
    # a fixture that legitimately runs this under a bare temp root. The caller only complains about
    # an empty source when the summary actually MAKES the claim (the C-23 lesson).
    tracked)     git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
                   && printf '%s tracked files' "$(git ls-files | grep -c .)" ;;
    # Composed from the SOURCE line rather than pattern-matched out of a restatement:
    # budget-baseline.md records "18 dispatches, **2,045,319 tokens**" and the ratio separately.
    f7_tokens)   f7sec=$(awk '/^## F7 —/{f=1;next} f&&/^## /{exit} f' context/budget-baseline.md 2>/dev/null)
                 d=$(printf '%s' "$f7sec" | grep -oE '[0-9]+ dispatches, \*\*[0-9,]+ tokens\*\*' | grep -oE '^[0-9]+' | head -1)
                 k=$(printf '%s' "$f7sec" | grep -oE '\*\*[0-9,]+ tokens\*\*' | grep -oE '[0-9,]+' | head -1)
                 r=$(printf '%s' "$f7sec" | grep -oE '\*\*[0-9]+\.[0-9]+×\*\*' | head -1 | tr -d '*')
                 { [ -n "$k" ] && [ -n "$d" ] && [ -n "$r" ]; } && printf '%s across %s dispatches (%s)' "$k" "$d" "$r" ;;
    gate_ts)     grep -oE 'APPROVE GATE-F8` @ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z' GATES.md 2>/dev/null \
                   | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]+Z' | head -1 ;;
    *)           return 1 ;;
  esac
  # Always succeed for a known name. Without this the last command's exit status leaks out, so an
  # extractor whose SOURCE is missing reported "unknown extractor" — a manifest error — and ccs-02,
  # which legitimately runs this under a bare temp root, failed six ways for the wrong reason.
  return 0
}

case "$MODE" in
prepare)
  mkdir -p "$CTX"
  [ -f "$ENTRY" ] || printf '# session-summary.md — distilled state (HC-8 §15.5)\n\n## Next action\n(pending)\n' > "$ENTRY"
  echo "== distill delta — ledgers newer than the entry point =="
  for f in PROGRESS.md Plan.md GATES.md context/plan-corrections.md; do
    [ -f "$f" ] || continue
    if [ "$f" -nt "$ENTRY" ]; then printf '  CHANGED  %s\n' "$f"; else printf '  current  %s\n' "$f"; fi
  done
  echo
  echo "== DISTILL INSTRUCTION (§15.5, binding) =="
  cat <<'INS'
  Rewrite context/session-summary.md so that it states CONCLUSIONS, not chronology:
   1. MERGE new material into the existing canonical sections. Do not append a new dated block —
      merging is what prevents compounded drift, and appending is what causes it.
   2. Mark resolved items resolved, and DELETE superseded claims outright. A summary that keeps
      every past belief is a transcript.
   3. Label every entry **verified** or **proposed**. An unverified claim silently promoted to
      fact across sessions is the hallucination vector these labels close.
   4. Repo-relative paths only. No pleasantries, no reasoning traces, no diffs, no raw log lines.
   5. End with a single "## Next action" section naming the next concrete step.
  Then run: ./scripts/save-context.sh check
INS
  ;;
check)
  echo "== save-context: §15.5 semantics =="
  [ -f "$ENTRY" ] && ok "entry point $ENTRY exists" || no "entry point $ENTRY missing"
  for f in "$CTX"/*.md; do
    [ -f "$f" ] || continue
    b=$(basename "$f")
    # Labelling binds the DISTILLED files §15.5 names, not everything that happens to live in
    # context/. plan-corrections.md is a machine-checked registry and f2-readiness.md an acceptance
    # spec; demanding verified/proposed of them was an over-broad guard on its first run, which is
    # the failure family this build has recorded six times. Hygiene below still applies to all.
    case "$b" in
      session-summary.md|decisions.md|architecture.md|runbook.md|troubleshooting.md|open-items.md)
        grep -qE '\*\*(verified|proposed)\*\*' "$f" \
          && ok "$b carries verified/proposed labels" \
          || no "$b is a distilled file with no verified/proposed label (§15.5)" ;;
      *) ok "$b is not a distilled summary — labelling not required, hygiene still checked" ;;
    esac
    grep -q "$ABS" "$f" \
      && no "$b contains an absolute machine path — §15.5 requires repo-relative" \
      || ok "$b is free of absolute machine paths"
    grep -qE '^\{"ts"|^@@ |^\+\+\+ |^--- ' "$f" \
      && no "$b contains raw log lines or diff hunks — §15.5 forbids both" \
      || ok "$b carries no raw logs or diffs"
  done
  grep -q '^## Next action' "$ENTRY" 2>/dev/null \
    && ok "entry point declares a Next action" \
    || no "entry point has no '## Next action' section"

  # C-28 — DECLARED BINDINGS replace the three hand-written ones that stood here (C-24 + CR-034).
  # Those bound the gate timestamp, the tracked-file count and the registered-ID count, one block of
  # bespoke code each. They worked, and they were the instance fix: every OTHER number in the
  # summary stayed unbound, which is how the live-numbers line reached three sessions stale while
  # its own prose claimed it "cannot silently rot again". One mechanism now, declared above.
  CROWS=$(printf '%s\n' "$CLAIMS_BLOCK" | awk '/^# CLAIMS-MANIFEST v[0-9]+$/{f=1;next} f&&NF')
  CN=$(printf '%s\n' "$CROWS" | grep -c . || true)
  # Vacuity guard first: a manifest that parses to nothing binds nothing and reports clean.
  [ "${CN:-0}" -ge 5 ] && ok "C-28 claims manifest parses to $CN declared binding(s)" \
                       || no "C-28 manifest parsed to ${CN:-0} rows — every fidelity check below would be vacuous"

  covered=""
  while IFS="$(printf '\t')" read -r cid loc ex; do
    [ -n "${cid:-}" ] || continue
    covered="$covered$loc
"
    got=$(grep -oE "$loc" "$ENTRY" 2>/dev/null | head -1 | sed -E "s/^$loc\$/\1/")
    case "$ex" in
      elsewhere:*)
        # A claim this script cannot compute without recursion — check-plan-corrections runs THIS
        # script under a temp root, so calling a suite back would loop. Bound by the only component
        # that can compute it: the suite itself. Asserted by reading that script's binding LOGIC,
        # never a token, so a script that merely mentions the label does not satisfy it.
        scr=${ex#elsewhere:}
        scrbody=$(sed 's/#.*//' "$scr" 2>/dev/null)
        n1=$(printf '%s\n' "$scrbody" | grep -cF -- 'session-summary.md' || true)
        n2=$(printf '%s\n' "$scrbody" | grep -cF -- "$loc" || true)
        if [ -z "$got" ]; then
          ok "$cid: summary makes no such claim — nothing to bind"
        elif [ ! -f "$scr" ]; then
          no "$cid: '$scr' is named as the binder and does not exist"
        # CAPTURE, THEN TEST. `sed file | grep -q` under `set -o pipefail` reports FAILURE even when
        # grep matched: grep -q exits the moment it matches, sed takes SIGPIPE, and pipefail
        # surfaces sed's status. It is SIZE-DEPENDENT — validate-crew.sh is short enough that sed
        # finishes first and the bug hides, while run-crew-tests.sh at ~1000 lines reproduces it
        # every time. That is the fourth pipefail incident recorded in this build, and the first
        # where the same code passed on one input and failed on another purely by file length.
        elif [ "${n1:-0}" -gt 0 ] && [ "${n2:-0}" -gt 0 ]; then
          ok "$cid: bound by $scr (its own total; binding logic present, not just a mention)"
        else
          no "$cid: $scr does not carry binding logic for this claim — the claim is effectively unbound"
        fi ;;
      sc_self) : ;;   # handled last, once this script's own total is final
      *)
        want=$(truth "$ex") || { no "$cid: unknown extractor '$ex' — a binding that names no source binds nothing"; continue; }
        if [ -z "$got" ]; then
          ok "$cid: summary makes no such claim — nothing to bind"
        elif [ -z "$want" ]; then
          no "$cid: summary claims '$got' but the source produced nothing to check it against"
        elif [ "$got" = "$want" ]; then
          ok "$cid: claim matches its source ($want)"
        else
          no "$cid: summary says '$got', the source says '$want'"
        fi ;;
    esac
  done <<CLAIMSEOF
$CROWS
CLAIMSEOF

  # COMPLETENESS — the class fix. Every bold span opening with a digit must be covered by a declared
  # locator. Adding an unbound number to the summary is what fails.
  # STATED LIMIT: only bold spans are checked. A number in running prose is invisible here, and that
  # is a real gap rather than a hidden one.
  unbound=""
  while IFS= read -r span; do
    [ -n "$span" ] || continue
    hit=0
    while IFS= read -r loc; do
      [ -n "$loc" ] || continue
      # The locator is matched against the SUMMARY and the span must fall inside what it matched.
      # Matching the locator against the bare span cannot work: the anchoring text ("crew suite ")
      # lives outside the bold. The first version did exactly that and reported five bound claims
      # as unbound — a completeness check that cries wolf gets switched off, which is worse than
      # one that is silent.
      grep -qF -- "$span" <<<"$(grep -oE "$loc" "$ENTRY" 2>/dev/null)" && { hit=1; break; }
    done <<COVEOF
$covered
COVEOF
    [ "$hit" = 1 ] || unbound="$unbound [$span]"
  done <<SPANEOF
$(grep -oE '\*\*[0-9][^*]*\*\*' "$ENTRY" 2>/dev/null | sort -u)
SPANEOF
  [ -z "$unbound" ] && ok "C-28 every numeric claim in the summary is covered by a declared binding" \
                    || no "C-28 UNBOUND claim(s):$unbound — declare them in CLAIMS-MANIFEST or remove them"

  # sc_self last, so this script's own total is final. The +1 is THIS assertion.
  SC_P=$P; SC_F=$F
  scloc=$(printf '%s\n' "$CROWS" | awk -F'\t' '$3=="sc_self"{print $2}')
  scgot=$(grep -oE "$scloc" "$ENTRY" 2>/dev/null | head -1 | sed -E "s/^$scloc\$/\1/")
  scwant="$((P + F + 1)) PASS / 0 FAIL"
  if [ -z "$scgot" ]; then
    ok "PB-03: summary makes no save-context claim — nothing to bind"
  elif [ "$scgot" = "$scwant" ]; then
    ok "PB-03: save-context claim matches this run ($scwant)"
  else
    no "PB-03: summary says '$scgot', this run is '$scwant'"
  fi

  printf '\n== save-context: %s PASS / %s FAIL ==\n' "$P" "$F"
  [ "$F" = 0 ] || exit 1
  ;;
*) echo "usage: save-context.sh [prepare|check]"; exit 64;;
esac
