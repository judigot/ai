# Software ecosystem

Use this file only when the workspace is `judigot/template-monorepo` or when
the user is changing this overlay. Do not include it from product `AGENTS.md`
files. Product repos stay standalone.

The overlay is https://github.com/judigot/ai. Apps fetch
https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md and then
follow the files it names. They do not clone this overlay, do not read `~/ai`
or other local clones (those copies can be stale), and do not list each
settings file themselves.

Canonical charter: `judigot/template-monorepo` `docs/ecosystem.md`.

```text
Previous projects → proven patterns → shared template
  → new projects → new lessons → improved template
```

The objective is not maximum code sharing. The objective is a high-quality
reusable personal engineering foundation based on real experience.

## Roles

| Repository | Role |
| --- | --- |
| `judigot/template-monorepo` | Shared application foundation. Generic only. |
| https://github.com/judigot/project-core | Agent workspace files in every app (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `agents/`). |
| https://github.com/judigot/bookingwars | Active product from the template. Independent product evolution plus a source of patterns that may be promoted. |
| https://github.com/judigot/ecommerce-app | Active product. Same dual role. Divergence is allowed when requirements differ. |
| https://github.com/judigot/ai | This overlay. Rules, workflow, skills — not app code. |
| `judigot/user` | Dotfiles, generators, IDE scaffolding. |
| Previous projects | References. Consult; do not copy automatically. |

Do not modify `judigot/scaffolder` unless the user explicitly authorizes it.
Only edit this overlay when the user is changing agent workflow.

## Reuse before reinvention

Before creating a new solution, search in this order:

1. The current project's existing implementation
2. `judigot/template-monorepo`
3. The other active products (`bookingwars`, `ecommerce-app`)
4. Relevant previous projects, as references
5. Then invent

Compare existing approaches. Reuse or improve the most appropriate proven
solution. Similar-looking code is not enough — the behavior, API, and
requirements must actually be generic.

## Promote only after validation

Default path:

```text
Build locally → validate in a real project → identify the reusable part
  → generalize → move it into the template
```

Promote into `template-monorepo` only when all of these hold:

1. Needed by more than one project, or clearly foundation (tooling, TypeScript,
   lint, test, CI).
2. Generic API and behavior: no product names, no domain-only rules.
3. Can live on the template stack (Bun, Turborepo, Oxlint → Biome → ESLint,
   `bun test`, Playwright) without product dependencies.
4. Does not force unrelated complexity onto other projects.
5. Validated in a real project, not designed in the abstract.

When promoting from a diverged product, re-implement on the template stack.
Do not copy product files verbatim.

Keep the implementation local when a shared abstraction would add unnecessary
complexity. Reconsider the abstraction later.

## Continuous improvement

While doing the requested task, also notice:

- Have we solved this before?
- Is there already a better implementation somewhere?
- Are we duplicating something that belongs in the template?
- Did we discover a reusable pattern or a weakness in the template?
- Did we learn something worth documenting?
- Would this approach still make sense across several future projects?

Do not expand the current task into a template promotion unless the user asked
for that, or the change is already clearly generic foundation work in
`template-monorepo`. Record the candidate in the product or template docs
instead of silently sharing it.
