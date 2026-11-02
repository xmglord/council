# Acceptance results

Build: /var/tmp/test3_plan_mode/. Judged on 2026-11-02 from the databases, read by API. Role checks used role sessions (`/web/session/authenticate`, then read-only `call_kw`).

## Counts

| List | Database | Needs | met | partial | not met | not verifiable | of which config only |
|---|---|---|---|---|---|---|---|
| t21 | demo_vantage_campaign_sales | 9 | 8 | 1 | 0 | 0 | 0 |
| t24 | demo_harbor_purchase_inventory | 9 | 5 | 3 | 1 | 0 | 0 |
| t25 | demo_lumen_invoicing_close | 13 | 10 | 3 | 0 | 0 | 1 |
| t26 | demo_casa_albar_cfdi | 10 | 9 | 1 | 0 | 0 | 3 |
| t27 | demo_ridgeline_group | 8 | 4 | 4 | 0 | 0 | 0 |
| Total | | 49 | 36 | 12 | 1 | 0 | 4 |

Limits of this review:
- The five databases received only read calls. Role logins do leave Odoo's normal session and login traces.
- Group and project figures are sums of posted `account.move.line` and `account.analytic.line` records. The `account.report` engine was not run.
- CFDI proof is the PAC test environment (`l10n_mx_edi_pac_test_env = true`). All SAT status checks are `error`, because `consultaqr.facturaelectronica.sat.gob.mx` could not be reached, so no document was confirmed against the SAT itself.

## t21: demo_vantage_campaign_sales

| Need | Verified | How |
|---|---|---|
| 1. Opportunity with a brief (media, venue, dates, amount) and documents | met | `crm.lead` 45: `x_brief_media_ids` [37, 39], `x_brief_venue_ids` [102, 103], 2027-01-01 to 2027-06-30, `expected_revenue` 170000; `ir.attachment` 539; all fields in the form as vantage_sales. |
| 1. Customer type, five pipeline stages | met | `res.partner.x_customer_type` has the four values (partner 52 agency, 53 corporate); `crm.stage` holds exactly Prospect, Brief Received, Proposal Sent, Negotiation, Won. |
| 2. One campaign code on quotation, order and invoices | met | `sale.order.name` S00025 is `account.move.invoice_origin` on invoices 101, 102 and 109; `account.report_invoice_document` prints `invoice_origin` and `ref`. |
| 3. One line per medium, venue and period; prices before VAT; line discount | met | S00025 has 3 lines with their own `x_start_date` and `x_end_date`; line 61 `discount` 10; tax 88 `price_include` false; vantage_sales holds `sale.group_discount_per_so_line`. |
| 4. What changed, who and when | met | `mail.message` on S00023: 1454 unit price 45000 -> 42000, 1456 discount 10 -> 15, 1458 start date, 1459 medium, by Sofia Sales with timestamps; automation 1 and 2 active. |
| 5. Three invoicing methods; customer PO number on the order and invoices | partial | `x_invoicing_method` has the 3 values and PO numbers reach invoices (S00024 `client_order_ref` PO-FICT-001 = `ref` on 100 and 104). But S00028 and S00029 are `full_on_po` and invoiced with no PO, and the field is only a label. Milestones are fixed amounts (S00026 invoice 103), and `sale_project` is not installed. |
| 6. On the order: invoiced and pending | met | As vantage_sales and vantage_finance: S00021 `amount_invoiced` 0, `x_amount_pending` 168200; S00024 167040 and 0; both fields in the form. |
| 6. On the customer: what they owe and since when | met | As both roles, partner 52: `x_receivable_total` 668160 (equals the sum of its open invoices), `x_receivable_overdue` 668160, `x_overdue_since` 2026-10-31; fields in the partner form. |
| "to the customer's payment" | met | `account.payment` 1 PAY00001, state reconciled, `reconciled_invoice_ids` [107]; INV/2026/00008 `payment_state` paid, `amount_residual` 0. |

