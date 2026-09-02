# Setup entrypoint

Run this before implementation. The overlay lives in `judigot/ai`. Coding happens in the user's project.

## Load

1. Start at `AGENTS.md` in `github.com/judigot/ai`.
   - If the user is changing this overlay and the workspace is `judigot/ai`, read the workspace files.
   - Otherwise fetch `https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md` and the files it names from that same tree. Always use that live tree. Do not clone this overlay. Do not read `~/ai` or any other local clone; those copies can be stale.
2. Decide workspace:
   - User is changing this plugin → stay in `judigot/ai`.
   - Workspace is `judigot/template-monorepo` → also read that repo's `docs/ecosystem.md`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. External work is **URLs only**. Pick the official pack from `settings/stack.md`. Do not clone those repos, copy their files here, or run `npx skills add`.
4. Search the current project before inventing a foundation piece.

## Clarify or route

If the goal is still open, ask questions and wait. If the work is large and the route is unclear, fetch Matt Pocock wayfinder from `settings/references.md`. Do not clone his repo.

Then wait for the implementation task.
