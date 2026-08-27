# SIDE-5 — Compliance API: the six-criteria verdict

Status: SIDE-5 deliverable — a criteria EVALUATION, never a build (RSCH-3 §D law: all six
required before any build gate opens). Evidence fetched 2026-08-27; quotes verbatim.

## Restatement (≤5 lines)

Objective: evaluate RSCH-3 §D's six ALL-required legal/privacy criteria against today's
evidence — the vendor's current docs for criterion 1, the estate's actual artifacts for 2–6 —
and record per-criterion verdicts with wake conditions. The expected honest outcome is a block;
the phase exists to make the block precise rather than vague.

## A. Criterion 1 verified: the sanctioned surface EXISTS `[E]`

`platform.claude.com/docs/en/manage-claude/compliance-api`, fetched 2026-08-27: "The Compliance
API gives Claude Enterprise and Claude Console customers programmatic access to their
organization's Activity Feed… the underlying chats, files, and projects in claude.ai
organizations; and Cowork, Claude Code, Claude Science, and Claude for Microsoft 365 sessions."
Endpoints under `/v1/compliance/*`; a scoped **Compliance Access Key** (created in claude.ai)
reaches everything, an Admin API key reaches the Activity Feed only; content endpoints serve
**Claude Enterprise data only**; teams "audit activity, retrieve or delete content"; 600
requests/minute per parent organization. The operator's original product idea — "pull chat/
memory/file content org-wide" — exists as the vendor's own sanctioned product surface, which is
precisely what criterion 1 demanded be true before anything else is discussed.

**Bonus finding for the TEI map `[E]`:** the same page documents **inference hooks** (beta) —
"your organization's AI security server receives each governed prompt before inference and can
deny it in real time." That is the TEI Execution Gateway as a vendor primitive; recorded here
for TEI-1's file.

**Deployment prerequisite, stated:** content access requires a Claude Enterprise tenant and
key provisioning by its owner. This estate has no Enterprise tenant today — the criterion is MET
as a fact about the vendor, not as access we hold.

## B. The six verdicts

| # | Criterion (RSCH-3 §D) | Verdict | Evidence today | Wake condition |
|---|---|---|---|---|
| 1 | Sanctioned surface only, verified never assumed | **MET** `[E]` | §A above, dated fetch | — (re-verify at any build gate; docs move) |
| 2 | Consent + jurisdiction | **NOT MET** | No written worker-notification/consent model exists anywhere in the estate; the operating jurisdiction itself is UNKNOWN, unrecorded | Operator produces the written model, reviewed against the named jurisdiction; EU AI Act high-risk date (2027-12-02) as context where applicable |
| 3 | Classification + internal-only storage with named retention | **NOT MET** | Internal-only exists as stated law (HELIX brief; TEI-PREPLAN standing laws) `[E]` — but no classification table and no named retention per class | A classification table with retention rows, gated |
| 4 | Delegated-filter distribution as policy rows | **NOT MET** | The filter is NAMED in the operator's brief `[E]`, never expressed as rows | The filter as policy rows: who, which classes, which egress paths |
| 5 | Transparency artifact for the collected-from population | **NOT MET** | None exists; the API's own records carry actor email, IP, and user-agent `[E]` — which raises the obligation, not lowers it | A population-visible document: what is collected, why, who reads it |
| 6 | Attribution, not ownership (PROV-O projection) | **PARTIAL** | The rule is ADOPTED as standing law (TEI-PREPLAN) `[E]`; no instantiated projection exists in any real record | TEI-2's instrumented run emits the first real PROV-O projection |

## C. Overall verdict: BLOCKED — 1 of 6 met, and the block is the system working

No SIDE-5 build opens. What a build WOULD be, parked for the day all six pass: a consumer of
the vendor's Compliance API (never a scraper — criterion 1's other half), adding exactly the
three things the vendor surface does not: per-department assurance views compiled per TEI-1
tiers, the delegated legal/compliance filter on every egress, and the PROV-O
attribution-not-ownership overlay. The differentiation is the assurance layer, not the plumbing;
the plumbing now demonstrably exists upstream.

## D. Weakest claim, flagged

`[I]` Plan coverage is read from one page: whether Claude **Team** (non-Enterprise) tenants get
any content endpoint was not separately verified, and "memory" artifacts are not explicitly
named in the fetched scope list (chats/files/projects/sessions are). Neither changes today's
verdict — criteria 2–5 block regardless — but both must be re-verified at any future build gate.
`[I]` The jurisdiction blank in criterion 2 is itself the largest unknown: its answer could add
requirements this table does not yet name.

## E. Verify

- Quotes traceable to the 2026-08-27 fetch of the compliance-api page; URL in §A.
- Verdict math: `grep -c 'NOT MET' docs/research/SIDE-5-compliance-verdict.md` → 4 (rows 2–5).
- The block is enforced by process, not prose: GATES.md carries no SIDE-5 build row, and the
  HELIX plan's own text ("builds nothing before its legal criteria pass") is the standing rule.
