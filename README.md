# council

**An open experiment, not a finished tool.** Three tests are closed. Pipeline v3 is pending, so the pipeline in this
repo is the one that was tested, with its known defects, and the usage rule below is preliminary. This is one app and
one run of each build. Nothing here shows that council is better than Claude Code's plan mode.

## The question

A single Claude session is a weak judge of its own plans. Does a multi-agent planning pipeline, where independent
architects, a rubric-bound judge, one planner, a fresh critic and a grounder produce the plan, lead to a better build
than plan mode, and does it earn its cost on a whole app?

## What was tested

| Test | What ran | Outcome |
|---|---|---|
| 1. Seeded defects | Two fixtures with 10 and 13 planted defects, reviewed by 1 generic reviewer, 4 generic reviewers and 4 lens reviewers, 2 reps each | **Did not pass.** Ceiling in both |
| 2. One real app | Same brief to plan mode and council; council's plan built into [odoo-functional-agent](https://github.com/xmglord/odoo-functional-agent) | App shipped; plan mode's plan not built yet, so the comparison stayed open |
| 3. Building the other plan | Plan mode's plan built with the same model and requirements | Council not shown to be better by defect count |

Costs are weighted token units (input 1, cache write 2, cache read 0.1, output 5). The ratios are assumed, so they
compare stages of this project and are not prices.

## What came out

### Test 1: the test could not discriminate

One generic reviewer caught every seeded defect in every rep: 10/10 and 13/13. Lens reviewers did not beat plain
resampling. On the second fixture they found fewer valid extras (30 and 32 against 35 and 33) and more invalid ones
(5 and 6 against 0 and 1). The rule written in advance said lenses had to clearly win, so they were removed. The
review stage is not justified for detection by this test, and the format cannot show a benefit.

### Test 2: council's plan shipped an app, and added defects of its own

All 30 tasks were built. Seven checks were written before either plan. An anonymized grader put council ahead on
verification (assertion format, API facts checked against Odoo 20 source), and still picked plan mode to execute:
"the gap is mostly one of scale". Council's planning cost about 10.9M against plan mode's 0.18M, about 60 times with
spikes and 36 times without them.

| Build failures, classified against plan mode by one non-blind grader | Count |
|---|---|
| Defects introduced by the council plan | 23 |
| Defects plan mode would also have had | 8 |
| Failures the council plan prevented | 11 |
| Plan hits that only offset its own design | 6 |

Most of the 23 were cheap contract gaps. The 11 include two holes in the demo-only guard.

### Test 3: plan mode built nearly the same thing

| | Plan mode | Council |
|---|---|---|
| Cost, full run counted the same way | 202.05M | about 91M (about 12M estimated) |
| Active agent hours, build | 11.9 | 5.3 |
| Hidden findings with evidence | 3, plus 2 unmeasured, 1 could not arise | 5, plus 1 unmeasured |
| Defect rows, T21-T27 (blind grader) | 21 | 20 |
| Needs read from the database (49) | 36 met, 12 partial, 1 not met | not read the same way |
| End state | T27 with AT-75 failing and AT-79 not run | Complete and published |

- **The cost gap comes from testing.** Plan mode cost half as much up to T21. Its tester alone took 145.31M, 72% of the
  total.
- **That testing also found more.** Its 69 regular tests on T27, by browser and by role, exposed about nine classes of
  real gap that council shows no sign of checking.
- **Cold cache does not explain the gap.** Without the cold-cache excess, at the point measured (137.64M and 68.06M,
  not the final totals), the figures are about 122M against 66M.

## What did not come out

- **Council is not shown to be better by defect count.** On the comparable window it is 21 against 20, and the totals
  are not comparable because plan mode's log has no rows before T21.
- **Test 1 did not pass.** It says nothing in favour of the review stage.
- **Plan mode did not close cleanly either.** AT-75 failed, and its clean-database reading points to a residue that is
  probably, not provably, the cause.
- **Pipeline v3 does not exist yet.** The lessons from tests 2 and 3 are listed in [next steps](docs/next_steps.md) and
  are not applied. The contracts that caused most of the 23 defects are still in this pipeline.

## Limits

- One app, one repetition. This shows no trend.
- The ceiling of test 3 moved three times, from 80M to 140M, 180M and 210M, each with an addendum and each after
  results were visible. The second addendum said it would be the last raise, and the third overrode it. Results past
  180M are the least pre-registered.
- Plan mode's arm was built second by an author who knew the answers, which favours it. It had no review session on T26
  or T27, while council had one on both.
- Both logs were kept by the same session, which knew both builds, and they differ in depth. 14 of the arm's 21 defect
  classifications and 26 of council's 72 are marked doubtful.
- The two Enterprise builds made different company choices in T24 to T26, and only the arm got the database reading.
- Fixtures and reviewers in test 1 came from the same model family.
- The tester's cost and the active agent hours were measured from transcripts that are not published.

## Preliminary usage rule

One app, one run, pipeline v3 pending. Not a general finding.

1. In this run, test depth drove the cost gap and exposed gaps the other build shows no sign of checking, while defect
   rows did not separate the plans (21 vs 20). Depth was not varied independently of the plan.
2. Hypothesis: council may earn its cost on large builds with high integration risk. Here it contributed grounded API
   facts and the assertion format, and its plan introduced 23 defects. App size and integration risk were never varied.
3. Plan mode with deep testing reached nearly the same build, at about 2.2 times the cost, without a clean close, and
   with an author who already knew the answers.

## Evidence

| Path | What it holds |
|---|---|
| [docs/evaluation.md](docs/evaluation.md) | Protocols, tables and readings for all tests |
| [docs/design.md](docs/design.md) | Why the pipeline has this shape |
| [docs/next_steps.md](docs/next_steps.md) | Candidates for v3 and what "finished" means |
| [eval/redactions.md](eval/redactions.md) | Every change made to evidence for publication, and what is not published |
| `eval/v1/`, `eval/v2/`, `eval/results/` | Test 1 fixtures and raw grades. The fixtures are retired: any future seeded test needs a new one |
| `eval/retired_agents/` | Lens reviewer prompts used in test 1 |
| `eval/test2/` | Protocol, plan mode's plan, build log, classification |
| `eval/test3/` | Protocol, addenda, requirements, needs, log, grades |

The answer keys of test 1 are withheld. `eval/answer_keys.sha256` holds their hashes.
`eval/test3/frozen.sha256` covers the frozen test 3 files, which are published unchanged:
`cd eval/test3 && sha256sum -c frozen.sha256`.

## Running the pipeline

This is here so the experiment can be reproduced, not as a recommendation. It needs Claude Code.

```
./install.sh
```

Then, in a Claude Code session started in the target project:

```
/council . short description of what to build
```

`install.sh` symlinks the skill and agents into the Claude Code config. Agents installed while a session is running
showed up a few minutes later (observed once); if `/council` or the `council-*` agents are missing, restart the session.

Output goes to `docs/plan/` in the project: `spec.md`, `sketches/`, `adr/`, `architecture_verdict.md`, `plan.md`,
`review/round_N/`, `verdict.md`. The pipeline stops twice for approval: after the spec and after the architecture
decision.

```
skills/council/SKILL.md     /council orchestration (runs in the main session)
skills/council/templates/   spec, ADR, plan, finding and judge-rubric templates
agents/council-*.md         subagents: architect, judge, planner, critic, grounder
```

## License

[MIT](LICENSE).
