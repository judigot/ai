# Setup entrypoint

Run this before implementation. The overlay lives in `judigot/ai`. Coding happens in the user's project.

## Load

1. Read `settings/rules.md`, `settings/workflow.md`, `settings/stack.md`, and `settings/references.md` (`~/ai` if present, otherwise the workspace copies, otherwise GitHub raw on `main`).
2. Decide workspace:
   - User is changing this plugin → stay in `judigot/ai`.
   - Workspace is `judigot/template-monorepo` → also read `settings/ecosystem.md`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. External work is **URLs only**. Pick the official pack from `settings/stack.md`. Do not clone those repos, copy their files here, or run `npx skills add`.
4. Search the current project before inventing a foundation piece.

## Clarify or route