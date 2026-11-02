# Plan: Facilities work orders

Spec: spec.md · ADRs: adr/

## Overview
One Django project (`fm`) with five apps: `core` (companies, sites, assets, users, holidays), `workorders` (work
orders, status machine, SLA, closing, audit, bulk actions), `inventory` (parts and stock), `photos`, and
`integrations` (accounting, reports). Celery runs background jobs. The UI is server-rendered with htmx and installable
as a PWA for technicians.

Status machine: `open → assigned → in_progress → closed`, plus `cancelled` from any state except `closed`.

## Module map
| Module | Responsibility | Owns paths | Depends on |
|---|---|---|---|
| core | Settings, auth, tenancy (company scoping), holidays | `fm/**`, `core/**` | — |
| workorders | WorkOrder model, status machine, SLA, closing, audit, bulk actions | `workorders/**` | core, inventory |
| inventory | Parts, stock per site | `inventory/**` | core |
| photos | Photo upload and storage | `photos/**` | workorders |
| integrations | Accounting posting, monthly PDF reports | `integrations/**` | workorders |
| pwa | Manifest, service worker, offline page | `static/pwa/**`, `templates/pwa/**` | workorders, photos |

## Tenancy and permissions
Every model that belongs to a company has `company` (directly or through `site`). `core.scoping.CompanyQuerySet`
provides `.for_user(user)`, which filters by `user.company_id`; technicians additionally get
`assigned_to=user`. Every list and detail view, form choice and export uses `.for_user(request.user)`.
Permission checks for actions: `workorders.permissions.can(user, action, wo)`, one function, unit-tested per role.

## Interfaces

### workorders → inventory: `inventory.stock.deduct(site_id: int, lines: list[tuple[int, int]]) -> None`
- `lines` are `(part_id, qty)`. Must be called inside the caller's `transaction.atomic()`.
- Implementation: for each line, `Part.objects.filter(pk=part_id, site_id=site_id).update(qty_on_hand=F("qty_on_hand") - qty)`.
  The `F()` expression makes each decrement atomic in the database, so concurrent closings cannot lose updates.
- Errors: `PartNotFound` if a part does not belong to the site.

### workorders → integrations: `integrations.tasks.post_cost.delay(work_order_id: int)`
- Enqueued with `transaction.on_commit` after a work order is closed.
- Task body: builds `{"external_id": f"WO-{wo.id}", "company": wo.site.company.code, "amount": wo.total_cost_cents, "date": wo.closed_at.date().isoformat()}`
  and POSTs it to the accounting endpoint with the bearer token from `ACCOUNTING_TOKEN`.
- Declared with `autoretry_for=(requests.RequestException,)`, `retry_backoff=True`, `max_retries=8`; HTTP timeout 10 s.
- On 201 it stores `CostPosting(work_order, entry_id, posted_at)`.

### workorders → notifications: `workorders.sla.schedule_warnings(wo) -> None`
- Called on creation. Enqueues `warn_supervisor.apply_async(args=[wo.id, "80"], eta=wo.created_at + 0.8 * window)` and
  `warn_supervisor.apply_async(args=[wo.id, "breach"], eta=wo.sla_due_at)`, where `window = wo.sla_due_at - wo.created_at`.
- `warn_supervisor` exits without sending if the work order is closed or cancelled by then.

### photos → workorders: `photos.services.attach(wo, files: list[UploadedFile], user) -> list[Photo]`
- Validates type (JPEG/PNG/HEIC by magic bytes), max 10 per work order, max 8 MB each. Errors: `PhotoRejected(reason)`.

## Data model
- `core.Company(id, code, name)`, `core.Holiday(company, date)`, `core.Site(company, name)`, `core.Asset(site, name, tag)`
- `core.User(AbstractUser + company, role ∈ {manager, technician, supervisor, accounting})`
- `workorders.WorkOrder(id, site, asset, priority, description, status, assigned_to, created_by, created_at, sla_due_at)`
  plus closing fields `closed_at, labor_hours: Decimal(6,2), total_cost_cents: int, notes` (added by T5).
