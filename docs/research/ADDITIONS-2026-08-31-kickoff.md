# ADDITIONS-2026-08-31 — the program kickoff, persisted

**Role of this document:** the byte-source for the 2026-08-31 additions program — including the
**51-item "Build your own X" checklist consumed by MATRIX-AI-1** and the workstream list. Persisted
at FENCE-2 per the HELIX gap-#7 lesson (a kickoff that lives only in conversation is unrecoverable).
This tracked copy is **complete but reflowed** (the formatter hook rewraps Markdown); a byte-exact
copy sits under the gitignored `Context-Transfer-additions-2026-08-31/` fence. A suite assertion
counts the 51 checklist items so truncation cannot pass silently.

**Correction annotation (operator, same day):** the retirement workstream's target as originally
phrased was corrected by the operator to **`claude-agent-orchestration-guide`**; the repo originally
named is out of scope for this engagement entirely and is not read or touched. The correction was
the operator's own ("Thats on me. User error"). The text below is otherwise their message as sent.

---

## 1 — MacBook forensics

"Look at what the MacBook had recently made changes to, if those commits made sense in the first
place in regards to what you noticed."

## 2 — Harness universalization

"We are also adding right now additions to our current gated plans: My MacBook session had a
limitation where installing the psychic-crew-lite or psychic-crew required claude to be booted and
utilized under its own file directory. This is problematic and I rather have the 'harness' of
psychic-crew and psychic-crew-lite to have the ability to start at the parent repo that its in so
that a deployment in whatever parent repo the harness is under that parent repo gets all the same
things as if deployment is under the parents directory and its sub directories. Findings found in
this new document handoff report: psychic-crew/harness-universalization-report.md hard check on its
requirements and then re-iterate then deploy. Should have the re-run scripts help adjust and match
changes as needed to override existing deployments (In GitHub repo).

- Also to note: we cannot make a universal harness from lite, so we need a change there because I
  want lite and psychic-crew to both have deployments the same.
- Its a spec written for context in a MacBook session using psychic-crew-lite to generate that
  report. Report is written as data and not orders."

## 3 — orca

"Add a new repo I have added to the mappings of indexes and a new project to explore:
psychic-crew/orca-main also the repository parent site of: https://github.com/stablyai. Check out
the entire repo in granularity and take inventory of what it is, how its structured, its entire
system and our business model and where we can surgically take it apart and add surgically or
validate or modulate or change our system."

## 4 — Project model default

"project model default? It seems to be Opus 4.8?? Check our configs and also if we are running on
psychic-crew right now on its latest model or automation-ecosystem. If things interfere then drop
the old automation-ecosystem scaffolding. [Corrected per the annotation above: the retirement
target is claude-agent-orchestration-guide; the originally named repo is out of scope.]

Default should be Opus Latest modeling version so that whenever anthropic drops new model
iterations we get live time update changes.... not 4.8

I also get this error:

'Fable 5's safeguards flagged this message. Our intentionally broad safeguards allow us to deliver
more capabilities faster, but can sometimes flag legitimate coding, cybersecurity, and biology
tasks. Switched to Opus 4.8. Send feedback with /feedback or learn more'

Switching should be latest opus model here."

## 5 — AI slop / comprehension

"Issue with AI slop: hard to understand what the code does since the users role is just prompt
engineering with inputs, decision making and planning BUT the hard part is the review of everything
engineered, built, created, changed etc... Could potentially need refactoring at times. Need a way
to create the same result but an easy way to understand what each line of code does and why.

How will I understand what? Research the best way of utilizing our harness we are systematically
building here and how trust can be established from paranoia of not being able to take the code and
knowing it all (context loading a human brain at this scale is not feasible). Might need strategies
like summary notes per code block or a high level overview after the build gets finished or
something to help the end user like me. Maybe after each gated phase an overview of the changes?
Stuff like that to help with a higher level technical abstraction that makes management easier with
simple explanation without tradeoffs with the logical work output values."

## 6 — Retirement gap question

"IF we Retired the old [system — target per the correction annotation:
claude-agent-orchestration-guide] with psychic-crew, are all gaps covered? If not then we need to
see what to change or add onto psychic-crew because I decide to retire the old system we got here
with psychic-crew, either with it in its current processing state or finished."

## 7 — Slash commands

"Slash commands have an issue here: If we use slash commands like: slash command page:
/repo-deep-dive — There would be too many slash commands, how can it be invoked naturally based on
user prompts and prompt engineering pertaining to the context and/or request? Im open to doing
small amounts of slash commands but will forget using it."

## 8 — The AI-Engineering checklist (MATRIX-AI-1's byte-source, 51 items)

"Add on this Checklist of what we have vs what can be build in AI Engineering for double checking
the projected final state of Psychic-crew and its capabilities to see if we can do any of these in
the highest level of granular fidelity:"

> Build your own Reasoner (Chain of Thought implementation)

> Build your own Agent loop (ReAct pattern)

> Build your own Inference Server (in C++/Rust)

> Build your own Transformer from scratch (Attention is all you need)

> Build your own Vector Database (HNSW index)

> Build your own RAG pipeline

> Build your own Flash Attention kernel (CUDA)

> Build your own Quantization library (Int8/FP4 implementation)

> Build your own Mixture of Experts (MoE) routing layer

> Build your own Distributed training loop (FSDP/Tensor Parallelism)

> Build your own KV Cache paging system (like vLLM)

> Build your own Speculative Decoding system

> Build your own State Space Model (Mamba implementation)

> Build your own RLHF pipeline (PPO implementation)

> Build your own Small Language Model (SLM)

> Build your own Matrix Multiplication kernel

> Build your own LoRA (Low-Rank Adaptation) trainer

> Build your own Code interpreter sandbox

> Build your own DPO (Direct Preference Optimization) loss function

> Build your own Graph RAG system

> Build your own Model merger (Model Soups/Spherical Linear Interpolation)

> Build your own Interpretability tool (SAE - Sparse Autoencoders)

> Build your own Synthetic data generator

> Build your own Function Calling router

> Build your own Structured Output parser (Context Free Grammars)

> Build your own Multi-modal projector (CLIP implementation)

> Build your own LLM Eval harness

> Build your own Guardrails system (Input/Output filtering)

> Build your own Prompt caching mechanism

> Build your own Tokenizer (BPE implementation)

> Build your own Autograd engine (like Micrograd)

> Build your own Diffusion model (UNet + Scheduler)

> Build your own Vision Transformer (ViT)

> Build your own Whisper-style ASR model

> Build your own Text-to-Speech pipeline

> Build your own Semantic Router

> Build your own Knowledge Graph builder

> Build your own Data curation pipeline (MinHash/Deduplication)

> Build your own AI Gateway (Load balancing/Failover)

> Build your own Parameter Efficient Fine-Tuning (PEFT) library

> Build your own Text-to-SQL engine

> Build your own Recommendation system (Two-tower architecture)

> Build your own Embedding model

> Build your own Logit Processor

> Build your own Softmax kernel optimization

> Build your own Adversarial attack generator

> Build your own Audio Spectrogram transformer

> Build your own Neural Architecture Search

> Build your own Model Distillation pipeline

> Build your own Feature Store

> Build your own Database driver (for Vectors)

## 9 — Closing

"This is the end of all the required list of additions you must execute upon."
