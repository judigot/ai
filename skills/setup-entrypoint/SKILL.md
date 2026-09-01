---
name: setup-entrypoint
description: Use this skill at the start of an agentic chat, when the user points at github.com/judigot/ai, pastes the init-chat prompt, or asks to follow their workflow before implementing. Load rules, confirm workspace, fetch external skill URLs when needed, and ask clarifying questions before writing code.
---

# Setup entrypoint

Run this before implementation. The overlay lives in `judigot/ai`. Coding happens in the user's project.

## Load

1. Read `settings/rules.md`, `settings/workflow.md`, `settings/stack.md`, and `settings/references.md` (`~/ai` if present, otherwise the workspace copies, otherwise GitHub raw on `main`).
2. Decide workspace:
   - User is changing this plugin → stay in `judigot/ai`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. Match https://github.com/judigot/template-monorepo for layout unless the app already differs.
4. External work is **URLs only**. Prefer [skills.sh/official](https://skills.sh/official) maker packs listed in `settings/references.md`. Do not clone those repos, copy their files here, or run `npx skills add`.

## Clarify or route

- Ambiguous goal, UX, data, or success criteria → ask questions (or fetch grill-with-docs). **Stop. Do not implement.**
- Destination named, route unknown, more than one session → fetch wayfinder. Plan and decide only.
- Spec already locked → TDD (`skills/tdd-ci`, optionally fetch Matt Pocock tdd), mini commits, push, CI, PR template, self-audit.

Do not ask about defaults already in `settings/rules.md`.

## Do not

- Download or vendor Matt Pocock, vercel-labs, or other third-party skill files
- Start a Cloud Agent on `judigot/ai` in order to build a different app
- Skip clarifying questions because it feels faster
