# Next steps (2026-10-30)

## What "finished" means

Council is finished when three things exist:

1. A usage rule backed by evidence: when to use it, when plan mode or another method is enough.
2. A pipeline version with the lessons of test 2 applied and tried on one new project.
3. The public repo decision resolved: this repo, published as an open experiment before pipeline v3.

## Step 1: ECC review (done)

Review of the ECC plugin, not published: adopt a part, on a project basis, without hooks at first. Not an arm of test 3.

## Step 2: test 3 (done, 2026-11-02)

Result in `docs/evaluation.md`; evidence in `eval/test3/`. Plan mode built nearly the same thing at about 2.2 times the cost, testing deeper and not closing cleanly. Most of the gap is testing cost.

## Step 3: pipeline v3

Apply after step 2, so its results can shape the changes. Candidates from test 2:

- Add to the review: how the result is installed and used on a real machine (global scope), shared runtime state in
  parallel tasks, live acceptance tests, and whether new capabilities are documented where the agent reads them.
- Keep: spikes, the grounder, the assertion format.
- Test simplifying: contracts caused most of the 23 council-introduced defects.
- Revisit the task list against the critic's and grounder's real yield.

Candidates from test 3 (one run):

- Avoid resuming long-lived subagents between rounds. Subagent cache lasts 5 minutes and the main session's 1 hour, and such resumes were 57% of the arm's cold-cache excess. Try fresh subagents briefed from files, with rework in the main session, and measure it.
- Decide test depth on purpose. Role and browser tests found gaps council missed, and were 72% of the arm's cost. Try cheap API checks for most tests, with browser and role tests kept for the riskiest needs.

## Step 4: next real large project

Run v3 on a new large project with the protocol pre-registered, if the gate accepts it, and log it like test 2. Private
data stays out of this repo. Then make the usage rule final.
