---
name: threshold-router
description: Route every prompt by complexity tier. Use PROACTIVELY on every user prompt in this repo.
---
1. If env CREW_TIER_LOCK is set: tier := its value (expected T3). Announce `[T3 — LOCKED]` and apply full-orchestra behavior (plan → execute → arbiter-mediated review discourse → fixer → tests). Do not score.
2. Else score 0–10 (+2 multi-file, +2 security-sensitive, +2 cross-cutting arch, +2 multi-system coordination, +1 novel domain, +1 irreversibility) → 0-3 T1 solo · 4-7 T2 (implement + security+quality via arbiter + fixer) · 8+ T3.
3. Manual overrides: "just do it" −4 · "full review" := T3.
