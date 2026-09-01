# Stack

Defaults inferred from current app packages. Follow the app if it already differs.

| Layer | Packages in use | Official skill (fetch, do not install) |
| --- | --- | --- |
| Language | TypeScript (strict), ESM | None on skills.sh/official. Use `settings/rules.md`. |
| Runtime / installs | Bun, Node `>=24` | None on skills.sh/official. |
| Monorepo | Turborepo | https://www.skills.sh/vercel/turborepo |
| SPA | Vite 8, React 19, Tailwind 4 | React: https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices — Vite has no official pack; use https://vite.dev/guide/ |
| App Router | Next.js 16, React 19, Tailwind 4 | https://www.skills.sh/vercel/next.js and the React skill above |
| React structure | React 19 | https://www.skills.sh/vercel-labs/agent-skills/vercel-composition-patterns |
| API | Hono, Zod, `@hono/node-server` | None on skills.sh/official. |
| Hosting | Vercel | https://www.skills.sh/vercel-labs/agent-skills/deploy-to-vercel and https://www.skills.sh/vercel |
| Unit tests | `bun test`, Testing Library, happy-dom | None on skills.sh/official. Use `skills/tdd-ci`. |
| E2E | Playwright | None on skills.sh/official. |
| Lint | Oxlint → Biome → ESLint `strict-type-checked` | None on skills.sh/official. Use `lint-master`. |

URLs are listed again in `settings/references.md`.
