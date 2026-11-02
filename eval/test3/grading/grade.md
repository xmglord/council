# Test 3 grading: builds X and Y

## Verdict

**Neither build wins outright. Y is stronger on the hidden findings and on finishing. X is stronger on depth of functional testing, but it did not close cleanly.**

- **Hidden findings:** Y surfaced 5 of 6 with evidence and 1 as an unmeasured claim. X surfaced 3 with evidence and 2 as unmeasured claims, and 1 could not arise. X's gap is narrower than 5 to 3 suggests: finding 6 was impossible on its US database, and it avoided finding 4 from the docs instead of running into it.
- **Finish:** Y built T01 to T30, published, and proved all T27 needs except two declared gaps. X ended T27 with AT-75 failing, AT-79 not run and no apply from a clean database, and T26 and T27 had no review session. X's T27 still measured more than Y's: isolation, bank data and PDFs.
- **Cost:** X reached about 201M at its last test run. The addenda put Y's full run at about 91M. Removing the cold-cache excess gives about 122M against 66M at the point measured, so that excess does not explain the gap.
- **Depth:** X ran 69 regular tests on T27 alone and left many limits on record per case. That exposed about nine classes of real gap that Y shows no sign of checking (section 4). This is X's real advantage, and it depends on the expensive browser and role testing.
- **Do not compare the defect totals directly.** 45 of Y's 72 defect rows are from the build stage, and X's log has no rows before T21. On T21-T27, the comparable window, the logs give X 21 and Y 20 defect rows.

## 1. Counts

Each cell is the count, with the doubtful ones in brackets. A row in a class ending in `?` in the final table is doubtful. "Both" rows are listed in each build's log, so the same failure can appear once in each (X L13 and Y L31 are one failure).

| Rows | X-only | Y-only | Both | Outside | Defects | Not a defect | Duplicate |
|---|---|---|---|---|---|---|---|
| Build X log | 11 (8) | 0 (0) | 6 (4) | 4 (2) | 21 | 10 | 7 |
| Build Y log, all | 0 (0) | 50 (20) | 4 (3) | 18 (3) | 72 | 20 | 0 |
| Y, build stage (T01-T20, spikes) | 0 (0) | 30 (10) | 2 (1) | 13 (1) | 45 | 9 | 0 |
| Y, T21-T27 only | 0 (0) | 14 (5) | 2 (2) | 4 (2) | 20 | 5 | 0 |
| Y, after T28 | 0 (0) | 6 (5) | 0 (0) | 1 (0) | 7 | 6 | 0 |

Plan hits:

| Build | Prevented (doubtful) | Neutral (doubtful) | Total |
|---|---|---|---|
| X | 5 (2) | 0 (0) | 5 |
| Y | 4 (3) | 14 (4) | 18 |

X's hits: 3 come from the log and 2 only from X's reports. Y's Neutral rows mostly protect things Y's own design introduced: the shared cluster, the marker and the hook. That is not a fault; it means they say little about Y against X.

### Aggregate rows unpacked

X L16, L17, L18 and L71 each summarise a whole test round, so a single class hides their content. These 25 failures are not added to the counts above.

| Row | X-only | Both | Outside |
|---|---|---|---|
| L16 (T27 round 1) | AT-15; AT-16? | AT-06?; AT-09? | |
| L17 (T26 round 1) | AT-12, 16, 37, 58; AT-61? | | AT-39?, 41? (test PAC code 211) |
| L18 (T24 round 1) | AT-39, 46; AT-38? | AT-29? | |
| L71 (T25 round 1) | AT-01, 24, 38; AT-07?, 57? | AT-29, 30, 32, 34, 35 (D+1) | |
| **Total (25)** | **15** | **8** | **2** |

Most of the 15 X-only failures are wrong expected results or fixtures in tests written ahead of the run, not configuration faults. That is the cost of X's test-first approach. Y's equivalent failures show up instead as scenario-authoring errors, in smaller numbers, because Y wrote fewer tests and wrote them after apply.

## 2. Hidden findings

"Evidence" means observed in a run that separates the two possibilities. "Unmeasured" means stated, even with an exact source line, but not observed. If a checked source line counted as evidence, X's finding 2 and Y's finding 1 would both move up, giving X 4 and Y 6.

