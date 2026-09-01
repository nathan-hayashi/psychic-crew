# CORPUS-OPENHANDS — the dive, against its named question

**The question (named at CORPUS-0):** How does OpenHands bound an agent's action space per step
(permissions, sandboxing), and which of those bounds have no equivalent in our hook layer?

## Identity

The corpus snapshot is **Agent Canvas** — OpenHands' self-hosted developer control center that
runs OpenHands, Claude Code, Codex, Gemini, or any ACP-compatible agent across local, remote,
and cloud backends. It is the CONTROL-PLANE repo, not the classic dockerized agent runtime; the
per-step bounds visible here are the ones the control plane itself enforces. Sidecars excluded
per the CORPUS-0 rule; nested extract at `OpenHands-main/`.

## Read manifest (M4: targeted)

README head · `src/hooks/use-has-permission.ts` (whole file — 7 lines) ·
`specs/workspace-upload-path.md` (whole spec) · `specs/` listing · targeted greps over
`src/utils/acp-command.ts` and `src/types/settings.ts` for permission/trust/confirm surfaces.

## Findings

1. **The per-step gate is ONE boolean.** `confirmation_mode: boolean` in settings — a single
   global switch over action confirmation, not per-action-class policy.
2. **The OSS permission hook is fail-OPEN by design.** `useHasPermission` returns `true` for
   every permission string, with the comment saying exactly that — RBAC is the cloud product's
   concern; the OSS surface grants by string.
3. **Path bounding is real and spec-driven.** The workspace-upload-path spec anchors every
   relative working dir against the agent-server's declared home (`/api/file/home`), caches the
   anchor per host, deliberately does NOT cache failed lookups, and records that the legacy
   naive resolver was REMOVED once its last callers disappeared — "the home-anchored resolver is
   the only sanctioned mechanism," with the removal noted as recoverable from git history.
4. **Capability is negotiated per session (ACP), not wired statically** — which agent runs, over
   which backend, with which declared capabilities, is a runtime conversation between control
   plane and agent.

## The answer

Bounds with NO equivalent in our hook layer: **one** — per-session capability negotiation. Our
layer wires its guards statically in settings and the two-root law; nothing here negotiates what
a session may do at runtime. That absence is DELIBERATE and stays: static fail-closed wiring is
the posture (a negotiable guard is a guard an agent can talk its way out of) — recorded as
considered-and-rejected-with-reason, not as a gap to fill. The rest is already held or held
more strongly: our per-action-CLASS hooks (bash-blocker patterns, sensitive-guard write scopes,
model-guard, release-guard) are strictly finer than the one confirmation boolean; our layer
never fail-opens where their OSS permission hook always does; their only-sanctioned-resolver
rule is our two-root law, already suite-asserted since HARNESS-CONV-1.

## The transfer — NONE this gate, stated loudly

No check transfers as a new suite arm (the no-silent-caps law: this is announced, not elided).
Two ideas are RECORDED for their owners instead: the failed-lookup-is-never-cached rule (a
cache-poisoning guard worth remembering if this estate ever caches a resolution), and the
checkbox executable-spec style (each requirement a testable [x] clause — the shape our GATES
rows already approximate).

## Disposition

- **Already held:** fail-closed beats fail-open; per-class beats boolean; only-sanctioned-
  resolver = the two-root law (asserted).
- **Rejected with reason:** runtime capability negotiation — static wiring IS the control.
- **Recorded for later:** failed-lookup-not-cached; executable-spec checkboxes.

**Question discharged.** (Census flips QUEUED → DIVED; this document is the standing record.)
