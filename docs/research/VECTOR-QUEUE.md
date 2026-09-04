# VECTOR-QUEUE — the ordered process queue (derived; never hand-edited)

**This file is generated**: `scripts/route-vector.sh --all > docs/research/VECTOR-QUEUE.md`.
It is a pure function of (GAP-REGISTER OPEN rows, config/vector-rules.json) — no timestamp, no
trail, no model. The suite re-derives it every run and byte-diffs this committed copy; if that
arm ever reds, run the command above and re-verify — the queue is repaired by derivation, never
by hand. Rules provenance: sha256 `3716d1b9d0dfbba81d3acc20644b6847cd3c4f4e66d4a296892f36f4c0556f30` (128 OPEN rows routed).

Routing policy prose lives beside the rules ids in the fence below and in
config/vector-rules.json's own why fields; the mapping lives ONLY there — this queue never
states destinations of its own.

## The queue (priority, then id)

```text
# VECTOR-QUEUE v1
GR-001	build-gate	1	V-UNVER-NONE
GR-005	build-gate	1	V-UNVER-NONE
GR-008	build-gate	1	V-UNVER-NONE
GR-009	build-gate	1	V-UNVER-NONE
GR-039	build-gate	1	V-UNVER-NONE
GR-066	research-dive	1	V-UNREAD
GR-068	research-dive	1	V-UNREAD
GR-081	research-dive	1	V-UNREAD
GR-082	build-gate	1	V-UNVER-NONE
GR-088	build-gate	1	V-UNVER-NONE
GR-109	build-gate	1	V-UNVER-NONE
GR-113	research-dive	1	V-UNREAD
GR-134	research-dive	1	V-UNREAD
GR-137	build-gate	1	V-UNVER-NONE
GR-002	build-gate	2	V-UNVER-PART
GR-003	build-gate	2	V-UNVER-PART
GR-004	build-gate	2	V-UNVER-PART
GR-006	build-gate	2	V-UNVER-PART
GR-010	build-gate	2	V-UNVER-PART
GR-012	build-gate	2	V-UNVER-PART
GR-013	operator-word	2	V-OPWORD
GR-014	operator-word	2	V-OPWORD
GR-015	operator-word	2	V-OPWORD
GR-017	build-gate	2	V-UNEXER
GR-019	build-gate	2	V-UNVER-PART
GR-020	build-gate	2	V-UNVER-PART
GR-022	build-gate	2	V-UNEXER
GR-024	build-gate	2	V-UNEXER
GR-025	build-gate	2	V-UNEXER
GR-026	build-gate	2	V-UNEXER
GR-028	build-gate	2	V-UNVER-PART
GR-030	build-gate	2	V-UNVER-PART
GR-031	build-gate	2	V-UNVER-PART
GR-032	operator-word	2	V-OPWORD
GR-033	build-gate	2	V-UNVER-PART
GR-037	build-gate	2	V-UNVER-PART
GR-038	operator-word	2	V-OPWORD
GR-044	build-gate	2	V-UNEXER
GR-047	build-gate	2	V-UNEXER
GR-050	build-gate	2	V-UNVER-PART
GR-054	build-gate	2	V-UNEXER
GR-058	web-verify	2	V-DRIFT
GR-062	web-verify	2	V-DRIFT
GR-065	build-gate	2	V-AMBIG
GR-070	operator-word	2	V-OPWORD
GR-071	operator-word	2	V-OPWORD
GR-072	operator-word	2	V-OPWORD
GR-073	operator-word	2	V-OPWORD
GR-074	operator-word	2	V-OPWORD
GR-075	operator-word	2	V-OPWORD
GR-076	web-verify	2	V-DRIFT
GR-079	build-gate	2	V-UNEXER
GR-080	web-verify	2	V-DRIFT
GR-083	build-gate	2	V-UNEXER
GR-084	build-gate	2	V-AMBIG
GR-087	operator-word	2	V-OPWORD
GR-089	operator-word	2	V-OPWORD
GR-093	web-verify	2	V-DRIFT
GR-094	build-gate	2	V-UNVER-PART
GR-095	web-verify	2	V-DRIFT
GR-111	build-gate	2	V-AMBIG
GR-112	build-gate	2	V-AMBIG
GR-115	operator-word	2	V-OPWORD
GR-117	build-gate	2	V-UNEXER
GR-119	build-gate	2	V-UNEXER
GR-120	build-gate	2	V-UNEXER
GR-126	operator-word	2	V-OPWORD
GR-127	build-gate	2	V-UNEXER
GR-131	build-gate	2	V-AMBIG
GR-132	build-gate	2	V-AMBIG
GR-133	build-gate	2	V-AMBIG
GR-136	web-verify	2	V-DRIFT
GR-007	accepted-limit	3	V-ACCEPTED
GR-011	accepted-limit	3	V-ACCEPTED
GR-016	accepted-limit	3	V-ACCEPTED
GR-018	accepted-limit	3	V-ACCEPTED
GR-021	accepted-limit	3	V-ACCEPTED
GR-023	accepted-limit	3	V-ACCEPTED
GR-027	accepted-limit	3	V-ACCEPTED
GR-029	accepted-limit	3	V-ACCEPTED
GR-034	accepted-limit	3	V-ACCEPTED
GR-035	accepted-limit	3	V-ACCEPTED
GR-036	accepted-limit	3	V-ACCEPTED
GR-040	accepted-limit	3	V-ACCEPTED
GR-043	accepted-limit	3	V-ACCEPTED
GR-045	accepted-limit	3	V-ACCEPTED
GR-046	accepted-limit	3	V-ACCEPTED
GR-048	accepted-limit	3	V-ACCEPTED
GR-049	accepted-limit	3	V-ACCEPTED
GR-051	accepted-limit	3	V-ACCEPTED
GR-052	accepted-limit	3	V-ACCEPTED
GR-053	accepted-limit	3	V-ACCEPTED
GR-055	accepted-limit	3	V-ACCEPTED
GR-056	named-wake	3	V-WAKE
GR-057	named-wake	3	V-WAKE
GR-059	named-wake	3	V-WAKE
GR-060	named-wake	3	V-WAKE
GR-061	named-wake	3	V-WAKE
GR-063	named-wake	3	V-WAKE
GR-064	named-wake	3	V-WAKE
GR-067	accepted-limit	3	V-ACCEPTED
GR-069	named-wake	3	V-WAKE
GR-090	accepted-limit	3	V-ACCEPTED
GR-091	accepted-limit	3	V-ACCEPTED
GR-092	accepted-limit	3	V-ACCEPTED
GR-096	accepted-limit	3	V-ACCEPTED
GR-097	accepted-limit	3	V-ACCEPTED
GR-098	accepted-limit	3	V-ACCEPTED
GR-099	accepted-limit	3	V-ACCEPTED
GR-100	accepted-limit	3	V-ACCEPTED
GR-101	accepted-limit	3	V-ACCEPTED
GR-102	accepted-limit	3	V-ACCEPTED
GR-103	accepted-limit	3	V-ACCEPTED
GR-104	accepted-limit	3	V-ACCEPTED
GR-105	accepted-limit	3	V-ACCEPTED
GR-106	accepted-limit	3	V-ACCEPTED
GR-107	accepted-limit	3	V-ACCEPTED
GR-108	accepted-limit	3	V-ACCEPTED
GR-110	accepted-limit	3	V-ACCEPTED
GR-114	accepted-limit	3	V-ACCEPTED
GR-116	accepted-limit	3	V-ACCEPTED
GR-118	accepted-limit	3	V-ACCEPTED
GR-121	accepted-limit	3	V-ACCEPTED
GR-122	accepted-limit	3	V-ACCEPTED
GR-123	accepted-limit	3	V-ACCEPTED
GR-124	accepted-limit	3	V-ACCEPTED
GR-125	accepted-limit	3	V-ACCEPTED
GR-128	accepted-limit	3	V-ACCEPTED
```

## Roll-up (per resolution class)

| resolution | rows |
|---|---|
| accepted-limit | 48 |
| build-gate | 45 |
| named-wake | 8 |
| operator-word | 15 |
| research-dive | 5 |
| web-verify | 7 |

## Weakest claims, flagged

[I] The routing is only as good as the register's uncertainty_class labels — a mislabeled row
routes confidently to the wrong process, and no arm can see that; the calibration roll-up at
SYNTH-1 is where systematic mislabeling would surface. [E-limits] ESCALATE rows (engine or
catch-all) are the operator's bin by design; zero today means the policy covers the current
register, not that it covers tomorrow's rows.
