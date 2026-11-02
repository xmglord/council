# Judge rubric

Score each criterion 1–5 with one sentence of justification citing the input. A score without a citation is invalid.
Ignore length, tone and confidence of the writing; judge content only.

## Architecture rubric (sketches → ADRs)
1. Spec fit: every must-requirement is served; no requirement is silently dropped.
2. Simplicity: fewest moving parts that meet the spec; the boring option wins ties.
3. Operability: who deploys, monitors and maintains it, with the team and budget in the spec.
4. Reversibility: expensive-to-reverse choices are few and justified.
5. Risk visibility: unknowns are named and paired with a spike.
6. Constraint compliance: hosting, data sensitivity, integrations.

Hard fail: any violated hard constraint from the spec.

## Plan rubric (plan.md + review findings → verdict)
1. Traceability: every must-requirement maps to at least one task.
2. Contracts: every cross-module dependency has an explicit interface (input, output, errors).
3. Executability: each task has inputs, deliverable, owned paths and a checkable acceptance criterion.
4. Parallel safety: no two tasks in the same wave own the same paths; dependency graph is acyclic.
5. ADR consistency: the plan does not contradict accepted ADRs.
6. Grounding: technical claims are verified or listed as spikes.
7. Scope discipline: nothing beyond the spec's must/should items without a stated reason.

Verdict: PASS only if no open blocker findings and every criterion ≥ 3.
Otherwise FAIL with the list of findings the planner must resolve.
