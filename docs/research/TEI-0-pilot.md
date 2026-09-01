# TEI-0 — the graph pilot, run against the first workflow's real material

**The falsification target (RSCH-1's weakest claim, verbatim):** does the graph answer a
question the compiled-document store cannot, on the first workflow's real material?

**The material:** the Lite Confluence pack (selected at RSCH-3 §E) — its PACK.md,
doc-standards, two templates, and six attack fixtures, exactly as tracked in the twin. Eleven
nodes; every edge justified by the no-shared-source-no-edge rule (an edge exists only where
its source document appears in BOTH endpoints' source lists).

```text
# TEI-GRAPH v1
{
  "nodes": [
    {"id": "pack", "source_docs": [".claude/skills/packs/confluence-docs/PACK.md"]},
    {"id": "doc-standards", "source_docs": [".claude/skills/packs/confluence-docs/doc-standards.md", ".claude/skills/packs/confluence-docs/PACK.md"]},
    {"id": "tpl-proposal", "source_docs": [".claude/skills/packs/confluence-docs/templates/proposal.md", ".claude/skills/packs/confluence-docs/PACK.md"]},
    {"id": "tpl-routing", "source_docs": [".claude/skills/packs/confluence-docs/templates/routing.md", ".claude/skills/packs/confluence-docs/PACK.md"]},
    {"id": "fx-injection", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/instruction-injection.md"]},
    {"id": "fx-exfil", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/exfil-link.md"]},
    {"id": "fx-fake-system", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/fake-system-block.md"]},
    {"id": "fx-html-comment", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/html-comment-directive.md"]},
    {"id": "fx-routing-override", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/routing-override.md", ".claude/skills/packs/confluence-docs/templates/routing.md"]},
    {"id": "fx-traversal", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/..%2f..%2fetc%2fpasswd.md"]},
    {"id": "fx-attack-readme", "source_docs": [".claude/skills/packs/confluence-docs/fixtures/attack/README.md"]}
  ],
  "edges": [
    {"from": "pack", "to": "doc-standards", "source_doc": ".claude/skills/packs/confluence-docs/PACK.md"},
    {"from": "pack", "to": "tpl-proposal", "source_doc": ".claude/skills/packs/confluence-docs/PACK.md"},
    {"from": "pack", "to": "tpl-routing", "source_doc": ".claude/skills/packs/confluence-docs/PACK.md"},
    {"from": "doc-standards", "to": "tpl-proposal", "source_doc": ".claude/skills/packs/confluence-docs/PACK.md"},
    {"from": "fx-routing-override", "to": "tpl-routing", "source_doc": ".claude/skills/packs/confluence-docs/templates/routing.md"}
  ]
}
```

## The falsification run

**The question asked** (a join question — the graph's best case): *which attack fixture
targets a surface a shipped template defines, and through which document?*

**Graph answer:** one edge lookup — `fx-routing-override → tpl-routing` via
`templates/routing.md`. Constant-time, mechanical, no reading.

**Compiled-store answer:** grep the pack's eleven small files for cross-references —
seconds of scanning, same answer.

**The verdict follows from the arithmetic, not the wish:** at pack scale the flat store
answers EVERYTHING the graph answers, cheaply. The weakest claim was neither confirmed nor
refuted at a scale where refutation is meaningless — so the pilot verdict is the honest one:

VERDICT: PARK — the graph lane earns nothing at eleven nodes. Wake condition: a TEI corpus
whose consumers need CLOSURE SEMANTICS (transitive pulls), because the estate already holds
the live counter-example at exactly that shape — psychic-repurpose's requires-graph, where
eleven nodes DO pay because consumers take transitive closures, not lookups. Graph shape pays
where closure semantics exist; it decorates where they do not. The RSCH-1 pilot question is
DISCHARGED with this verdict, and the repurpose PULL-PROTOCOL §7 note (this arc owns the
pilot) is discharged with it.
