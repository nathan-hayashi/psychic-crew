# DIVE-W1-RU-1 — ruflo, under the temporal-bisect question

**Gate:** DIVE-W1-RU-1 (wave dive 2). **Source:** `ruflo-main/` (census `DIVED`, re-opened by this named
question). **Question (fixed at SOURCE-MAP-1):** what exactly would a parent-side
temporal-bisect layer need from ruflo's verification-history design — and what does their
implementation get wrong that ours must not? **Prediction on record:** TAKE-FEW.

## Read manifest (measured; sidecar exclusion applies; nothing else was opened)

| artifact | lines | how read |
|---|---|---|
| `verification/README.md` | 358 | FULL — the three-layer design doc |
| `plugins/ruflo-core/scripts/witness/history.mjs` | (head 60) + lib call-through | the query tool's commands and shapes |
| `plugins/ruflo-core/scripts/witness/lib.mjs` | targeted: findRegressionIntroductions (:238-252), seedDerivation (:167), ed25519 loader (:53-81) | the bisect algorithm and the signing scheme |
| `verification/{linux,macos,windows}/history.jsonl` | 11/40/9 entries measured; one entry read | the live temporal data |
| witness scripts census | init 83 · lib 300 · perf 204 · regen 94 · verify 219 lines | measured, not line-read beyond the targets |

## The answer — what a parent bisect layer needs

1. **One append-only JSONL per platform**, one snapshot per attestation event: `{v, commit,
   issuedAt, summary, fixes: {id: {sha256, markerVerified}}}` — platform-keyed because
   file hashes legitimately differ across userlands (their stated CRLF/prebuilt reasoning is
   our BSD-vs-GNU story verbatim).
2. **A pure query tool over it** — `summary · regressions · timeline · list`. The bisect
   itself is ~20 lines (lib.mjs:238-252): walk backwards from the latest snapshot, for each
   currently-failing control find the last-passing entry; report `(lastPass, regressedAt)`
   and hand `git log lastPass..regressedAt -- <file>` the collapsed window.
3. **The drift-vs-regression split**: hash changed but control present = DRIFT (suppressed
   alarm); control absent = REGRESSION (flagged). Plus `timeline --id` — which doubles as a
   BRITTLE-NEEDLE DETECTOR: a flapping marker is a marker chosen badly.
4. **The same-commit law**: the history append travels in the same commit as the state it
   describes (their anti-pattern list; our atomicity discipline, independently arrived).
5. **Granularity truth** (folded into the landing, not a separate mechanism): bisect
   resolution equals append cadence. Theirs appends per regen (release-ish; their own example
   window is 18 hours). Ours should append per green SUITE RUN — run-level windows, strictly
   finer, and exactly the record OR-1's evidence-run take already wants.

## What they get wrong — ours must not copy

**The signature is authentication theater.** The Ed25519 seed is
`sha256(gitCommit + ':ruflo-witness/v1')` (lib.mjs:167) — derivable by ANYONE from public
data. A doctored manifest re-signs trivially (update gitCommit, re-derive, re-sign); their
`verify.mjs` "signature valid: yes" then passes in full. The README's claim that a bad
signature means the manifest "has been tampered with" is FALSE against an adversary — the
scheme detects accidental corruption and derivation drift only. (In-CI it borrows integrity
from the checkout's ground-truth commit; standalone it proves reproducibility, not
authenticity.) The estate's own record already holds the honest form of this decision: lite's
witness claims content-hash integrity ONLY, and CORPUS-BABYSITTER-2 BLOCKED signed approvals
because no key may exist here until granted — a keyless signature that "works" is exactly the
theater this dive names, and the operator-held-key route remains the one honest signing path.

## Verdicts

```text
# DIVE-RU-1-VERDICTS v1
1	per-platform-jsonl-history-plus-query-tool	TAKE-PATTERN	GR-042,GR-135	verification/README.md schema + lib.mjs:238-252
2	drift-regression-split-and-flap-timeline	TAKE-PATTERN	GR-042	features table + history.mjs timeline command
3	same-commit-history-law	VALIDATE-AGAINST	GR-135	anti-patterns list; our atomic-close discipline independently arrived
4	derivable-seed-signature-theater	REJECT	GR-071	lib.mjs:167 seedDerivation; README tamper claim overreaches
5	monotone-decreasing-tool-baseline	VALIDATE-AGAINST	GR-042	mcp-tool-baseline.json ADR-112; RATCHET-1's shrink-only sibling
```

Roll-up: **2 TAKE-PATTERN · 0 MODULATE-OURS · 2 VALIDATE-AGAINST · 1 REJECT** — measured
outcome **2 TAKE-class** (= TAKE-FEW at the ratified boundary; the prediction held).

## Landing shapes

| mechanism | landing shape | future gate | register rows closed |
|---|---|---|---|
| per-platform history + query tool | CONVERGES with OR-1's evidence-run take into ONE record: SUITE-ATTEST-1 appends per green run `{ts, head, platform, userland, totals, per-section fingerprints}` platform-keyed, plus the pure query tool (summary/regressions/timeline) — run-level bisect windows, BSD-cert consumption, registry maturity provenance in one artifact | SUITE-ATTEST-1 (successor) | GR-135, GR-042 |
| drift/flap semantics | the attest record's per-section fingerprints classify drift-vs-regression; a lite leg adds `timeline` to its existing witness history (v2, small) | SUITE-ATTEST-1 + lite witness v2 | GR-042 (partial) |

## Register delta

No flips: GR-042 and GR-135 stay OPEN — the mechanism is now SPECIFIED but unbuilt,
and a research gate never builds. The REJECT attaches as evidence to GR-071 (the
operator-key row), whose disposition is untouched. No new rows: this dive found design and a
flaw, not new gaps. Queue re-derived unchanged by construction.

## Weakest claims, flagged

`[I]` The signature-theater finding rests on lib.mjs:167 and the README's own seedDerivation
disclosure; verify.mjs was censused (219 lines) but not line-read — a verification step
outside the derivation path could exist unseen, though the seed formula alone suffices for
the re-sign attack. `[E-limits]` The 40-entry macOS history was sampled at one entry; the
JSONL schema is taken from the README's schema block plus that sample.

Evidence census: [E] 11 · [I] 2 · [S] 0 · [V?] 0
