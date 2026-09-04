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
#   Since GAP-REGISTER-1 (the vector program) the same two planes govern the LIVING registers
#   this suite hosts (section G onward): FAIL stays structural-only, NOTE stays dated-divergence.
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
_sha256 () { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1; fi; }

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
babysitter	DIVED
agent-framework	DIVED
takt	DIVED
conductor	DIVED
zeroshot	DIVED
OpenHands	DIVED
langgraph	DIVED
claude-agent-sdk-python	DIVED
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
  tierbad=$(printf '%s\n' "$cov" | awk -F'\t' '{print $3}' | grep -vE '^(full|full-split|delta|promoted|done|exempt)$' | grep -c .)
  case "$tierbad" in ''|*[!0-9]*) tierbad=0 ;; esac
  [ "$tierbad" = 0 ] && pass "tier column vocabulary legal, all rows (GAP-REGISTER-1 closed the unvalidated column)" \
    || fail "off-vocabulary tier value(s): $tierbad row(s)"
  arl=$(grep -A1 -E '[0-9]+ full \+' "$COVDOC" | head -2 | tr '\n' ' ')
  if [ -z "$arl" ]; then
    fail "the coverage arithmetic line is gone — the tier re-derivation has nothing to bind"
  else
    a_f=$(printf '%s' "$arl" | sed -E 's/.*: ([0-9]+) full \+.*/\1/')
    a_s=$(printf '%s' "$arl" | sed -E 's/.* ([0-9]+) full-split.*/\1/')
    a_d=$(printf '%s' "$arl" | sed -E 's/.* ([0-9]+) delta.*/\1/')
    a_p=$(printf '%s' "$arl" | sed -E 's/.* ([0-9]+) promoted.*/\1/')
    a_n=$(printf '%s' "$arl" | sed -E 's/.* ([0-9]+) done.*/\1/')
    a_x=$(printf '%s' "$arl" | sed -E 's/.* ([0-9]+) prohibited-exempt.*/\1/')
    t_f=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="full"' | grep -c .)
    t_s=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="full-split"' | grep -c .)
    t_d=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="delta"' | grep -c .)
    t_p=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="promoted"' | grep -c .)
    t_n=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="done"' | grep -c .)
    t_x=$(printf '%s\n' "$cov" | awk -F'\t' '$3=="exempt"' | grep -c .)
    if [ "$t_f" = "$a_f" ] && [ "$t_s" = "$a_s" ] && [ "$t_d" = "$a_d" ] && [ "$t_p" = "$a_p" ] && [ "$t_n" = "$a_n" ] && [ "$t_x" = "$a_x" ]; then
      pass "tier arithmetic re-derived: fence counts ($t_f/$t_s/$t_d/$t_p/$t_n/$t_x) == the doc's own roll-up line"
    else
      fail "tier arithmetic divergence: fence $t_f/$t_s/$t_d/$t_p/$t_n/$t_x vs prose $a_f/$a_s/$a_d/$a_p/$a_n/$a_x"
    fi
  fi
  tp=$(mktemp)
  { printf '%s\n' "$cov"; printf 'phantom-tier\tQUEUED\tbogus\tCORPUS-PHANTOM\n'; } > "$tp"
  tpc=$(awk -F'\t' '{print $3}' "$tp" | grep -vcE '^(full|full-split|delta|promoted|done|exempt)$')
  case "$tpc" in ''|*[!0-9]*) tpc=0 ;; esac
  [ "$tpc" -ge 1 ] && pass "control fires: a planted off-vocabulary tier is seen by the legality scan" \
    || fail "tier control DID NOT fire"
  rm -f "$tp"
fi


echo "== C5. BASE-2 matrix — shape, vocabulary, roll-up agreement (arc 3) =="
B2="docs/research/BASE-2-comparison.md"
if [ ! -f "$B2" ]; then
  fail "BASE-2 doc missing: $B2"