| # | Finding | X | Y |
|---|---|---|---|
| 1 | Approval threshold uses the taxed total | **Evidence.** `harbor_purchase_inventory__result.md:43`: "Qty 43: 43,000.00, 49,880.00, purchase. Qty 44: 44,000.00, 51,040.00, to approve" | **Unmeasured.** `log_Y.md:74`: "compares `amount_total` (tax included; verified `purchase_order.py:1338`)". The later 69,000 taxed check (L78) cannot separate taxed from untaxed |
| 2 | Mandatory analytic enforced only by Post | **Unmeasured.** `lumen_invoicing_close__decision_log.md:208`: "`action_post` over API and auto-post do not. So **Odoo permits, and only the button obliges**". A guard was built on top, so the bare bypass was never run. The R2 receipts do not isolate it | **Evidence.** `log_Y.md:80`: "the negative "post without analytics" passed", with source `account_move_views.xml:783` |
| 3 | Rate dated D applies from D+1 | **Evidence.** `lumen_invoicing_close__decision_log.md:373`: "on 2026-10-01 the rate was still 0.7791 from 2010"; five tests failed on it | **Evidence.** `log_Y.md:80`: "`_get_rates` uses `name < date` in 20 (`res_currency.py:186`) vs `<=` in 19"; found through failing scenarios |
| 4 | SAT rejects PUBLICO EN GENERAL without a global invoice | **Unmeasured.** `casa_albar_cfdi__decision_log.md:121`: "**The name cannot be `PUBLICO EN GENERAL`:** `mexico.rst:1102-1104`". No rejection seen and no CFDI40130. Doc-based avoidance, which is why it is also a plan hit | **Evidence.** `log_Y.md:85`: "read by the SAT as a global invoice and rejected (CFDI40130)"; fixed, with a global invoice stamped at L86 |
| 5 | Template account `171.16000` fails SAT validation | **Evidence.** `casa_albar_cfdi__decision_log.md:344`: "It fails `ACCOUNT_ID_PATTERN` and `EXPORTABLE_SAT_CODE_PATTERN`"; AT-57 confirms it absent, though the account has no activity, so that test alone cannot separate the causes | **Evidence.** `log_Y.md:85`: "as account `171.16000`, flagged `l10n_mx_is_sat_invalid`"; L87: "182 of 183 l10n_mx subgroups ship `active=False`" |
| 6 | Branch-only user cannot invoice with a tax under `l10n_mx_edi` | **Could not arise.** `ridgeline_group__decision_log.md:34`: "Installed: `l10n_us`, `l10n_us_account`, `l10n_us_reports`, `l10n_us_1099`, `l10n_us_check_printing`". No `l10n_mx` appears in the Ridgeline reports | **Evidence.** `log_Y.md:90` and L92: "`AccessError: Access to unauthorized or invalid companies.`"; traced to `_l10n_mx_edi_is_generic_local_tax`, and a sudo patch removes it |

| Build | With evidence | Unmeasured | Not surfaced | Could not arise |
|---|---|---|---|---|
| X | 3 | 2 | 0 | 1 |
| Y | 5 | 1 | 0 | 0 |

Finding 6 was not missed by X. It depended on a database choice, made under different clarifications. It is also the only finding that decided a business design in Y (branch invoices issued by a Foods+Riverside accountant).

## 3. Results that depend on raised ceilings

- **At 80M:** X had T21 and T24 closed and T25 in retest, so finding 1 and the first-round evidence for finding 3 exist by this point. Finding 2's decision-log entry dates from T25's spec.
- **Between 80M and 140M:** T26, and with it X's scoring on findings 4 and 5, plus T25's close.
- **Between 140M and 180M:** T27 round 1 (56 of 60).
- **Past 180M only:** T27 round 2, under the third addendum: AT-06 passing and so `report.url` confirmed as the cause; AT-75 failing; the corrected bank, role and `group_masterdata` results; the final 67 of 69 and 23 of 24; and X L15, L54 and L55.

No hidden-finding score depends on results past 180M. The defect class of X L15 and L54 does, as does the claim that the PDF fault is solved. AT-06's failure itself is from before 180M.

## 4. Found by one build, with no sign in the other

Checked by keyword search of the other side's files, so "no sign" means none in the available record, not proof that the behaviour was absent.

**X, not in Y:**

