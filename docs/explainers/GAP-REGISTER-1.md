# GAP-REGISTER-1, explained plainly

## What changed

Every weakness this estate ever admitted to — 133 of them, from the threat model's residuals to
the smallest declined badge — now lives in one machine-readable register, each row citing the
exact file that proves it, typed by what KIND of not-knowing it is (seven ratified kinds), and
carrying its current disposition with history in an append-only flip log. The suite grew a
section that re-extracts the declared sources live every run: the threat model's 12 rows gained
their first mechanical consumer, the COMM-AUDIT line is bound at all four findings, the 0.6
confidence threshold is asserted at its seven sites, and two instrument gaps the register
itself named were closed in the same gate (the census tier column, the weakest-claims epoch
arm) — birth flips proving disposition changes are real, not aspirational.

## The honest limits

Roughly 85% of rows are census-authored and unbound by the FAIL plane — the register header
says so, and the NOTE-plane scan reports marker hits no row covers, advisory never red. The
register doubles as the program's hallucination log and opens with three real specimens
reported-not-corrected, one of them the orchestrator's own completion-record figure (the
ledger said registry 44->48; disk holds 47; the suite's 47==47 was always right).

## Verify it yourself

```
./scripts/check-decision-matrices.sh | grep -A24 'G. GAP-REGISTER'
awk '/^# GAP-REGISTER v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/research/GAP-REGISTER.md | wc -l
```

## What could break, and what catches it

A deleted threat-model row, a dropped COMM finding, an off-vocabulary value, a non-OPEN row
without its flip line, an evidence path that stopped existing, a post-epoch research doc
without its weakest-claims section — each is a named FAIL the same run, and every scanner has
a planted control shown firing.
