# S6 dive — ruflo (promoted at CORPUS-0)

Provenance: these findings were recorded in `Plan.md` as dated S6 ledger entries (2026-08-19/20)
and are promoted here VERBATIM — the census showed ruflo as DIVED with no standing document, so
the record moves to where a reader looks, unedited. The ledger remains the original.

## The dive record, quoted

> [S6|2026-08-20T00:14:40Z] RUFLO DIVE — and the map's own steer was half wrong in a useful way. It says read ruflo ONLY for swarm topology, federation and learned routing, and warns the size-to-insight ratio is poor. Correct for orchestration. But verification/ is a major find the map does not mention at all, and it lands squarely on this build's central obsession. THREE-LAYER REGRESSION PROTECTION: behavioural smoke tests in CI, a cryptographic WITNESS MANIFEST attesting that each documented fix's load-bearing code is still present, and a temporal history file for bisecting when a regression entered. Their stated motivation is exact: three regressions all PASSED UNIT TESTS on the broken commits and still broke users on first install, because unit tests verify code paths while users hit flag parsers, fresh-install resolution and version drift. Their fix: every documented fix is attested by a marker substring plus a SHA-256 plus a signature, so anyone at the same commit can re-derive and verify independently, and deleting the load-bearing line of a fix flips markerVerified false and blocks publish.

> [S6|2026-08-20T00:14:40Z] RUFLO — WHY THAT MATTERS HERE MORE THAN ANYTHING ELSE IN THE CORPUS. context/plan-corrections.md plus check-plan-corrections.sh IS a hand-rolled witness manifest: 25 documented fixes, each with a detector. The audit found two of those detectors reported APPLIED while testing nothing, and S1 repaired them by hand. Ruflo's construction makes that class harder by design — a marker substring is still a substring, but pairing it with a content hash means any edit to the attested file forces a re-verification rather than letting a stale detector drift, and the signature makes the attestation checkable by someone who does not trust the checker. This build has layer 1 and a weak layer 2 and NO layer 3: nothing here can bisect when a control stopped working. Their operating thresholds are worth copying too — a rolling-median baseline so one slow run is not a regression, and an explicit "should not regress beyond ~3x, anything larger is signal". REGISTERED, NOT PROPOSED: the CR backlog is frozen until S6 completes, so this becomes an input to the Lite plan's verification design rather than a change request against the current build.

## Disposition

Adopted into the twin at its build: the three-layer regression protection became Lite's witness
manifest (layer 2, content-hash attestation) and temporal history (layer 3, bisectable), with
rolling-median thresholds folded into verification design. The parent carries layer 1 and the
hand-rolled corrections registry; the gap statement ("nothing here can bisect when a control
stopped working") remains true of the parent and is recorded, not hidden.
