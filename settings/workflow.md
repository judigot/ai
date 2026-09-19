# Session protocol

This repository is the overlay for every agentic chat: coding rules, routing, and delivery discipline.

Provider routing, model mappings, worker contracts, and durable handoffs are
defined in `settings/agent-orchestration.md`. That policy takes precedence over
generic agent or model defaults in this overlay.

Other people's skills live on the web. **Reference them. Do not download them.** See `settings/references.md`.

Implement in the user's project. Only edit `judigot/ai` when the user is changing this workflow.

## 1. Setup entrypoint

Before writing code:

1. Follow this overlay's `AGENTS.md` loading policy: try remote instructions every session, then use `~/ai` only if a required remote file is inaccessible. Clone there if absent; verify and preserve an existing checkout. Read all required files from the selected source and report local version/freshness when falling back. When maintaining `judigot/ai`, use the workspace files. Bootstrap through agent-level instructions or `prompts/prompt-init-chat.md`; do not install a loader or overlay files in the app.
2. Confirm the workspace is the **app repo**, unless the user is maintaining this overlay. A fallback clone is an instruction source, not the app workspace.
3. Use the official skill for that layer in `settings/stack.md`. Do not invent a parallel stack.
4. Search this project before inventing a new solution.
5. If the goal, UX, or success criteria are ambiguous, **ask clarifying questions**. For a full grilling session, fetch the grill URL in `settings/references.md`. Do not implement yet.
6. If the destination is nameable but the route is not, and the work will not fit one session, fetch and follow **wayfinder** from `settings/references.md`. Plan and decide. Do not build.
7. Never `git clone` / `npx skills add` third-party skill repos to satisfy a route.

When the workspace is `judigot/template-monorepo`, also follow that repo's `docs/ecosystem.md`.

Product repos stay standalone: do not include `settings/ecosystem.md` from a
product's `AGENTS.md`. That file is for template and overlay maintenance.

Git is the only source of truth for worktree state; do not create sprint `.state`
files. An app-level `CONTEXT.md` from a grilling session records domain language,
not worktree or sprint metadata.

## 2. Route

| Situation | Do this |
| --- | --- |
| Ambiguous product or behavior | Clarify / fetch grill. Do not code. |
| Effort bigger than one session, route unclear | Fetch wayfinder. Plan and decide, do not build. |
| Locked spec or ticket | TDD, then implement |
| React UI, design-system components, or HTML-to-React conversion | Read `settings/frontend.md` and `skills/frontend-design/SKILL.md`; apply the React/Next.js routes below as appropriate. |
| Static HTML previews inside an existing mock gallery | `agents/ui-mock-iframe.md` |
| Existing Java/Spring backend | Read `settings/backend-java.md`; for JUnit additions or maintenance, use `skills/junit-test-implementation/SKILL.md`. |
| Hard bug with no reliable repro | Fetch diagnosing-bugs, else debugger agent |
| React | Fetch vercel-react-best-practices and vercel-composition-patterns |
| Next.js | Fetch https://www.skills.sh/vercel/next.js |
| Vercel deploy | Fetch deploy-to-vercel |
| Turborepo | Fetch https://www.skills.sh/vercel/turborepo |
| Vite | https://vite.dev/guide/ (no official skills.sh pack) |
| TypeSafe / Jev requested, or semantic routing, ranking, extraction, or verification needs typed judgments | Fetch the official TypeSafe skill from `settings/references.md`; follow `docs/typesafe-jev.md`. Optional capability, not a default worker model. |
| Hono / Zod / Playwright / lint | Overlay rules + `lint-master` / `tdd-ci`. No official maker pack. |
| Fast client MVP / generate app from schema / Scaffolder | `skills/scaffolder/SKILL.md`. Draft PR on the target repo. Do not write `main`. |
| "Is there a skill for X?" | Official makers first (https://skills.sh/official), then the catalog |
| Lint-only or formatter fights | `lint-master` |
| Visible EC2 agent desktop / live UI testing / cloud workstation recordings | `skills/cloud-dev-desktop/SKILL.md` |
| Unsure which Matt Pocock flow | Fetch ask-matt |

## 3. Test-driven delivery

Apply delivery checks to the task: read-only work needs no tests, commits, CI, or
PR. For documentation-only edits, review text, links, and the diff. Commit, push,
and create PRs only when authorized and permitted by the environment. If a
required check cannot run, report the blocker and verified results separately;
do not claim full validation. These qualifications also apply to delivery skills.

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

Before stopping, follow `skills/self-audit/SKILL.md`. Fix applicable failures and report checks or delivery steps that remain blocked. Do not claim tests passed or work was published when it was not.
