---
name: council
description: Plan a large build (a whole app or system, or a big migration) with a planning council. Architects work independently, a judge decides, a single planner writes the plan, a fresh critic and a grounder review it, and the judge gates it. Use only when the user asks for /council or explicitly for a council-reviewed plan.
disable-model-invocation: true
argument-hint: "[project dir] [short description]"
---

# Council

You are the **orchestrator**. You route files between agents and ask the user at the gates.
**Do not judge, merge or rewrite agent outputs yourself.** Your context holds the whole conversation, which is
the contamination the council exists to avoid. When you relay results, summarize them; do not editorialize.

Arguments: $ARGUMENTS

Templates (pass these absolute paths to the agents):
- `${CLAUDE_SKILL_DIR}/templates/spec.md`
- `${CLAUDE_SKILL_DIR}/templates/adr.md`
- `${CLAUDE_SKILL_DIR}/templates/plan.md`
- `${CLAUDE_SKILL_DIR}/templates/finding.md`
- `${CLAUDE_SKILL_DIR}/templates/rubric.md`

Output directory: `<project>/docs/plan/` (call it `$OUT`). If it already contains a council run, ask the user whether to resume or start over.

**You are the only writer.** Council agents have no write tools; each returns its full output as its reply.
Save every reply verbatim with Write to the path named in the step (do not summarize or reformat it). For the
judge's architecture reply, split it at the `=== file: <name> ===` markers and write each part to `$OUT/<name>`.
Pass agents input **paths**, never pasted content, so they read the files themselves.

## Step 0: is a council warranted?

Before anything else, check the request against these questions:
- Is this a new multi-module system, a large migration, or a plan several agents will execute?
- Would a spike or a measurement settle it faster? If so, say that and stop.
- Is it a bounded change? If so, recommend plan mode and stop unless the user insists.

## Step 1: intake → `$OUT/spec.md`

Interview the user to fill the spec template. Use AskUserQuestion for decisions that branch the design.
Do not invent requirements: anything unresolved goes to "Open questions".
**Gate 1:** show the spec and get approval before continuing.

## Step 2: divergence → `$OUT/sketches/`

Launch 2–3 `council-architect` agents **in one message, in parallel**. Give each the spec path and a different constraint. Defaults:
- A: "Use the most boring, standard stack that meets the spec; minimize moving parts."
- B: "Choose what best fits the spec's requirements and constraints, even if it is less common."
- C (only when the spec leaves hosting or integration strategy genuinely open): "Optimize for the lowest operational burden for the team in the spec."

Vary the model per architect (pass `model`: `opus` for one, `sonnet` for another) for some diversity.
Save the replies as `sketch_a.md`, `sketch_b.md`, ... and **shuffle** which constraint gets which letter (use `shuf -e a b c` in Bash; do not pick the order yourself),
so the letter does not reveal the constraint. Record the mapping in `$OUT/sketches/.mapping` (the judge must not read it).

## Step 3: architecture decision → `$OUT/adr/`, `$OUT/architecture_verdict.md`

Launch `council-judge` in mode `architecture` with the spec, the sketch files (not `.mapping`), the rubric and the ADR template. Split its reply at the file markers into `$OUT/architecture_verdict.md` and `$OUT/adr/*.md`.
**Gate 2 (point of no return):** present the decision, the rejected alternatives and the required spikes. The user approves, overrides or asks for spikes first. When the user overrides, record it in the affected ADR as `Status: accepted (user override)`.

Spikes before planning: run each one in the main session only when the user asks, outside the project's source tree
(scratchpad or a folder the user names), and clean up what it created. Save each result as `$OUT/spikes/<id>_<slug>.md`
(question, method, measurements, verdict). **Do not edit the ADRs with spike results**; the spikes directory goes to the
planner, which records any conflict with an ADR under Risks. If a spike contradicts an ADR's decision, stop and ask
the user whether to re-run the judge in mode `architecture` with the spike results as an extra input.

## Step 4: plan → `$OUT/plan.md`

Launch `council-planner` with the spec, the ADR directory, the spikes directory if it exists, and the plan template. Save its reply as `$OUT/plan.md`.

## Step 5: review → `$OUT/review/round_<N>/`

Launch `council-critic` and `council-grounder` **in one message, in parallel**. Give each the spec, the ADRs, the spikes directory if it exists, the plan and the finding template. Save the replies as `$OUT/review/round_<N>/critic.md` and `$OUT/review/round_<N>/grounder.md`.
Reviewers must not see each other's findings or earlier rounds.

## Step 6: gate → `$OUT/verdict.md`

Launch `council-judge` in mode `plan` with the spec, the ADRs, the plan, all findings of the round, the rubric and the previous verdict if there is one. Save its reply as `$OUT/verdict.md` (keep earlier rounds as `verdict_round_<N>.md`).
- FAIL and round < 2: launch `council-planner` in revision mode with the current plan and the verdict, save its reply over `$OUT/plan.md`, then go back to Step 5 with N+1.
- FAIL after round 2: stop and present the unresolved findings to the user. Do not loop further.
- PASS: go to Step 7.

## Step 7: hand-off

Report to the user: the verdict, the number of tasks and waves, the mandatory spikes, and the paths under `$OUT`.
Also report the token usage the Agent results showed for each agent, summed per step, plus your own work in the main
session (intake, spikes, orchestration) measured from the session transcript, so the run's cost is measured, not guessed.
Recommend running the spikes before any execution starts.