1. `report.url` unset: real PDFs lose the header and styling (AT-06; the fix is confirmed only past 180M).
2. Bank accounts with no company are readable by every role (AT-09).
3. `out_receipt` passes guards, so a sale with no CFDI reaches the SAT files (Casa); receipts also skip the post guard (Lumen R2).
4. On create, an automation rule does not evaluate `filter_pre_domain`, and `--dry-run` cannot show it (L14).
5. The clerk can post any accounts through a payment or an imitated link (R8, R9); `reversed_entry_id` is writable (R11).
6. The SAT chart file lists only accounts with activity: 48 rows, 130 active accounts absent.
7. Cancellation answered 211 in 7 of 7 first attempts, silent on screen; in a locked period the entry stays Posted (different PAC from Y).
8. Create Bills with nothing received gives a 0.00 bill and marks the order Fully Billed; replenishment drafts at 0.00 merge with priced lines.
9. Tax follows the delivery address (R12); Pay on EUR invoices proposes the wrong bank (D37).
10. The test PAC signed a fictional RFC, so a stamp passing there proves little about receiver data.

**Y, not in X:**

1. The root cause of the branch `AccessError` (finding 6), traced and patched.
2. Apply gives installed modules' groups to admin but not to the bot: 45 groups against 38 (L30).
3. A re-created database inherits the template's signaling sequence, so a stale registry serves the old marker (L23).
4. Odoo checks access before field names, so a misspelled field returned the expected `AccessError` as a false pass (L82).
5. [withheld: private post-build validation]
6. Agent claims about versions are unreliable: 4 of 21 drift candidates were labelled correctly against 19 source (L68).
7. `RecursionError` in `mail_bot` on first web client load, seen once (L61).
8. In `-p` mode a plugin skill cannot read its own files without `--add-dir` (L56).
9. A plugin hook runs in every session once installed at user scope (L96).
10. `--allowedTools "Bash(ofa *)"` covered 2 of 91 Bash calls in T26 (L88).

Most of Y's list concerns tooling and agent behaviour, and most of X's concerns Odoo behaviour a client would meet. Y's public build and [withheld: private post-build validation] gave it exposure that X never had, so items 5, 9 and 10 could not have appeared in X's record.

## 5. Confidence and limits

- **Hidden findings: high** for the facts. **Medium** for the evidence/unmeasured line, which is a definition, shown in section 2.
- **Prevented and Neutral: low to medium.** Y's rows are compared with an X build stage that is not visible.
- **Defect classes: medium** on T21-T27, **low** on Y's build stage. X's log has nothing before T21, so every build-stage Y-only row means "tied to Y's text", not "X was shown to be free of it". X's build may have had its own such defects.
- **The two logs do not measure the same thing.** Y's has a keeper recording fine contract issues. X's is a summary, and its first-round results are marked "not yet graded". I used X's reports to unpack them, and no equivalent exists for Y, so X's Odoo gaps are visible in a way Y's are not.
- **"Both?" rows rest on absence.** Where Y shows no test of a thing (L70, L74), I assumed the same gap was left. Y may have avoided it.
- **The scenarios differ.** The companies, PACs and countries differ: T26 used Solución Factible against Quadrum, and T27 used US against a database with `l10n_mx_edi`. T25 and T24 also differ in company. Identical behaviour should not be expected from the two runs.
- **Help differed.** Y's log shows review-session input changing outcomes (L84, L86, L89). X had no review session on T26 or T27. Y's results are not those of the plan alone, and neither are X's, where the author approved every correction package.
- **Unstated evidence.** I did not see Y's scenarios, plans or runs, and X's `evidence/` files were not provided. All results are as reported by each build.
- **Sample.** One build each on the same app; this shows no trend.
- **Blindness.** This session auto-loaded project notes about the experiment's existence. I made no attempt to link X or Y to a method, opened nothing outside the grading folder, and the classes above rest only on the files provided.
- **Not counted.** Notes at X L20-L48, including cold-cache attribution (9.14M of 16.04M attributed to the pipeline) and the review session that never ran, are recorded as notes. If the cost note were counted as a defect it would be X-only.

## 6. Per-row table

Classes: `X-only`, `Y-only`, `Both`, `Outside`. A trailing `?` marks a doubtful class. `ND` means not a defect, and `DUP` a repeat of a counted row. Line numbers refer to `log_X.md` and `log_Y.md`.

### Defect rows, build X