## t24: demo_harbor_purchase_inventory

| Need | Verified | How |
|---|---|---|
| 1. Orders of 50,000 or more need the purchasing manager's approval | partial | `po_double_validation` two_step, amount 50000; P00020 approved by Mara Manager, P00025 and P00095 wait in `to approve`. But P00024 (`amount_untaxed` 50000, `amount_total` 48000 with 4% WH) was confirmed by the buyer alone, and RFQs P00025 and P00092 were emailed to the vendor before approval. |
| 2. Vendors with price, minimum quantity and lead time; the cheapest one proposed | met | 9 `product.supplierinfo` records carry price, `min_qty` and `delay`; the native rule was accepted by clarification. Its exception is live: draft P00097 orders olive oil from Bay at 110 although Coastal has 100 (`_select_seller`). |
| 3. Below the minimum, an RFQ up to the maximum, prepared automatically | partial | 4 `stock.warehouse.orderpoint` records `trigger` auto, `horizon_days` 0; P00097 80 oil and P00098 55 degreaser are drafts by OdooBot. But Disinfectant (max 15, vendor `min_qty` 24) comes out at `price_unit` 0.0 on P00098. |
| 4. Two-step receipt; a partial delivery stays pending on the same order | met | `stock.warehouse` 3 `reception_steps` two_steps; Receipts and Storage `create_backorder` always; P00065: IN/00008 60 units, backorder IN/00009 40 units, line `qty_received` 100, same order. |
| 5. Lots with expiry recorded at receipt; first to expire goes out first | met | Food products `tracking` lot and `use_expiration_date` true; category Packaged Food uses FEFO; Receipts `use_create_lots` true; with lots SOON (2026-11-30) and LATE (2027-04-29) in stock, OUT/00004 took SOON. |
| 6a. Bill only what was received | met | Products 39 to 43 `purchase_method` receive; BILL/2026/10/0001 (P00079) 2100 for 60 of 100 units. |
| 6b. Accounts Payable sees a quantity or price difference | met | As harbor_ap: `x_po_qty_ordered`, `x_po_qty_received`, `x_po_qty_billed`, `x_po_price_unit` on bill lines (bill 107: 100, 60, 100, 35), `release_to_pay` and the warning in the form; drafts 108 and 109 show `exception`. |
| 6c. Payment blocked until the difference is resolved | partial | Bills 106 and 115 are `blocked`, and `account.move.py:6760` refuses payment. But the automation fires only when a bill is posted: BILL/2026/10/0005 (111) is `release_to_pay` exception and `not_paid` with no block, and harbor_ap unblocked bill 107 while it still shows 100 billed against 60 received. |
| "about 30 vendors" | not met | 4 vendors have `product.supplierinfo` records; 6 partners have `supplier_rank` > 0, 2 of them shipped demo data. Nothing limits the number, but the vendors are not loaded. |

## t25: demo_lumen_invoicing_close

