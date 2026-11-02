# Test 3: execution log

Kept by the council session from the arm's transcript, in the format of test 2. The council session does not coach.

| Date | Stage | What failed | Cause | Fix |
|---|---|---|---|---|

Setup check 2026-10-30: one `claude -p` run on haiku in the arm's configuration confirmed Bash and Read are denied on `~/council` and `~/odoo_functional_agent`. That session is excluded from the arm's cost.

Isolation gap found by the author on 2026-10-30, with the arm already running: `protocol.md` denies fetches of `xmglord/odoo-functional-agent`, but the settings denied only `raw.githubusercontent.com` and that string in Bash. `github.com` was open, and so was `xmglord/xmglord`, whose case study (not yet published) lists the six hidden findings.

- Checked first: the arm had 0 WebFetch and 0 WebSearch calls at that point, see the audit line below.
- Decision: extend the settings, not the frozen files. `settings.json` implements the protocol and is not among the frozen hashes. It is stronger than the protocol's wording: rules filter by domain, so every GitHub domain is denied, including `github.com/odoo`. Git clones of Odoo's repos still work; `Bash(*xmglord*)` is denied.
- Confirmed in a separate session, excluded from cost: WebFetch to `github.com/xmglord/xmglord` and `echo xmglord` are denied.
- Update 2026-10-31: the arm process was restarted on 2026-10-30 at 14:07 local, after the rules changed, so it runs with them. Earlier note, kept: not confirmed whether the running arm session picked up the new rules. Checked 2026-10-30: the transcript has no reload record and no denial, and the session started before the change, so there is no evidence either way. A restart with `--continue` applies them.
- WebSearch stays allowed: it has no domain filter, and a blanket deny would change what the arm can do compared with the council builder. Search results could expose public text, so the audit covers it.
- Audit at that point: 44 Bash, 4 Read, 0 WebFetch, 0 WebSearch. Three Bash calls mention GitHub: reading Odoo's source, and writing `sync_docs.sh` and the README. None mentions `xmglord`.
- Added to the final audit: every WebFetch and WebSearch call, every Bash call with a network command, and whether any response shows a hidden finding. Each one gets recorded here. A hit is reported as contamination and the grader is told.
- `xmglord/xmglord` must not publish the case study until the audit ends.

Final audit, 2026-11-02, over the main transcript and every subagent:

- WebFetch and WebSearch: 0.
- Browser: 460 navigations, all to `localhost:8080`.
- Network commands: `docker pull` and build, `uv pip install`, `git clone` of `odoo/documentation`, `npm view` of the Firefox MCP package, and `curl` to `odoo.com`, GitHub (a reachability check) and the test PACs. None reached the denied repos.
- Denied paths: no read. `xmglord` appears only in the arm's own leak-check grep (three of those calls were denied by the rule); `~/.claude.json` was listed once with `ls`.
- Hidden findings from outside sources: none found. The six are for the grader. By text search, findings 1, 3 and 5 appear with their own measurement or source citation, finding 4 appears as a documentation rule (`mexico.rst`) without the error code, finding 2 is unclear, and finding 6 does not appear (T27 is a US database).
- Stray file: `~/Downloads/FBINV_2026_00005.pdf`, a demo invoice from AT-06, outside the arm's folder.
- Own-config check: the arm's name `odoo_functional_agent` comes from `plan_mode.md`, not from an access.

Contamination: none found.

Grading setup, 2026-11-02: the X/Y coin is in `mapping.txt`; the blind grader works only from an anonymized package with no cost tables. The logs differ in depth and X has case-study reports while Y has none, and each plan's style can hint at its source; these limits go with the result. The database reading runs in a fresh session under the arm's configuration, launched by the author, because the plugin's guard denies this session any Odoo call; the guard was not bypassed. That session also checks whether AT-75 appears on a clean database. Its cost is excluded.

## Stage A findings

