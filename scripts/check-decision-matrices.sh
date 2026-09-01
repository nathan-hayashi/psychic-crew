#!/usr/bin/env bash
# check-decision-matrices.sh — the H3b standalone decision-matrix suite (D24).
#
# Subject: docs/audit/DECISION_MATRICES.md, a DATED record (CR-033: its figures were read off disk
# on 2026-08-20 and are not maintained). The suite therefore has TWO verdict planes and never
# confuses them:
#   FAIL  — structural breakage only: the record does not parse, a cited parent-side artifact is
#           gone, the census meets an unclassified corpus directory, or an extraction is vacuous.
#   NOTE  — a dated figure that today's artifacts no longer match. Dated records legitimately
#           diverge; the reader's hazard is not knowing WHICH rows still describe the present.
#           Notes are the product, not a defect.
#
# Why it exists (H3b, queued since S6, re-homed by R-CH-1): the matrices exist so "a reader can
# act from them" — their own stated purpose. M6 already answers every one of its rows differently
# than it did on its date; without this suite a reader acts on 2026-08-20.
#
# Census law (M4, binding): "do not read further without a named question." Section C carries the
# corpus classification as DATA, both directions: a directory on disk that the table does not
# classify FAILS by name (tomorrow's drop is caught on arrival), and a classified directory
# missing from disk FAILS by name (the census cannot silently describe a corpus that left).
#
# Deliberately NOT done, stated: no cross-repo assertion (Lite-facing matrix rows are reported as
# prose, never asserted — the parent suite has never depended on the twin's checkout and does not
# start here); no invocation of check-plan-corrections.sh (its C-21 detector executes the metrics
# generator — the registered H2a loop — so M2's "rows the checker reports" quantity is NOT
# re-derived live and that limit is stated in section B's output).
#
# Own code obeys R-SD-1 v2: capture-then-validate, no count-then-default composite, no
# status-consumed pipeline with a signal-able producer.
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; F=0; N=0
pass () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
fail () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }
note () { N=$((N+1)); printf '  [NOTE] %s\n' "$1"; }

DM="docs/audit/DECISION_MATRICES.md"

echo "== A. structure — the record parses and still says what a matrix must say =="
if [ ! -f "$DM" ]; then
  fail "$DM is missing — nothing below can run"
  printf '\n== check-decision-matrices: %s PASS / %s FAIL / %s NOTED ==\n' "$P" "$F" "$N"
  exit 1
fi
mh=$(grep -cE '^## M[1-6] ' "$DM")
case "$mh" in ''|*[!0-9]*) mh=0 ;; esac
[ "$mh" = 6 ] && pass "all six matrix headings present" \
              || fail "expected 6 matrix headings, found $mh — the record's shape changed"
dm_dec=$(grep -ciE 'decision' "$DM")
case "$dm_dec" in ''|*[!0-9]*) dm_dec=0 ;; esac
[ "$dm_dec" -ge 6 ] && pass "decision language present throughout ($dm_dec sites) — these are aids, not tables" \
                    || fail "decision language nearly absent ($dm_dec sites) — the file's own contract is a decision column"
grep -qF 'do not read further without a named question' "$DM" \
  && pass "M4's reading law is present verbatim (the census below enforces its perimeter)" \
  || fail "M4's reading law is missing — the census below would enforce a rule the record no longer states"

echo "== B. M2 — the registry, re-derived live against the dated figures =="
reg="context/plan-corrections.md"
ids=$(grep -oE 'C-[0-9]{2}' "$reg" 2>/dev/null | sort -u | grep -c .)
rows=$(grep -c '^| C-[0-9]' "$reg" 2>/dev/null)
case "$ids"  in ''|*[!0-9]*) ids=0  ;; esac
case "$rows" in ''|*[!0-9]*) rows=0 ;; esac
[ "$ids" -ge 20 ] && pass "registry parses non-vacuously ($ids distinct IDs)" \
                  || fail "registry extraction vacuous ($ids IDs) — every comparison here would be trivially clean"
[ "$ids" = "$rows" ] && pass "index rows equal registered IDs ($rows/$ids) — the PB-05 invariant holds independently" \
                     || fail "index rows ($rows) diverge from registered IDs ($ids) — the registry's own index is stale again"
m2dated=$(grep -oE '\| Registered IDs in `plan-corrections.md` \| \*\*[0-9]+\*\*' "$DM" | grep -oE '[0-9]+')
case "$m2dated" in ''|*[!0-9]*) m2dated=0 ;; esac
if [ "$m2dated" = 0 ]; then
  fail "M2's dated registered-ID figure could not be extracted — the comparison below is vacuous"
