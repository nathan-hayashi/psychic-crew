# CORPUS-0 — the coverage table, the four-value census, and the eight questions

Arc 2's opening contract: every census row maps to a discharging gate or an explicit exemption,
suite-asserted both directions (`scripts/check-decision-matrices.sh`), so the arc cannot close
partial silently. The census vocabulary is re-ratified FOUR-VALUE by this gate's token:
`ETL-BUILD / DIVED / QUEUED / PROHIBITED` — `BARRED` is retired because it conflated "no
question named yet" (now QUEUED, reopened by its dive gate) with the absolute prohibition (now
PROHIBITED, closed by LAW and asserted by ABSENCE from disk).

Columns: name, census status, tier, discharge (a gate id, or the exemption).

```text
# CORPUS-COVERAGE v1
zeroshot	DIVED	full	CORPUS-ZEROSHOT
OpenHands	DIVED	full	CORPUS-OPENHANDS
conductor	DIVED	full	CORPUS-CONDUCTOR
claude-agent-sdk-python	DIVED	full	CORPUS-SDKPY
takt	QUEUED	full	CORPUS-TAKT
langgraph	QUEUED	full	CORPUS-LANGGRAPH
agent-framework	QUEUED	full	CORPUS-AGENTFW
babysitter	QUEUED	full-split	CORPUS-BABYSITTER-1+CORPUS-BABYSITTER-2
turbo	ETL-BUILD	delta	CORPUS-DELTA
open-code-review	ETL-BUILD	delta	CORPUS-DELTA
neatcontext-plugins	ETL-BUILD	delta	CORPUS-DELTA
mermaid-hybrid-stack-guide	ETL-BUILD	delta	CORPUS-DELTA
gastown	DIVED	promoted	CORPUS-0
ruflo	DIVED	promoted	CORPUS-0
oh-my-claudecode	DIVED	promoted	CORPUS-0
orca	DIVED	done	RSCH-4
claude-agent-orchestration-guide	ETL-BUILD	done	F6
automation-ecosystem	PROHIBITED	exempt	PROHIBITED-BY-LAW
```

Arithmetic, closed: 7 full + 1 full-split (two gates, one row) + 4 delta + 3 promoted (this
gate) + 2 done (RSCH-4, F6) + 1 prohibited-exempt = 18 rows; 17 on disk, and the 18th's ABSENCE
is the assertion.

## The eight questions (named HERE, before any reading — M4's law)

A dive gate reads its corpus ONLY against its named question; a dive that reads first violates
the law it cites. One question per QUEUED row, suite-bound both directions.

```text
# CORPUS-QUESTIONS v1
takt	How does takt encode the pacing of agent turns (cadence, budgets), and does any mechanism map onto our budget-baseline discipline?
langgraph	What does langgraph checkpoint per graph node, and how do its resume semantics compare to our disk-canonical continuity law (HC-8)?
agent-framework	What contract does agent-framework enforce between planner and executor roles, and where does it place the human gate relative to ours?
babysitter	What supervision loop does babysitter run over child agents — part 1 (BABYSITTER-1): what it watches and how it detects; part 2 (BABYSITTER-2): what it intervenes with — and which halves transfer under our human-gate law?
```

## Adopted corrections

- **Sidecar exclusion** (from RSCH-4's orca survey, now census-wide): NTFS `:Zone.Identifier`
  sidecar files carry a Windows-user path and are EXCLUDED from all corpus evidence listings and
  counts, every dive gate.
- **Map counts**: any corpus file-count cited in a dive doc states whether sidecars and build
  output are excluded (the oh-my-claudecode lesson: 12,012 files, ~1,526 source — a count
  without its denominator's definition misleads).
