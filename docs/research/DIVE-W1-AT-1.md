# DIVE-W1-AT-1 — the agent-teams flag, verified

**Gate:** DIVE-W1-AT-1 (wave dive 5; dry-eligible). **Source:** dated web fetches (lane laws;
PROGRAM-OPEN ruling scope). **Question (fixed at SOURCE-MAP-1):** does the agent-teams
environment flag exist in current Claude Code documentation, and does its semantics touch the
EX-05 dispatch law? **Prediction on record:** TAKE-ZERO.

## Read manifest (measured)

One web search + one full official-page fetch, retrieval date 2026-09-03:
code.claude.com/docs/en/agent-teams (the complete page, read whole). The S6 claim under test
re-read from docs/research/S6-oh-my-claudecode.md.

## The answer

**The flag exists**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, research preview since
February 2026, DISABLED BY DEFAULT — without it, no team is set up, no team directories are
written, and no teammates spawn. **The S6 [V?] claim verifies remarkably intact**: as of
v2.1.178 the TeamCreate/TeamDelete tools genuinely no longer exist; each session has exactly
ONE implicit team under a session-derived name (session- + 8 id chars); teammates launch when
the lead calls the Agent tool WITH A NAME while the flag is on.

**Does it touch EX-05? Yes — as a named threat surface, not a live breach.** Enabled teams
are the ANTITHESIS of this estate's topology: teammates message each other DIRECTLY through
mailbox files under the user scope (~/.claude/teams/.../inboxes/), self-claim from a shared
task list, and coordinate WITHOUT the lead — peer-to-peer where our law is arbiter-brokered
star. The spawn itself still passes PreToolUse[Agent] (HOOK-2's guard keeps seeing it), but
post-spawn teammate-to-teammate traffic is SendMessage, not the Agent tool: outside the
dispatch guard's matcher and outside every trail HOOK-1 writes. Three facts bound the risk
today: the flag is default-off; non-interactive sessions never spawn teammates even with it
set; and a settings-layer pin to "0" overrides a shell export (project settings beat user
env per the documented precedence — though local/managed layers could still override). Also
verified in passing: teammates cannot spawn teammates (no nesting), and inter-agent messages
are marked as agent-origin — a teammate cannot relay approvals.

## Verdicts

```text
# DIVE-AT-1-VERDICTS v1
1	omc-claim-verified-intact	VALIDATE-AGAINST	GR-085	code.claude.com/docs/en/agent-teams fetched 2026-09-03; TeamCreate removal + implicit team + name-spawn all confirmed
2	teams-flag-ex05-threat-surface	VALIDATE-AGAINST	GR-136	peer mailboxes outside the estate's trails; default-off + headless immunity + the available settings pin bound the risk
3	agent-origin-message-marking	VALIDATE-AGAINST	GR-085	teammates cannot relay approvals - the platform's own untrusted-relay rule converges with our document-authority law
```

Roll-up: **0 TAKE-PATTERN · 0 MODULATE-OURS · 3 VALIDATE-AGAINST · 0 REJECT** — measured
outcome **0 TAKE-class** (TAKE-ZERO; five predictions for five) — **and the dry tail reads
[0,0]: the wave is DRY-ELIGIBLE.**

## Landing shapes

No TAKE-class shapes. One defensive line rides the register row it created: pinning
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to "0" in the project settings env would make the
default-off state a declared, settings-precedence-backed fact — a HIGH-surface one-liner
that belongs to the successor program under the operator's word, recorded on GR-136.

## Register delta

- GR-085 → **RESOLVED:DIVE-W1-AT-1** (flip logged): the [V?] is verified, dated, and confirmed
  intact; the dispatch-law question it raised is answered in this record.
- NEW GR-136 (dispatch-residual · external-drift · no · OPEN): the agent-teams flag,
  if ever enabled in any settings layer, routes teammate coordination outside the dispatch
  guard's matcher and the estate's trails; protection today is default-off plus headless
  immunity; the settings pin is the available hard line. Mid-wave-born demand, by design.
- A dated verification note lands beside the S6 record (med-class doc append).

## Weakest claims, flagged

`[E-limits]` One page, fetched once, dated — platform docs drift; the new register row's
external-drift class exists precisely to re-verify. `[I]` "Outside every trail" rests on the
documented mailbox path and SendMessage tool identity; an undocumented hook surface for
teammate traffic would narrow the finding.

Evidence census: [E] 9 · [I] 2 · [S] 0 · [V?] 0