elif [ "$m2dated" = "$ids" ]; then
  pass "M2's registered-ID figure still matches the live registry ($ids)"
else
  note "M2 is dated: it counted $m2dated registered IDs on 2026-08-20; the registry holds $ids today (C-26..C-28 landed after). CR-033 — the record is right about its date, not about today."
fi
note "M2's 'rows the checker reports' quantity is NOT re-derived here: doing so would execute check-plan-corrections.sh, whose C-21 detector runs the metrics generator (the registered H2a loop). Stated limit, not an oversight."

echo "== C. M4 census — every corpus directory classified, both directions =="
# The classification is DATA, maintained here the way FIXTURE_IDS is: a new drop must be added
# deliberately or this fails by name. Statuses (CORPUS-0 four-value vocabulary, ratified by that
# gate's token): ETL-BUILD (consumed at build under §11) · DIVED (targeted dive done) · QUEUED
# (a named question stands in docs/research/CORPUS-0-coverage.md; its dive gate discharges it) ·
# PROHIBITED (reads barred by standing law; NEVER on disk — the ABSENCE is the assertion).
# BARRED is retired: it conflated no-question-yet with the absolute prohibition.
CENSUS='turbo	ETL-BUILD
claude-agent-orchestration-guide	ETL-BUILD
mermaid-hybrid-stack-guide	ETL-BUILD
neatcontext-plugins	ETL-BUILD
open-code-review	ETL-BUILD
gastown	DIVED
ruflo	DIVED
oh-my-claudecode	DIVED
orca	DIVED
babysitter	QUEUED
agent-framework	QUEUED
takt	QUEUED
conductor	QUEUED
zeroshot	DIVED
OpenHands	QUEUED
langgraph	QUEUED
claude-agent-sdk-python	QUEUED
automation-ecosystem	PROHIBITED'
cen_n=$(printf '%s\n' "$CENSUS" | grep -c .)
[ "$cen_n" -ge 10 ] && pass "census table parses to $cen_n classifications (vacuity guard)" \
                    || fail "census table vacuous ($cen_n rows)"
unclass=""
for d in *-main; do
  [ -d "$d" ] || continue
  base=${d%-main}
  hit=$(printf '%s\n' "$CENSUS" | grep -cF "$base	")
  case "$hit" in ''|*[!0-9]*) hit=0 ;; esac
  [ "$hit" -ge 1 ] || unclass="$unclass [$d]"
done
[ -z "$unclass" ] && pass "every corpus directory on disk is classified — a new drop fails here by name" \
                  || fail "UNCLASSIFIED corpus director(ies) on disk:$unclass — M4's law has no verdict for them yet"
gone=""; prohpresent=""
while IFS="$(printf '\t')" read -r nm st; do
  [ -n "${nm:-}" ] || continue
  if [ "${st:-}" = "PROHIBITED" ]; then
    [ -d "${nm}-main" ] && prohpresent="$prohpresent [$nm]"
    continue
  fi
  [ -d "${nm}-main" ] || gone="$gone [$nm]"
done <<CENEOF
$CENSUS
CENEOF
[ -z "$gone" ] && pass "every classified directory is on disk — the census describes the corpus that exists" \
               || fail "classified director(ies) missing from disk:$gone"
[ -z "$prohpresent" ] && pass "PROHIBITED corpora are ABSENT from disk — the prohibition is machine-visible and holding" \
                      || fail "PROHIBITED corpus present on disk:$prohpresent — the standing law is breached"
note "H3b deep-dive closure, SUPERSEDED AT CORPUS-0: that closure held exactly while no question was named. CORPUS-0 NAMED the eight (docs/research/CORPUS-0-coverage.md, CORPUS-QUESTIONS v1) under M4's own law — question first, reading second — so the eight rows are QUEUED for their dive gates, not closed. The three S6 dives are promoted to docs/research/S6-*.md verbatim; the PROHIBITED row is closed by LAW (reads barred estate-wide, absence asserted above), never by absence of questions."


echo "== C2. CORPUS-0 — coverage table + questions, bound both directions =="
COVDOC="docs/research/CORPUS-0-coverage.md"
if [ ! -f "$COVDOC" ]; then
  fail "coverage doc missing: $COVDOC"
