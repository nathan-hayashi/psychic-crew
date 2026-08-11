# GATES.md — Gate Ledger
Format per F5: gate · ISO · demo_result · stress_result · operator_token_line. Verdicts are exactly PASS | FAIL | ESCALATE (§0.2c); PASS requires zero open P0/CRITICAL findings. Backfilled F0–F4 at F5.

| Gate | ISO (UTC) | Demo result | Stress result | Operator token line |
|---|---|---|---|---|
| G-F0 | 2026-08-11T04:02:53Z | tree + validate-crew 7 PASS / 3 SKIP / 0 FAIL + repo live | idempotency zero-diff across 12 files; HC-5 deny-list config shown (live hook test deferred to G-F2 per plan) | awaiting `APPROVE GATE-F0` |
