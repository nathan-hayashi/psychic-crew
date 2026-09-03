# RATCHET-1, explained plainly

## What changed

The zero-dependency doctrine became a machine check with an empty baseline that can only
shrink. Two scanners run every suite pass: no dependency manifest (package.json, requirements,
Gemfile, go.mod, Cargo, composer — the full name set) may be tracked anywhere outside the two
named fixture apps (stress-project and stress-site, both measured as the only legitimate
carriers); and no tracked shell may invoke a forbidden interpreter or installer (pip, gem, go
run, npm install, npx, python3, perl, ruby) — the allowed set is bash, jq, awk, sed, grep,
git, and node, all in live use. The needles are fragment-assembled, the deny-list carrier file
is exempt by name and fixture lines by shape (a scanner must not eat the guards that
legitimately spell its prey), and the census has a vacuity floor so a scan over nothing cannot
read green.

## The honest limit

Ad-hoc session commands are out of scope — this governs TRACKED shell, in the same register
shell-discipline uses for its own stated gaps. The motivating incident is cited in-gate: the
estate's python3 death at S1, the last interpreter dependency, killed with the manifests it
parsed.

## Verify it yourself

```
./scripts/run-crew-tests.sh F7 | grep -A5 'RATCHET-1'
git ls-files | grep -cE 'package.json' # the two fixture apps only
```

## What could break, and what catches it

A new manifest anywhere else → named FAIL by path. A tracked script reaching for a forbidden
interpreter → named FAIL by file:line. Both proven able to fire by planted probes every run.
Exemptions may only shrink; adding one is a gate like everything else.
