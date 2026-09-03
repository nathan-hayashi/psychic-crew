# LITE-PARITY-1, explained plainly

## What changed

The twin repo gained the two shell-portability scanners the parent has carried since the
MacBook certification: rule 2 (a wc -l count must never reach a string comparison — BSD pads
the count and the compare silently takes the wrong branch) and rule 7 (the GNU-isms that fail
or silently lie on macOS). The port used the twin's own corrected comment-stripper — and the
parent's two scanners were upgraded to the same stripper in the same gate, because parity
means the better form on both sides, not the older form copied forward.

## The port earned its keep before it landed

The pre-sweep found three real offenders in the twin: check-sync compared two direct
sha256sum outputs — on a Mac both come back empty and "" = "" reads as a MATCH, a silent false
pass on the very mechanism that guards mirror fidelity — and check-witness attested files with
the same GNU-only tool. All three now route through a mirrored _sha256 helper where an empty
hash is a failure, never a match. Census 3 → 0, ledgered.

## Verify it yourself

```
(cd ../psychic-crew-lite && ./scripts/validate-lite.sh | tail -1)   # 71/1/0
grep -n '_sha256' ../psychic-crew-lite/scripts/check-sync.sh | head -2
```

## What could break, and what catches it

A future wc-to-string or GNU-ism in either repo → the same scanner, same needles, both sides.
The one step that remains is the operator's: the BSD certification run of the lite suite on
the actual Mac — named in PORTABILITY.md, never claimed.