- `workorders.WorkOrderPart(work_order, part, qty)` (added by T5)
- `workorders.AuditEntry(work_order, actor, from_status, to_status, at)` (append-only; no update/delete in admin)
- `inventory.Part(site, sku, name, unit_cost_cents: int, qty_on_hand: int)`
- `photos.Photo(work_order, file, uploaded_by, uploaded_at)`
- `integrations.CostPosting(work_order unique, entry_id, posted_at)`

Money is stored as integer cents everywhere.

## Settings and deployment
- `USE_TZ = True`, `TIME_ZONE = "UTC"`. Datetimes are stored and computed in UTC; `core.middleware.UserTimezoneMiddleware`
  activates America/Mexico_City for rendering.
- Secrets from environment variables (`.env` on the VM, not in git): `SECRET_KEY`, `DATABASE_URL`, `ACCOUNTING_TOKEN`, `REDIS_URL`.
- Media: `MEDIA_ROOT = /srv/fm/media`. The nginx server block serves `/media/` directly from that directory for
  performance (`location /media/ { alias /srv/fm/media/; }`) and proxies everything else to gunicorn.
- `docker-compose.yml` services: `web` (gunicorn, 3 workers), `worker` (`celery -A fm worker -B -l info`,
  `deploy.replicas: 2` for throughput), `redis`. Celery broker: Redis with default transport options.
- Backups: nightly `pg_dump` and `rsync` of `/srv/fm/media` to the company NAS, 35 daily copies; restore tested in T12.

## Tasks

### T1: Project skeleton and core
- Depends on: — · Owns: `fm/**`, `core/**`, `docker-compose.yml`, `deploy/nginx/fm.conf`, `requirements.txt`
- Deliverable: project, settings, `core` models, login with Django auth (company accounts), `CompanyQuerySet.for_user`,
  holiday CSV import command, nginx server block, compose file.
- Acceptance: `docker compose up -d && curl -fsS localhost/health` returns 200; `python manage.py import_holidays sample.csv`
  creates the rows; `pytest core` passes, including a test that `.for_user` never returns another company's rows.

### T2: Work orders base
- Depends on: T1 · Owns: `workorders/models.py`, `workorders/views.py`, `workorders/permissions.py`,
  `workorders/migrations/0001_initial.py`, `templates/workorders/**` (except `close.html`)
- Deliverable: WorkOrder model (fields up to `sla_due_at`, nullable for now), status machine with
  `WorkOrder.transition(to, actor)`, create/list/detail/assign views scoped with `.for_user`.
- Acceptance: `pytest workorders/tests/test_base.py` passes: illegal transitions raise, a technician cannot see another
  technician's work order, a manager cannot see another company's.

### T3: Inventory
- Depends on: T1 · Owns: `inventory/**`
- Deliverable: Part model, stock list per site, CSV stock import, `inventory.stock.deduct`.
- Acceptance: `pytest inventory` passes, including 20 concurrent deductions of 1 unit from a part with 20 units leaving exactly 0.

### T4: SLA computation
- Depends on: T2 · Owns: `workorders/sla.py`, `workorders/migrations/0002_sla.py`, `workorders/tests/test_sla.py`
- Deliverable: `sla_due_at` computed on creation as `created_at + timedelta(hours=SLA_HOURS[priority])` with
  `SLA_HOURS = {1: 4, 2: 8, 3: 24, 4: 72}`; `sla_due_at` made non-nullable; `schedule_warnings`.
- Acceptance: `pytest workorders/tests/test_sla.py` passes for each priority.

### T5: Closing flow
- Depends on: T2, T3 · Owns: `workorders/closing.py`, `workorders/migrations/0002_closing.py`, `templates/workorders/close.html`,
  `workorders/tests/test_closing.py`
