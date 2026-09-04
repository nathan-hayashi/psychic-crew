#!/usr/bin/env bash
# check-envelope.sh — TEI-0's standalone checker: the envelope schema and the graph pilot,
# validated with jq alone (no validator dependency — HC-5). Fixtures are embedded and planted
# into mktemp at run time; controls are proven to fire every run.
# TM-FENCE-1 adjudication (2026-09-04): the evidence enum here is ["E","I","S"] while the plan
# grammar adds [V?]. ADJUDICATED INTENTIONAL, not drift: V? is a PROSE staleness marker
# (verify-before-reliance), never an evidence class an envelope claim may carry — a claim has
# evidence or it does not. The schema is correct; the grammar governs prose; the ambiguity is
# resolved by this decision, recorded at the gate.
set -uo pipefail
cd "$(dirname "$0")/.."
P=0; F=0
ok () { P=$((P+1)); printf '  [PASS] %s\n' "$1"; }
no () { F=$((F+1)); printf '  [FAIL] %s\n' "$1"; }

echo "== A. envelope schema =="
jq -e . envelope.schema.json >/dev/null 2>&1 && ok "envelope.schema.json parses" || no "schema does not parse"
req=$(jq -r '.required[]' envelope.schema.json 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')
want="applicable_policies claims contradictions expiration missing_information permitted_recipients provenance source_manifest "
[ "$req" = "$want" ] && ok "schema requires exactly the eight envelope members" \
  || no "schema required-set drifted: [$req]"

T=$(mktemp -d)
cat > "$T/good.json" <<'GEOF'
{"source_manifest":[{"path":"a.md","sha256":"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef","retrieved_at":"2026-09-01T00:00:00Z","classification":"internal"}],
 "claims":[{"text":"x","source_paths":["a.md"],"evidence_class":"E"}],
 "contradictions":[],"missing_information":["owner unstated"],
 "applicable_policies":["R-SEC-1"],"permitted_recipients":["operator"],
 "expiration":"this run","provenance":{"assembled_at":"2026-09-01T00:00:00Z","assembled_by":"check-envelope fixture","method":"embedded"}}
GEOF
gv=$(jq -r --slurpfile s envelope.schema.json '
  ($s[0].required - (keys)) as $missing
  | if ($missing | length) == 0 then "ok" else "missing:" + ($missing | join(",")) end
' "$T/good.json" 2>/dev/null)
[ "$gv" = "ok" ] && ok "embedded valid envelope carries every required member" \
  || no "valid-fixture check broken: $gv"
sm=$(jq -r '[.source_manifest[] | select((.sha256 | test("^[a-f0-9]{64}$")) and .retrieved_at and .classification)] | length' "$T/good.json" 2>/dev/null)
[ "$sm" = "1" ] && ok "source_manifest entries carry hash + retrieval time + classification" \
  || no "source_manifest shape check failed ($sm)"
jq 'del(.provenance)' "$T/good.json" > "$T/bad.json"
bv=$(jq -r --slurpfile s envelope.schema.json '
  ($s[0].required - (keys)) as $missing
  | if ($missing | length) == 0 then "ok" else "missing:" + ($missing | join(",")) end
' "$T/bad.json" 2>/dev/null)
case "$bv" in
  missing:provenance) ok "control fires: an envelope without provenance is refused by name" ;;
  *) no "control DID NOT fire on the provenance-less envelope ($bv)" ;;
esac

echo "== B. the graph pilot (no shared source, no edge) =="
G="$T/graph.json"
awk '/^# TEI-GRAPH v1$/{f=1;next} f&&/^```/{exit} f' docs/research/TEI-0-pilot.md > "$G"
jq -e . "$G" >/dev/null 2>&1 && ok "pilot graph parses as JSON" || no "pilot graph does not parse"
nn=$(jq '.nodes | length' "$G" 2>/dev/null); ne=$(jq '.edges | length' "$G" 2>/dev/null)
case "$nn" in ''|*[!0-9]*) nn=0 ;; esac; case "$ne" in ''|*[!0-9]*) ne=0 ;; esac
{ [ "$nn" -ge 10 ] && [ "$ne" -ge 4 ]; } && ok "graph non-vacuous ($nn nodes, $ne edges)" \
  || no "graph vacuous: $nn nodes, $ne edges"
viol=$(jq -r '
  . as $g
  | [ .edges[] | . as $e
      | ($g.nodes[] | select(.id == $e.from) | .source_docs) as $fs
      | ($g.nodes[] | select(.id == $e.to)   | .source_docs) as $ts
      | select( (($fs // []) | index($e.source_doc)) == null
                or (($ts // []) | index($e.source_doc)) == null )
      | "\($e.from)->\($e.to)" ]
  | if length == 0 then "none" else join(" ") end' "$G" 2>/dev/null)
[ "$viol" = "none" ] && ok "no-shared-source-no-edge holds for every live edge" \
  || no "edge(s) without a shared source: $viol"
jq '.edges += [{"from":"fx-exfil","to":"tpl-proposal","source_doc":"phantom.md"}]' "$G" > "$T/gp.json"
pviol=$(jq -r '
  . as $g
  | [ .edges[] | . as $e
      | ($g.nodes[] | select(.id == $e.from) | .source_docs) as $fs
      | ($g.nodes[] | select(.id == $e.to)   | .source_docs) as $ts
      | select( (($fs // []) | index($e.source_doc)) == null
                or (($ts // []) | index($e.source_doc)) == null )
      | "\($e.from)->\($e.to)" ]
  | length' "$T/gp.json" 2>/dev/null)
case "$pviol" in ''|*[!0-9]*) pviol=0 ;; esac
[ "$pviol" -ge 1 ] && ok "control fires: a planted no-shared-source edge is refused ($pviol violation)" \
  || no "graph control DID NOT fire on the planted edge"
sd=$(jq -r '[.nodes[].source_docs[]] | unique | length' "$G" 2>/dev/null)
case "$sd" in ''|*[!0-9]*) sd=0 ;; esac
[ "$sd" -ge 10 ] && ok "graph grounded in $sd distinct pack documents (the real material)" \
  || no "graph grounding thin: $sd source docs"
vc=$(grep -c '^VERDICT: PARK' docs/research/TEI-0-pilot.md)
case "$vc" in ''|*[!0-9]*) vc=0 ;; esac
[ "$vc" -eq 1 ] && ok "pilot verdict recorded exactly once (PARK, wake condition named)" \
  || no "pilot verdict line count $vc != 1"
rm -rf "$T"

printf '\n== check-envelope: %s PASS / %s FAIL ==\n' "$P" "$F"
[ "$F" -eq 0 ]
