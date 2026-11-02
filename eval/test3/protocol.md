# Test 3: building plan mode's plan (frozen 2026-10-30)

## Question

Does the plan mode plan, built for real, reach the same results as the council plan, at what cost, and with what
failures? Test 2 could only judge this: plan mode was never built.

## Arm

One arm: `eval/test2/plan_mode.md` plus `amendment.md`, built by claude-opus-5-5, the council builder's model. The
council arm is the build already logged in test 2. ECC is not an arm: `eval/ecc_review.md`.

## Stages and baseline

Weighted units as in test 2 (input 1, cache write 2, cache read 0.1, output 5), deduplicated by message id, subagents
included.

| Stage | Scope | Council, cumulative |
|---|---|---|
| A | Phases 0-4, first end to end with the T21 requirement | 40.2M |
| B | T24 and T25 requirements | 53.2M |
| C | T26 and T27 requirements | 64.7M |

The council figures exclude its example sessions (only T21 was measured, 2.55M). The arm's figures include them, so
report both totals for the arm: with and without example sessions.

**Continue** to the next stage while budget remains and the stage measures something new. By default all three run.
**Hard ceiling: 80M**, example sessions included. Passing 40M is a result, not a stop. At the ceiling, stop and report
where it got to.

## Inputs

- Requirements: `requirements/tNN.md`, only the text above "## Clarifications". Asked the same questions, the author
  gives the answers in that section; nothing else.
- The author approves and answers intake, as in test 2, and does not coach. Every intervention is logged.
- For T26 and T27 a fresh session with no memory of either build may review plans, matching the council's review
  session. The council session keeps the log and does not advise.

## Isolation

- Working folder `/var/tmp/test3_plan_mode/`, outside `~`.
- Own `CLAUDE_CONFIG_DIR`, with no plugins or memory. Deny rules on `~/odoo_functional_agent`, `~/council`,
  `~/.cache/ofa`, and fetches of `xmglord/odoo-functional-agent`.
- Own Postgres container and ports; `odoo-pg` and the 8070 server are not touched.
- Source: Odoo core `3ff8b8d9`, Enterprise `f7c24608`, the council's commits.
- Before starting, a read of `~/council` from the arm session must be denied. At the end, audit the transcripts for
  any access.

## Metrics (frozen)

1. Cost and elapsed time at each milestone.
2. Needs proved per requirement (`acceptance/`), judged from the database, not from the arm's tests.
3. Defects, in the classes of `eval/test2/classification.md`, with council as the other side.
4. How many of `hidden_findings.md` the arm surfaces.
5. Guard checks: an unmarked database is refused, a missing marker does not pass, in-page scripts cannot navigate
   away, and other sessions on the machine are unaffected.
6. Author interventions.

## Grading

A fresh agent gets the two logs anonymized as X and Y, the needs and the classes. It does not get the mapping or this
session's notes. The mapping stays in `mapping.txt` until grading ends.

## Known limits

- The author already knows the answers, which favours the arm.
- The plan was written for Community; the amendment fixes scope, not design.
- One rep, one app, built second.
- The council arm is the old pipeline, and its example sessions were barely measured.
- Results compare two builds, not two methods in general.
