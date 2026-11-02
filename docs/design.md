# Council: design notes

## Problem

A single Claude session is a weak judge of its own plans:

1. **Context anchoring.** Once a plan is in the context window, critique happens inside that plan's framing.
2. **Self-preference.** LLM evaluators rate their own outputs higher (Panickssery et al., NeurIPS 2024, arXiv 2404.13076).
3. **One sample.** One reasoning path, no visible variance.

For large plans (a whole app: architecture, stack, modules, tasks) that will later be executed by several agents in
parallel, plan defects are the expensive ones: they propagate into every task built on top of them.

## What actually helps

The "council" pattern bundles four mechanisms. They are not equally valuable:

| Mechanism | Value | Why |
|---|---|---|
| Context isolation (fresh agent, no author reasoning) | High | Removes anchoring; cheap |
| Distinct lenses (pre-mortem, simplest option, executability, grounding) | Not supported: two seeded tests, one fresh critic found every defect; lenses ≤ resampling (see evaluation). Dropped except grounding | Meant to force search where the author did not look |
| Rubric fixed in advance + separate judge | High | The most persuasive text does not win by default |
| Debate between assigned positions | Low | See below |

Evidence on debate: at equal compute, multi-agent debate does not beat self-consistency / majority voting
(Huang et al. 2023, arXiv 2310.01798; Smit et al., ICML 2024, arXiv 2311.17371; Zhang et al. 2025, arXiv 2502.08788, which benchmarks 5 debate methods
across 9 benchmarks). Smit et al. add that tuning agreement levels can lift debate above non-debate protocols. Same-model agents have correlated errors and debates converge by conformity. arXiv 2502.08788
points to **model heterogeneity** as the lever that does help — the design of Karpathy's llm-council (several
providers, anonymized peer ranking, a chairman model that synthesizes).

## Design decisions

- **One author, many reviewers.** Plans written by committee are incoherent merges. The council diverges only on
  expensive-to-reverse decisions (architecture) and reviews the detailed plan; a single planner writes it.
- **One fresh critic plus a grounder.** The review stage is one generic critic (context isolation, no assigned lens)
  and the grounder. The red-team, executability and scope lenses were dropped after test 1 (2026-10-22): one generic
  critic caught every seeded defect in both fixtures, lenses did not beat resampling, and the scope lens produced
  most invalid findings. The grounder stays for provenance: it fetches sources, generic reviewers cite from memory.
  Retired prompts: `eval/retired_agents/`.
- **Anonymized inputs to the judge.** Architect sketches are labeled A/B/C; the judge does not know which model or
  constraint produced them.
- **Rubric before content.** The judge's rubric is a fixed file, not written after seeing the proposals.
- **Main session orchestrates, does not judge.** It holds the full conversation (contaminated context). It only
  routes files between agents and asks the user at approval gates. Orchestration stays in the main session (not in
  an orchestrator subagent) because only the main session can ask the user questions mid-pipeline.
- **Only the orchestrator writes.** Agents return their full output as text and the orchestrator saves it verbatim.
  The first design (agents write files, return one-line summaries) failed: in test 2 the harness refused every
  Write from the custom council agents ("Subagents should return findings as text, not write report files") while
  `general-purpose` agents wrote fine (2026-10-22, Claude Code 2.1.308). Cost: agent outputs pass through the
  orchestrator's context.
- **Grounding over opinion.** The grounder checks technical claims (library capabilities, versions, limits) against
  real docs; unverifiable claims become mandatory spikes, not debates.
- **Claude-only for now.** Partial diversity via different Claude models per role. Multi-provider is phase 2,
  conditional on the evaluation showing correlated misses, and only for non-sensitive projects.

## Pipeline

1. Intake → `spec.md` (user approves)
2. 2–3 architects in parallel, different constraints → `sketches/sketch_{a,b,c}.md`
3. Judge (architecture rubric) → `adr/*.md` + `architecture_verdict.md` (user approves: point of no return)
4. Planner → `plan.md`
5. Critic + grounder in parallel → `review/round_N/{critic,grounder}.md`
6. Planner revises → judge (plan rubric) → `verdict.md` pass/fail; max 2 review rounds
7. Output consumed by an executor session (out of scope for v0)

## When to use it

Written before the tests. What they showed, and the preliminary rule that replaces this for now, is in the README.

- Yes: new multi-module apps/systems, large migrations, any plan that several agents will execute.
- No: anything a spike or a measurement settles (do the measurement), bounded changes (plan mode is enough),
  factual questions.

## Known limits

- Same-model reviewers share blind spots; a second reviewer of the same model does not remove this.
- Cost is several times a single session; measured in `evaluation.md`, not estimated here.
- Subagents can spawn subagents (up to 3 levels by default), but council agents have no `Agent` tool on purpose:
  each one does exactly one job.
