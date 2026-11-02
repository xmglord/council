# Test 2: execution failures against plan mode

Each defect row of `execution_log.md` (by line number) and each plan hit, classified against what
`plan_mode.md` would have done. Grader: the council session that kept the log (one grader, not blind, knows both
plans). Line numbers checked against the log on 2026-10-30; the log keeps growing, so the Task column is the stable key.
Classes:

- **C**: council-introduced. The failure exists because of something only the council plan has (contracts,
  waves, spikes, the bot user, the bash hook, the shared Postgres decision); plan mode would not have had it.
- **B**: both. Plan mode would have hit the same failure, or the same gap would have existed in it.
- **P**: council prevented. A plan hit that avoided a failure plan mode would likely have hit.
- **N**: neutral. A plan hit that only offsets a council-introduced need or defect.

## Defects (31)

| Line | Task | Class | Why |
|---|---|---|---|
| 9 | Postgres decision | C | Plan mode used its own Postgres in Docker; ADR-0004 shared `odoo-pg` with a superuser role. The author's input explains the wrong premise, not the choice: the class records what only this plan had, not blame |
| 10 | T01 file count | C | Verdict amendment vs task file list: a multi-document plan artifact |
| 11 | T01 error code | C | Contract C1 detail; plan mode had no CLI contract |
| 12 | T01 root CLAUDE.md | C | Plan mode explicitly proposed a public CLAUDE.md plus a gitignored local one |
| 13 | T05/T08 hardening | C | Contract gap between tasks in different waves |
| 14 | T06 `new_page` | B | Plan mode's URL hook covered the same tools with no spike at all |
| 15 | T06 heredoc | C | Plan mode's hook only checked browser URLs, not shell commands |
| 16 | T06 C12 rules | C | Same bash hook |
| 17 | config.toml | C | Plan mode used a `.env` key, no config file deliverable |
| 18 | `@api.model` calls | B | Any JSON-2 client must tell model methods from record methods |
| 19 | inspect `--settings` | C | CLI contract detail |
| 20 | Amendment ownership | C | Parallel file ownership |
| 21 | cron "every database" | C | Claim made only by the council plan (shared server) |
| 22 | `product_and_description` | C | Wrong fact only in the council plan |
| 23 | C11 front matter | C | Contract detail |
| 24 | S6 metric | C | Spike only in the council plan |
| 25 | `ofa reset` stale registry | B | Any drop and re-create of the same name on a running server; the council predicted the risk but not the fix |
| 26 | `pre_state` rule | C | Concept only in the council plan |
| 27 | `.gitignore plans/` | C | Spec text only in the council plan |
| 28 | T01 stub acceptance | C | Wave-based acceptance |
| 29 | C11 source path | C | Wrong fact only in the council plan |
| 30 | T09-T11 contracts | C | Underspecified contracts (the decisions themselves would exist in plan mode, unwritten) |
| 31 | Wave 4 live state | C | Parallel execution only in the council plan |
| 32 | Bot groups snapshot | C | The dedicated bot user is a council design; plan mode's key was unspecified (likely admin) |
| 33 | `is_company` read-back | B | Neither plan read values back; both would catch it on the second apply |
| 34 | `saveTo` screenshots | B | Same Firefox MCP tool in both |
| 35 | T18 lint design | C | Task only in the council plan |
| 36 | Landed costs edition | C | Wrong fact only in the council plan |
| 37 | Run id collision | B | Implementation bug; plan mode also kept per-run directories |
| 38 | No company context | B | Neither plan gave scenarios a company |
| 39 | Run artifacts overwrite | B | Implementation of per-run artifacts, present in both |

Totals: **C 23, B 8.**

## Plan hits (18)

| Line | Task | Class | Why |
|---|---|---|---|
| 115 | `reset` + `doctor` check | P | Caught the stale-registry bug at acceptance; plan mode had no such check |
| 116 | Single live actor | N | Needed only because of parallel execution |
| 117 | S2/S8 facts | P | Plan mode assumed API mechanics (K7 partial) |
| 118 | C3 parameter names | P | Same |
| 119 | `get_str` returns `''` | P | A missing marker would have passed plan mode's marker guard |
| 120 | `--db-filter` keeps template free | N | Template copy is a council design |
| 121 | S3 provisioning facts | P | Script ran unchanged |
| 122 | `gevent_port` | N | Council server setup |
| 123 | Hygiene test caught CLAUDE.md | N | Offsets defect line 12 |
| 124 | Hardened conf held | N | Mitigates the council's own shared-Postgres choice |
| 125 | Tests on grounded shapes | P | Same as 117 |
| 126 | Hook `onFailure: block`, live check | P | Plan mode's hook was never tested live |
| 127 | Red team found `evaluate_script` bypass | P | Plan mode's URL hook had the same hole and no red team |
| 128 | Re-apply caught `is_company` | B | Plan mode had the same "second apply is empty" check |
| 129 | RFC hygiene, review stop | P | Caught a real SAT RFC before commit |
| 130 | Read-back confirmed writes | N | Exists because of the fix for line 33 |
| 131 | Verify every name | P | 15+ pre-20 names caught (K7) |
| 132 | S5 facts for stamping | P | Plan mode had no MX scope (scope confound) |

Totals: **P 11, B 1, N 6.** Two of the P hits are guard holes (119, 127).

## Beyond the defect log: what the examples found

The five examples (T21, T24-T27) found real Odoo 20 behaviour through read-back assertions, role identities and
negative tests: approval on the taxed total, mandatory analytics enforced only by the Post button, a currency-rate
drift (`<` vs `<=`), the SAT rejecting a "PUBLICO EN GENERAL" receiver without a global invoice, a broken account
in the l10n_mx template, and a branch-user crash in `l10n_mx_edi`. These come from K2 (assertion format), where plan
mode had prose scenarios. Whether prose scenarios would have found them is not measured.
