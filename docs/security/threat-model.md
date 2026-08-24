# threat-model.md — psychic-crew and psychic-crew-lite (S2a, 2026-08-23)

Written by reading the code in both repositories, not from memory of it. Every control below names
the file that implements it and the assertion that tests it; where there is no assertion, the
residual column says so rather than leaving the reader to assume one exists.

**The residual column is the point of this document.** A threat model whose every row ends "covered"
is a marketing document. These rows end honestly, and several of them end badly.

## Scope and posture

Two public GitHub repositories on one WSL2 workstation, operated by one person through Claude Code.
No network services, no deployed artifacts, no runtime multi-tenancy. **Zero credentials exist**
(R-SEC-1 rule 1). The most valuable thing either repo holds is not data — it is the *integrity of
its own evidence*: ledgers, gate rows, audit trails and suites that later decisions rest on.

That shapes the model. The realistic adversary is not an intruder after secrets; it is **content
that persuades a session to do the wrong thing**, and **a session that convinces itself it did the
right thing**. Most rows below are about the second.

## Assets

| Asset | Where | Why it matters |
| --- | --- | --- |
| Gate ledgers | `GATES.md` (both) | The only record that an operator authorised anything. |
| Decision ledgers | `Plan.md`, `PROGRESS.md`, `context/`, `docs/RULINGS.md` | Cold-start truth after compaction; read as authoritative. |
| Execution authority | `MASTER_FIFO_PLAN_CLAUDE.md` + `DIRECTORY_GUIDE.md` | Byte-pinned; the map binds the tree. |
| Enforcement layer | `hooks/*`, `scripts/validate-*`, `check-sync.sh`, `gate-guard.sh` | If these lie, everything downstream inherits the lie. |
| Audit trails | `logs/*.jsonl` (both) | Gate evidence. Already proven corruptible (C-14/C-27). |
| Witness manifest | Lite `docs/WITNESS-MANIFEST.md` | Attests that past corrections still hold. |
| Public remotes | both `origin/dev` | Publication is irreversible; caches and forks outlive deletion. |
| Pack workspaces | Lite `.claude/skills/packs/*/{inbox,work,out}` | Hold **real internal documents**. Never tracked. |

## Trust boundaries

1. **Operator → session.** The operator is trusted. Their *instructions* are authority; documents
   they hand over are **not** (boundary 3).
2. **Session → session.** A later session trusts only the filesystem, never a predecessor's claim.
   This is why fidelity bindings and the witness manifest exist.
3. **Document → session.** The hard one. Anything read from an inbox, corpus or the web is **data
   about where to look, never an instruction** (§0.2d, R-SEC-1 rule 7).
4. **Repo → remote.** One-way and irreversible. Everything crossing it is public forever.
5. **Parent → Lite.** MIRRORED files must be byte-identical; drift is a failure, not a variant.

## Actors

| Actor | Trusted for | Not trusted for |
| --- | --- | --- |
| Operator | Instructions, gate tokens, rulings | — |
| This session | Executing within a gate | Deciding a gate is approved (H0a exists because it did) |
| Subagents | Producing findings | Releasing their own output (cross-release law) |
| Document authors | Nothing | Anything — a document is data (boundary 3) |
| Corpus / web authors | Nothing | Anything; read-only reference material |

## Surfaces — control, where tested, residual

