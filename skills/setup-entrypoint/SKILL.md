---
name: setup-entrypoint
description: Use this skill at the start of an agentic chat, when the user points at github.com/judigot/ai, pastes the init-chat prompt, or asks to follow their workflow before implementing. Load rules, confirm workspace, install or route to external skills, and ask clarifying questions before writing code.
---

# Setup entrypoint

Run this before implementation. The overlay lives in `judigot/ai`. Coding happens in the user's project.

## Load

1. Read `settings/rules.md` and `settings/workflow.md` from this overlay (`~/ai` if present, otherwise the workspace copies, otherwise GitHub raw on `main`).
2. Decide workspace:
   - User is changing this plugin → stay in `judigot/ai`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. Check external skills (do not vendor them here):
   - `find-skills` / `npx skills find` for skills.sh
   - Matt Pocock set, including `setup-matt-pocock-skills`, `wayfinder`, `tdd`, `grill-me` / `grill-with-docs`, `ask-matt`
   - If missing, ask the user to run `~/ai/scripts/install-external-skills.sh` (and in the **target** repo, `/setup-matt-pocock-skills` once)

## Clarify or route

- Ambiguous goal, UX, data, or success criteria → ask questions (or `/grill-with-docs`). **Stop. Do not implement.**
- Destination named, route unknown, more than one session → `/wayfinder`. Plan and decide only.
- Spec already locked → TDD (`skills/tdd-ci` or `/tdd`), mini commits, push, CI, PR template, self-audit.

Do not ask about defaults already in `settings/rules.md`.

## Do not

- Copy Matt Pocock or vercel-labs skill files into this overlay
- Start a Cloud Agent on `judigot/ai` in order to build a different app
- Skip clarifying questions because it feels faster
