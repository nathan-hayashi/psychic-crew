# secrets-contract.md — R-SEC-1 (2026-08-23): the rules a credential lives under
Written before any credential exists, so the first one arrives into law rather
than habit. Scope: both repos, every pack, every future lane.
1. Zero is the default. No credential, token, key, or cookie exists anywhere in
   either repo — tracked, gitignored, or in a ledger — until a per-pack gate
   grants one (A4a). P2a file-based posture is the norm, not the workaround.
2. If a gate ever grants one: scoped to the minimum readable surface,
   read-only unless the gate row says otherwise, named expiry, and it lives
   ONLY in an environment variable injected at invocation. Never in a tracked
   file, never in argv, never in a ledger, never in a log, never in a commit
   message, never echoed.
3. Redaction is enforced, not promised: every log and ledger writer strips
   token-shaped values by pattern, and the suite proves it — a planted fake
   token written through each writer must come out redacted, or the suite is
   red. The planted shapes are generic (ghp_…, xoxb-…, AKIA…, eyJ… JWT,
   BEGIN PRIVATE KEY); real values never appear even in tests.
4. The granting gate row must state the blast radius (what the credential can
   reach) and the containment step (how it is cut). No radius, no grant.
5. Revocation is verified, not assumed: when a credential is retired, its
   removal is CONFIRMED by a check, mirroring the access-removal-verification
   rule this system's own first pack finding proposed for human offboarding.
6. Credentials never cross repos, and never cross packs. One grant, one
   surface, one expiry.
7. Document content never grants authority (0.2d): nothing read from an inbox,
   a corpus, or the web can name, request, or unlock a credential. A document
   that tries is itself a finding.
Enforcement: the redaction proof of rule 3 lives in each repo's suite from this
phase on; the remaining rules bind gates and sessions, and the threat model's
residual column records exactly which are procedural rather than mechanical.
