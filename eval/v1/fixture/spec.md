# Spec: Purchase requests

## Problem
Purchase requests in a 5-company group go through email and spreadsheets. Approvals get lost, nobody knows the
status of a request, and accounting re-types approved requests by hand.

## Users
~120 employees across 5 companies (requesters), ~15 approvers (area managers and finance), 3 accounting staff.
Internal web app, desktop browsers. All users have Google Workspace accounts.

## Goals
- G1: every request has a visible status and an owner at all times.
- G2: approval within 2 business days for 80% of requests.

## Non-goals
- Supplier management, purchase orders, payments, inventory.
- Mobile app.

## Functional requirements
- R1 (must): employees create a request: company, cost center, description, amount, currency (MXN/USD), attachments (PDF/images, max 10 MB each).
- R2 (must): routing by amount: up to 50,000 MXN → area manager; above → area manager then finance.
- R3 (must): approvers approve or reject with a comment. A requester can never approve their own request.
- R4 (must): email notification to the next approver and to the requester on every state change.
- R5 (must): audit trail: who did what and when, for every state change, immutable, kept 5 years.
- R6 (must): daily reminder email at 09:00 to approvers with requests pending more than 1 business day.
- R7 (must): accounting exports approved requests to CSV per company and date range.
- R8 (should): dashboard with counts per status and per company.
- R9 (must): sign-in with the company Google Workspace accounts (SSO); no local passwords.

## Constraints
- Hosting: one existing Linux VM (4 vCPU, 8 GB RAM) with Docker; PostgreSQL 16 already runs there.
- Team: one mid-senior Python developer builds and maintains it.
- Data: internal financial data; stays on the company VM. Secrets never in the repository.
- Email: company Google Workspace SMTP relay.

## Success criteria
- All 5 companies use it for every new request within 2 months of launch.

## Open questions
- Exact list of cost centers per company (accounting will provide a CSV).
