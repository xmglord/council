# Redactions

Everything changed or left out for publication. Closed evidence was not edited to improve it.

## Rules

- Replacements stay inside the line, so line numbers still match the original, and the rest of the text is unchanged.
- A placeholder says what class of text it replaces: `[redacted: <class>]` or `[withheld: <reason>]`.
- The frozen files of test 3 (`protocol.md`, `amendment.md`, `hidden_findings.md`) are unchanged and pass
  `sha256sum -c frozen.sha256`.
- Evidence written in Spanish (`eval/test2/plan_mode.md`, the brief in `eval/test2/protocol.md`) stays in Spanish, since
  a translation would no longer be the artifact that was tested.

## Edited evidence

The hash is the first 16 hex characters of the sha256 of the original file, which is kept privately.

| File | Lines and class | Original sha256 |
|---|---|---|
| `eval/test2/plan_mode.md` | employer name (10, 68), home path (11), private notes path (87) | `63dfd4eb20a83bd9` |
| `eval/test2/execution_log.md` | local database role (9, 21, 64, 115, 124), local path (82), Enterprise code detail (92, 94), private project and access detail (95), private terms (96, 106), withheld validation (99-107) | `40e69342c713dc10` |
| `eval/test3/grading/grade.md` | withheld validation (100, 107, 257-261, 293). Classes and counts are unchanged | `dd740ae0739778f8` |
| `eval/test3/grading/acceptance_results.md` | scratchpad path (105) | `9c647b376c545fc8` |
| `eval/v1/fixture/spec.md` | one word in the problem statement (4) | `5659a09cae872713` |
| `eval/v2/fixture/spec.md` | one word in the problem statement (4) | `33d0d61d7655a945` |

The fixture edit changes "holding" to "group". No answer key or result cites that word.

In `eval/test2/execution_log.md`, the classification in `eval/test2/classification.md` uses lines 9-39 and 115-132, so
the counts 23, 8, 11 and 6 do not depend on any withheld row. Rows `Y Ln` in `eval/test3/grading/grade.md` refer to line
n+2 of this log (checked on two rows).

## Edited documents

`docs/evaluation.md`, `docs/next_steps.md` and `docs/design.md` are live documents, so they were edited directly:

- Machine paths and private plans removed.
- The test 2 confound keeps the different intake answers and drops a note on licensing that does not affect the result.
- One post-build validation on a private case is withheld.
- **Corrected:** test 3 said "165M on four requirements". 165M is what came after T24, so it covers three (T25-T27).
- **Clarified:** the cold-cache figures of 122M and 66M are at the point measured, not at the final totals.
- Citations in `docs/design.md` were checked against the sources on 2026-11-02, and one nuance from Smit et al. was added.

## Not published

| What | Why |
|---|---|
| `eval/v1/answer_key.md`, `eval/v2/answer_key.md` | Withheld; hashes in `eval/answer_keys.sha256`. The decision rules of the second fixture exist in full only there; `docs/evaluation.md` restates how they applied |
| Test 3 archive (transcripts, the arm's repository, grading package) | May quote code that cannot be published |
| Private post-build validation | Confidential |
| `eval/ecc_review.md` | Review of a third-party project, not a test of council. `eval/test3/protocol.md:11` still names it |
| `eval/test3/excluded_sessions.txt` | Session paths, of no use without the transcripts |
| The council plan for test 2 (`docs/plan/` in the app's project) | Local only by that project's decision |

## What this means for auditing

- The comparison tables can be checked against the logs, classification and grades published here.
- The per-defect grades of test 1 cannot be checked against the keys, and the grading of plan mode's reports in test 3
  cannot be checked against those reports.
