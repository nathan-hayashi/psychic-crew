# CORPUS-SDKPY — the dive, against its named question

**The question (named at CORPUS-0):** Which session and tool lifecycle events does the SDK
expose that our hooks cannot see, and what would each enable as an assertion?

## Identity

claude-agent-sdk-python — the official Python SDK for building Claude agents; the relevant
surface is its strongly-typed hook vocabulary (`src/claude_agent_sdk/types.py`), where every
event carries a TypedDict input (base: session_id, transcript_path, cwd, permission_mode; tool
events add a subagent-context mixin with agent_id). Nested extract; sidecars excluded.

## Read manifest (M4: targeted)

`src/claude_agent_sdk/` listing · `types.py` — the HookEvent union and every HookInput class
(lines 263–400, read directly) · our own `.claude/settings.json` hook keys (jq), for the diff.

## Findings

The SDK's event vocabulary is ten strong: PreToolUse, PostToolUse, PostToolUseFailure,
UserPromptSubmit, Stop, SubagentStop, PreCompact, Notification, SubagentStart,
PermissionRequest. This repo wires eight (plus SessionStart, which the platform provides
outside this SDK union). The THREE the SDK exposes that our layer never sees:

1. **UserPromptSubmit** (`prompt: str`) — the turn's entry point, before any processing.
2. **SubagentStop** (`agent_id`, `agent_transcript_path`, `agent_type`) — the closing half of
   the lifecycle whose opening half (SubagentStart) we already log to
   `logs/subagent-starts.jsonl`.
3. **PermissionRequest** (with subagent context) — the ask-for-permission moment itself, agent-
   attributed.

Also unexploited: PreCompact's typed `trigger: manual|auto` (our emergency checkpoint does not
record which), and Notification's typed `notification_type`.

## The answer — each absence, priced as the assertion it would enable

- **UserPromptSubmit** would enable machine-stamped receipt of gate tokens (the exact-token
  arrival recorded at submission, not reconstructed from ledger prose) and remote-preamble
  recognition at entry (a REMOTE PROMPT PROTOCOL turn logged as such the moment it lands).
- **SubagentStop** would enable the PAIRED-LIFECYCLE arm: every start row eventually matched by
  a stop row with the same agent_id — orphan detection (the hung-agent case gastown's watchdog
  chain exists for, cross-referenced in S6-gastown), and a partial close of C-25's standing
  SKIP (identity coverage currently sees births, never deaths).
- **PermissionRequest** would enable the other half of the denial trail: bash-blocker logs
  denials, but nothing logs ASKS — an agent-attributed record of every permission escalation,
  granted or not.

## The transfer — NONE this gate, by CLASSIFIER LAW, stated loudly

Wiring any of these is a `.claude/settings.json` change — HIGH class in the intake classifier,
a permission-surface edit that a dive gate must not smuggle in under a research token. All
three are RECORDED AS NAMED CANDIDATES awaiting an operator-declared gate (SubagentStop first —
it closes a standing SKIP and its log file's schema already exists by symmetry with the starts
trail). No pre-declared token exists for a hook gate; under the program's pre-declared-tokens
law, this queues as a proposal, not a build.

## Disposition

- **Recorded, operator's word required:** the three wirings above, each with its assertion
  spelled; SubagentStop flagged as the strongest (closes C-25's SKIP).
- **Already held:** the eight wired events; agent-attributed tool custody (C-25 runtime ids).
- **Rejected:** nothing — the SDK vocabulary is a superset, not a disagreement.

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)

## TM-FENCE-1 currency note (2026-09-04, dated append)

The awaiting-an-operator-declared-gate language above is DISCHARGED history: the three hook events priced here (SubagentStop, UserPromptSubmit, PermissionRequest) shipped
at HOOK-1 (2026-09-02, the register program). The prose above stays as the dated record of
the dive that priced it; this note is the pointer forward.