- Deliverable: closing fields and `WorkOrderPart`; closing view: labor hours, parts used, notes; in one
  `transaction.atomic()` it deducts stock, computes `total_cost_cents`, transitions to `closed` and enqueues `post_cost` on commit.
- Acceptance: `pytest workorders/tests/test_closing.py` passes: stock decremented, cost = labor × rate + Σ parts, `post_cost` enqueued once.

### T6: Photos
- Depends on: T2 · Owns: `photos/**`
- Deliverable: Photo model, `attach` service, upload widget on the work-order detail page; the closing form uploads all
  photos together in one multipart POST.
- Acceptance: `pytest photos` passes (type, count and size limits); uploading 3 sample photos through the page stores 3 files.

### T7: Monthly cost report
- Depends on: T2 · Owns: `integrations/reports.py`, `integrations/templates/reports/**`, `integrations/tests/test_reports.py`
- Deliverable: Celery beat task on the 1st of each month at 06:00 that aggregates `total_cost_cents` of work orders by
  company with `TruncMonth("closed_at")`, renders one PDF per company (WeasyPrint) for the previous month and emails it to accounting.
- Acceptance: `pytest integrations/tests/test_reports.py` passes against a fixture with known totals per month.

### T8: Audit log and bulk actions
- Depends on: T5 · Owns: `workorders/audit.py`, `workorders/bulk.py`, `workorders/migrations/0003_audit.py`,
  `workorders/tests/test_audit.py`
- Deliverable: `AuditEntry` written by a `post_save` receiver on WorkOrder that compares the status loaded in
  `__init__` with the saved one. Bulk close and bulk reassign from the list view; for performance on large selections
  they run `WorkOrder.objects.for_user(user).filter(id__in=ids).update(status="closed", closed_at=now())` (or `assigned_to=…`).
- Acceptance: `pytest workorders/tests/test_audit.py` passes: every transition through `transition()` creates exactly one entry.

### T9: Accounting posting
- Depends on: T5 · Owns: `integrations/tasks.py`, `integrations/models.py`, `integrations/migrations/**`, `integrations/tests/test_tasks.py`
- Deliverable: `post_cost` task and `CostPosting` per the interface above.
- Acceptance: `pytest integrations/tests/test_tasks.py` passes with `responses` mocking the endpoint: one POST per closed
  work order, `CostPosting` stored, retries on connection errors.

### T10: SLA warnings
- Depends on: T4 · Owns: `workorders/notifications.py`, `templates/email/sla_*.txt`, `workorders/tests/test_notifications.py`
- Deliverable: `warn_supervisor` task and email templates.
- Acceptance: with `CELERY_TASK_ALWAYS_EAGER` and a frozen clock, a P2 work order produces the 80% email and the breach email; none if closed first.

### T11: PWA and offline
- Depends on: T5, T6 · Owns: `static/pwa/**`, `templates/pwa/**`
- Deliverable: `manifest.json`; a service worker that precaches static assets (CSS, JS, icons) and the closing page of
  the technician's assigned work orders, so the closing form opens without signal (R4); offline fallback page.
- Acceptance: in Chrome DevTools with "Offline" checked, an assigned work order's closing page loads from the cache.

### T12: Backups and runbook
- Depends on: T1 · Owns: `deploy/backup.sh`, `docs/runbook.md`
- Deliverable: backup script and cron entry; runbook for deploy, restore and rotating `ACCOUNTING_TOKEN`.
- Acceptance: restoring last night's backup into a scratch database shows the same work-order count as production.

## Execution order
- Wave 1: T1
- Wave 2: T2, T3, T12
- Wave 3: T4, T5, T6, T7
- Wave 4: T8, T9, T10, T11

## Spikes
- S1: WeasyPrint renders the report template with the company logo inside the container image (fonts installed).
- S2: The accounting endpoint is reachable from the VM with the issued token (one test POST in their sandbox).

## Risks
- Single developer (bus factor 1): runbook in T12.
- Holiday CSVs arrive late: SLA warnings may be early on unknown holidays until imported.