else
  b2m=$(awk '/^# BASE-2-MATRIX v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$B2")
  b2n=$(printf '%s\n' "$b2m" | grep -c .); case "$b2n" in ''|*[!0-9]*) b2n=0 ;; esac
  [ "$b2n" -eq 4 ] && pass "BASE-2 matrix carries exactly 4 candidate rows" \
    || fail "BASE-2 matrix rows $b2n != 4 (the contract forbids adding or dropping)"
  b2bad=$(printf '%s\n' "$b2m" | awk -F'\t' 'NF!=6 {print $1" (cols "NF")"}')
  [ -z "$b2bad" ] && pass "every BASE-2 row carries exactly 5 axis cells" \
    || fail "BASE-2 row shape broken: $(tr '\n' ' ' <<<"$b2bad")"
  b2voc=$(printf '%s\n' "$b2m" | cut -f2-6 | tr '\t' '\n' | sort -u | grep -vxF 'OURS' | grep -vxF 'THEIRS' | grep -vxF 'TIE' | grep -vxF 'NOT-COMPARABLE-DOCUMENTED-ONLY')
  [ -z "$b2voc" ] && pass "every cell uses the four-value verdict vocabulary exactly" \
    || fail "BASE-2 off-vocabulary cell value(s): $(tr '\n' ' ' <<<"$b2voc")"
  b2r=$(awk '/^# BASE-2-ROLLUP v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$B2")
  b2err=""
  for v in OURS THEIRS TIE NOT-COMPARABLE-DOCUMENTED-ONLY; do
    claimed=$(printf '%s\n' "$b2r" | awk -F'\t' -v k="$v" '$1==k{print $2}')
    case "$claimed" in ''|*[!0-9]*) claimed=-1 ;; esac
    actual=$(printf '%s\n' "$b2m" | cut -f2-6 | tr '\t' '\n' | grep -cxF "$v")
    case "$actual" in ''|*[!0-9]*) actual=0 ;; esac
    [ "$claimed" -eq "$actual" ] || b2err="$b2err [$v: rollup $claimed vs cells $actual]"
  done
  [ -z "$b2err" ] && pass "roll-up agrees with the cells for all four verdict values" \
    || fail "BASE-2 roll-up disagreement:$b2err"
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


echo "== G. GAP-REGISTER — the open-items register, both directions =="
# The living successor of M6's open-items matrix (E above answers a dated record; G binds the
# register that replaced the scatter). Two planes as declared in the header: FAIL is structural,
# NOTE is a dated or advisory figure. The register's own header states its honest bound: ~85% of
# rows are census-authored and unbound by this FAIL plane — the declared-source manifest below is
# the bound minority, re-extracted live each run.
GR="docs/research/GAP-REGISTER.md"
if [ ! -f "$GR" ]; then
  fail "register missing: $GR — nothing in G can run"
else
  grt=$(awk '/^# GAP-REGISTER v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$GR")
  grn=$(printf '%s\n' "$grt" | grep -c .); case "$grn" in ''|*[!0-9]*) grn=0 ;; esac
  [ "$grn" -ge 35 ] && pass "vacuity floor: $grn register rows (>=35; completeness is the dated header claim, not this floor)" \
    || fail "register vacuous: $grn rows"
  grbad=$(printf '%s\n' "$grt" | awk -F'\t' 'NF!=9{c++} END{print c+0}')
  [ "$grbad" = 0 ] && pass "every row is exactly 9 tab-separated fields (tab-free prose by construction)" \
    || fail "$grbad row(s) with wrong field count"
  grdup=$(printf '%s\n' "$grt" | cut -f1 | sort | uniq -d | tr '\n' ' ')
  [ -z "$grdup" ] && pass "ids unique" || fail "duplicate id(s): $grdup"
  gridb=$(printf '%s\n' "$grt" | cut -f1 | grep -vcE '^GR-[0-9]{3}$')
  case "$gridb" in ''|*[!0-9]*) gridb=0 ;; esac
  [ "$gridb" = 0 ] && pass "id format GR-nnn holds" || fail "$gridb malformed id(s)"
  grcb=$(printf '%s\n' "$grt" | cut -f2 | grep -vcE '^(security-residual|dispatch-residual|verification-gap|parked-wake|operator-blocked|open-question|portability|uncertainty-marker|unrecoverable|declined-disclosed|ruling|chronicle|lite|sidekick)$')
  case "$grcb" in ''|*[!0-9]*) grcb=0 ;; esac
  [ "$grcb" = 0 ] && pass "class vocabulary legal (14 ratified values)" || fail "$grcb off-vocabulary class value(s)"
  grdb=$(printf '%s\n' "$grt" | cut -f5 | grep -vcE '^(OPEN|RESOLVED:[A-Za-z0-9-]+|SUPERSEDED:[A-Za-z0-9-]+)$')
  case "$grdb" in ''|*[!0-9]*) grdb=0 ;; esac
  [ "$grdb" = 0 ] && pass "disposition shapes legal (current value only; history is the flip log's)" \
    || fail "$grdb illegal disposition(s)"
  grmb=$(printf '%s\n' "$grt" | cut -f6 | grep -vcE '^(no|partial|yes)$')
  case "$grmb" in ''|*[!0-9]*) grmb=0 ;; esac
  [ "$grmb" = 0 ] && pass "mechanical vocabulary legal" || fail "$grmb off-vocabulary mechanical value(s)"
  grub=$(printf '%s\n' "$grt" | cut -f7 | grep -vcE '^(unverified-claim|unexercised-path|unread-source|external-drift|operator-blocked|ambiguous-record|accepted-limit)$')
  case "$grub" in ''|*[!0-9]*) grub=0 ;; esac
  [ "$grub" = 0 ] && pass "uncertainty-class vocabulary legal (the seven ratified kinds of not-knowing)" \
    || fail "$grub off-vocabulary uncertainty class(es)"
  grtb=$(printf '%s\n' "$grt" | cut -f8 | grep -vcE '^(TM-[0-9]+|COMM-F[0-9]|REG-EXP|CORR-PEND|CR-AUD|CENSUS)$')
  case "$grtb" in ''|*[!0-9]*) grtb=0 ;; esac
  [ "$grtb" = 0 ] && pass "source-tag vocabulary legal" || fail "$grtb off-vocabulary source tag(s)"
  grf=$(awk '/^# GAP-FLIPS v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$GR")
  grfm=""
  while IFS="$(printf '\t')" read -r gid _rest; do
    [ -n "${gid:-}" ] || continue
    fh=$(printf '%s\n' "$grf" | cut -f1 | grep -cxF "$gid")
    case "$fh" in ''|*[!0-9]*) fh=0 ;; esac
    [ "$fh" -ge 1 ] || grfm="$grfm [$gid]"
  done <<GFEOF
