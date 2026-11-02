# Plan: agente funcional de Odoo 20 (odoo_functional_agent)

## Contexto

El usuario es fuerte en lo técnico y débil en lo funcional (decidir qué configurar, configurarlo, probarlo). Quiere un agente que, a partir de una necesidad de negocio, decida la configuración, la aplique y la pruebe en bases demo de Odoo 20. Es un proyecto personal para el portafolio público (xmglord). Decisiones ya tomadas: **API JSON-2 como canal principal + Firefox MCP para verificación/evidencia/pasos solo-UI**, **Odoo 20 Community en Docker**, **proyecto de Claude Code** (skills + subagentes + hooks).

Hechos verificados hoy (2026-10-23):
- Existen `odoo/odoo` rama `20.0`, `odoo/documentation` rama `20.0` (licencia CC-BY-SA-4.0) e imagen Docker `odoo:20.0` (`20.0-20261015`).
- En Odoo 20 `/json/2/<model>/<method>` con API key (Bearer) es la API; `/xmlrpc` y `/jsonrpc` están deprecados y el servicio `db` se eliminó.
- El perfil MCP de Firefox es un **clon del diario con todos sus logins** (incluida, presumiblemente, la sesión de Odoo.sh de [redacted: employer], que también vive bajo `*.odoo.com`). Usarlo para este proyecto viola "nunca producción". Por eso este proyecto usa un perfil limpio propio.
- El directorio `[redacted: home]/odoo_functional_agent` está vacío y no es repo git.

Veredicto de diseño: el valor no está en "un agente que da clics", sino en **tres cosas**: (1) conocimiento anclado en fuentes verificables (docs 20.0 + introspección de la BD viva, no la memoria del modelo, que no conoce bien Odoo 20); (2) configuración declarativa e idempotente (spec YAML aplicada por API); (3) escenarios de prueba de negocio que verifican el resultado. El agente además deja un **registro de decisiones** (por qué cada ajuste), que es lo que ataca el punto débil del usuario: aprende leyendo el razonamiento, no solo el resultado.

## Arquitectura

```
odoo_functional_agent/
├── CLAUDE.md                 # reglas de operación del agente (ver nota de idioma)
├── README.md                 # qué es, arquitectura, caso de estudio
├── docker/compose.yaml       # odoo:20.0 + postgres:16 propio, Odoo en 127.0.0.1:8070
├── pyproject.toml            # paquete `ofa` (CLI)
├── ofa/                      # CLI de configuración
│   ├── client.py             # cliente JSON-2 (httpx), API key por env
│   ├── guard.py              # allowlist de destino + marcador de BD demo
│   ├── db.py                 # crear/borrar BD demo (con datos demo) y poner marcador
│   ├── inspect.py            # fields_get de res.config.settings / modelos, módulos disponibles
│   ├── spec.py               # modelo pydantic del spec YAML
│   └── apply.py              # plan (dry-run/diff) y apply idempotente
├── specs/                    # specs por escenario (YAML)
├── scenarios/                # necesidad de negocio + pruebas de aceptación (md)
├── knowledge/playbooks/      # compendio curado por dominio, cada afirmación cita ruta de docs 20.0
├── scripts/sync_docs.sh      # clona odoo/documentation 20.0 (depth 2) en .cache/docs (gitignored)
├── .claude/
│   ├── agents/analyst.md     # necesidad → fit-gap → spec + decision log + pruebas (solo lectura)
│   ├── agents/configurator.md# aplica el spec con `ofa`; navegador solo para pasos solo-UI
│   ├── agents/tester.md      # corre los escenarios por API + navegador, junta evidencia
│   ├── skills/odoo-lookup/   # cómo consultar docs locales + `ofa inspect` antes de afirmar algo
│   ├── skills/implement/     # orquesta analyst → (aprobación del usuario) → configurator → tester
│   ├── hooks/url_guard.py    # PreToolUse sobre navigate_page/new_page: solo http://localhost:8070
│   └── settings.json
├── tests/                    # pytest de integración contra contenedor real
└── runs/<fecha>_<escenario>/ # salida de cada corrida: decision log, plan, resultado, capturas (gitignored salvo casos de estudio elegidos)
```

### Spec (config como código)

```yaml
target: {url: http://localhost:8070, db: demo_distributor}
modules: [sale_management, stock, account]
settings:            # campos de res.config.settings
  group_discount_per_so_line: true
records:             # upsert por clave natural; xmlid ofa.<...> para idempotencia
  - model: account.payment.term
    xmlid: ofa.term_30_days
    values: {name: "30 Days", ...}
ui_steps:            # lo que no tiene API razonable; lo ejecuta el configurator por navegador
  - "..."
```