| Date | What happened | Note |
|---|---|---|
| 2026-10-30 | `selection_ids` sequences did not converge: Odoo renumbers from 0 | Arm's spec defect, fixed by removing `sequence` after author choice |
| 2026-10-31 | The tester ran its checks in the browser, with 316 snapshots and 150 screenshots; most of the stage's cost | Compare with council's API scenarios |
| 2026-10-31 | The arm's report says a test invoice landed in `~/Downloads` and was deleted | Outside the arm's folder; to verify in the audit |
| 2026-10-31 | Parts of AT-16 to AT-18 ran as admin; `amount_to_invoice` claim is from source reading only | Reported by the arm |
| 2026-10-31 | T24 apply did not converge: `is_company` is computed and the four fictional vendors have no tax id | Same Odoo behaviour as council's defect on `is_company` (test 2, C7); here caught by the arm's convergence check |
| 2026-11-01 | T26 second round: a rule meant to protect cancelled CFDIs blocked every invoice and credit note in every company, because `on_create_or_write` does not evaluate the pre-domain on create; `--dry-run` does not run rules | Defect introduced by the arm's fix, found live by its tests. 52 pass, 3 fail, 3 not run, with 34 carried from the earlier spec |
| 2026-11-02 | T27 second test run, finished 18:01 UTC at about 201M: of 69 regular, 67 pass (50 run, 17 carried), 1 fail (AT-75), 1 not run (AT-79); 23 of 24 limits confirmed, AT-90 differs. AT-06 passes, so `report.url` was the cause | Reported by the tester, not yet graded. The bank-leak fix broke opening four posted bills (AT-75): defect introduced by the arm's fix, left open by the stop rule |
| 2026-11-02 | T27 first test run: 56 of 60 regular pass, finished at 162.11M | Reported by the arm; not yet graded |
| 2026-10-31 | T26 first test run: 42 of 49 regular pass | Reported by the arm; not yet graded |
| 2026-10-31 | T24 first test run: 37 of 41 regular pass, 4 fail; 9 of 10 gap checks confirm the limit, 1 differs (AT-09). Role steps ran by session, not browser, except visible ones | Reported by the arm; not yet graded |

Ceiling raised from 80M to 140M on 2026-10-31 at the author's decision, with the arm at 68.92M: `addendum_2026-10-31.md`. Record the arm's state when it crosses 80M.

80M crossed on 2026-10-31 at 20:38 UTC, during T25's second test round: T21 and T24 closed, T25 retesting, T26 and T27 not started.

Ceiling raised from 140M to 180M on 2026-11-02 at the author's decision, with the arm at about 131M and AT-44 running: `addendum_2026-11-02.md`. It is the last raise. Record the arm's state when it crosses 140M.

140M crossed on 2026-11-02 around 15:20 UTC, at T27's approval stop: T21 to T26 closed, T27's spec and 76 tests written, nothing applied yet.

180M crossed on 2026-11-02 around 17:42 UTC, during T27's second test round: T21 to T26 closed, T27 at 56 of 60 regular from round one. No stop took effect. Ceiling raised to 210M at the author's decision, with the arm at 192.14M and no more correction rounds: `addendum_2026-11-02b.md`. The review session never ran, so T26 and T27 both went without one, while the council had one in both.

Author's note, 2026-11-02: after a stage closes, the arm leaves an agent listed as alive and idle. Checked at close: no subagent wrote after 18:01 UTC and the cost stayed at 202.05M, so it spent nothing. The author ended the arm with `/exit`, stopping that task.

T27 differences from the council's clarifications, as proposed: eliminations go in an `ELIM` journal in Holdings, not a fourth company, and the controller's limit is a marker group with an access rule tied to the company name, not an allow-list. The arm did not ask about either, so the author gave no answer.

Review session: the author chose to use it for T27 only (2026-11-01); T26 ran without one, so T26 has no review while the council's had. It runs fresh, from `/var/tmp/test3_review/`, under the arm's denies, and its cost is excluded from the arm's and reported apart, as the council's review session is not in its cost either.

AT-44 was due at 2026-11-01 05:01 UTC and ran at 2026-11-02 06:31 UTC, a day late: the machine was suspended from 2026-11-01 03:11 UTC until 06:29 UTC the next day, and the arm's wait loop ended on waking. The arm checked the clock and went ahead, since the test's window lasts until 2026-11-03 05:00 UTC. No intervention. The cold restart took the cost from 126.11M to about 129.5M, likely expired cache, not measured; elapsed time at T26 includes this suspension.

Cold cache, measured 2026-11-02 at the author's request. A resume after a pause rewrites the context at weight 2 instead of reading it at 0.1, so human waits inflate the cost. Counted per transcript, subagents included, as calls after a gap over 5 minutes that wrote more than 20k tokens, with the excess taken as 1.9 per token: arm 21 resumes, 16.04M of 137.64M (11.7%); council builder 6 resumes, 1.60M of 68.06M (2.4%). Main sessions alone: 3.92M and 1.41M, so most of the arm's excess is subagents resumed after waiting. The method is an estimate and the council's example sessions are not included. The ceiling keeps counting raw cost. The results report both: raw, and with the excess removed. Removing it leaves the arm at about 122M and the builder at about 66M, so it narrows the gap and does not close it.

