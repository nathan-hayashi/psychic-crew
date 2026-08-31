# MATRIX-AI-1 — the 51-item AI-engineering checklist vs the estate's projected final state

**Byte-source:** the operator's kickoff (`docs/research/ADDITIONS-2026-08-31-kickoff.md` §8 —
suite-asserted to carry exactly 51 items). **Law:** verdicts are judged at the highest granular
fidelity honestly reachable under the hard constraints — HC-5 (no installs, no clones, no GPU
toolchains, no training-compute acquisition), HC-7 (Claude-only inference), and the
zero-dependency doctrine. **Vocabulary:** `EXISTS` (the estate already does this, enforced) ·
`GENERALIZE` (a real partial exists; the rest is an extension, not a new build) ·
`FEASIBLE-ZERO-DEP` (buildable from scratch here, honestly at pedagogical/small scale where noted)
· `BLOCKED-HC` (requires installs, GPU kernels, model-weight access, or training compute — barred
by constitution, not by difficulty) · `REJECT` (off-mission for an IT-automation harness). Builds
happen only under their own later gates; this matrix decides standing, not work.

## The matrix (machine-readable; the suite binds row count and verdict legality)

```text
# MATRIX-AI v1
1	reasoner-cot	EXISTS
2	agent-loop-react	EXISTS
3	inference-server-cpp-rust	BLOCKED-HC
4	transformer-from-scratch	FEASIBLE-ZERO-DEP
5	vector-database-hnsw	FEASIBLE-ZERO-DEP
6	rag-pipeline	GENERALIZE
7	flash-attention-cuda	BLOCKED-HC
8	quantization-library	FEASIBLE-ZERO-DEP
9	moe-routing-layer	GENERALIZE
10	distributed-training-fsdp	BLOCKED-HC
11	kv-cache-paging	BLOCKED-HC
12	speculative-decoding	BLOCKED-HC
13	state-space-model-mamba	FEASIBLE-ZERO-DEP
14	rlhf-ppo	BLOCKED-HC
15	small-language-model	BLOCKED-HC
16	matmul-kernel	FEASIBLE-ZERO-DEP
17	lora-trainer	BLOCKED-HC
18	code-interpreter-sandbox	GENERALIZE
19	dpo-loss	FEASIBLE-ZERO-DEP
20	graph-rag	GENERALIZE
21	model-merger-slerp	BLOCKED-HC
22	interpretability-sae	BLOCKED-HC
23	synthetic-data-generator	EXISTS
24	function-calling-router	EXISTS
25	structured-output-parser-cfg	GENERALIZE
26	multimodal-projector-clip	BLOCKED-HC
27	llm-eval-harness	EXISTS
28	guardrails-io-filtering	EXISTS
29	prompt-caching-mechanism	GENERALIZE
30	tokenizer-bpe	FEASIBLE-ZERO-DEP
31	autograd-micrograd	FEASIBLE-ZERO-DEP
32	diffusion-model	BLOCKED-HC
33	vision-transformer	BLOCKED-HC
34	whisper-asr	BLOCKED-HC
35	text-to-speech	BLOCKED-HC
36	semantic-router	GENERALIZE
37	knowledge-graph-builder	GENERALIZE
38	data-curation-minhash	FEASIBLE-ZERO-DEP
39	ai-gateway-lb-failover	REJECT
40	peft-library	BLOCKED-HC
41	text-to-sql	GENERALIZE
42	recommendation-two-tower	REJECT
43	embedding-model	BLOCKED-HC
44	logit-processor	BLOCKED-HC
45	softmax-kernel-optimization	BLOCKED-HC
46	adversarial-attack-generator	EXISTS
47	audio-spectrogram-transformer	BLOCKED-HC
48	neural-architecture-search	BLOCKED-HC
49	model-distillation	BLOCKED-HC
50	feature-store	REJECT
51	vector-database-driver	GENERALIZE
```