`ofa apply --dry-run` imprime el diff (módulos por instalar, settings que cambian, registros a crear/actualizar); `ofa apply` lo ejecuta: instala módulos (`button_immediate_install`), crea `res.config.settings` y llama `execute`, upsert de registros vía `ir.model.data`. Re-aplicar el mismo spec debe dar diff vacío.

### Seguridad (no negociable)

1. **`ofa` se niega** si el host no es `localhost`/`127.0.0.1` o la BD no empieza con `demo_`, **y** además exige el parámetro de sistema `ofa.demo_marker` que solo `ofa db create` pone. El marcador es la guarda real: no depende de nombres.
2. **Perfil de Firefox limpio** para este proyecto (`firefox-mcp --create-profile ofa`, luego lanzar con `FIREFOX_MCP_PROFILE=<ruta> firefox-mcp`), sin sesiones de nada. El MCP usa el puerto fijo 2828: solo un perfil MCP a la vez.
3. **Hook `url_guard.py`** bloquea navegación fuera de `http://localhost:8070`. No cubre clics en enlaces externos; por eso la guarda principal es el perfil limpio.
4. API key de la BD demo en `.env` (gitignored). Nada de rutas de la máquina, [redacted: employer] ni datos reales en el repo.

### Conocimiento (compendio)

Tres capas, en orden de autoridad: **BD viva** (`ofa inspect`: `fields_get` con `string`/`help`, módulos y dependencias) > **docs 20.0 locales** (grep en `.cache/docs/content/applications/...`) > **playbooks curados** (`knowledge/playbooks/<dominio>.md`: patrones de decisión tipo "si el negocio X, configura Y porque Z", cada uno con cita a la ruta de docs y verificado en una corrida). La skill `odoo-lookup` obliga al agente a citar fuente antes de afirmar que un ajuste existe o qué hace. No se vendorizan las docs (tamaño y CC-BY-SA); se sincronizan.

## Fases (pasos chicos, una sesión cada uno)

0. **Bootstrap**: `git init`, remoto `xmglord/odoo_functional_agent` antes del primer commit (verificar `git config user.email` = identidad personal), `.gitignore`, `docker/compose.yaml` (verificar que 8070 esté libre), venv `~/.venvs/ofa`. Levantar Odoo 20 y crear una BD demo a mano para confirmar.
1. **CLI `ofa`**: client + guard + db + inspect + spec + apply con dry-run. Tests de integración contra el contenedor (idempotencia, guardas que rechazan BD sin marcador / host remoto).
2. **Conocimiento**: `sync_docs.sh`, skill `odoo-lookup`, primer playbook: **quote-to-cash** (Ventas + Inventario + Facturación de Community).
3. **Agentes**: `analyst`, `configurator`, `tester`, skill `implement`, perfil Firefox limpio + hook. El analyst para y pide aprobación del spec antes de aplicar.
4. **Primer caso end-to-end**: un escenario de negocio concreto (p. ej. distribuidora con plazos de pago, descuentos por línea y dos almacenes) → spec → apply en BD nueva → tester verifica el flujo completo → caso de estudio en el README con decision log y capturas.
5. **Expansión por dominio**, uno a la vez (Compras, Fabricación, CRM, RR. HH. de Community), cada uno con su playbook y escenario. Documentar en el README qué queda fuera por ser Enterprise.

## Puntos a confirmar al implementar

- **Idioma de `CLAUDE.md` y de `.claude/agents|skills`**: tu regla dice CLAUDE.md y skills en español, pero aquí son el producto público. Propongo inglés para todo lo versionado y, si quieres notas personales en español, un `CLAUDE.local.md` gitignored.
- Nombre del repo: `odoo_functional_agent` (sigue tu convención; el CLI se llama `ofa`).
- Plan de portafolio: agregar el repo a [redacted: private notes] cuando haya el primer caso end-to-end, no antes.

## Verificación

- `pytest` de integración verde contra el contenedor Odoo 20: apply dos veces → segundo diff vacío; `ofa` rechaza BD sin marcador y host no local.
- Prueba de guarda del navegador: pedir `navigate_page` a una URL externa → bloqueado por el hook; `list_pages` muestra el perfil limpio (sin sesiones).
- End-to-end fase 4: BD nueva → `/implement` con el escenario → spec aprobado → apply → tester reporta cada prueba de aceptación pasa/falla con evidencia en `runs/`.
- Al terminar cada fase: borrar BD y capturas de prueba que no sean entregables (regla de limpieza).