| Line | Stage | Class | Why |
|---|---|---|---|
| X L9 | T21-27 | X-only? | `selection_ids` sequence did not converge. Spec-level choice in X; Y shows no selection plan, so its read-back was never exercised here |
| X L10 | T21-27 | X-only | Browser tester, 316 snapshots and 150 screenshots: a design cost that Y's API scenarios do not carry |
| X L11 | T21-27 | X-only? | Stray invoice in `~/Downloads` from the browser channel; the file was removed |
| X L12 | T21-27 | Both? | Admin-run steps and a source-only claim. Y's scenarios ran as a manager-level bot up to T24, a similar identity gap |
| X L13 | T21-27 | Both | `is_company` computed. Same Odoo behaviour as Y L31; the log says so |
| X L14 | T21-27 | X-only | Rule added by X's own fix blocked all invoices; `on_create_or_write` skips the pre-domain |
| X L15 | T21-27 | X-only? | PAST 180M. Bank-leak fix broke opening four bills (AT-75). Residue reading is an inference. Y shows no bank-leak fix, and no check either |
| X L16 | T21-27 | X-only? | AGGREGATE, T27 round 1. See unpacking |
| X L17 | T21-27 | X-only? | AGGREGATE, T26 round 1. See unpacking |
| X L18 | T21-27 | X-only? | AGGREGATE, T24 round 1. See unpacking |
| X L54 | T21-27 | Outside? | PAST 180M. No clean-database run, by the stop rule; the dirty-apply path is still X's |
| X L55 | T21-27 | DUP | Same event as X L54 |
| X L56 | T21-27 | X-only | Analyst added two global restrictions nobody asked for; X's role split |
| X L57 | T21-27 | ND | Decision only; failures counted at L15/L16 |
| X L58 | T21-27 | X-only? | `base.group_multi_company` added by Odoo. Y's log noted the fact from source before T27 and logs no failure |
| X L59 | T21-27 | ND | Approval |
| X L60 | T21-27 | Outside? | Global Lock blocked by demo bank lines; changes a test's wording |
| X L61 | T21-27 | ND | Approval |
| X L62 | T21-27 | DUP | Same event as X L14 |
| X L63 | T21-27 | ND | Approval |
| X L64 | T21-27 | Outside | `SubagentHandback` refused a second report: tool failure |
| X L65 | T21-27 | DUP | Same event as X L17 |
| X L66 | T21-27 | X-only? | `tz` changes at login, spec did not converge; Y shows no `tz` declaration |
| X L67 | T21-27 | ND | Approval and declared limit |
| X L68 | T21-27 | ND | Input choice; records that the runs differ |
| X L69 | T21-27 | ND | Approval |
| X L70 | T21-27 | Both? | Pay proposes the wrong bank on EUR invoices. X calls it a config defect (D37). Y shows no check of it, so same gap likely left |
| X L71 | T21-27 | Both? | AGGREGATE, T25 round 1. D+1 root cause is common; see unpacking |
| X L72 | T21-27 | DUP | Same event as X L73 |
| X L73 | T21-27 | Outside | Company answered against the clarification: user input |
| X L74 | T21-27 | Both? | Send Reminder reached the vendor before approval. Y shows no test of it, so same gap likely left |
| X L75 | T21-27 | DUP | Same event as X L18 |
| X L76 | T21-27 | DUP | Same event as X L13 |
| X L77 | T21-27 | ND | Accepted gap; scored under finding 1 |
| X L78 | T21-27 | ND | Author action |
| X L79 | T21-27 | DUP | Same event as X L9 |
| X L80 | T21-27 | Both | Billing method only a label; the log says same gap as Y's T21 |
| X L81 | T21-27 | ND | Author action |

### Defect rows, build Y

