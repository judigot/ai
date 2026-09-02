# Session protocol

This repository is the overlay for every agentic chat: coding rules, routing, and delivery discipline.

Other people's skills live on the web. **Reference them. Do not download them.** See `settings/references.md`.

Implement in the user's project. Only edit `judigot/ai` when the user is changing this workflow.

## 1. Setup entrypoint

Before writing code:

1. Follow `settings/rules.md`, `settings/stack.md`, `settings/ecosystem.md`, and this file.
2. Confirm the workspace is the **app repo**, not this overlay.
3. Use the official skill for that layer in `settings/stack.md`. Do not invent a parallel stack.
4. Search for an existing solution before inventing one: current project, then `template-monorepo`, then other active products, then previous projects as references. See `settings/ecosystem.md`.
5. If the goal, UX, or success criteria are ambiguous, **ask clarifying questions**. For a full grilling session, fetch the grill URL in `settings/references.md`. Do not implement yet.
6. If the destination is nameable but the route is not, and the work will not fit one session, fetch and follow **wayfinder** from `settings/references.md`. Plan and decide. Do not build.
7. Never `git clone` / `npx skills add` third-party skill repos to satisfy a route.

## 2. Route

| Situation | Do this |
| --- | --- |
| Ambiguous product or behavior | Clarify / fetch grill. Do not code. |
| Effort bigger than one session, route unclear | Fetch wayfinder. Plan and decide, do not build. |
| Locked spec or ticket | TDD, then implement |
| Hard bug with no reliable repro | Fetch diagnosing-bugs, else debugger agent |
| React | Fetch vercel-react-best-practices and vercel-composition-patterns |
| Next.js | Fetch https://www.skills.sh/vercel/next.js |
| Vercel deploy | Fetch deploy-to-vercel |
| Turborepo | Fetch https://www.skills.sh/vercel/turborepo |
| Vite | https://vite.dev/guide/ (no official skills.sh pack) |
| Hono / Zod / Playwright / lint | Overlay rules + `lint-master` / `tdd-ci`. No official maker pack. |
| "Is there a skill for X?" | Official makers first (https://skills.sh/official), then the catalog |
| Lint-only or formatter fights | `lint-master` |
| Unsure which Matt Pocock flow | Fetch ask-matt |

## 3. Test-driven delivery

- Red → green → refactor, one vertical slice at a time.
- Overlay rules: `skills/tdd-ci/SKILL.md`. For Matt Pocock's loop, fetch the tdd URL in `settings/references.md` — do not install it.
- Write the failing test first. Commit it. Then write the minimum code that makes it pass.
- **CI is the success signal.** Local tests are a preview. Do not treat the task as done while CI is red or missing for a change that should be covered.
- Users will often only look at CI. Make that status trustworthy.

## 4. Mini commits, push early

- Commit each meaningful slice (failing test, implementation, refactor, lint). Never batch a whole feature into one commit.
- Push after every commit so the PR and remote have the work before the session hits a token limit.
- Conventional Commits, short subject. Stage specific files, not `git add .`, unless the slice is the whole intended change.

## 5. Clarifying questions

Ask when the answer changes architecture, UX, data, or scope.

Do not ask about defaults already in `settings/rules.md` (strict TypeScript, Bun, ESM, interface prefix `I`, no `console.log`).

If a parent agent already locked the spec (task-master spawned with a goal), execute. Do not re-grill.

## 6. Pull requests

Use `settings/pr-body.md`. Every PR must include a **manual testing checklist** a non-technical person can follow: numbered steps, what to click, what they should see, and how to know it failed.

## 7. Self-audit

Before stopping, follow `skills/self-audit/SKILL.md`. Fix audit failures. Do not declare done with unpushed commits, empty PR checklists, or red CI.
