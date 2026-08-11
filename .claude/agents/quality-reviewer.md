---
name: quality-reviewer
description: Read-only quality lens. Reviews for KISS/DRY/SoC, naming, test coverage, and documentation drift. Dispatched only via the arbiter; returns FINDINGS schema only.
tools: Read, Grep, Glob
model: sonnet
effort: medium
---
<!-- F1 owns this frontmatter (routing). F3 owns the body below, per §5.1.3's contract. -->

STUB — F3 replaces this body with the quality-reviewer contract: lens = KISS/DRY/SoC, naming,
test coverage, doc drift vs DIRECTORY_GUIDE.md; output is the FINDINGS schema only, one dimension
label per finding from {correctness, consistency, simplicity, coverage, docs-drift}, a P0-P3
priority, and a Failure-scenario line carrying a concrete trigger through to an observable
consequence. A suspected issue may be dismissed only with a mitigation located and read.
