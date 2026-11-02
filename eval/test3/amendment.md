# Amendment to `eval/test2/plan_mode.md`

Scope facts only, the same ones the council's intake recorded. Nothing learned during the council build goes here.

1. **Edition:** Odoo 20 Enterprise, not Community. Source copies are in `src/odoo` and `src/enterprise` next to this
   file. Use them instead of the plain `odoo:20.0` image's bundled addons.
2. **Scope:** five areas: Sales + CRM, Purchase + Inventory, Accounting, Mexican localization, and multi-company. This
   replaces Manufacturing and HR in phase 5.
3. **Mexican localization:** CFDI 4.0 stamping against a test PAC is in scope.
4. **Repository:** local git only, no remote. The project contains Enterprise code paths, so nothing is published.
5. **Ports:** Odoo on 127.0.0.1:8080 and its Postgres on 127.0.0.1:5433. Port 8070 is taken on this machine.
6. **First end-to-end case (phase 4):** the requirement the author gives you, not the distributor example.

Everything else in the plan stands. Where it has a gap, decide and note the decision.