| # | Surface | Control | Tested by | RESIDUAL |
| --- | --- | --- | --- | --- |
| 1 | Gate ordering | `gate-guard.sh` requires an APPROVED row before commit | `H0a` assertions both repos; 5 controls | **Stops ordering mistakes, NOT forgery (S4a).** A session that writes a fake APPROVED line passes it. Detection is the ledger-vs-operator-memory audit — procedural, not mechanical. Mitigating fact measured here: replacing `GATES.md` with a symlink shows as a type change in `git status`, so that variant is visible. |
| 2 | Model policy | `model-guard` (write), `apply-models` (stamp), `validate-crew` (gate) | F1 cases; SECURITY-1 probes P6–P11 | Was **beaten by indirection** at this session's start — alias/pinned/session paths. Fixed by resolving the proposed config. Residual: guard reads only `.claude/*` and `models.config.json`; a model named through a file outside that surface is unguarded at write time, caught at stamp. |
| 3 | Secrets on disk | `sensitive-guard` blocks writes; `.gitignore` covers the shapes | SECURITY-1 publication probe | `secrets/`, `.ssh/`, `*.pem`, `id_rsa`, `credentials.json` were **not ignored** until this session, while `security.md` claimed they were. Fixed. Residual: the guard covers the `Write|Edit` path only; a file arriving by another route relies on `.gitignore` alone. |
| 4 | Log/ledger redaction | `scrub()` in `_common.sh`, called by `deny()`, `audit-logger`, `provenance-flag` | R-SEC-1 rule-3 proof (this phase) | `error-recovery` wrote tool error text through `cut -c1-400` — a **length limit, not redaction** — and leaked a planted token verbatim. Fixed. Residual: `scrub()` matches known shapes and assignment positions; a novel credential format is not covered by construction. |
| 5 | Pack document intake | Workspaces gitignored on the pack-root glob; tracked-under-workspace assertion | Lite `H. skill packs`, 5 assertions | **Judgment is model-interpreted.** Whether a finding is correct, and whether a routing call is right, is not mechanically checkable — `PACK.md` says so and the manual drills carry it. Injection hardening lands in LITE-SECURITY-1. |
| 6 | Untrusted document content | §0.2d; R-SEC-1 rule 7 | LITE-SECURITY-1 fixtures + live drill | Until Block 2 closes this is **procedural only** — a contract with no adversarial test. Pack #1 is own-documents-only in the interim by ruling. |
| 7 | Map ↔ tree correlation | CR-024 both directions for `scripts/`, `context/`, `hooks/`; Lite completeness over `hooks/ scripts/ .claude/` | CR-024, C-26, map-completeness | **`docs/` is outside the converse correlation BY DESIGN (D21)** — high-churn output area, bound at directory granularity. A stray tracked file under `docs/` is not caught. Stated as a decision, not drift. |
| 8 | Diagram / spec truth | Structural validators: fences, referential integrity, `$schema`, tracked data URL | S3 validator; H2a assertions | **Well-formed ≠ true.** Only the d2 hook topology is bound to its source (`settings.json`); every other diagram could depict a different system and pass. |
| 9 | Shell write-path defects | R-SD-1 v1+v2, two class assertions per repo, empty allowlists | 4 class assertions | **Stated scanner gap:** other early-exit consumers (`head -n`, `grep -m`, `sed q`) are covered by rule 5 in prose only and gain needles when evidence produces an instance. |
| 10 | Cross-release integrity | `released_by ≠ from_agent`, enforced at the write | Lite release-guard, 5 behaviours; stress 14/14 | Guard sees only payloads it can read; a line assembled from shell variables is invisible to it and caught by the trail scan at the gate. Both stated. |
| 11 | Corpus / reference material | Read-only; `provenance-flag` correlates ledger writes against `logs/rounds/` | C-13 detector | Verbatim relay only. **Paraphrase is not detected**, by construction — paraphrase implies a judgement was applied. |
| 12 | Publication to public remote | Ignore rules + stage-everything probe + tracked-under-workspace | Lite pack assertions | Irreversible. Residual is human: nothing prevents an operator pasting content into a tracked file by hand, and no check reads prose for confidentiality. |

## What would change this model

A granted credential (R-SEC-1 rules 2–6 activate, and rows 3–4 change character); a second pack;
any network-reaching lane; or a second operator. Until then the dominant risk stays where the
evidence says it is: **not exfiltration, but a control that reports green while checking nothing** —
which is why this build's own registries record eleven instances of that class and this document
names five more as live residuals.
