# GAP-REGISTER — the estate's open items, measured (v1, 2026-09-03)

**Purpose.** Every weakness this estate has recorded about itself — security residuals,
unchecked claims, parked items, operator-blocked work, open questions, accepted limits —
as one typed row each, so uncertainty is measured and routable instead of scattered. The
VECTOR-1 router consumes OPEN rows; the flip log below carries every disposition change,
dated, append-only. The register doubles as the program's hallucination log: any
record-vs-disk contradiction found during the vector program lands here as an
`ambiguous-record` row, reported never corrected (three real specimens are birth rows,
one of them the orchestrator's own completion-record figure).

**Measured completeness claim (dated).** 133 rows as of 2026-09-03, authored from the
2026-09-03 two-report gap census over parent, lite, and sidekick tracked records. The
claim is dated per CR-033; the standing tax below keeps it honest forward.

**The new-gap standing tax.** Any future record that states a gap adds its register row in
the same gate (the reverse arm forces this only for the declared sources below; everywhere
else it is the same discipline the reliability registry's tax normalized — procedural,
stated plainly).

**Extraction-source manifest (the FAIL-plane reverse binding; each re-extracted live by
suite section G):**

- `TM-1..TM-12` — the threat model's 12 numbered surface rows: `grep -c '^| [0-9]* |'
  docs/security/threat-model.md` == 12, and the extracted row-number set equals the
  register's TM tags. The frozen record gains a consumer, never an edit; in-place fencing
  is successor work (GR-carried).
- `COMM-F1..F4` — label extraction from the single frozen `[COMM-AUDIT-1|...]` ledger
  line: count == 4 and set-equality. F4 is registered `accepted-limit` (outside repo
  functions by its own text).
- `REG-EXP` / `CORR-PEND` — live count bindings: the aggregate rows' subjects are
  re-counted from `docs/RELIABILITY-REGISTRY.md` (maturity experimental) and
  `context/plan-corrections.md` (status PENDING) each run; a divergence is the causing
  gate's cascade to pay.
- `CR-AUD` — one aggregate row over the frozen priced CR backlog.
- `CENSUS` — rows enumerated by the 2026-09-03 census itself; forward evidence resolution
  applies (parent paths must exist; `lite:`/`side:` prefixed rows are cross-repo prose,
  announced not asserted — the no-cross-repo-assertion law).

Beyond the manifest, completeness is a dated claim: **~85% of rows are unbound by the FAIL
plane** — the program's honest confidence bound, inherited by every downstream closure.
The NOTE-plane scan reports marker hits no row covers, advisory never red.

**Vocabularies (ratified by `APPROVE GAP-REGISTER-1`; legality suite-armed by
set-difference):**

- `uncertainty_class` v1 — `unverified-claim` (asserted, no mechanical check — the
  green-while-checking-nothing class) · `unexercised-path` (built, never fired) ·
  `unread-source` (material exists unread) · `external-drift` (dated web fact that can
  rot) · `operator-blocked` (needs the operator's word, credential, or hardware) ·
  `ambiguous-record` (two records disagree) · `accepted-limit` (recorded so nobody
  re-derives; no intent to close). Reserved words are exactly these seven.
- `class` v1 — security-residual · dispatch-residual · verification-gap · parked-wake ·
  operator-blocked · open-question · portability · uncertainty-marker · unrecoverable ·
  declined-disclosed · ruling · chronicle · lite · sidekick.
- `source_tag` v1 — `TM-<n>` · `COMM-F<n>` · `REG-EXP` · `CORR-PEND` · `CR-AUD` ·
  `CENSUS`.
- `disposition` — `OPEN` · `RESOLVED:<gate>` · `SUPERSEDED:<gate>`; the cell holds the
  CURRENT value only; history lives in `# GAP-FLIPS v1`, append-only, and every non-OPEN
  row must own at least one flip line.
- `mechanical` — `no` · `partial` · `yes`, as the source documents themselves state.

**Motivating-holes disclosure (plainly, so no reader believes more was hardened than
was):** hole 1 — the 0.6 confidence threshold was bound by nothing; this gate adds the
binding arm over the agent surface, while the full calibration ledger stays successor work
(GR-carried). Hole 2 — the confidence-vs-outcome calibration ledger: DEFERRED to the
successor program; the source map's prediction column is its program-local pilot. Hole 3 —
the threat model had no mechanical consumer; this gate's TM binding is that consumer;
in-place fencing stays successor work (GR-carried).

## The register

```text
# GAP-REGISTER v1
GR-001	security-residual	gate-guard stops ordering mistakes not forgery; a session writing a fake APPROVED line passes; detection is ledger-vs-operator-memory audit, procedural	docs/security/threat-model.md:59	OPEN	no	unverified-claim	TM-1	GAP-REGISTER-1
GR-002	security-residual	model-guard reads only .claude/* and models.config.json; a model named through any other file is unguarded at write time	docs/security/threat-model.md:60	OPEN	partial	unverified-claim	TM-2	GAP-REGISTER-1
GR-003	security-residual	sensitive-guard covers the Write|Edit path only; a secret arriving by any other route relies on .gitignore alone	docs/security/threat-model.md:61	OPEN	partial	unverified-claim	TM-3	GAP-REGISTER-1
GR-004	security-residual	scrub() matches known credential shapes and positions; a novel credential format is uncovered by construction	docs/security/threat-model.md:62	OPEN	partial	unverified-claim	TM-4	GAP-REGISTER-1
GR-005	security-residual	pack-document judgment is model-interpreted; finding correctness and routing calls are not mechanically checkable	docs/security/threat-model.md:63	OPEN	no	unverified-claim	TM-5	GAP-REGISTER-1
GR-006	security-residual	untrusted-document contract procedural; adversarial fixtures exist only since LITE-SECURITY-1	docs/security/threat-model.md:64	OPEN	partial	unverified-claim	TM-6	GAP-REGISTER-1
GR-007	security-residual	docs/ sits outside the map-tree converse correlation by design (D21); a stray tracked file under docs/ is not caught	docs/security/threat-model.md:65	OPEN	no	accepted-limit	TM-7	GAP-REGISTER-1
GR-008	security-residual	well-formed diagrams are not proven true; only the d2 hook topology is bound to its source	docs/security/threat-model.md:66	OPEN	no	unverified-claim	TM-8	GAP-REGISTER-1
GR-009	security-residual	early-exit consumers head -n, grep -m, sed q are covered by rule-5 prose only; needles arrive on evidence	docs/security/threat-model.md:67	OPEN	no	unverified-claim	TM-9	GAP-REGISTER-1
GR-010	security-residual	cross-release guard sees only payloads it can read; a line assembled from shell variables is invisible until the gate-time trail scan	docs/security/threat-model.md:68	OPEN	partial	unverified-claim	TM-10	GAP-REGISTER-1
GR-011	security-residual	provenance-flag detects verbatim relay only and flags after the write; paraphrase undetected by construction	docs/security/threat-model.md:69	OPEN	no	accepted-limit	TM-11	GAP-REGISTER-1
GR-012	security-residual	publication residual is human; beyond one conversation-URL assertion no check reads prose for confidentiality	docs/security/threat-model.md:70	OPEN	partial	unverified-claim	TM-12	GAP-REGISTER-1
GR-013	security-residual	user-global allow-list carries a promptless any-host network-fetch rule; zero-network law procedural for the bare-fetch shape even in the parent	Plan.md:637	RESOLVED:COMM-HARDEN-1	no	operator-blocked	COMM-F1	GAP-REGISTER-1
GR-014	security-residual	parent allow-list gh repo rule is generic over any repo argument; narrowing to estate-scoped forms awaits the operator	Plan.md:637	RESOLVED:COMM-HARDEN-1	no	operator-blocked	COMM-F2	GAP-REGISTER-1
GR-015	security-residual	the turbo repo carries an upstream remote to the external original — the one external comms surface on the machine	Plan.md:637	RESOLVED:COMM-HARDEN-1	no	operator-blocked	COMM-F3	GAP-REGISTER-1
GR-016	security-residual	session-level claude.ai connectors exist under operator account control; outside repo functions, named for completeness	Plan.md:637	OPEN	no	accepted-limit	COMM-F4	GAP-REGISTER-1
GR-017	security-residual	red-team never tested ledger-content forgery by a write-capable session, settings/deny-list-change classes, or the pack document-intake injection surface	docs/security/redteam-1.md:67-72	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-018	security-residual	P5 symlink probe recorded not fixed: GATES.md swapped for a symlink to a doctored copy passes the guard; git-status type change is the only signal	docs/security/redteam-1.md:59	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-019	security-residual	of R-SEC-1's seven rules only rule 3 redaction is mechanically enforced; the rest bind gates and sessions procedurally	lite:.claude/rules/secrets-contract.md:27-29	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-020	dispatch-residual	bypass detection is caught never prevented; SubagentStart cannot block creation; PreToolUse deny prevention scoped only to EX-05 specialists at HOOK-2	ROADMAP.md:39	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-021	dispatch-residual	HOOK-2 defeats ordering and attribution not deliberate forgery; the dispatching session could write a marker itself; C-25/C-05 detection is the net beneath	docs/explainers/HOOK-2.md:12-17	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-022	dispatch-residual	HOOK-2 break-glass is named not armed: unwritable .claude/state or absent jq recovers only by operator hand-edit	docs/explainers/HOOK-2.md	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-023	dispatch-residual	C-25 covers only specialist starts the platform reports; an unannounced dispatch is invisible	context/plan-corrections.md:292	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-024	dispatch-residual	C-25b paired-lifecycle and HOOK-1 lifecycle arms are announce-only behind HK1_CUT; promotion to FAIL is a named wake	scripts/validate-crew.sh:372	RESOLVED:PROMOTE-1	partial	unexercised-path	CENSUS	GAP-REGISTER-1
GR-025	dispatch-residual	C-25 identity coverage has no live trail until a subagent is dispatched in-session; standing announced SKIP	scripts/validate-crew.sh:354	OPEN	partial	unexercised-path	CENSUS	GAP-REGISTER-1
GR-026	dispatch-residual	HOOK-1 platform delivery provable only live; fixtures prove wiring; trail arms announce absence rather than fail	docs/explainers/HOOK-1.md:35-38	OPEN	partial	unexercised-path	CENSUS	GAP-REGISTER-1
GR-027	dispatch-residual	F7 arbiter coverage is ordering-undecidable forever; granularity never captured, unrecoverable backward	ROADMAP.md:40	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-028	dispatch-residual	arbiter trail append residual race: FLAG-lines-to-separate-file hardening deferred at STRESS-1	docs/research/STRESS-1-report.md:140	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-029	dispatch-residual	sender-check leg of the three-check release is data-conditional; deferral announced where trails are absent	.claude/rules/arbiter-protocol.md	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-030	verification-gap	AGGREGATE: reliability-registry sections at maturity experimental — count bound live by the suite section-G binding	docs/RELIABILITY-REGISTRY.md	OPEN	yes	unverified-claim	REG-EXP	GAP-REGISTER-1
GR-031	verification-gap	AGGREGATE: corrections-registry rows at status PENDING — count bound live	context/plan-corrections.md	OPEN	yes	unverified-claim	CORR-PEND	GAP-REGISTER-1
GR-032	verification-gap	AGGREGATE: priced-and-parked audit change requests still open in the frozen CR backlog	docs/audit/CHANGE_REQUESTS.md:432	OPEN	no	operator-blocked	CR-AUD	GAP-REGISTER-1
GR-033	verification-gap	rule-2 scanner catches the inline wc-l string-compare form only; the two-step across-lines form was swept by hand and has no needle	docs/PORTABILITY.md:27-29	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-034	verification-gap	R-SD-1 rule 8 prose persistence is a discipline with no scanner; enforced by practice and record	.claude/rules/shell-discipline.md:78-80	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-035	verification-gap	R-SD-1 rule 4 durable/runtime separation enforced by practice not a scanner	.claude/rules/shell-discipline.md:78-80	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-036	verification-gap	RATCHET-1 governs tracked shell only; ad-hoc session commands out of scope by stated limit	docs/explainers/RATCHET-1.md:16-19	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-037	verification-gap	publication-fence alternation is enumerative not structural; tomorrow's unfenced drop class needs a new fence entry	GATES.md:27	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-038	verification-gap	check-plan-corrections executes the metrics generator so verification rewrites a tracked file and stales the CR-006 fence; registered H2a, redesign needs its own gate	GATES.md:27	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-039	verification-gap	the section-4.3 map covers docs/audit/ only; two docs/ files sit outside any mapped path (the C-26 shape)	GATES.md:25	OPEN	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-040	verification-gap	CR-033 line-number citations stale by design after each batch; forward-looking vs historical split is the recorded reframing	GATES.md:17	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-041	verification-gap	M1 stall detection enforced by nothing, zero assertions; no answer for a hung agent	docs/audit/DECISION_MATRICES.md:30	RESOLVED:STALL-VOCAB-1	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-042	verification-gap	M1 temporal bisect of controls enforced by nothing; cannot answer when a control stopped working; lite carries layers 2-3, parent does not	docs/audit/DECISION_MATRICES.md:31	RESOLVED:SUITE-ATTEST-1	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-043	verification-gap	HC-6 interpretation locks are prose readings with nothing to bind; accepted	docs/audit/DECISION_MATRICES.md:24	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-044	verification-gap	the 30-line reference cap is flag-only; promotion to deny waits on evidence of abuse	docs/audit/DECISION_MATRICES.md:29	OPEN	partial	unexercised-path	CENSUS	GAP-REGISTER-1
GR-045	verification-gap	intake skill judgment legs unasserted: observable completion condition, question materiality, implied paths; carried by four manual drills	.claude/skills/intake/SKILL.md:104-107	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-046	verification-gap	RPG-2 whether a live request matches a trigger is judgment; unasserted	docs/explainers/RPG-2.md:14	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-047	verification-gap	registry per-assertion granularity is declared v2 with its wake: a section splits when implicated in a real defect	docs/RELIABILITY-REGISTRY.md:13-16	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-048	verification-gap	audit-rubric suite totals are not environment-invariant; only primary-checkout figures compare against floors	docs/AUDIT-RUBRIC.md:47-51	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-049	verification-gap	audit-rubric staleness axis is advisory never red; the rubric proves nothing about content	docs/AUDIT-RUBRIC.md:43-45	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-050	verification-gap	gated-fixes law second half procedural: that a row's fix rode a gate is stated not enforced	docs/AUDIT-RUBRIC.md:93-99	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-051	verification-gap	CHANGE-PLANE-INDEX line numbers advisory; 18 heading-less CRs and CK-CONFLUENCE-1 have no unique definition anchor	docs/CHANGE-PLANE-INDEX.md:745-763	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-052	verification-gap	CR-006 ships as specification not image; suite checks well-formedness and cannot check the picture is good	GATES.md:25	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-053	verification-gap	README d2 claim binds project-scope hooks only; user-scope hooks merge in addition governed by the harness layer	docs/research/RETIRE-1-gap-map.md:53	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-054	verification-gap	lite release-trail law proven against synthetic lines only; no live dispatch has released anything — honest SKIP	lite:docs/security/redteam-1.md:145	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-055	verification-gap	R-SP-1 deliberately not an in-suite behavioural case; live-tree phantom or env override were both worse; gate control is the recorded proof	lite:docs/RULINGS.md:80-85	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-056	parked-wake	graph lane PARKed at eleven nodes; wake = a TEI corpus whose consumers need closure semantics (transitive pulls)	docs/research/TEI-0-pilot.md:52-58	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-057	parked-wake	SIDE-2 validator-scaffold generator parked; wake = a second consumer beyond the crews asks	docs/research/SIDE-2-plugin-surfaces.md:49	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-058	parked-wake	RSCH-2 PARK set of six ecosystem items each with a named revisit condition	docs/research/RSCH-2-ecosystem.md:20	OPEN	no	external-drift	CENSUS	GAP-REGISTER-1
GR-059	parked-wake	Managed Agents production lane parked; opening is a gated decision weighing separate billing, beta churn, non-ZDR sessions	docs/research/RSCH-1-claude-native.md:100	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-060	parked-wake	PACK-2 skill-pack lane skipped by verbatim operator instruction; Q6 order recorded for reopening	ROADMAP.md:7-17	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-061	parked-wake	peer review designed not built; the independence contract is the hard part; unscheduled	ROADMAP.md:31	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-062	parked-wake	WORKAROUND-01 auto-checkpoint snapshots are a workaround not architecture; removal condition = an official continuity capability	ROADMAP.md:35	OPEN	partial	external-drift	CENSUS	GAP-REGISTER-1
GR-063	parked-wake	PostCompact upgrade candidate exists; PreCompact cannot shape the compaction summary; operator decision not defect	context/f2-readiness.md:75	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-064	parked-wake	SIDE-5 build parked until all six legal criteria pass; today 1 of 6 met	docs/research/SIDE-5-compliance-verdict.md:48	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-065	parked-wake	amend-hook trigger unexplained; wake condition OPEN; separate commit/push discipline standing	GATES.md:50	OPEN	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-066	parked-wake	RSCH-4 non-TAKEs: two MODULATE-OURS (idempotency receipts, CLI vocabulary) and two VALIDATE-AGAINST (telemetry ordering, browser boundary) recorded as measuring sticks	docs/research/RSCH-4-orca.md:54-71	OPEN	no	unread-source	CENSUS	GAP-REGISTER-1
GR-067	parked-wake	SIDE-3 branch-proxy stays descriptive; promotion wake did not trigger at STRESS-1	docs/research/STRESS-1-report.md:148	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-068	parked-wake	BASE-2 sixteen cells NOT-COMPARABLE-DOCUMENTED-ONLY; each priced snapshot + named question + dive gate	GATES.md:77	OPEN	no	unread-source	CENSUS	GAP-REGISTER-1
GR-069	parked-wake	next band recalibration on the operator's word not a schedule	docs/AUDIT-RUBRIC.md:35-36	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-070	operator-blocked	macOS/BSD certification is an operator run, now owed for the lite suite too; scanners prevent regressions, they do not prove BSD green	docs/PORTABILITY.md:40-53	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-071	operator-blocked	signed approvals blocked by R-SEC-1 rule 1; operator-held git-signing recorded as the one compatible route, operator's word only	docs/research/CORPUS-BABYSITTER-2.md:42-45	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-072	operator-blocked	SIDE-5 criteria 2-5 unmet: no consent/jurisdiction model, no classification table, filter named not rowed, no transparency artifact; Enterprise tenant prerequisite unheld	docs/research/SIDE-5-compliance-verdict.md:37-53	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-073	operator-blocked	jurisdiction unknown and unrecorded — the largest unknown; its answer could add unnamed requirements	docs/research/SIDE-5-compliance-verdict.md:61-62	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-074	operator-blocked	secrets backend Q2 deferred post-build; env plus gitignore discipline interim	docs/audit/DECISION_AUDIT.md:23	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-075	operator-blocked	TEI-2..4 unbuilt; pre-planned only, on the operator's word	docs/CHANGE-PLANE.md:157	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-076	open-question	orca licence anomaly unresolved: org stablyai vs copyright holder Lovecast Inc; no local file explains	docs/research/RSCH-4-orca.md:6-7	OPEN	no	external-drift	CENSUS	GAP-REGISTER-1
GR-077	open-question	orca survey read under 0.1 percent; lockfile unread so transitive deps unknown; 98 of 99 reliability gates known only by aggregate; a thirteenth candidate could exist unread	docs/research/RSCH-4-orca-survey.md:115-120	RESOLVED:DIVE-W1-OR-1	no	unread-source	CENSUS	GAP-REGISTER-1
GR-078	open-question	RSCH-2 roughly thirty Ekn rows must be web-re-verified before any INCORPORATE promotion	docs/research/RSCH-2-ecosystem.md:144-147	RESOLVED:DIVE-W1-EK-1	no	external-drift	CENSUS	GAP-REGISTER-1
GR-079	open-question	SIDE-2 claude.ai zip lane unexercised; wake = one operator upload	GATES.md:40	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-080	open-question	SIDE-5 weakest claims: Team-plan content-endpoint coverage unverified; memory artifacts not named in fetched scope	docs/research/SIDE-5-compliance-verdict.md:55-62	OPEN	no	external-drift	CENSUS	GAP-REGISTER-1
GR-081	open-question	STRESS-1 CrewAI rubric column documentation-sourced not run-sourced; HC-5 barred an install	docs/research/STRESS-1-report.md:97-98	OPEN	no	unread-source	CENSUS	GAP-REGISTER-1
GR-082	open-question	STRESS-1 zero-challenge round means nine findings survived a corroborating read not an independent one	docs/research/STRESS-1-report.md:55-58	OPEN	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-083	open-question	HARNESS-SPEC limits: mktemp-root interaction designed not demonstrated; 18-dir walk-up snapshot rots silently; nothing proves a model produces good findings under the machinery	docs/research/HARNESS-SPEC.md:182-190	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-084	open-question	INDEX-1 push rejection cause unexplained; recorded	Plan.md:548	OPEN	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-085	open-question	oh-my-claudecode platform fact V?: agent-teams flag vs the dispatch law; registered for whoever next touches EX-05	docs/research/S6-oh-my-claudecode.md:14	RESOLVED:DIVE-W1-AT-1	no	external-drift	CENSUS	GAP-REGISTER-1
GR-086	open-question	gastown NDI nondeterministic idempotence: a philosophy this build has no name for; recorded	docs/research/S6-gastown.md:11	RESOLVED:DIVE-W1-GA-1	no	unread-source	CENSUS	GAP-REGISTER-1
GR-087	open-question	MATRIX-AI 22 of 51 items BLOCKED-HC by law; builds only under future gates	docs/research/MATRIX-AI-1.md:7-11	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-088	portability	early-exit consumer needles (second PORTABILITY bullet) remain prose-covered pending an instance	docs/PORTABILITY.md:55-65	OPEN	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-089	portability	operator BSD run on the lite suite named not claimed; the one step only the Mac completes	docs/PORTABILITY.md:62-63	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-090	portability	PLATFORM_GAP_POWERSHELL findings reasoned from code not reproduced on Windows; frozen audit record	docs/audit/PLATFORM_GAP_POWERSHELL.md:99-102	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-091	portability	fresh-clone drill blocked by the build's own deny-list; git archive is the stricter proof; guard not widened	GATES.md:15	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-092	portability	fresh-install bare-clone SKIPs structural by design; nothing to test on a new clone	docs/GETTING-STARTED.md:45-47	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-093	portability	platform may switch a session to a fallback model of its own choosing; no local file selects that target and none can	.claude/rules/model-policy.md:32-39	OPEN	no	external-drift	CENSUS	GAP-REGISTER-1
GR-094	portability	model: fable is a valid frontmatter alias; a broken guard is a silent HC-2 breach; three independent layers stand	.claude/rules/model-policy.md:16	OPEN	partial	unverified-claim	CENSUS	GAP-REGISTER-1
GR-095	uncertainty-marker	OQ-2 session model id V?: a 1M-context variant .pinned cannot express; pinned-mode reproducibility would not reproduce the variant	Plan.md:17	OPEN	no	external-drift	CENSUS	GAP-REGISTER-1
GR-096	unrecoverable	seven residual legacy-name strings left in the unedited execution authority under EX-01; delta-0 checks hold them	Plan.md:66	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-097	unrecoverable	upstream audit-trail artifacts R3/R4/R5 and the final audit prompt are gone; findings survive, the argument does not	ROADMAP.md:44	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-098	unrecoverable	source_files 21 knowledge files never delivered and will not be retrieved; operator declined re-export	ROADMAP.md:44	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-099	unrecoverable	dispatch cost measured only from session transcripts outside the repo; not knowable at dispatch time, no hook can record it	ROADMAP.md:41	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-100	unrecoverable	orchestrator token spend unmeasurable from inside the session; every recorded figure a strict lower bound	context/f7-metrics.md:50-52	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-101	unrecoverable	the section-7 token axis was unsatisfiable by construction; passing by trigger asserts nothing about efficiency	GATES.md:14	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-102	unrecoverable	the arbiter held no Bash so witnessed no run; B8/B9 numbers agent-captured not arbiter-observed	context/f7-metrics.md:54	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-103	declined-disclosed	README badges declined-disclosed both harness repos; an unbound badge is the exact hole	GATES.md:64	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-104	declined-disclosed	sidekick raster screenshot declined; hand-authored SVG under the zero-binaries law	side:GATES.md:11	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-105	declined-disclosed	lite carries no mechanical arm for the repurpose-pull contract; absence declared	lite:docs/REPURPOSE-PULL.md:30-35	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-106	declined-disclosed	lite threat model dropped with reason; kept joint in the parent as a declared refusal	lite:GATES.md:19	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-107	declined-disclosed	eight parent hooks plus five agents plus the arbiter protocol dropped in lite, each a recorded decision	lite:docs/SYNC-CORRELATION.md:66-70	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-108	declined-disclosed	lite gate_ts and phase extractors available but unclaimed; checker reports nothing-to-bind	lite:context/CLAIMS.md:45-46	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-109	declined-disclosed	ROADMAP self-declared unbound to the distilled summary; a periodic obligation not a check; M6's live illustration	ROADMAP.md:5	OPEN	no	unverified-claim	CENSUS	GAP-REGISTER-1
GR-110	ruling	HC-2 attestation not machine-checkable; the session model is written nowhere a script can read; operator attestation labelled	GATES.md:13	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-111	ruling	sidekick visibility flip happened out-of-band; no token, no commit, flip date unrecorded; grandfathered at reconcile	side:GATES.md:6	OPEN	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-112	ruling	visibility drift: ledger said private-at-creation, GitHub says three public — inverse of stated intent; ratified	docs/CHANGE-PLANE.md:153-154	OPEN	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-113	chronicle	websites fetched targeted never traversed; chronicle honest gap 2 open	docs/CHANGE-PLANE.md:147-148	OPEN	no	unread-source	CENSUS	GAP-REGISTER-1
GR-114	chronicle	no autonomous self-improvement; every change human-gated by design	docs/CHANGE-PLANE.md:155-156	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-115	chronicle	TEI product beyond TEI-1 unbuilt; chronicle gap M6 half-open	docs/CHANGE-PLANE.md:157	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-116	lite	R-PD-1 caps how many packs exist not what pack 1 points at; own-documents-only is an operator instruction, nothing on disk can tell whose document is in inbox	lite:docs/RULINGS.md:33-36	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-117	lite	lite red-team did not test forgery; parent P5 symlink residual applies unchanged	lite:docs/security/redteam-1.md:160-162	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-118	lite	lite red-team did not test a hostile operator; every control assumes the operator trusted	lite:docs/security/redteam-1.md:164	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-119	lite	lite red-team did not test binary and rich formats; docx macro and scripted HTML shapes registered not claimed	lite:docs/security/redteam-1.md:167	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-120	lite	lite red-team did not test volume; six fixtures one document; nothing speaks to scale	lite:docs/security/redteam-1.md:170	OPEN	no	unexercised-path	CENSUS	GAP-REGISTER-1
GR-121	lite	lite stress proves the machinery not the reviewer; findings scored against a fixed answer key; the harness stands in and says so	lite:README.md:175-178	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-122	lite	lite README suite counts deliberately not restated after rotting unnoticed L2 to README-SYNC-1; one number stated and bound	lite:README.md:192	OPEN	partial	accepted-limit	CENSUS	GAP-REGISTER-1
GR-123	lite	gate-guard stated limit travels with its bytes: ordering mistakes not forgery; mirrored byte-identical	lite:Plan.md:72	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-124	sidekick	nothing mechanical proves a mobile session honors the remote preamble; suite proves byte-identity to the recorded protocol only	side:docs/REMOTE-PROMPT-PROTOCOL.md:47-50	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-125	sidekick	whether a request matches a template at all is judgment; stated unasserted	side:README.md:60-63	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-126	sidekick	department presets are not the TEI-3 authority-resolver, which does not exist; whether department approval rules are deterministically expressible is an open experiment staged last because it may fail	side:docs/INTEGRATION-CONTRACT.md:39-46	OPEN	no	operator-blocked	CENSUS	GAP-REGISTER-1
GR-127	sidekick	sibling-checkout and node-absent legs are stated SKIPs; browser render legs are the operator machine's drill	side:docs/INTEGRATION-CONTRACT.md:48-53	OPEN	partial	unexercised-path	CENSUS	GAP-REGISTER-1
GR-128	sidekick	SIDE-R1 fallback-rule inversion declared out loud; the remote lane inverts block-on-low-confidence and the unasserted half is stated	side:GATES.md:8	OPEN	no	accepted-limit	CENSUS	GAP-REGISTER-1
GR-129	verification-gap	census coverage-table tier column was unvalidated: no legal-vocabulary arm, no arithmetic re-derivation — closed this gate	scripts/check-decision-matrices.sh:149-155	RESOLVED:GAP-REGISTER-1	yes	unverified-claim	CENSUS	GAP-REGISTER-1
GR-130	verification-gap	no arm fired when a research doc omitted its weakest-claims section — the epoch arm closes it for all program docs forward	docs/research/RSCH-1-claude-native.md:169	RESOLVED:GAP-REGISTER-1	yes	unverified-claim	CENSUS	GAP-REGISTER-1
GR-131	open-question	envelope schema evidence enum is E/I/S while the plan grammar is E/I/S/V? — a live vocabulary divergence between two ratified records; reported not corrected	envelope.schema.json:73-80	RESOLVED:TM-FENCE-1	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-132	open-question	the register-program completion record claims registry 44 to 48 while disk holds 47 and the suite's 47==47 was always green — the orchestrator's own figure is the program's first logged hallucination; reported not corrected	Plan.md:638	RESOLVED:TM-FENCE-1	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-133	open-question	CORPUS-SDKPY and CORPUS-LANGGRAPH still read awaiting-an-operator-declared-gate for hook candidates HOOK-1 discharged 2026-09-02; dated research prose lagging the ledger; reported not corrected	docs/research/CORPUS-SDKPY.md:40	RESOLVED:TM-FENCE-1	no	ambiguous-record	CENSUS	GAP-REGISTER-1
GR-134	open-question	orca application source under 1 percent read; a thirteenth pattern-candidate could exist unread - the residue of the survey row this dive resolved	docs/research/DIVE-W1-OR-1.md:1	OPEN	no	unread-source	CENSUS	DIVE-W1-OR-1
GR-135	verification-gap	no dated suite-run attestation exists - when a control last proved itself and on what platform/userland is unrecorded; BSD certification and temporal claims ride session memory	docs/research/DIVE-W1-OR-1.md:1	RESOLVED:SUITE-ATTEST-1	no	unverified-claim	CENSUS	DIVE-W1-OR-1
GR-136	dispatch-residual	agent-teams flag if ever enabled in any settings layer routes teammate coordination through user-scope mailboxes outside the dispatch guard and the estate's trails; default-off + headless immunity today; the settings pin to 0 is the available hard line	docs/research/DIVE-W1-AT-1.md:1	RESOLVED:COMM-HARDEN-1	no	external-drift	CENSUS	DIVE-W1-AT-1
GR-137	verification-gap	no standing confidence-vs-outcome ledger exists estate-wide; the vector program's 6-for-6 table is seed evidence held in one record, not a mechanism; CALIB-1 is its named landing	docs/research/SYNTH-1-incorporation-program.md:1	RESOLVED:CALIB-1	no	unverified-claim	CENSUS	SYNTH-1
```

## The flip log

```text
# GAP-FLIPS v1
GR-129	2026-09-03	OPEN>RESOLVED:GAP-REGISTER-1	GAP-REGISTER-1
GR-130	2026-09-03	OPEN>RESOLVED:GAP-REGISTER-1	GAP-REGISTER-1
GR-077	2026-09-03	OPEN>RESOLVED:DIVE-W1-OR-1	DIVE-W1-OR-1
GR-086	2026-09-03	OPEN>RESOLVED:DIVE-W1-GA-1	DIVE-W1-GA-1
GR-078	2026-09-03	OPEN>RESOLVED:DIVE-W1-EK-1	DIVE-W1-EK-1
GR-085	2026-09-03	OPEN>RESOLVED:DIVE-W1-AT-1	DIVE-W1-AT-1
GR-135	2026-09-04	OPEN>RESOLVED:SUITE-ATTEST-1	SUITE-ATTEST-1
GR-042	2026-09-04	OPEN>RESOLVED:SUITE-ATTEST-1	SUITE-ATTEST-1
GR-041	2026-09-04	OPEN>RESOLVED:STALL-VOCAB-1	STALL-VOCAB-1
GR-013	2026-09-04	OPEN>RESOLVED:COMM-HARDEN-1	COMM-HARDEN-1
GR-014	2026-09-04	OPEN>RESOLVED:COMM-HARDEN-1	COMM-HARDEN-1
GR-015	2026-09-04	OPEN>RESOLVED:COMM-HARDEN-1	COMM-HARDEN-1
GR-136	2026-09-04	OPEN>RESOLVED:COMM-HARDEN-1	COMM-HARDEN-1
GR-024	2026-09-04	OPEN>RESOLVED:PROMOTE-1	PROMOTE-1
GR-131	2026-09-04	OPEN>RESOLVED:TM-FENCE-1	TM-FENCE-1
GR-132	2026-09-04	OPEN>RESOLVED:TM-FENCE-1	TM-FENCE-1
GR-133	2026-09-04	OPEN>RESOLVED:TM-FENCE-1	TM-FENCE-1
GR-137	2026-09-04	OPEN>RESOLVED:CALIB-1	CALIB-1
```

## Weakest claims, flagged

`[I]` The aggregate-vs-individual cut is a judgment: three families ride one row each
because a live tracker already counts them; if a tracker's discipline lapses, this
register under-represents exactly that family. `[I]` The census the CENSUS rows derive
from was model-authored in one session from marker-phrase sweeps; a gap stated in
vocabulary the sweep did not carry is absent here, and only the NOTE-plane scan or a
future reader finds it. `[E-limits]` Cross-repo rows (`lite:`/`side:`) are prose, never
asserted — the parent suite has never depended on a sibling checkout and does not start
here. What would reopen this record: any FAIL-plane extraction divergence, a NOTE-plane
hit no row covers, or a census sweep under new marker vocabulary.
