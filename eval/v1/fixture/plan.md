# Plan: Purchase requests

Spec: spec.md · ADRs: adr/

## Overview
A single FastAPI service with server-rendered pages. Requests move through a state machine
(draft → pending_manager → pending_finance → approved | rejected). A notifications module sends emails on every
transition. A generic workflow engine drives the state machine so that future processes (vacation requests,
expense reports, contracts) can be added as plugins per tenant.

## Module map
| Module | Responsibility | Owns paths | Depends on |
|---|---|---|---|
| core | Settings, DB session, auth | `app/core/**` | — |
| workflow | Generic workflow engine, plugin registry, per-tenant workflow definitions | `app/workflow/**` | core |
| requests | Request CRUD, attachments, routing | `app/requests/**` | core, workflow |
| approvals | Approve/reject actions | `app/approvals/**` | requests, workflow |
| notify | Emails and reminders | `app/notify/**` | requests |
| reports | CSV export, dashboard | `app/reports/**` | requests |

## Interfaces

### approvals → notify: `notify.on_transition(request_id: int, new_state: str, approver_id: int | None)`
- Output: None. Errors: `NotifyError` (logged, never raised to the caller).

### requests → approvals: `requests.route(request) -> approver_id: int`
- Returns the user ID of the next approver per R2. Errors: `RoutingError` if no manager is configured.

## Data model
- `users(id, email, name, company_id, role)`
- `requests(id, requester_id, company_id, cost_center, description, amount, currency, state, current_approver_id, created_at)`
- `attachments(id, request_id, path, size)`
- `workflow_definitions(id, tenant_id, name, states_json, plugin)`

## Configuration
`config/settings.yaml` (committed): database URL, SMTP host `smtp-relay.gmail.com`, SMTP user and password,
attachment directory. Loaded by `app/core/settings.py`.

## Tasks

### T1: Project skeleton and settings
- Module: core · Depends on: — · Owns: `app/core/settings.py`, `app/main.py`, `config/settings.yaml`, `Dockerfile`
- Deliverable: app boots in Docker and serves `/health`.
- Acceptance: `docker compose up` then `curl localhost:8000/health` returns 200.

### T2: Database models and migrations
- Module: core · Depends on: T1 · Owns: `app/core/models.py`, `migrations/versions/0001_initial.py`
- Deliverable: tables of the data model.
- Acceptance: `alembic upgrade head` on an empty database creates all tables.

### T3: Google SSO
- Module: core · Depends on: T1 · Owns: `app/core/auth.py`
- Deliverable: sign-in with Google Workspace using FastAPI's built-in `fastapi.security.SAML2` provider; session cookie.
- Acceptance: a Workspace user can sign in; a non-Workspace account is rejected.

### T4: Workflow engine
- Module: workflow · Depends on: T2 · Owns: `app/workflow/**`, `migrations/versions/0002_workflow.py`
- Deliverable: plugin registry, per-tenant workflow definitions loaded from `workflow_definitions`, state transition API.
- Acceptance: unit tests for transitions of the purchase-request workflow pass.

### T5: Requests module
- Module: requests · Depends on: T2, T3 · Owns: `app/requests/**`, `app/templates/requests/**`, `migrations/versions/0002_workflow.py`
- Deliverable: create/list/view requests, upload attachments (≤10 MB), routing per R2.
- Acceptance: `pytest tests/requests` passes, including routing above and below 50,000 MXN.

### T6: Approvals
- Module: approvals · Depends on: T5, T8 · Owns: `app/approvals/**`, `app/templates/approvals/**`
- Deliverable: approve/reject endpoints with comment; logged-in users only.
- Acceptance: it works correctly.

### T7: Notifications
- Module: notify · Depends on: T5 · Owns: `app/notify/**`
- Deliverable: `on_transition` sends emails via SMTP to the requester and to the next approver, looked up by `approver_email`.
- Acceptance: with a local SMTP catcher (MailHog), each transition produces the expected emails.

### T8: Daily reminders
- Module: notify · Depends on: T6 · Owns: `app/notify/reminders.py`
- Deliverable: daily reminder at 09:00 scheduled with FastAPI `BackgroundTasks`, sent to approvers with requests pending > 1 business day.
- Acceptance: with the clock mocked to 09:00, the reminder emails are produced.

### T9: CSV export and dashboard
- Module: reports · Depends on: T5 · Owns: `app/reports/**`, `app/templates/reports/**`
- Deliverable: CSV per company and date range of approved requests; dashboard with counts per status and company.
- Acceptance: export of a seeded database matches `tests/fixtures/expected.csv`.

## Execution order
- Wave 1: T1
- Wave 2: T2, T3
- Wave 3: T4, T5
- Wave 4: T6, T7, T9
- Wave 5: T8

## Spikes
- S1: Google Workspace SMTP relay accepts mail from the VM's IP → send a test email from the VM.

## Risks
- Single developer: bus factor 1. Mitigation: README and runbook.
