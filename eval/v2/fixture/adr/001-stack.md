# ADR-001: Stack

- Status: accepted

## Context
One Python developer; one VM with Docker Compose and PostgreSQL 16; server-rendered web app used from desktops and
Android phones; scheduled and delayed jobs (SLA warnings, monthly reports, cost posting).

## Decision
Django 5.2 + PostgreSQL 16, server-rendered templates with htmx, installable as a PWA on the phones.
Celery 5 with Redis 7 as broker for background and scheduled jobs. Containers behind the VM's existing nginx.

## Alternatives rejected
- FastAPI: Django's admin, auth and ORM migrations save the single developer weeks.
- Native Android app: two codebases for one developer.

## Consequences
- Reversal cost: high (whole codebase).
