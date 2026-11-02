# Evaluation

## Question

Do lens-specific reviewers find more real plan defects than generic reviewers at the same compute?
This measures the **review stage** only, not plan generation or the architecture divergence.

## Test 1: seeded defects

Fixture v1: `eval/v1/fixture/` (spec, one ADR, a plan with 10 seeded defects). Answer key: withheld (hash in `eval/answer_keys.sha256`),
pre-registered before any run, including the lens each defect was predicted to be caught by.

Conditions (all reviewers: `general-purpose` agent, model sonnet, same fixture copied into an isolated directory per run):

| Condition | Reviewers | Prompt |
|---|---|---|
| A | 1 | Generic: "find its problems" |
| B | 4, union of findings | Generic (same as A): plain resampling |
| C | 4, union of findings | One council lens each (body of `agents/council-<lens>.md`, now in `eval/retired_agents/`) |

B vs C is the comparison that matters: same compute, only the prompts differ.
In C the lens prompt is passed as the task prompt to a `general-purpose` agent rather than as the subagent's system
prompt, because the agents installed mid-session were not yet available when the runs were launched. This also keeps
the agent type identical across conditions. Side effect: the emulated red-team and scope reviewers had web tools,
which their real definitions do not.

Grading: a separate grader agent (opus) receives the answer key and the finding sets with condition labels
replaced by random letters. Per set: which seeded defects were caught, and each extra finding marked valid or invalid.

Decision rule: if C does not clearly beat B, the cheaper single fresh critic (A) or plain resampling (B) is the
recommendation, not the lens council. Two repetitions only: the reading is qualitative, not a trend.

Known limits of this test:
- Fixture and answer key were written by the same model family that reviews them.
- Seeded defects are cleaner than real ones; detection here is an upper bound.
- One fixture, one domain.

## Step 0 check: does the gate reject a bounded task?

Negative case only; a gate that rejects everything would also pass it. The positive control is test 2.

2026-10-23, run in the author's portfolio project, task phrased without size hints ("publish my Firefox MCP setup to the portfolio:
profiles, launch wrapper and skill"). Result: **stopped at Step 0 and recommended plan mode.** It read the project
before deciding: it counted the files and lines (wrapper 50, skill 101), found the profile config and the hooks in
`install.sh`, and gave concrete reasons (no modules, no migration, no parallel execution). It also listed the
non-architectural work (a separate public repo because dotfiles is private, scrubbing machine paths and profile IDs,
a README explaining why it exists). One observation, so this is not a trend.

## Test 2: end to end (planning 2026-10-23, build 2026-10-26 to 2026-10-28)

App: [`odoo-functional-agent`](https://github.com/xmglord/odoo-functional-agent) (Odoo 20 functional configuration agent). Protocol and the pre-registered checks
K1–K7: `eval/test2/protocol.md`. Plan mode plan: `eval/test2/plan_mode.md`; council output: the project's `docs/plan/`, local only and not published.

Step 0 positive control: the gate accepted this request (it had rejected the bounded portfolio task).

Run notes: the user asked for three spikes at Gate 2 (Odoo 20 availability, channel coverage UI vs API, headless
provisioning), run by the orchestrator in the main session; it then wrote spike evidence into the ADRs, which the skill
did not cover (fixed afterwards: `$OUT/spikes/`, ADRs untouched). Review: FAIL round 1 (1 blocker), PASS round 2.

The plan rubric was not used to compare: the council plan is 1208 lines, plan mode's 94, so grading is not blind, and
the rubric scores contracts and parallel safety that plan mode never attempted (it plans for one session).

**Confound found while grading:** the two conditions got different user answers. Plan mode asked about the edition
and the user chose Community. The council intake recorded Enterprise and Mexican localization in scope. Scope
differences below come partly from this, not from the method.

K checks (grader: opus, anonymized X/Y, brief + checks + the two plan.md files only; mapping `eval/test2/mapping.txt`):

| Check | Plan mode | Council |
|---|---|---|
| K1 API vs browser | yes (asked the user, recommending API) | yes |
| K2 scenario verification | partial: prose scenarios, no assertion format | yes: `ofa.scenario/1` with read-back assertions |
| K3 review + change record | partial: approval and dry-run, no rollback | partial: approval and hash-frozen plan, no live diff, no rollback |
| K4 knowledge grounding | yes, no staleness flag | yes, `verified_on` + `ofa stale` |
| K5 MX/CFDI as scope question | no | partial: in scope from intake, never questioned |
| K6 demo-only guard | yes (dedicated Postgres) | yes, but shares `odoo-pg` with non-demo DBs |
| K7 verified on Odoo 20 | partial: core API mechanics assumed | yes: checked against 20.0 source, live spike task |

Grader's pick to execute: plan mode, adding the council's assertion format and API checks; "the gap is mostly one of
scale". Two of its council criticisms do not hold: the extra scope came from the user's intake answers (confound
above), and "depends on documents the executor lacks" is an artifact of giving the grader plan.md only (executors run
locally with `docs/plan/`). The shared-Postgres criticism holds.