$(printf '%s\n' "$grt" | awk -F'\t' '$5!="OPEN"')
GFEOF
  [ -z "$grfm" ] && pass "every non-OPEN row owns at least one flip line (history append-only, never overwritten)" \
    || fail "non-OPEN row(s) without a flip:$grfm"
  grfo=""
  while IFS="$(printf '\t')" read -r fid _r2; do
    [ -n "${fid:-}" ] || continue
    rh=$(printf '%s\n' "$grt" | cut -f1 | grep -cxF "$fid")
    case "$rh" in ''|*[!0-9]*) rh=0 ;; esac
    [ "$rh" = 1 ] || grfo="$grfo [$fid]"
  done <<GFEOF2
$grf
GFEOF2
  [ -z "$grfo" ] && pass "every flip line's id resolves to exactly one register row" \
    || fail "orphaned flip id(s):$grfo"
  grem=""; grcross=0
  while IFS="$(printf '\t')" read -r gid _c _s gev _rest3; do
    [ -n "${gid:-}" ] || continue
    case "$gev" in
      lite:*|side:*) grcross=$((grcross+1)) ;;
      *) gp="${gev%%:*}"
         [ -e "$gp" ] || grem="$grem [$gid:$gp]" ;;
    esac
  done <<GREOF
$grt
GREOF
  [ -z "$grem" ] && pass "forward evidence resolves: every parent-repo evidence path exists on disk ($grcross cross-repo rows announced as prose, never asserted)" \
    || fail "evidence path(s) missing:$grem"
  tmn=$(grep -c '^| [0-9]* |' docs/security/threat-model.md 2>/dev/null)
  case "$tmn" in ''|*[!0-9]*) tmn=0 ;; esac
  tmset=$(grep -oE '^\| [0-9]+ \|' docs/security/threat-model.md 2>/dev/null | tr -dc '0-9\n' | sort -n | tr '\n' ' ')
  grtm=$(printf '%s\n' "$grt" | cut -f8 | grep '^TM-' | sed 's/^TM-//' | sort -n | tr '\n' ' ')
  if [ "$tmn" = 12 ] && [ "$tmset" = "$grtm" ]; then
    pass "threat-model binding: 12 numbered surface rows extracted live, number-set == register TM tags (the frozen record's first mechanical consumer)"
  else
    fail "threat-model binding broken: doc rows $tmn, doc set [$tmset] vs register [$grtm]"
  fi
  cml=$(grep '^\[COMM-AUDIT-1|' Plan.md | head -1)
  cmlab=$(printf '%s' "$cml" | grep -oE 'F[1-9]' | sort -u | tr '\n' ' ')
  grcm=$(printf '%s\n' "$grt" | cut -f8 | grep '^COMM-F' | sed 's/^COMM-//' | sort -u | tr '\n' ' ')
  if [ "$cmlab" = "F1 F2 F3 F4 " ] && [ "$cmlab" = "$grcm" ]; then
    pass "COMM-AUDIT binding: the frozen ledger line carries F1-F4 and the register carries all four (F4 accepted-limit, not dropped)"
  else
    fail "COMM-AUDIT binding broken: line [$cmlab] vs register [$grcm]"
  fi
  rexp=$(awk '/^# RELIABILITY-REGISTRY v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/RELIABILITY-REGISTRY.md 2>/dev/null | awk -F'\t' '$5=="experimental"' | grep -c .)
  case "$rexp" in ''|*[!0-9]*) rexp=0 ;; esac
  gragg1=$(printf '%s\n' "$grt" | cut -f8 | grep -cxF 'REG-EXP')
  [ "$rexp" -ge 1 ] && [ "$gragg1" = 1 ] \
    && { pass "REG-EXP aggregate bound: exactly one row, live subject re-counted"; note "live experimental-maturity sections today: $rexp (the aggregate row's subject, dated by this run)"; } \
    || fail "REG-EXP aggregate broken: subject count $rexp, rows $gragg1"
  cpend=$(grep -c 'PENDING' context/plan-corrections.md 2>/dev/null)
  case "$cpend" in ''|*[!0-9]*) cpend=0 ;; esac
  gragg2=$(printf '%s\n' "$grt" | cut -f8 | grep -cxF 'CORR-PEND')
  [ "$gragg2" = 1 ] \
    && { pass "CORR-PEND aggregate bound: exactly one row"; note "live PENDING mentions today: $cpend (the aggregate row's subject, dated by this run)"; } \
    || fail "CORR-PEND aggregate rows: $gragg2 (want exactly 1)"
  gr06=""
  for f6 in .claude/rules/fallback-protocol.md .claude/agents/arbiter.md .claude/agents/fixer.md .claude/agents/lead-executor.md .claude/agents/lead-planner.md .claude/agents/quality-reviewer.md .claude/agents/security-reviewer.md; do
    grep -q '0\.6' "$f6" 2>/dev/null || gr06="$gr06 [$f6]"
  done
  [ -z "$gr06" ] && pass "0.6 confidence threshold bound: present in all seven ratified sites (the first motivating hole, measured; the calibration ledger stays successor work)" \
    || fail "0.6 threshold missing from:$gr06"
  grnh=0
  for nf in docs/security/threat-model.md docs/security/redteam-1.md docs/PORTABILITY.md; do
    ev_has=$(printf '%s\n' "$grt" | cut -f4 | grep -cF "$nf")
    case "$ev_has" in ''|*[!0-9]*) ev_has=0 ;; esac
    if [ "$ev_has" = 0 ]; then
      nh=$(grep -ciE 'procedural(,| rather than| not) mechanical|no scanner|recorded, not hidden' "$nf" 2>/dev/null)
      case "$nh" in ''|*[!0-9]*) nh=0 ;; esac
      grnh=$((grnh+nh))
    fi
  done
  [ "$grnh" = 0 ] && pass "NOTE-plane scan: every scanned marker file is cited by at least one row's evidence" \
    || note "NOTE-plane: $grnh marker hit(s) in files no register row cites — advisory, the register may be incomplete there"
  grp2=$(mktemp)
  printf 'GR-999\tchronicle\tphantom row for the control\tdocs/NO-SUCH-FILE-gr-probe.md:1\tOPEN\tno\taccepted-limit\tCENSUS\tGAP-REGISTER-1\n' > "$grp2"
  grpm=""
  while IFS="$(printf '\t')" read -r gid2 _c2 _s2 gev2 _rest4; do
    [ -n "${gid2:-}" ] || continue
    gp2="${gev2%%:*}"
    [ -e "$gp2" ] || grpm="$grpm [$gid2]"
  done < "$grp2"
  [ -n "$grpm" ] && pass "control fires: a planted row with unresolvable evidence is caught by the resolution logic" \
    || fail "evidence-resolution control DID NOT fire"
  rm -f "$grp2"
  wcep=$(git log --diff-filter=A --format=%H -1 -- "$GR" 2>/dev/null)
  if [ -z "$wcep" ]; then
    note "WEAKEST-CLAIMS-EPOCH not yet committed (the declared straddle) — the arm arms at the gate commit"
  else
    wcm=""; wcn=0
    for wf in $(git ls-files 'docs/research/*.md'); do
      wfa=$(git log --diff-filter=A --format=%H -1 -- "$wf" 2>/dev/null)
      [ -n "$wfa" ] || continue
      if [ "$wfa" != "$wcep" ] && git merge-base --is-ancestor "$wfa" "$wcep" 2>/dev/null; then
        continue
      fi
      wcn=$((wcn+1))
      grep -q '^## Weakest claims' "$wf" || wcm="$wcm [$wf]"
    done
    [ "$wcn" -ge 1 ] || fail "epoch arm vacuous: zero post-epoch docs (the register itself should be one)"
    [ -z "$wcm" ] && pass "WEAKEST-CLAIMS-EPOCH holds: all $wcn post-epoch research docs carry the section (pre-epoch docs grandfathered by ancestry)" \
      || fail "post-epoch doc(s) missing the weakest-claims section:$wcm"
  fi
  wcp=$(mktemp)
  printf '# a post-epoch doc without the section\n\nprose only\n' > "$wcp"
  grep -q '^## Weakest claims' "$wcp" && fail "epoch control DID NOT fire" \
    || pass "control fires: a sectionless doc is seen by the epoch grep"
  rm -f "$wcp"