| Need | Verified | How |
|---|---|---|
| 1. Domestic customers get the standard sales tax automatically | met | `account.fiscal.position` 1 Domestic `auto_apply` true, US; tax 1 15%; all posted customer documents from id 61 with a US customer carry tax; automation 1 refuses a mismatch at posting. |
| 1. Customers abroad: no tax, and the invoice says why | partial | Position 2 Foreign Trade maps 15% to 0% and its `note` prints on the invoice; invoices 62 and 64 tax 0. But INV/2026/00083 (id 273), German customer with a US delivery address, posted with 15% under Domestic after the last guard edit. INV/2026/00050 predates that edit. |
| 2. Projects 30% at signature, 70% on delivery due in 30 days | met | S00024: INV/2026/00015 30000 down payment; INV/2026/00016 100000 minus 30000, dated 2026-10-30, due 2026-11-29; term 12 100% at 30 days. |
| 2. Retainers due in 15 days; 2% within 10 days with the tax reduced in proportion | met | Term 13 `early_discount` true, 2%, 10 days, `included`, due in 15 days; BNK1/2026/00010: bank 1127, discount 20, `tax_line_id` 15% 3.00; paid late (INV/2026/00020), 23 stays open. |
| 3. EUR invoices and payments, exchange difference booked automatically | met | INV/2026/00055 EUR 1000 paid in full; partial reconcile 1100 with EXCH/2026/10/0011: 100 to 441000 Foreign Exchange Gain; loss case EXCH/2026/10/0012 50 to 641000; residual 0. |
| 4. Two bank accounts; one transfer for several invoices; partial payments | met | Journals 6 (USD) and 17 (EUR; no `bank_account_id` set). Statement line 34 3450 closes 3 invoices; line 35 3000 closes 2 and leaves INV/2026/00036 residual 450. |
| 4. A partial refund is a credit note tied to the invoice | met | RINV/2026/00005 230, `reversed_entry_id` 129; INV/2026/00038 residual 920; automation 1 refuses `out_refund` without an origin. |
| 5. Every invoice and bill assigned to a project and a department | met | `account.analytic.applicability` mandatory for both plans on invoices and bills; 93 of 93 posted product lines from id 61 have `analytic_distribution` with both, none `has_invalid_analytics`. |
| 5. Revenue, costs and margin by project and by department | met | `ir.filters` 6 and 7 are shared; sum of `account.analytic.line`: S00034 57000, S00035 37000, Design 222681.16, Engineering 127990, both views total 350671.16. |
| 6. The clerk invoices and records bills | met | lumen_clerk in `account.group_account_invoice`, `account.move` create and write true; INV/2026/00010 and BILL/2026/10/0003 created by Clara Clerk. |
| 6. The clerk cannot post manual entries, change taxes or touch closed periods | partial | `has_access` false on `account.tax`, `account.fiscal.position`, `account.lock_exception` and the lock-date wizard, and automation 2 is active. But MISC/2026/10/0005 and EXCH/2026/10/0016 show Clara Clerk posting at 20:45, after the guard's last write at 20:28. The cause could not be established by reading. |
| 6. Only the accountant posts adjustments and closes the month | partial | Lock-date wizard and exceptions are open to lumen_accountant only among the roles. But the same MISC/2026/10/0005 applies, and demo user `demo` also holds `account.group_account_user`. |
| 6. Nobody, the accountant included, changes a closed month without reopening it | met (config only) | `fiscalyear_lock_date` 2026-08-31 applies to every user; `account.lock_exception` 1 and 2 are revoked; the one document dated in August after the lock (MISC/2026/08/0002) falls inside exception 2. |

## t26: demo_casa_albar_cfdi

The build uses company 3 (`base.demo_company_2_mx`, ZAPATERIA URTADO ÑERI). The requirement names `base.demo_company_mx`, which in this database is company 2 (id 4 does not exist).

