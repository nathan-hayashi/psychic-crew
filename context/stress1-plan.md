# STRESS1-A1 — lead-planner packet (persisted verbatim by the orchestrator)
# task_id: STRESS1-A1 · dispatched 2026-08-27 · measured 128,098 subagent tokens vs 15,000 budget line (trigger fired, mid-gate item)

# STRESS-1 BUILD PLAN — stress-site/ (cats-and-dogs landing page)

## 0. PRECONDITIONS — verified against named artifacts
P1 suite invocation node --test --test-reporter=tap 'test/**/*.test.js' (session-summary:43; rct:974-976) VERIFIED
P2 zero-dep probe exits exactly 1 (rct:1002-1007) VERIFIED
P3 mermaid validator scans every tracked .md except docs/audit/ → NO mermaid fence under stress-site/ VERIFIED
P4 CR-024 map-vs-tree polices scripts/context/hooks only → new top-level dir safe VERIFIED
P5 DIRECTORY_GUIDE:26 last tree entry → §4.3 pair-edit under a D-valve is GATE-OWNED, not executor VERIFIED
P6 tracked 105→121 count cascade GATE-OWNED (README:58, summary:9, save-context:53/PB-06) VERIFIED
P7 rollback tags stress1-a0 (pre-build) and stress1-a (Stage A close) must exist before A1/B1 — UNMET, orchestrator creates
P8 the shell-fetch-piped-to-interpreter class is hook-denied; the bare fetch verb is not; tests use the node:http client regardless VERIFIED
Expected red after Stage A commit: 121-vs-105 bindings + dirty-tree canary = documented commit-straddle, gate-owned.

## 1. FILE TREE — 16 files
package.json (module, engines>=22, zero deps) · README.md (no mermaid; threshold stated) ·
public/index.html · public/privacy.html · public/styles.css · public/app.js (no fetch-API/XHR/dynamic-import) ·
src/mime.js · src/safepath.js · src/router.js · src/server.js (127.0.0.1 only) · bin/serve.js (--port default 0) ·
tools/branch-proxy.mjs · test/router.test.js (6) · test/content.test.js (5) · test/server.test.js (5) · test/complexity.test.js (2)

## 2. STAGE A — one lead-executor dispatch, 6 steps, 52,000 tokens
A1 scaffold+package.json (accept: jq dep-probe exits 1; type=module) 6K · A2 index.html original copy, zero external origins, >=4 sections 12K ·
A3 privacy.html (collection/retention/contact; zero third-party) 8K · A4 styles.css+app.js (no at-import; no fetch-API/XHR/dynamic-import) 8K ·
A5 README (no mermaid; the test command; threshold 8 stated) 6K · A6 constraint sweep (6 files tracked; 0 abs-path; 0 cred-shapes; 0 non-loopback origins) 12K.
Close: checkpoint commit + tag stress1-a before Stage B. rollback_tag all steps: stress1-a0.

## 3. STAGE B — one lead-executor dispatch, 8 steps, 68,000 tokens
B1 mime+safepath (traversal fence: dot-dot plain, percent-encoded, absolute system path → null) 8K · B2 router pure fn (200 root + privacy, 404, 405 with Allow, 400 refused) 9K ·
B3 server+CLI loopback (never the all-interfaces address; SIGTERM exit 0; node:+relative imports only) 9K · B4 branch-proxy.mjs (NAME tab COUNT per function; at-or-under 8 passes; nonzero names offender) 9K ·
B5 router+content suites (11 names set-equal both directions) 11K · B6 live-server suite with exactly 3 edge- cases; port 0; porcelain-clean after 11K ·
B7 complexity suite + negative control (9-branch planted fn in OS-temp, never repo) 8K · B8 bind: TAP pass 18 fail 0, two consecutive identical runs 3K.
rollback_tag all steps: stress1-a.

## 4. APP-SUITE CONTRACT — 18 cases (floor 15)
router: root-path-serves-index-html · privacy-path-serves-privacy-html · unknown-path-returns-404-with-a-body ·
post-to-a-static-path-returns-405-and-an-allow-header · query-string-does-not-change-the-resolved-file · plain-dot-dot-traversal-is-refused
content: every-asset-referenced-by-a-page-resolves-on-disk · no-page-references-an-external-origin ·
declared-content-types-cover-every-served-extension · privacy-page-states-collection-retention-and-contact · both-pages-share-one-stylesheet-and-no-inline-script
server: server-binds-loopback-and-reports-its-bound-port · two-identical-gets-return-byte-identical-bodies ·
EDGE1 edge-percent-encoded-traversal-is-refused · EDGE2 edge-head-returns-headers-and-an-empty-body · EDGE3 edge-aborted-request-does-not-kill-the-server
complexity: complexity-branch-count-proxy-max-8-per-function (THE proxy check; counts if, else-if, loops, case, and-and, or-or, ternary, plus 1; PROXY not CC; barred from frozen rubric) ·
branch-proxy-flags-a-planted-nine-branch-function (negative control)
THRESHOLD: 8 branches per function; 9 or more fails case 17.

## 5. DISCOURSE — two rounds under logs/rounds/stress1-round-{1,2}/
R1 parallel via arbiter (branch count is a floor): security-reviewer reads safepath/router/server/serve/index/privacy/app/package (dims: secrets, permission-widening, injection, destructive-surface, api-usage);
quality-reviewer reads src, tests, tools, README, styles, index, privacy (dims: correctness, consistency, simplicity, coverage, docs-drift).
R2 fixed grammar AGREE/CHALLENGE/CONNECT/SURFACE; each reads ONLY the other's R1 packet + cited paths; arbiter compiles discourse.md, confidence arithmetic, drops undefended challenges, releases to fixer.

## 6. BUDGETS — source context/budget-baseline.md:39 (lead-executor n=5 mean 88,874 min 58,187 max 118,365)
Stage A 52K + Stage B 68K = 120K authored. STATED PLAINLY: below the measured floor (2x88,874=177,748).
Per option-A ruling (G-F7b): a ceiling is a GATE TRIGGER, not pass/fail. Measure after each stage; record before interpreting.

## 7. CONSTRAINTS (binding)
node: builtins only; zero deps; nothing installed, nothing brought in from outside (HC-5). Loopback only; no fetch-API/XHR/dynamic-import/external origin/CDN/font/analytics.
Original content only — zero copying; genre = plain landing page (index + privacy, static bytes via node:http).
Runtime writes nothing under stress-site/; scratch goes to OS temp. No abs machine paths; no token-shaped literals; no mermaid fence.

## 8. WEAKEST CLAIM
The 120K two-stage budget — authored, not measured; baseline predicts 177,748 (1.48x); falsifier = measure-dispatch-cost after each stage; expectation RECORDED PRE-RUN that the trigger fires (C-18 discipline).
Runner-up: EDGE3 abort-timing flake; falsifier = 10 consecutive runs; mitigation = state-check rewrite (post-abort GET returns 200).
Not claimed: proxy measures CC; site accessible/performant; crew suite green after Stage A (P6/P7 say why).

## HANDOFF
Two lead-executor dispatches through the arbiter. BLOCKING before A1: tag stress1-a0 must exist (P7).
P5 pair-edit + P6 cascade are gate-owned; executor must not attempt them.
