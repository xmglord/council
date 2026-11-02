# ADR-001: Stack

- Status: accepted

## Context
One Python developer, one VM with Docker and PostgreSQL 16, internal desktop web app, Google Workspace SSO (R9).

## Decision
FastAPI + SQLAlchemy 2 + Alembic on PostgreSQL 16, server-rendered Jinja2 templates with htmx. One Docker container
behind the VM's existing Caddy reverse proxy. Attachments on the VM filesystem under `/srv/purchases/files`.

## Alternatives rejected
- Django: heavier than needed for ~8 screens; the developer prefers FastAPI.
- SPA (React): two codebases for one developer.

## Consequences
- Reversal cost: high (whole codebase).