| Line | Stage | Class | Why |
|---|---|---|---|
| Y L7 | build | Y-only? | Shared superuser cluster. Log says mostly user input, counted against the plan; the other plan used its own Postgres |
| Y L8 | build | Y-only | Amendment not carried into T01's file list |
| Y L9 | build | Y-only | C1 `<code>` undefined |
| Y L10 | build | Y-only? | Root `CLAUDE.md` outside the local-only rule; caught by Y's own test |
| Y L11 | build | Y-only | C2 has no shared hardening check |
| Y L12 | build | Y-only | Spike narrower than C12 |
| Y L13 | build | Y-only? | Hook and heredocs. X's reports show no hook to compare |
| Y L14 | build | Y-only? | C12 rules underspecified; same comparison limit |
| Y L15 | build | Y-only | No task creates `config.toml` |
| Y L16 | build | Y-only | Amendment 9 needs data C3 lacks |
| Y L17 | build | Y-only | C3 CLI gap |
| Y L18 | build | Y-only | Amendment and file owner mismatch |
| Y L19 | build | Y-only? | Cron wording; harmless here |
| Y L20 | build | Y-only | Wrong fact: `product_and_description` |
| Y L21 | build | Y-only | C11 underspecified |
| Y L22 | build | Y-only | S6 metric does not match its question |
| Y L23 | build | Y-only? | `reset` and stale registry. X's reset path is not visible |
| Y L24 | build | Y-only | C7 `pre_state` rule wrong |
| Y L25 | build | Y-only | `.gitignore` spec error |
| Y L26 | build | Y-only | Acceptance tied to a stub |
| Y L27 | build | Y-only | Wrong fact: file path in example |
| Y L28 | build | Y-only | C6, C8, C9 underspecified |
| Y L29 | build | Y-only? | Parallel safety ignores runtime state. X's parallelism is not visible |
| Y L30 | build | Y-only? | Bot groups snapshot. X's apply identity is not visible |
| Y L31 | build | Both | `is_company`; same Odoo behaviour as X L13. Y missed it silently, X's convergence check stopped at T24 |
| Y L32 | build | Y-only? | Screenshot save path; X also used browser captures, method not visible |
| Y L33 | build | Y-only | T18 designed before its measurement |
| Y L34 | build | Y-only | Wrong fact: landed costs |
| Y L35 | build | Y-only? | Run id collision: implementation, contract silent |
| Y L36 | T21-27 | Both? | No company context in reads. X's scenarios ran by company, but `ofa inspect settings` reads the default company (Harbor result:219) |
| Y L37 | T21-27 | Y-only? | Run artifacts overwritten; own tooling, log says tooling |
| Y L45 | build | ND | Spike output by design. X hit the same Payment Way need (hit Y130) |
| Y L46 | build | Both? | PAC network risk unlisted; X's stamping has the same dependency |
| Y L47 | build | Outside | Builder claim wrong |
| Y L48 | build | Outside | Builder error |
| Y L49 | build | Outside | Builder error |
| Y L50 | build | Outside | Builder misreported a plan hit |
| Y L51 | build | ND | Discovery |
| Y L52 | build | ND | Measurement |
| Y L53 | build | Outside | Subagent error |
| Y L54 | build | Outside | Builder errors |
| Y L55 | build | ND | Cost signal |
| Y L56 | build | Outside | Builder command error; the plan prescribes none |
| Y L57 | build | Outside? | Nested sessions not isolated. Builder design error, inside a task only Y has |
| Y L58 | build | Outside | Input error |
| Y L59 | build | Outside | Input-induced |
| Y L60 | build | ND | Spike finding |
| Y L61 | build | Outside | Odoo or tool behaviour; builder slip caught |
| Y L62 | build | ND | Spike finding; gaps documented as the plan allows |
| Y L63 | build | Y-only | Skill-generated plan claims a proof it does not ship |
| Y L64 | build | Outside | Builder error, self-corrected |
| Y L65 | build | Y-only | Linter gate false positives block every plan |
| Y L66 | build | ND | Observation |
| Y L67 | build | Outside | Builder errors caught |
| Y L68 | build | ND | Discovery |
| Y L69 | build | ND | Decision record |
| Y L70 | T21-27 | ND | Milestone; caveats restated at L71 and L74 |
| Y L71 | T21-27 | Y-only | Scenarios written after approval. X's specs were approved with their tests (L59, L67) |
| Y L72 | T21-27 | Outside | Reviewer error |
| Y L73 | T21-27 | ND | Results, with a small warehouse gap and a server outage |
| Y L74 | T21-27 | Y-only | Scenarios cannot act as another user. X tested by role from T21. Fixed later by 3a |
| Y L75 | T21-27 | Y-only | Scenario-format error (`$var` list against id); partial rerun |
| Y L76 | T21-27 | Y-only | Skill never locates the source path |
| Y L77 | T21-27 | Outside | Builder process error |
| Y L78 | T21-27 | ND | Capability added; ordering bug caught live |
| Y L79 | T21-27 | Y-only | No expect-error step |
| Y L80 | T21-27 | Both? | AGGREGATE. D+1 caught both (X's first version assumed the same day); analytic compendium error, archived match and stale cookie are Y's |
| Y L81 | T21-27 | ND | Follow-up |
| Y L82 | T21-27 | Y-only | Hole in approved `expect_error` design |
| Y L83 | T21-27 | Outside? | README omission, caught before commit |
| Y L84 | T21-27 | Y-only? | Need 6 marked Not tested; row is also a positive finding |
| Y L85 | T21-27 | Y-only | Customer named "Publico en General" rejected (CFDI40130). X's plan avoided the name. The template account in the same row is finding 5, not a plan defect |
| Y L86 | T21-27 | Outside? | Code 207 on test PAC and viewport; cause open |
| Y L87 | T21-27 | Y-only | Review stop condensed; permission mode was not the assumed barrier |
| Y L88 | T21-27 | Y-only? | `--allowedTools` covered little; a silent viewport failure is a tool fact |
| Y L89 | T21-27 | Y-only | SKILL.md not told about `check`; recurrence sent to the wrong app |
| Y L90 | T21-27 | Y-only? | Branch `AccessError`. Exists because Y's database ships `l10n_mx_edi`; X's US database could not hit it |
| Y L91 | T21-27 | Y-only? | Third guessed refusal text; 0 screenshots |
| Y L92 | T21-27 | ND | Root cause of L90; correction of a deduction |
| Y L93 | post | ND | Docs |
| Y L94 | post | ND | Publish checks |
| Y L95 | post | ND | Milestone |
| Y L96 | post | Y-only | Global guard hook hits other sessions after install |
| Y L97 | post | Y-only? | [withheld: private post-build validation] |
| Y L98 | post | Y-only? | [withheld: private post-build validation] |
| Y L99 | post | Y-only? | [withheld: private post-build validation] |
| Y L100 | post | Y-only? | [withheld: private post-build validation] |
| Y L101 | post | Y-only? | [withheld: private post-build validation] |
| Y L102 | post | Outside | First measurement invalid; correct refusal of a relay |
| Y L103 | post | ND | Review |
| Y L104 | post | ND | Ready |
| Y L105 | post | ND | Published |

### Plan hits

| Hit | Class | Why |
|---|---|---|
| Y L113 | Neutral | Guards a shared cluster that Y itself chose |
| Y L114 | Neutral | Rule offsets Y's own parallel build |
| Y L115 | Neutral? | Facts used in Y's fixtures; no failure named |
| Y L116 | Neutral? | Client parameter names; X needs the same but no comparison is visible |
| Y L117 | Neutral | Marker design is Y's own |
| Y L118 | Neutral | Template flow is Y's own |
| Y L119 | Neutral | Provisioning is Y's own |
| Y L120 | Neutral | Rejects a finding about Y's own config |
| Y L121 | Prevented? | Stopped a leak, but it offsets a hole Y's plan left (L10) |
| Y L122 | Neutral | Observes the risk of Y's Decision A |
| Y L123 | Neutral? | Not yet exercised at the time, per the row |
| Y L124 | Neutral | Hook is Y's own |
| Y L125 | Neutral? | Closes a bypass in Y's own guard |
| Y L126 | Neutral | X's convergence check found the same bug, so nothing was prevented relative to X |
| Y L127 | Prevented? | Real RFC caught; the other items are Y's own process |
| Y L128 | Neutral | Confirms Y's own read-back and sync |
| Y L129 | Prevented? | Pre-20 names caught; X's use of `ofa inspect` may catch the same |
| Y L130 | Prevented | First stamp passed. X lost AT-12 to Payment Way and hit it in Vantage AT-24 |
| X L13 | Prevented | Log: convergence check stopped `is_company` at first apply. Y reported `created` silently (Y L31) |
| X L59 | Prevented | Log (also L67): spec approved with its tests. Y's skill wrote them after approval (Y L71) |
| X L18 | Prevented? | Log: role steps by session from T24. Y's T24 could not test need 1's `to approve` (Y L74). By session, not screen |
| X report | Prevented | Report only (Casa D03): rejected the name `PUBLICO EN GENERAL`. Y hit CFDI40130 (Y L85) |
| X report | Prevented? | Report only (Vantage decision log:307): avoided `amount_to_invoice`. Y's v1 scenario failed on it, and again in [withheld: private post-build validation]. X's claim stays unmeasured |
