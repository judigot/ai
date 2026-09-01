# Stack

Default product stack. Match [judigot/template-monorepo](https://github.com/judigot/template-monorepo) (site: https://judigot.com/template-monorepo) unless the app already differs.

Fetch that repo's README and existing apps/packages. Copy its patterns. Do not clone it into `judigot/ai`.

## Defaults

| Layer | Choice |
| --- | --- |
| Language | TypeScript (strict), ESM |
| Package manager | Bun |
| Frontends | Vite + React (primary), Next.js App Router (when the app needs it) |
| API | Hono REST, as in the template (`apps/api`) |
| Monorepo | Turborepo workspaces, as in the template |
| Hosting | Vercel |
| Database | Neon PostgreSQL |
| Cloud | AWS when the work is infra, IAM, SDK, or services Vercel does not cover |

## How to build

1. Read the template-monorepo layout (`apps/vite`, `apps/nextjs`, `apps/api`, `packages/*`, `turbo.json`, quality-gate scripts).
2. Reuse its lint chain (Oxlint → Biome → ESLint `strict-type-checked`), Bun scripts, and CI shape.
3. For vendor-specific behavior (React perf, Next.js, Vercel, Neon, AWS), fetch the **official** skill URL in `settings/references.md`. Do not download those packs.

Vite has no maker pack on [skills.sh/official](https://skills.sh/official). Use the template's `apps/vite` plus https://vite.dev/guide/.
