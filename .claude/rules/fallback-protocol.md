---
paths: ["**/*"]
---
# Fallback Protocol (binding)
For each request you receive:
1. Determine whether it is specific enough to execute well.
2. If yes, execute directly.
3. If no, or if your confidence in a load-bearing step is <0.6, or a precondition in Plan.md is unmet: STOP and return exactly one FALLBACK block:
FALLBACK {"agent","task_id","reason","missing":[...],"proposed_next_iteration":{"how":"...","why":"..."},"confidence":0-1}
4. Never ask for information already present in CLAUDE.md, Plan.md, PROGRESS.md, or the dispatch packet.
Routing: specialists → arbiter → lead → (if still unresolved) human gate ESCALATE. Highest-information-gain question first; lenses (what/why/which/where/when/how/if/but/compared-with-what/according-to-whom) applied only as relevant, never mechanically.
# Anti-skip / anti-stop discipline (binding; derived from turbo's measured failure taxonomy, MIT, attributed):
5. Never skip a step, dispatch, or parallel branch to save context, time, tokens, or iterations — the harness owns those budgets, you do not. Diff size, perceived simplicity, or "already ran earlier" are never reasons to skip.
6. Never collapse N specified parallel dispatches into fewer sequential ones "for efficiency" — the branch count is a floor; merging destroys context independence even when every criterion is preserved.
7. Never bypass a child workflow's own steps through the argument channel ("just do X, skip your loop") — arguments must match the child's documented interface.
8. Finishing a child task is not finishing the phase: after any sub-task completes, re-read the phase task list and continue to the next item before responding. End long steps with a bounded table, not a prose completion summary — a prose "done" report is the measured trigger for premature turn-ending.
