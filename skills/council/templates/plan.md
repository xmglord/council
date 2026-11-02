# Plan: <project name>

Spec: spec.md · ADRs: adr/

## Overview
<One paragraph: what gets built and the shape of the system.>

## Module map
| Module | Responsibility | Owns paths | Depends on |
|---|---|---|---|
| M1 | | `src/m1/**` | — |

## Interfaces (contracts between modules)
For each boundary: caller, callee, operation, input schema, output schema, errors.
Contracts are the only thing parallel agents may assume about each other.

### M1 → M2: <operation>
- Input:
- Output:
- Errors:

## Data model
<Entities, key fields, relations, ownership by module.>

## Tasks
Each task must be executable by an agent that reads only this plan, the spec and the ADRs.

### T1: <title>
- Module: M1
- Depends on: —
- Owns paths: `src/m1/...`  (no two parallel tasks own the same path)
- Inputs: <contracts / files it relies on>
- Deliverable: <what exists when done>
- Acceptance: <checkable command or observable behavior>

## Execution order
<Waves of tasks that can run in parallel; the dependency graph must be acyclic.>
- Wave 1: T1, T2
- Wave 2: T3 (needs T1)

## Spikes (before freezing the plan)
- S1: <risky assumption> → <cheap test> → <what result changes which decision>

## Risks
- <Risk> · likelihood · impact · mitigation
