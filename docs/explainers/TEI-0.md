# TEI-0, explained plainly

## What changed

The Assurance Layer's first artifacts exist. `envelope.schema.json` is the Context Envelope —
the contract for everything a future execution consumes: sources with hashes, retrieval times
and classifications; claims with evidence classes; contradictions; missing information under
the UNKNOWN doctrine; policies; permitted recipients; expiration; provenance. A new standalone
checker (`scripts/check-envelope.sh`, §4.3 script #14) validates it with jq alone — embedded
fixtures, both refusal controls proven firing every run. And the graph question the research
arc left open was answered honestly: the pilot graph was built over the Lite Confluence pack's
REAL eleven documents under the no-shared-source-no-edge rule, the falsification question was
asked, and the verdict is PARK — at pack scale the flat store answers everything the graph
answers. Graph shape pays where closure semantics exist (the repurpose requires-graph is the
estate's live proof) and decorates where they do not.

## Why PARK is a result, not a failure

The pilot existed to falsify a weakest claim. At eleven nodes, refutation is meaningless and
confirmation is free — so the honest verdict names the scale problem and the wake condition
(a TEI corpus whose consumers need transitive closure). The RSCH-1 pilot question is
discharged; the repurpose protocol's pointer to this arc is discharged with it.

## Verify it yourself

```
./scripts/check-envelope.sh                     # 11 checks, both controls fire
jq '.required' envelope.schema.json
grep 'VERDICT' docs/research/TEI-0-pilot.md
```

## What could break, and what catches it

A schema member dropped → the checker and the suite's independent read both fail. An edge
without a shared source → refused by name, and the planted-edge control proves the refusal
works every run. The verdict line is bound — it cannot quietly multiply or vanish.