fi

echo "== H. VECTOR — the amelioration router: pinned rules, derived queue =="
# Doc-data plane of VECTOR-1 (engine arms live in the crew suite beside TEI-1). The load-bearing
# arm is queue-equals-derivation: the committed queue is proven a pure function of
# (register, rules) every run — a hand edit, an unrouted register change, or an ungated rules
# tweak reds the same run.
VQ="docs/research/VECTOR-QUEUE.md"
if [ ! -f "$VQ" ]; then
  fail "queue missing: $VQ"
else
  vqt=$(awk '/^# VECTOR-QUEUE v1$/{f=1;next} f&&/^```/{exit} f&&NF' "$VQ")
  vqn=$(printf '%s\n' "$vqt" | grep -c .); case "$vqn" in ''|*[!0-9]*) vqn=0 ;; esac
  [ "$vqn" -ge 35 ] && pass "queue vacuity: $vqn routed rows" || fail "queue vacuous: $vqn"
  vqb=$(printf '%s\n' "$vqt" | awk -F'\t' 'NF!=4{c++} END{print c+0}')
  [ "$vqb" = 0 ] && pass "queue rows are 4 fields (id, resolution, priority, rule_id)" || fail "$vqb malformed queue row(s)"
  vqv=$(printf '%s\n' "$vqt" | cut -f2 | grep -vcE '^(research-dive|web-verify|operator-word|build-gate|named-wake|accepted-limit|ESCALATE)$')
  case "$vqv" in ''|*[!0-9]*) vqv=0 ;; esac
  [ "$vqv" = 0 ] && pass "resolution vocabulary legal (six ratified + engine ESCALATE)" || fail "$vqv off-vocabulary resolution(s)"
  vqd=$(mktemp)
  bash scripts/route-vector.sh --all > "$vqd" 2>/dev/null
  if cmp -s "$vqd" "$VQ"; then
    pass "queue-equals-derivation: committed queue byte-identical to a fresh derivation (pure function held)"
  else
    fail "queue DRIFTED from its derivation — recovery: scripts/route-vector.sh --all > $VQ (never hand-edit)"
  fi
  rm -f "$vqd"
  gropen=$(awk '/^# GAP-REGISTER v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/research/GAP-REGISTER.md | awk -F'\t' '$5=="OPEN"{print $1}' | sort)
  vqids=$(printf '%s\n' "$vqt" | cut -f1 | sort)
  [ "$gropen" = "$vqids" ] && pass "coverage both ways: every OPEN register row exactly once in the queue; no phantom queue id; no non-OPEN row routed" \
    || fail "queue/register divergence: $(comm -3 <(printf '%s\n' "$gropen") <(printf '%s\n' "$vqids") | head -3 | tr '\n' ' ')"
  vqsha=$(grep -oE 'sha256 `[a-f0-9]{64}`' "$VQ" | grep -oE '[a-f0-9]{64}')
  vlive=$(_sha256 config/vector-rules.json)
  { [ -n "$vlive" ] && [ "$vqsha" = "$vlive" ]; } \
    && pass "rules provenance in the queue header matches the live rules hash" \
    || fail "queue header rules-hash stale or empty: '$vqsha' vs '$vlive'"
  vqp=$(mktemp)
  printf 'GR-001\tbogus-resolution\t9\tV-NONE\n' > "$vqp"
  vqpc=$(cut -f2 "$vqp" | grep -vcE '^(research-dive|web-verify|operator-word|build-gate|named-wake|accepted-limit|ESCALATE)$')
  case "$vqpc" in ''|*[!0-9]*) vqpc=0 ;; esac
  [ "$vqpc" -ge 1 ] && pass "control fires: a planted off-vocabulary queue row is seen by the legality scan" \
    || fail "queue control DID NOT fire"
  rm -f "$vqp"
fi

printf '\n== check-decision-matrices: %s PASS / %s FAIL / %s NOTED (notes are dated divergences, kept per CR-033) ==\n' "$P" "$F" "$N"
[ "$F" = 0 ] || exit 1
