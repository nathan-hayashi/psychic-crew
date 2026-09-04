# SOURCE-MAP-1, explained plainly

## What changed

The router's research demand became fifteen named rabbit holes across three lanes: three
re-dives of corpora already on disk (orca, ruflo, gastown — each under a NEW question, because
a named question is what reopens a dived corpus), four dated web verifications, and an
eight-item shopping list of repos only the operator can place (Dify, Langflow, MetaGPT and
AutoGen unlock the sixteen frozen baseline cells; plus Mem0, CrewAI, Aider, and n8n flagged
source-available). Every row carries its question AT BIRTH — for drops, before the corpus even
exists here — plus a falsifiable yield prediction that SYNTH-1 will score. The dry rule is
frozen before the first dive: the wave ends when the last two dives performed both pull out
nothing, minimum two, aborts excluded, operator override in both directions.

## The census decision, plainly

The plan's default was to add the drop names to the corpus census now. Gate 1's own
tier-arithmetic arm made that expensive for zero on-disk drops, so the stated alternative was
taken: arrival is the classified event — a drop's dive gate adds the census, coverage, and
question rows together, and any window between landing and classification is that drop's
declared straddle. The discharge allowlist gained the `DIVE-W1-*` grammar today so those
future rows have a legal gate to name.

## Verify it yourself

```
./scripts/check-decision-matrices.sh | grep -A18 'I. SOURCE-MAP'
awk '/^# SOURCE-MAP v1$/{f=1;next} f&&/^```/{exit} f&&NF' docs/research/SOURCE-MAP-1.md | wc -l
```

## What could break, and what catches it

An unclaimed research vector, a dead register link, a drop row off the naming law, an
unignored directory landing at the root, a dive doc missing its verdict fence or
weakest-claims section, an outcome appearing on an undived row — each is a named FAIL, and
the validator's planted fixture proves it can reject before it ever meets a real dive.