| Need | Verified | How |
|---|---|---|
| 1. Stamped CFDI 4.0 with the customer's RFC, regime, ZIP, CFDI use and 16% IVA | met | XML of INV/2026/00010: Version 4.0, Rfc EKU9003173C9, DomicilioFiscalReceptor 20928, RegimenFiscalReceptor 601, UsoCFDI G03, TasaOCuota 0.160000, UUID 0F079661. |
| 1. Sales to the general public with the generic RFC | met | XML of INV/2026/00011: Rfc XAXX010101000, regime 616, UsoCFDI S01. INV/2026/00018 used it for a customer with no RFC, but predates the current guard (2026-11-01 00:28). |
| 1. Incomplete fiscal data found before stamping | met (config only) | Automation 1 at Confirm checks RFC, ZIP, regime and CFDI use; moves 102 (no RFC) and 103 (no ZIP) stay draft and unstamped. |
| 2. Counter sales PUE with the actual payment way | met | MetodoPago PUE with FormaPago 01 on INV/2026/00011 and 28 on INV/2026/00020; `l10n_mx_edi_payment_method_id` required by automation 1. |
| 2. Credit customers PPD, one stamped payment receipt per payment, partial ones included | met | INV/2026/00021 PPD; documents 11 and 12: Pago 2.0, NumParcialidad 1 and 2, ImpPagado 4640 and 6960, ImpSaldoInsoluto 6960 and 0.00, own UUIDs. |
| 3. A return or discount is a stamped credit note related to the invoice | met | RINV/2026/00005: TipoDeComprobante E, CfdiRelacionados TipoRelacion 01, UUID 6CC90F0A of INV/2026/00023; RINV/2026/00006 uses 03. |
| 4. Cancel with the SAT reason and replace with an invoice that references it; the cancelled one stays visible | partial | INV/2026/00013 cancel, reason 01, `l10n_mx_edi_cfdi_cancel_id` INV/2026/00032, whose XML has TipoRelacion 04. But INV/2026/00042 is CFDI `cancel`, reason 03, while the move stays `posted` with 11600 open. |
| 5. Fee bills withhold 10% ISR and two thirds of the IVA, on the bill and in the accounts | met | BILL/2026/10/0003: ISR 1000 to account 642, IVA 1066.67 to 643, total 9533.33; on the half payment of BILL/2026/10/0004, CBMX/2026/10/0009 moves 533.34 of withheld IVA from 643 to 644. |
| 6. SAT chart of accounts with grouping codes | met (config only) | 150 accounts, all with a debit or credit tag, codes as `601.34.01`; only `171.16000` fails the SAT pattern and it has 0 lines. No SAT XML was generated. |
| 6. SAT trial balance | met (config only) | `l10n_mx_reports` provides `action_l10n_mx_generate_sat_xml` on Trial Balance; albar_accountant reads report 13 and the menu exists. No generated file is in the database. |

## t27: demo_ridgeline_group

| Need | Verified | How |
|---|---|---|
| 1. Holdings, Foods and Logistics are separate legal companies with own chart, journals, bank, numbering | met | `res.company` 4, 5, 7: no shared root, VATs 84-1000001, 84-1000002, 84-1000003; 130, 127, 128 accounts; journals HINV, FINV, LINV; `res.partner.bank` 12, 13, 14. |
| 1. The Foods branch: Foods' tax ID, identifiable invoices, own stock | met | Company 6 `parent_id` 5, VAT 84-1000002; journal FBINV, invoice FBINV/2026/00001; warehouse FEAST `lot_stock_id` 62. |
| 2. Shared products, customers and vendors; vendor terms, prices and taxes per company | met | Partners 51 and 52, product 44 `company_id` false; partner 52 supplier term Immediate, 30, 15, 45 days by company; product 44 taxes 58, 117, 150; pricelists per company; only ridgeline_group_masterdata may create contacts and products. |
| 3. Staff only in their company; branch staff only in the branch | met | Each role reads `account.move`, `sale.order`, `purchase.order`, `stock.warehouse` only in its companies; `allowed_company_ids` for other companies is refused. Branch staff can still read Foods' journals and bank 13, which is standard for a branch. |
| 3. The controller sees and switches between every company, runs multi-company reports, does not post in Logistics | partial | ridgeline_group_controller reads all four companies; `has_access` write true on Holdings and Foods, false on Logistics. But `ir.access` 923 is a deny-list on the name `Ridgeline Logistics`, not the agreed allow-list, so a rename removes the restriction. |
| 4. Foods' haul PO → Logistics SO; Logistics' invoice → Foods draft bill | partial | P00020 -> S00037 and P00021 -> S00038 by OdooBot; LINV/2026/00002 -> FBILL/2026/11/0002 draft, posted by Frank. But the form's read (`web_read` with `allow_out_payment`) gives Access Error on res.partner.bank to ridgeline_foods_accountant on bills 76 and 78. |
| 5. Monthly management fee → draft bills | partial | HINV/2026/00001 and 00002 `auto_post` monthly, next drafts 82 and 81 dated 2026-12-02, bills 84 and 83 generated by OdooBot. But the same Access Error hits bill 84 for ridgeline_foods_accountant and bill 83 for ridgeline_logistics_accountant. |
| 6. P&L and balance sheet per company and for the group, without inter-company double counting | partial | With all companies, ELIM/2026/11/0001 nets inter-company revenue, expense, receivable and payable to 0, leaving profit 5400. But the agreed Ridgeline Eliminations company does not exist; the entries sit in Holdings, whose own balance sheet shows Intercompany Receivable -2500 on 2026-11-30 unless the journal is filtered out. |