Roll-up: **7 EXISTS · 10 GENERALIZE · 9 FEASIBLE-ZERO-DEP · 22 BLOCKED-HC · 3 REJECT** (= 51).

## The one-line why, per verdict class (every row cited)

**EXISTS (7)** — the estate already does it, suite-enforced: #1 the plan/discourse machinery IS
orchestrated chain-of-thought (lead-planner → arbiter rounds → release); #2 the 8-agent bench + the
tick of dispatch→observe→adjudicate is a ReAct loop at crew scale; #23 the fixture/corpus
generators that feed every negative control are synthetic-data generation with provenance; #24
army-selector + the intake classifier + the DISPATCH schema are a function-calling router as data;
#27 the four suites + the frozen-rubric bench + 11/11 mutation kills are an eval harness — this
build's actual core; #28 the hook layer + deny-lists + shape-redaction scrub are I/O guardrails in
production; #46 the red-team probe/mutation machinery is an adversarial generator for the guard
domain (gradient attacks on weights: blocked, and out of domain).

**GENERALIZE (10)** — a real partial exists; the delta is an extension: #6/#20/#37 retrieval,
graph-RAG and KG-building generalize the TEI Context-Fetch plan + the RSCH-1 plain-JSON graph-lane
PILOT; #9 expert routing exists at AGENT granularity (army-selector) — tensor-level MoE is the
pedagogical remainder; #18 the guarded-execution surface (hooks, deny-lists, mktemp isolation law)
generalizes toward a sandbox — kernel-level isolation needs privileges and stays out; #25 schema
enforcement via suites/jq generalizes to a CFG-constrained parser (pure-python, buildable); #29 the
vendor's prompt caching is used today and the cache-hit VERIFICATION pattern (the 10× cost lever
identified at the retirement review) is the portable half; #36 the intake classifier is a
deterministic router — semantic (embedding) routing stays blocked with #43; #41 sqlite3 lives in
the Python stdlib, so generation-by-Claude + mechanical validation is our eval-harness shape
applied to SQL; #51 the access layer folds into #5's index.

**FEASIBLE-ZERO-DEP (9)** — buildable from scratch under the constitution, at the honest scale
stated: #30 BPE and #31 micrograd-class autograd are the classic pure-python builds; #5 HNSW in
pure python with JSONL persistence; #38 MinHash dedup is pure hashing; #16 a cache-blocked matmul
demonstrates the technique (no SIMD without a toolchain); #4/#13 a tiny transformer / SSM scan in
pure python is pedagogically real and honestly slow; #8/#19 quantization math and the DPO loss are
implementable and testable on synthetic tensors — algorithms, not serving.

**BLOCKED-HC (22)** — barred by constitution, not difficulty. Every row needs at least one of: a
compiler/GPU toolchain (#3 #7 #16-SIMD #45 #47), training compute or weight access (#10 #12 #14
#15 #17 #21 #22 #26 #32 #33 #34 #35 #40 #43 #48 #49), an inference runtime to host (#11 #12), or
raw logit access the vendor API does not expose (#44). Each is one operator ruling away from a
re-verdict if the constitution ever changes; none is "too hard."

**REJECT (3)** — off-mission for an IT-automation harness: #39 a multi-vendor gateway's purpose
contradicts HC-7's single-vendor law; #42 recommendation systems and #50 feature stores serve ML
product surfaces this estate does not have.

## Weakest claims, flagged

`[I]` The FEASIBLE-ZERO-DEP scale notes ("pedagogical") are judgment about worth, not
possibility — a gate that picks one up re-prices it. `[I]` #29's portable half assumes the
cache-verification pattern survives without its original stack (it was read, not run, before the
prohibition landed; the pattern is cited from the gap-map era record only). `[E-limits]` Verdicts
judge the PROJECTED final state including pre-planned lanes (TEI, graph PILOT) — where a lane is
pre-planned but unbuilt, the verdict says GENERALIZE, never EXISTS.
