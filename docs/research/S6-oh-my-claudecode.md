# S6 dive — oh-my-claudecode (promoted at CORPUS-0)

Provenance: these findings were recorded in `Plan.md` as dated S6 ledger entries (2026-08-19/20)
and are promoted here VERBATIM — the census showed oh-my-claudecode as DIVED with no standing document, so
the record moves to where a reader looks, unedited. The ledger remains the original.

## The dive record, quoted

> [S6|2026-08-20T00:14:40Z] OH-MY-CLAUDECODE DIVE. Read targeted per the map: the team skill and the routing surface, not the 12,012 files (of which ~1,526 are source; the rest is build output). THE STAGED LOOP is recognisably F7's pipeline — decompose, execute, verify, fix — with the difference the map already identified: OMC runs it PER TASK ON DEMAND, this build runs it once per phase behind a human gate. LIVE PLATFORM FACT worth recording and marked [V?] for confirmation: their skill states that Claude Code 2.1.178+ REMOVED native TeamCreate/TeamDelete, and that with an experimental agent-teams environment flag each session has ONE IMPLICIT TEAM whose teammates are spawned directly with the dispatch tool using distinct name values. That is consistent with EX-05 as this build restated it — the orchestrator dispatches, subagents do not — but it names a flag whose effect on that premise has NOT been verified here. Registered as a question for whoever next touches the dispatch law, not acted on. ALSO: their pipeline can be wrapped in a persistence loop that retries on failure and requires architect verification before completion — that is the Ralph design D2b earmarked for the corpus, already integrated by a project we have. Their multi-vendor worker types are excluded here by HC-7 and need no further thought.

## Disposition

Adopted: nothing directly — the staged loop was already F7's pipeline shape. Registered, still
open: the [V?] platform fact about agent-teams flags and the dispatch-law question it raises for
whoever next touches EX-05. Excluded by law: multi-vendor worker types (HC-7).

## AT-1 verification note (2026-09-03, dated append)

The [V?] platform fact above was verified at DIVE-W1-AT-1 against the official page
(code.claude.com/docs/en/agent-teams, fetched 2026-09-03): CONFIRMED INTACT — TeamCreate and
TeamDelete no longer exist as of v2.1.178, each session carries one implicit session-named
team, and teammates spawn via the Agent tool with a name while
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 (default OFF). The dispatch-law question it raised is
answered in that dive's record; the standing threat surface it revealed is GR-carried.