else
  cov=$(awk '/^# CORPUS-COVERAGE v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$COVDOC")
  covn=$(printf '%s\n' "$cov" | grep -c .); case "$covn" in ''|*[!0-9]*) covn=0 ;; esac
  cenn=$(printf '%s\n' "$CENSUS" | grep -c .)
  [ "$covn" -eq "$cenn" ] && pass "coverage rows ($covn) == census rows ($cenn)" \
    || fail "coverage/census row mismatch: $covn vs $cenn"
  covpair=$(printf '%s\n' "$cov" | awk -F'\t' '{print $1 "\t" $2}' | sort)
  cenpair=$(printf '%s\n' "$CENSUS" | sort)
  [ "$covpair" = "$cenpair" ] && pass "coverage (name,status) pairs == census, set-equal both ways" \
    || fail "coverage/census divergence: $(comm -3 <(printf '%s\n' "$covpair") <(printf '%s\n' "$cenpair") | head -2 | tr '\n' ' ')"
  covbad=""
  while IFS="$(printf '\t')" read -r cnm cst ctier cdis; do
    [ -n "${cnm:-}" ] || continue
    case "${cdis:-}" in
      CORPUS-ZEROSHOT|CORPUS-OPENHANDS|CORPUS-CONDUCTOR|CORPUS-SDKPY|CORPUS-TAKT|CORPUS-LANGGRAPH|CORPUS-AGENTFW|CORPUS-DELTA|CORPUS-0|RSCH-4|F6|PROHIBITED-BY-LAW) : ;;
      CORPUS-BABYSITTER-1+CORPUS-BABYSITTER-2) : ;;
      *) covbad="$covbad [$cnm:$cdis]" ;;
    esac
  done <<COVEOF
$cov
COVEOF
  [ -z "$covbad" ] && pass "every discharge is a named gate or the one exemption (no row can dangle)" \
    || fail "unknown discharge(s):$covbad"
  qs=$(awk '/^# CORPUS-QUESTIONS v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$COVDOC")
  qn=$(printf '%s\n' "$qs" | grep -c .); case "$qn" in ''|*[!0-9]*) qn=0 ;; esac
  qexp=$(printf '%s\n' "$CENSUS" | awk -F'\t' '$2=="QUEUED"' | grep -c .)
  case "$qexp" in ''|*[!0-9]*) qexp=0 ;; esac
  [ "$qn" -eq "$qexp" ] && pass "one named question per QUEUED row ($qn == $qexp; discharged questions live in their dive docs)" \
    || fail "question rows $qn != QUEUED rows $qexp"
  qnames=$(printf '%s\n' "$qs" | cut -f1 | sort)
  queued=$(printf '%s\n' "$CENSUS" | awk -F'\t' '$2=="QUEUED"{print $1}' | sort)
  [ "$qnames" = "$queued" ] && pass "questions <-> QUEUED rows, set-equal both ways (no unquestioned QUEUED, no phantom question)" \
    || fail "question/QUEUED divergence: $(comm -3 <(printf '%s\n' "$qnames") <(printf '%s\n' "$queued") | tr '\n' ' ')"
  for pd in S6-gastown S6-ruflo S6-oh-my-claudecode; do
    [ -f "docs/research/$pd.md" ] && pass "promotion doc exists: $pd (the CORPUS-0 discharge is an artifact, not a claim)" \
      || fail "promotion doc MISSING: $pd — the promoted rows would discharge against nothing"
  done
  covp=$(mktemp)
  { printf '%s\n' "$cov"; printf 'phantom-corpus\tQUEUED\tfull\tCORPUS-PHANTOM\n'; } > "$covp"
  covp2=$(awk -F'\t' '{print $1 "\t" $2}' "$covp" | sort)
  [ "$covp2" != "$cenpair" ] && pass "control fires: a phantom coverage row breaks census agreement" \
    || fail "coverage control DID NOT fire"
  rm -f "$covp"
fi

echo "== D. M5 — dispatch economics, re-derived from the live TSV =="
tsv="logs/metrics/dispatch-costs.tsv"
if [ ! -f "$tsv" ]; then
  pass "TSV absent (gitignored, expected in a clone/extract) — M5 re-derivation not checkable here, announced"
else
  m5rows=$(grep -cE '^\| `[a-z-]+` \| [0-9]+ \| [0-9,]+ \| [0-9,]+ \|' "$DM")
  case "$m5rows" in ''|*[!0-9]*) m5rows=0 ;; esac
  [ "$m5rows" -ge 5 ] && pass "M5 parses to $m5rows role rows (vacuity guard)" \
                      || fail "M5 extraction vacuous ($m5rows rows)"
  m5div=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    role=$(printf '%s' "$line" | sed -E 's/^\| `([a-z-]+)`.*/\1/')
    dn=$(printf '%s' "$line" | awk -F'|' '{gsub(/[ ,]/,"",$3); print $3}')
    dt=$(printf '%s' "$line" | awk -F'|' '{gsub(/[ ,]/,"",$5); print $5}')
    ln=$(awk -F'\t' -v r="$role" '$1==r{n++} END{print n+0}' "$tsv")
    lt=$(awk -F'\t' -v r="$role" '$1==r{t+=$3} END{print t+0}' "$tsv")
    if [ "$dn" = "$ln" ] && [ "$dt" = "$lt" ]; then :
    else m5div=$((m5div+1)); note "M5 dated for $role: recorded n=$dn total=$dt, live TSV has n=$ln total=$lt"; fi
  done <<M5EOF
