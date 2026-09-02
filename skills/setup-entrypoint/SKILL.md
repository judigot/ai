---
name: setup-entrypoint
description: Use this skill at the start of an agentic chat, when the user points at github.com/judigot/ai, pastes the init-chat prompt, or asks to follow their workflow before implementing. Load rules, confirm workspace, fetch external skill URLs when needed, and ask clarifying questions before writing code.
---

# Setup entrypoint

Run this before implementation. The overlay lives in `judigot/ai`. Coding happens in the user's project.

## Load

1. Read `settings/rules.md`, `settings/workflow.md`, `settings/stack.md`, `settings/references.md`, and `settings/ecosystem.md` (`~/ai` if present, otherwise the workspace copies, otherwise GitHub raw on `main`).
2. Decide workspace:
   - User is changing this plugin → stay in `judigot/ai`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. External work is **URLs only**. Pick the official pack from `settings/stack.md`. Do not clone those repos, copy their files here, or run `npx skills add`.
4. Before inventing a foundation piece, search the current project, then `judigot/template-monorepo`, then other active products, then previous projects. Do not promote product code into the template unless the user asked or the work is already generic foundation.

## Clarify or route

- Ambiguous goal, UX, data, or success criteria → ask questions (or fetch grill-with-docs). **Stop. Do not implement.**
- Destination named, route unknown, more than one session → fetch wayfinder. Plan and decide only.
- Spec already locked → TDD (`skills/tdd-ci`, optionally fetch Matt Pocock tdd), mini commits, push, CI, PR template, self-audit.

Do not ask about defaults already in `settings/rules.md`.

## Do not

- Download or vendor Matt Pocock, vercel-labs, or other third-party skill files
- Start a Cloud Agent on `judigot/ai` in order to build a different app
- Skip clarifying questions because it feels faster
