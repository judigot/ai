# Session protocol

This repository is the overlay for every agentic chat: coding rules, routing, and delivery discipline. It does not replace [skills.sh](https://skills.sh) or [mattpocock/skills](https://github.com/mattpocock/skills). Install those separately (`scripts/install-external-skills.sh`). Do not copy their skill files into this repo.

Implement in the user's project. Only edit `judigot/ai` when the user is changing this workflow.

## 1. Setup entrypoint

Before writing code:

1. Follow `settings/rules.md` and this file.
2. Confirm the workspace is the **app repo**, not this overlay.
3. If the goal, UX, or success criteria are ambiguous, **ask clarifying questions** (use `/grill-me` or `/grill-with-docs` when those skills are installed). Do not implement yet.
4. If the destination is nameable but the route is not, and the work will not fit one session, use `/wayfinder`. That requires Matt Pocock skills plus `/setup-matt-pocock-skills` once in the target repo.
5. If those skills are missing, tell the user to run `~/ai/scripts/install-external-skills.sh` rather than inventing a parallel process.

## 2. Route

| Situation | Do this |
| --- | --- |
| Ambiguous product or behavior | Clarify / grill. Do not code. |
| Effort bigger than one session, route unclear | `/wayfinder` (plan and decide, do not build) |
| Locked spec or ticket | TDD, then implement |
| Hard bug with no reliable repro | `/diagnosing-bugs` if installed, else debugger agent |
| "Is there a skill for X?" | `find-skills` / `npx skills find` |
| Lint-only or formatter fights | `lint-master` |
| Unsure which Matt Pocock flow | `/ask-matt` |

## 3. Test-driven delivery

- Red → green → refactor, one vertical slice at a time.
- Prefer Matt Pocock `/tdd` when installed; otherwise follow `skills/tdd-ci/SKILL.md`.
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