$(grep -E '^\| `[a-z-]+` \| [0-9]+ \| [0-9,]+ \| [0-9,]+ \|' "$DM")
M5EOF
  [ "$m5div" = 0 ] && pass "all $m5rows M5 role rows still match the live TSV — the crew-role economics have not moved since the audit" \
                   || pass "M5 compared row-by-row; $m5div dated divergence(s) noted above, none a failure (CR-033)"
fi

echo "== E. M6 — the open-items matrix, answered by today's ledger =="
# Every re-derivation here is parent-side. M6's value today is exactly its age.
e_ok=0
crv=$(sed 's/#.*//' scripts/run-crew-tests.sh 2>/dev/null | grep -c 'CR-003')
case "$crv" in ''|*[!0-9]*) crv=0 ;; esac
if [ "$crv" -ge 2 ]; then
  note "M6 says CR-003 'stays deferred' — its spec half was DELIVERED 2026-08-21 (the suite carries $crv live CR-003 sites); only the renderer half remains deferred (H1b, scoped at D23)"
  e_ok=$((e_ok+1))
fi
if [ -f docs/metrics-snapshot.json ]; then
  note "M6 says CR-006 'move data to context/ first' — closed differently at GUARD-1/H2a: a TRACKED snapshot beside a url-backed spec, asserted every run"
  e_ok=$((e_ok+1))
fi
cr27=$(sed 's/#.*//' scripts/validate-crew.sh 2>/dev/null | grep -c 'CR-027')
case "$cr27" in ''|*[!0-9]*) cr27=0 ;; esac
if [ "$cr27" -ge 1 ]; then
  note "M6 says CR-027 'do it when convenient' — done, and generalised into live bindings (README counts bound every run)"
  e_ok=$((e_ok+1))
fi
note "M6's Lite rows (GATE-L0 readiness, the correlation map) are cross-repo and reported as prose only: the twin built through L4 and its security phase — see the parent GATES rows from LITE onward for the parent-side record"
[ "$e_ok" -ge 3 ] && pass "M6 re-derivation non-vacuous: $e_ok of its parent-side rows answered from today's artifacts" \
                  || fail "M6 re-derivation vacuous ($e_ok rows) — the mechanism, not the record, is broken"

echo "== F. M1/M3 — cited parent-side artifacts still exist; the two 'partial' risks, revisited =="
f_missing=""
for a in scripts/validate-crew.sh scripts/apply-models.sh scripts/save-context.sh hooks/model-guard.sh hooks/bash-blocker.sh hooks/reference-cap.sh; do
  [ -f "$a" ] || f_missing="$f_missing [$a]"
done
[ -z "$f_missing" ] && pass "every parent-side enforcement artifact M1 cites is on disk" \
                    || fail "M1-cited artifact(s) gone:$f_missing"
c28m=$(awk '/CLAIMS-MANIFEST v[0-9]+$/{f=1;next} f&&/^PB-[0-9]/{n++} END{print n+0}' scripts/save-context.sh 2>/dev/null)
case "$c28m" in ''|*[!0-9]*) c28m=0 ;; esac
if [ "$c28m" -ge 5 ]; then
  note "M3's 'partial — 3 claims of many' fidelity row is dated: C-28 replaced the three hand bindings with a declared manifest of $c28m rows plus a completeness check that FAILS on any unbound bold number"
  pass "the fidelity partial-risk row has a live successor mechanism ($c28m manifest rows)"
else
  fail "the C-28 manifest did not parse ($c28m rows) — M3's fidelity risk row has regressed toward its dated state"
fi
d2c=$(sed 's/#.*//' scripts/run-crew-tests.sh 2>/dev/null | grep -c 'd2cfg')
case "$d2c" in ''|*[!0-9]*) d2c=0 ;; esac
[ "$d2c" -ge 2 ] && note "M3's 'well-formed, never true' diagram row is narrower than written: the d2 topology has been bound to settings.json both directions since CR-003 landed — every OTHER diagram still passes on structure alone, exactly as M3 warns" \
                 || fail "the d2 binding logic is gone from the suite — M3's diagram risk row has fully reopened"

printf '\n== check-decision-matrices: %s PASS / %s FAIL / %s NOTED (notes are dated divergences, kept per CR-033) ==\n' "$P" "$F" "$N"
[ "$F" = 0 ] || exit 1
