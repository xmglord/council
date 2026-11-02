# Spec: Facilities work orders

## Problem
Maintenance of buildings and equipment across a 5-company group is coordinated by WhatsApp and spreadsheets.
SLAs are not measured, spare parts disappear, and maintenance costs reach accounting weeks late and by hand.

## Users
- Facility managers (~20): create work orders.
- Technicians (~40): execute them on site with Android phones; many machine rooms and basements have no signal.
- Supervisors (~8): assign, reassign and close work orders, often in bulk.
- Accounting (3): consume costs.

## Goals
- G1: 90% of work orders meet their SLA.
- G2: maintenance cost reaches accounting the day the work order closes.

## Non-goals
- Preventive maintenance planning, purchasing of parts, native mobile apps.

## Functional requirements
- R1 (must): managers create a work order for an asset at a site: priority (P1–P4), description, optional photos.
- R2 (must): SLA per priority counted in **business hours** (Mon–Fri 09:00–18:00, America/Mexico_City, excluding the
  holidays of the work order's company): P1 4 h, P2 8 h, P3 24 h, P4 72 h. The supervisor is warned at 80% of the SLA
  and again at breach.
- R3 (must): users see only work orders, photos and parts of their own company. Technicians see only work orders assigned to them.
- R4 (must): technicians can fill in the closing form (labor hours, parts used, notes) and take up to 10 photos where
  there is no signal; everything is sent automatically when connectivity returns. Phone photos are 3–6 MB each.
- R5 (must): parts stock per site. Closing a work order deducts the parts used. Stock must never go negative: if a part
  is short, closing is refused with a message naming the part.
- R6 (must): audit log of every status change (who, when, from → to), including bulk actions. Kept 5 years.
- R7 (must): when a work order closes, its cost (labor + parts) is posted to the accounting system **exactly once**.
- R8 (must): monthly cost report (PDF) per company, by calendar month in America/Mexico_City time.
- R9 (should): supervisors bulk-close and bulk-reassign work orders from the list view.

## External interface: accounting system
`POST https://accounting.internal/api/cost-entries`, bearer token.
Body: `{"external_id": str, "company": str, "amount": "1234.50", "date": "YYYY-MM-DD"}`. `amount` is MXN as a decimal
string with 2 places. Responds 201 with the entry. The endpoint does not deduplicate by `external_id`; a request that
repeats a previously seen `Idempotency-Key` header returns the existing entry instead of creating a new one.

## Constraints
- Hosting: one Linux VM (4 vCPU, 8 GB RAM) with Docker Compose. PostgreSQL 16 runs on the VM.
- Reverse proxy: the VM's existing nginx, managed by IT with its default configuration; the app team may add its own `server` block.
- Team: one mid-senior Python developer builds and maintains it.
- Data stays on the VM. Photos may show restricted areas (server rooms, vaults). Secrets never in the repository.

## Success criteria
- All companies use it for every new work order within 3 months.

## Open questions
- Holiday calendars per company: HR will provide them yearly as CSV.