Cost (weighted units: input 1, cache write 2, cache read 0.1, output 5; assumed ratios, no model price difference):
plan mode ~183k; council ~10.9M = subagents 4.43M (grounder 1.98M) + main session 6.45M, of which spikes and side
work 4.34M. Council ≈ 36× plan mode without spikes, ≈ 60× with them.

Reading (one app, one rep): the council was stronger exactly where the user is weak (verification: K2, K7) and the
grounder found real Odoo 20 facts (backorder wizard without `res_id`, cron ignores `dbfilter`); plan mode reached the
same core design at a few percent of the cost. Whether that difference matters is decided by execution: record what
breaks while building, per plan.

### Execution (2026-10-26 to 2026-10-28)

All 30 tasks done; the plugin is public (`xmglord/odoo-functional-agent`) and installs from its marketplace in a
fresh session. Log: `eval/test2/execution_log.md`. Each failure classified against plan mode:
`eval/test2/classification.md` (one grader who kept the log and knows both plans; not blind).

| | Count |
|---|---|
| Defects introduced by the council plan (contracts, waves, spikes, bot user, bash hook, shared Postgres) | 23 |
| Defects plan mode would also have had | 8 |
| Failures the council plan prevented | 11 (2 of them guard holes: empty marker string, `evaluate_script` bypass) |
| Plan hits that only offset its own design | 6 |

- Most council-introduced defects were cheap: underspecified or inconsistent contracts the builder resolved in
  minutes. The costly ones: the lint task (T18) had to be redesigned, the bot-user snapshot broke a live apply, and
  the parallel-safety criterion ignored shared runtime state. Two were wrong-but-plausible facts that reached
  docs before being caught.
- What the council bought: grounded API facts (K7) and the assertion format (K2). In the examples, assertions, role
  identities and negative tests found six real Odoo 20 behaviours, including a crash in `l10n_mx_edi` for branch
  users. Plan mode's prose scenarios were not run, so their yield is unknown.
- The tooling grew past the plan during the examples (company context, test identities, `expect_error`,
  `save_as` + `check`). Each came from a gap an example exposed, not from the plan.
- The author's role: every example had author intake answers and approvals; T21 needed one functional correction
  by the author, later examples none. From T26 on the author also reviewed plans with a separate review session.
  Its suggestions, which the author took: the T26 fiscal-data rule, three test-plan changes (T26 need 6, T27
  needs 5 and 6), two corrections at T26's second approval and the T27 controller design.

Cost (same weighted units as above), measured from transcripts:

| Stage | Weighted |
|---|---|
| Plan mode planning | 0.18M |
| Council planning | 6.46M main session (10.9M with subagents) |
| Build session (builder) | 46.0M |
| Builder subagents (wave 1-3 parallel tasks) | 22.0M |
| Example sessions (author-run) | T21 2.55M measured; T24-T27 not measured (transcripts deleted in cleanup) |

The build cost about 68M weighted units without the example sessions, roughly 6× the council planning cost.
Planning cost matters little next to execution; what matters is whether the plan lowers the build cost, and with
one condition built that is not measured.

One post-build validation on a private case is withheld. No count or reading on this page uses it.