Attribution of the arm's 16.04M, same day. The usage records show the cache time-to-live: 1 hour on every main-session call and 5 minutes on every subagent call, in both builds. A resume counts as human only if the gap, minus the human wait and suspension, stays under that limit.

| Cause | Resumes | Excess | Share |
|---|---|---|---|
| Pipeline: a subagent idle over 5 minutes while others work, then resumed | 13 | 9.14M | 57% |
| Author's waits alone | 6 | 4.09M | 25.5% |
| AT-44's clock window plus suspension | 2 | 2.81M | 17.5% |

The builder's 1.60M is 1.41M author's waits and 0.19M pipeline: it worked in its main session (1,035 calls against the arm's 239), so it had little to resume. The arm's resumes rewrote subagent contexts of 77k to 779k tokens. Human waits are classified from transcript events, so the split is an estimate. One build each: it shows this run's shape, not a rule about plan mode. The pattern comes from this plan's analyst, configurator and tester rounds; a council plan with the same design would likely pay the same.

## Author interventions

| Date | Stage | Question or correction | Who started it |
|---|---|---|---|
| 2026-11-02 | C (T27) | Closed without the clean-database validation, under the third addendum's stop rule: AT-75 stays failed with the inference declared. The council session checks the clean apply separately, outside the arm's cost | Author, after the council session flagged the rule |
| 2026-11-02 | C (T27) | Arm proposed validating the final spec on a clean database; author first chose it and told the arm to wait, to check it against the stop rule. Cron left as it is | Arm's question |
| 2026-11-02 | C (T27) | Removed two global restrictions the analyst had added unapproved, at the arm's own objection, and approved the re-apply (arm's recommended options; the transcript shows the removal, the approval is pending confirmation) | Arm's question |
| 2026-11-02 | C (T27) | After 56 of 60 regular tests: author took the arm's recommended options (fix package, fix `report.url` in `ofa` and Ridgeline only, keep database, case study and commit) | Arm's question |
| 2026-11-02 | C (T27) | `base.group_multi_company` added to 3 users, because Odoo adds it and the apply did not converge (arm's recommended option) | Arm's question |
| 2026-11-02 | C (T27) | Spec approved (hash `05e56dc02c17ba13`, 76 tests) at 15:24 UTC, before any review session had started. Placeholder taxes and `draft` state (arm's recommended options) | Arm's question |
| 2026-11-02 | C (T26) | AT-44 could not set the Global Lock because of 7 unreconciled demo bank lines; author chose `Lock Sales` (arm's recommended option), which changes the test's wording | Arm's question |
| 2026-11-01 | C (T26) | Approved the re-apply of the corrected spec (hash `8d36996f5b99b4b4`), starting with smoke test AT-72 | Arm's question |
| 2026-11-01 | C (T26) | Fix the blocking rule and repeat the affected tests (arm's recommended option), no wait requested | Arm's question |
| 2026-11-01 | C (T26) | Re-apply of the corrected spec (hash `58c8214f8adcf68f`) and retests, including AT-44 when its window opens: approved per the transcript | Arm's question |
| 2026-11-01 | C (T26) | The analyst's second report never reached the arm: `SubagentHandback` refused a second report, so the arm waited 25 minutes. Author told it where to read the report; no content given | Tool failure, seen by the author |
| 2026-10-31 | C (T26) | After 42 of 49 regular tests: author took the arm's recommended options (fix package, evaluate retry and notice for cancellations stuck in 211, keep database, case study and commit) and told the arm to wait | Arm's question |
| 2026-10-31 | C (T26) | `tz` of the users changed on its own after logins, so the spec did not converge; author chose to remove `tz` (arm's recommended option) and told the arm to wait | Arm's question |
| 2026-10-31 | C (T26) | Spec approved (61 tests). Remove the demo bank link from BNK1; keep stamping as a manual Send with a reminder, declared as a limit (arm's recommended options). Author told the arm to wait | Arm's question |
| 2026-10-31 | C (T26) | Company: ZAPATERIA URTADO ÑERI, Solución Factible, name unchanged (arm's recommended options; council used demo company 4 with Quadrum, so the runs differ here). Author told the arm to wait | Arm's question |
| 2026-10-31 | B (T25) | Re-apply of the final spec (hash `bd4b16a07c0b00e4`) with 32 retests, including the EUR journal fix: approved; author told the arm to wait | Arm's question |
| 2026-10-31 | B (T25) | Approved re-apply and a retest of 30 tests; chose to look for a real fix for the EUR journal proposed by Pay, and to fix the guard's message (all arm's recommended options); told the arm to wait | Arm's question |
| 2026-10-31 | B (T25) | After 50 of 61 regular tests: author took the arm's recommended options (fix package, declare two role limits, keep the database, case study and commit) and told the arm to wait | Arm's question |
| 2026-10-31 | B (T25) | Corrected spec approved on a `--country US` database. Company 1 renamed to Lumen Ridge Studios (arm's recommended option; council left the demo name, so the runs differ here). Author told the arm to wait | Arm's question |
| 2026-10-31 | B (T25) | Spec approved; down payment inherits 30 days. Company answered as Mexico, MXN, 16%, against the T25 clarification (demo company 1, USD, generic chart, 15%); the council session flagged it before anything was applied, to correct per protocol | Arm's question |
| 2026-10-31 | B (T24) | Approved re-apply of the corrected spec (only change: `group_send_reminder` false) and the retest of six tests; author told the arm to wait | Arm's question |
| 2026-10-31 | B (T24) | After 37 of 41 regular tests and 10 gap checks: author took the arm's recommended options (fix package, accept role steps by session instead of browser, keep the database, case study and commit) and told the arm to wait | Arm's question |
| 2026-10-31 | B (T24) | `is_company` did not converge; author chose to remove it (arm's recommended option) and told the arm to wait | Arm's question |
| 2026-10-31 | B (T24) | Spec approved. Threshold: 50,000 on the taxed total, accepted as a gap (T24 clarification); the arm raised this itself. Company: Mexico, MXN (arm's recommended option; council's T24 used San Francisco, USD, so the two runs differ here) | Arm's question |
| 2026-10-31 | A (T21) | Author rejected the arm's combined closing command; reason not recorded in the transcript | Author |
| 2026-10-30 | A (T21) | `selection_ids` sequences did not converge after the apply; author chose to remove `sequence` from the spec, and told the arm to wait. Not applied yet | Arm's question |
| 2026-10-30 | A (T21) | Approve applying the spec: yes. Billing method: label only (recommended, same gap as council T21). Company: Mexico, MXN, 16% (T21 clarification) | Arm's question |
| 2026-10-30 | A (T21) | Author told the arm to wait before continuing; the council session gave no content advice | Author |

## Cost at each milestone

| Stage | Weighted cost | Elapsed | Result |
|---|---|---|---|
| Stage C closed, T27, commits `00038d1` and `17d5345`, 2026-11-02 18:06 UTC (council at T27: 64.7M, excluding example sessions) | 202.05M | | No example sessions in the arm. Arm's tests, second round: 67 of 69 regular, AT-75 failed and left open, spec final never applied clean, no review session; not yet graded |
| T26 closed, commit `bc4a205`, 2026-11-02 06:53 UTC (council at T26: 59.8M, excluding example sessions) | 135.90M | | Arm's own tests: 59 regular pass, 15 limits confirmed; 55 of the 74 results come from earlier specs and were not observed again on the final one; AT-44 ran with `Lock Sales`; no review session; not yet graded |
| Stage B closed, T25 (council at T25: 53.2M, excluding example sessions) | 91.45M | | Arm's own tests: 66 regular pass; not a clean close by its own report; crossed 80M during T25's second test round |
| T25 first test run, fix package pending (council at T25: 53.2M, excluding example sessions) | 64.35M | | 50 of 61 regular tests; this run alone cost about 20M; the 80M ceiling will likely stop the arm in stage C |
| T24 closed, commit `dd257ae`, 2026-10-31 (council at T24: 42.3M, excluding example sessions) | 36.70M | | Arm's own tests: 40 regular pass, 14 limits confirmed, six of them explicit needs Odoo does not meet as asked; not yet graded |
| Stage B, T24 paused 2026-10-31 after its first test run (council at T24: 42.3M, excluding example sessions) | 30.76M | | Fix package pending; T25 not started; the arm warns that a cron recreates RFQs in the Harbor database on 2026-11-01 08:25 UTC |
| Stage A closed, commit `8467267`, 2026-10-31 07:47 UTC | 19.2M approx. | | AT-13/14 reworded by the arm, not re-run; base `demo_vantage_campaign_sales` kept |
| Stage A end to end, 2026-10-31 07:41 UTC (council baseline 40.2M, which excludes example sessions) | 18.86M | | Arm's own tests: 22 of 24 passed, 2 failed on wording; 0 WebFetch, 0 WebSearch; not yet graded against `acceptance/t21.md` |
| Stage A, paused 2026-10-30 20:55 UTC | 3.82M | | 39 of 39 records applied; spec change pending; `ui_steps` and 24 tests not run; 0 WebFetch, 0 WebSearch |
| Phases 0-3 (before stage A's requirement) | 1.26M | 45 min | 4 commits, 58 integration tests; `/implement` not yet run end to end |
