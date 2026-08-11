# GATES.md — Gate Ledger
Format per F5: gate · ISO · demo_result · stress_result · operator_token_line. Verdicts are exactly PASS | FAIL | ESCALATE (§0.2c); PASS requires zero open P0/CRITICAL findings. Backfilled F0–F4 at F5.

| Gate | ISO (UTC) | Demo result | Stress result | Operator token line |
|---|---|---|---|---|
| G-F0 | 2026-08-11T04:02:53Z | tree + validate-crew 7 PASS / 3 SKIP / 0 FAIL + repo live; evidence decayed at commit eb2f01a (validator self-match, §5.2.4) and was repaired + **re-verified 2026-08-11T04:23:36Z**, confirmed independently by the operator's support-session audit | idempotency zero-diff across 12 files; HC-5 deny-list config shown (live hook test deferred to G-F2 per plan) | **APPROVED** `APPROVE GATE-F0` @ 2026-08-11T04:41:35Z |
| G-F1 | 2026-08-11T04:48:41Z | reroute quality-reviewer opus/high via config → apply → frontmatter diff → revert; validate-crew 8 PASS / 3 SKIP / 0 FAIL | 5 fable poison vectors (agent model, session model, pinned map, alias map, agent frontmatter) each exit 2; clean-config control exit 0; prose mention correctly ignored | **APPROVED** `APPROVE GATE-F1` @ 2026-08-11T05:01:16Z |
| G-F2 | (pending) | (pending) | (pending) | awaiting `APPROVE GATE-F2` |
