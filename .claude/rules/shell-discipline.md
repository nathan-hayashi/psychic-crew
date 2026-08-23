# shell-discipline.md — standing write-path idioms (R-SD-1, 2026-08-22)
Born from five recurrences across two builds of one defect class; the instance
fixes live in the correction registries (parent: the C-27 sweep; Lite: the L2
clean-tree write, f03835f). These are standing rules, enforced by a class
assertion in each repo's suite.
1. Count-then-default composites are forbidden. `$(cmd || echo DEFAULT)` is
   illegal wherever cmd can print before failing. Canonical offender:
   `grep -c PAT FILE || echo 0` — grep -c prints its count and THEN exits
   nonzero on zero matches, so the composite emits two lines ("0" and "0") and
   corrupts any numeric consumer. grep -c never needs a default; it always
   prints a number.
2. Capture, then test, then validate. `n=$(grep -c PAT FILE)`; branch on the
   exit status explicitly where it matters; validate `[[ $n =~ ^[0-9]+$ ]]`
   before the value reaches --argjson, arithmetic, or any ledger.
3. A write is not a write until it is read back. Every append to a ledger,
   history, or trail confirms its own line landed and fails loudly otherwise —
   printing "recorded" is not recording. Proven twice: the guard has already
   caught its own author.
4. Runtime chatter and durable history never share a file (the C-13/C-14
   class). Durable means tracked, append-only, commit-stamped; any query over
   mixed stores labels every hit [durable] or [runtime] and states plainly when
   an answer does not travel off this machine.
Enforcement: the suite's class assertion scans comment-stripped shell for the
forbidden composite using fragment-assembled needles. The allowlist is empty
and stays empty.