Reading (one app, one rep, one non-blind grader; scope confound: Enterprise and MX were in the council's scope
only): the council's process added more defects of its own than it prevented, but the ones it prevented were
heavier (guard holes, wrong API shapes) than most it added (contract gaps). Plan mode was never built, so "plan
mode would have hit it" is a judgement, not a measurement.

## Test 3: building plan mode's plan (2026-10-30 to 2026-11-02)

Protocol, addenda, log and grades: `eval/test3/`. One arm: `eval/test2/plan_mode.md` plus a scope amendment, built with
the same model and requirements as the council build. X = plan mode, Y = council (`eval/test3/mapping.txt`).

**Result: plan mode's plan built nearly the same thing, more slowly and at about 2.2 times the cost, and did not close
cleanly. It tested deeper. Council is not shown to be better by defect count.**

| | Plan mode | Council |
|---|---|---|
| Cost, full run counted the same way | 202.05M | about 91M (about 12M estimated) |
| Active agent hours, build | 11.9 | 5.3 |
| Hidden findings with evidence | 3, 2 unmeasured, 1 could not arise | 5, 1 unmeasured |
| Defect rows, T21-T27 (blind grader) | 21 | 20 |
| Needs from the database (49) | 36 met, 12 partial, 1 not met | not read the same way |
| End state | T27 with AT-75 failing and AT-79 not run | Complete and published |

Cumulative cost, build only:

| Milestone | Plan mode | Council |
|---|---|---|
| T21 | 19.21M | 40.2M |
| T24 | 36.70M | 42.3M |
| T25 | 91.45M | 53.2M |
| T26 | 135.90M | 59.8M |
| T27 | 202.05M | 64.7M |

- **The gap comes from testing, not from building.** Plan mode cost half as much up to T21, then spent 165M on three requirements (T25-T27), and the tester alone is 145.31M, 72% of the total. Its 69 regular tests on T27, run by browser and by role, also produced its advantage: about nine classes of real gap that council shows no sign of checking.
- **Cold cache does not explain it.** Without the excess, at the point measured (137.64M and 68.06M, not the final totals), the figures are about 122M against 66M. Of the arm's 16.04M excess, 57% came from subagents resumed after idling, 25.5% from the author's waits and 17.5% from AT-44's window plus suspension. Subagent cache lasts 5 minutes; the main session's lasts 1 hour.
- **Defect totals are not comparable.** Council's 72 include 45 from the build stage, and plan mode's log has no rows before T21.
- **The AT-75 failure is probably a residue, not proven.** On a clean database the new bill opens, but only because it arrives with no bank account. The bills that fail were created before the bank accounts got a company; that link is one run and unproven. The spec converged from scratch.
- **Guard checks:** the marker check and the URL guard exist and have tests. `evaluate_script` is not restricted by the arm's configuration, and the guard's own note says it does not cover clicks. This was read from code, not run. The hook is project-scoped, so other sessions are unaffected.

Limits:

- One app, one rep, built second, and the author knew the answers, which favours the arm.
- The ceiling moved three times, from 80M to 210M, each with an addendum and each time after results were visible. Results past 180M, including T27's second round, are the least pre-registered.
- No review session ran on T26 or T27, while council had one on both.
- The database reading covers the arm only. Two T27 "partial" verdicts (the controller's allow-list, the fourth company) rest on clarifications the arm was never given, because it did not ask.
- Both logs were written by this session, which knew both builds, and they differ in depth. 14 of the arm's 21 defect classifications and 26 of council's 72 are marked doubtful. Plan style may have hinted at the source.
- Both Enterprise builds ran with different company choices in T24 to T26.
- The tester's 145.31M and the active agent hours were measured from transcripts that are not published.

## Results

### Test 1, run 1 (2026-10-22)

Raw grades, set mapping and token counts: `eval/results/2026-10-22_seeded_run1.md`.

| Condition | Rep | Seeded caught | Distinct valid extras | Invalid extras | Subagent tokens |
|---|---|---|---|---|---|
| A (1 generic) | 1 | 10/10 | 13 | 0 | 47.7k |
| A (1 generic) | 2 | 10/10 | 11 | 0 | 46.9k |
| B (4 generic) | 1 | 10/10 | 21 | 1 | 190.3k |
| B (4 generic) | 2 | 10/10 | 22 | 1 | 193.9k |
| C (4 lenses) | 1 | 10/10 | 22 | 3 | 188.5k |
| C (4 lenses) | 2 | 10/10 | 25 | 2 | 190.4k |

Reading:
- **Ceiling effect: the test did not discriminate.** A single generic reviewer caught all 10 seeded defects in both
  reps. The seeded defects were too obvious; this run cannot say whether lenses help on detection.
- Four reviewers instead of one: ~4× tokens for ~10 more valid issues, mostly minor (CSV formula injection, CSRF,
  user deactivation, comment storage).
- Lenses vs resampling (C vs B), same compute: +1 and +3 valid extras, +2 and +1 invalid extras. Within noise at n=2.
  The invalid ones came mostly from the scope lens over-cutting ("collapse modules", "split dashboard").
- Issues only lens sets found: CSRF, approver delegation/absence, unshared conventions across parallel agents
  (X26–X28). Single observations, not a pattern.
- The grounder reported citing docs from memory without fetching them (2 of 2 runs). Its prompt now requires a
  fetch; anything unfetched is `unverifiable`.

Decision per the pre-registered rule: C did not clearly beat B, so the council's review stage is **not justified by
this test**. The review stage stays in the pipeline pending a discriminating test, with a single fresh critic as the
cheap fallback.

Next test must avoid the ceiling: subtle defects (cross-section inconsistencies, defects that need the spec to
see, wrong-but-plausible library claims), or a real plan whose execution problems are known afterwards.

### Test 1, run 2 (2026-10-22, fixture v2)

Fixture `eval/v2/` (facilities work orders, Django + Celery): a clean, structured plan with 13 subtle defects
(spec-vs-plan contradictions, framework semantics verified in official docs, undeclared dependency, migration
collision). Decision rules pre-registered in the withheld answer key. C used the real installed council agents.
Raw grades: `eval/results/2026-10-22_seeded_run2.md`.

| Condition | Rep | Seeded caught | Distinct valid extras | Invalid extras | Subagent tokens |
|---|---|---|---|---|---|
| A (1 generic) | 1 | 13/13 | 24 | 0 | 54.8k |
| A (1 generic) | 2 | 13/13 | 27 | 0 | 57.4k |
| B (4 generic) | 1 | 13/13 | 35 | 0 | 234.6k |
| B (4 generic) | 2 | 13/13 | 33 | 1 | 226.1k |
| C (4 council agents) | 1 | 13/13 | 30 | 5 | 138.4k |
| C (4 council agents) | 2 | 13/13 | 32 | 6 | 140.5k |

The grader's 13/13 for the single reviewers was spot-checked by grepping their raw findings for each defect's key
terms: all present.

Against the pre-registered rules:
1. Discrimination check: **failed again.** One generic sonnet reviewer caught all 13 in both reps.
2. Council beats resampling: **no.** Same detection; C found fewer valid extras than B (30/32 vs 35/33) and more
   invalid ones (5/6 vs 0/1). Every invalid C finding came from the scope lens: simplification preferences
   (drop Celery, drop htmx, merge apps) that are not defects.
3. Worth it over one critic: **no** for detection. Four reviewers add ~6–11 valid issues, mostly minor.

Other observations (two reps, not a trend):
- The council agents are cheaper than `general-purpose` ones: ~35k vs ~57k tokens per reviewer (smaller system prompt).
- With the fetch requirement, the grounder fetched sources (12–13 tool calls) while generic reviewers said they cited
  from memory. Provenance improved; detection did not.
- Custom council agents could not write files (see design.md); the pipeline now has the orchestrator write everything.

Conclusion: two seeded-defect tests, two ceilings. Planted defects in a written plan are found by a single fresh
critic; this test format cannot show a benefit for parallel lens review, and none appeared. The review stage of the
council is not justified for detection; what remains untested is the architecture stage (divergent sketches + judge)
and the end-to-end effect on a real build (test 2).