## Separate check: demo_ridgeline_group_clean

**Does the res.partner.bank read failure on inter-company bills also appear from scratch? No, not on this run.** The new draft bill opened without Access Error, but only because it arrived with no bank account. The read restriction itself is still there.

Convergence: yes.
- `ofa db create demo_ridgeline_group_clean --country US`: exit 0.
- `ofa apply`: exit 0, "Applied. A new plan is empty."
- Second `ofa apply --dry-run`: "No changes."
- The spec applied was a copy with one change, `target.db`, because the original targets demo_ridgeline_group: [redacted: scratchpad]/ridgeline_clean.yaml
- The ui_steps were not done. `ridgeline_foods_accountant` therefore has no password, so its calls used a temporary API key that expires in one day.

Test on the clean database:
- Invoice `account.move` 64, LINV/2026/00001, Logistics to Foods, 1234.00, posted, `partner_bank_id` 14.
- Bill `account.move` 65 arrived in Ridgeline Foods: `state` draft, `auto_generated` true, journal Purchases (26), `ref` LINV/2026/00001, `partner_bank_id` false.
- As `ridgeline_foods_accountant`, with companies 5 and 6 active, `web_read` on bill 65 returned without error. It used all 128 fields of the role's form view, including `partner_bank_id` with `display_name` and `allow_out_payment`, and `bank_partner_id`. Values returned: `partner_bank_id` false, `bank_partner_id` Ridgeline Logistics.
- `allow_out_payment` was added by hand because the `many2one_bank` widget declares it in `relatedFields`; without it the same read passes on bills that do fail. No browser was used.

| Check | demo_ridgeline_group_clean | demo_ridgeline_group |
|---|---|---|
| Inter-company bill read | bill 65, draft, `partner_bank_id` false: opens | bills 76 and 78 (`partner_bank_id` 14), 84 (12): AccessError, Bank Account (res.partner.bank); bill 183 (false): opens |
| Direct `res.partner.bank` read of bank 14 as Foods accountant | AccessError, HTTP 403 | AccessError |

Why the two differ:
- On the clean base, `_compute_partner_bank_id` filters `bank_ids` by company. Bank 14 belongs to company 7, so a Foods bill gets none.
- In the original base, the failing bills were created at 15:54 to 15:56 with a bank set; banks 12, 13 and 14 were last written at 17:18 and 17:28.
- That fits a bank company set after those bills were created, but `company_id` has no tracked history, so it is unproven. This is also one run. To confirm: repeat the test on a throwaway database with the bank's `company_id` empty when the bill is created, then set it.

Remaining points:
- Bills 76, 78, 83 and 84 still fail in demo_ridgeline_group.
- A clean-base bill does not carry the vendor's bank account.
- With only company 6 active, the same `web_read` returns 403 on Journal Entry, not on the bank, because the bill belongs to Foods.

Left behind: demo_ridgeline_group_clean with invoice 64, draft bill 65 and two expiring API keys, plus the `OFA_API_KEY_DEMO_RIDGELINE_GROUP_CLEAN` line that `ofa db create` adds to `.env`.
