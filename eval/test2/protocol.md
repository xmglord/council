# Test 2: end to end, plan mode vs /council

Project: `~/odoo_functional_agent` (personal, goes to the portfolio). Odoo 20: branch `20.0` exists in odoo/odoo
(checked with `git ls-remote`, last commit 2026-10-23).

## Brief (identical input for both conditions)

The user's own requirements only. Design opinions raised while choosing the idea (API vs browser, approval gate,
scenario tests) are left out on purpose: they are the checks below.

```
Quiero un agente experto en Odoo 20 que haga configuraciones funcionales por mí. Mi punto débil es el lado funcional: decidir qué configurar, configurarlo y probarlo. La idea es tener un compendio de conocimiento de Odoo o un agente experto que, a partir de lo que necesita el negocio, haga las configuraciones funcionales. Había pensado que las hiciera usando el MCP de Firefox que ya tengo. Solo se usa contra bases demo, nunca contra producción. Es un proyecto personal que va a mi portafolio público.
```

## Order

1. Plan mode first, in a fresh session in the empty project folder. Save the final plan to
   `eval/test2/plan_mode.md` (outside the project, so the council never sees it). The project folder stays empty.
2. Then `/council . <brief>` in a fresh session in the same folder.

During intake, the user answers requirement questions and says "decide tú" to design questions.

## Pre-registered checks (written before either run)

Did the plan surface each point (yes / partial / no, citing the section)?

| ID | Check |
|---|---|
| K1 | Questions browser-driven configuration: proposes the API / data records for applying config, or justifies the browser for specific steps |
| K2 | Correctness verification: business-flow scenarios with checkable outcomes after applying a config |
| K3 | Human review before applying, plus a record of what changed (diff, rollback) |
| K4 | Knowledge grounding: version-specific sources for Odoo 20 and how they stay current |
| K5 | Localization (Mexico, CFDI) raised as a scope question, not silently assumed or ignored |
| K6 | A hard guard that it only runs against demo databases |
| K7 | Odoo 20 is recent: APIs and features verified on 20, not assumed from earlier versions |

Then: blind grading of the two `plan.md` files on the plan rubric (both normalized to the same template by an agent
that does not know which is which), token cost per condition, and later what broke during execution.

Known limits: one app, one rep. The user heard K1–K3 before the runs and may lean toward them in intake answers.
