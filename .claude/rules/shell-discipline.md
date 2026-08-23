# shell-discipline.md — standing write-path idioms (R-SD-1 v2, 2026-08-22)
Born from five recurrences across two builds of one defect class, widened after
a sixth from its sibling class: the SIGPIPE flake fixed at b77fbec, where
C-09 failed one-in-four on unchanged inputs. Instance
fixes live in the correction registries; these are standing rules, enforced by
class assertions in each repo's suite.
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
5. A pipeline whose status is consumed must not have a signal-able producer.
   `producer FILE | grep -q PAT` under pipefail is forbidden: grep -q exits the
   instant it matches, the producer's next write takes SIGPIPE (141), and
   pipefail reports the producer's death as the pipeline's verdict — a race
   that scales with file size and load. Remedy, uniformly and with no
   small-input exemption: here-strings (`grep -q PAT <<<"$(producer FILE)"`)
   or capture-then-test. Uniformity is the guard; a risk-tiered allowlist is a
   future defect with paperwork.
6. A diagnostic must exercise the exact construct under test. Probing a
   SIGPIPE-sensitive `grep -q` pipeline with `grep -c` observes a different
   program — grep -c reads to EOF and cannot take the signal it is hunting —
   and returned a confident negative on a live defect. A near-miss probe's
   clean result is void, not reassuring; this has now happened twice.
Enforcement: two class assertions per repo, comment-stripped, fragment-assembled
needles, empty allowlists — one for the rule-1 composite, one for any
`| grep -q` in tracked shell. Stated scanner gap: other early-exit consumers
(head -n, grep -m, sed q) are covered by rule 5's class in prose and gain
needles when evidence produces an instance, not before.
