---
name: setup-entrypoint
description: Load the workflow overlay before implementation, confirm the working project, and route unclear goals to clarification or planning.
---

# Setup entrypoint

Run this before implementation. The overlay is https://github.com/judigot/ai. Coding happens in the user's project.

## Load

1. Start at `AGENTS.md` in https://github.com/judigot/ai.
   - If the user is changing this overlay and the workspace is https://github.com/judigot/ai, read the workspace files.
   - Otherwise try the remote `AGENTS.md` and every required file first. Only if remote loading fails, use `~/ai`, automatically cloning `judigot/ai` there if absent. Verify an existing checkout and preserve its contents. Reload all required instructions from that checkout and report its commit, local modifications, and unverified freshness. If neither source works, report the blocker. Follow environment permissions; do not add a project loader or overlay files. The standalone bootstrap is `prompts/prompt-init-chat.md`.
2. Decide workspace:
   - User is changing this plugin → stay in https://github.com/judigot/ai.
   - Workspace is `judigot/template-monorepo` → also read that repo's `docs/ecosystem.md`.
   - Otherwise the app repo is the workspace. Do not clone this overlay as the project.
3. External work is **URLs only**. Pick the official pack from `settings/stack.md`. Do not clone those repos, copy their files here, or run `npx skills add`.
4. Search the current project before inventing a foundation piece.

## Clarify or route

If the goal is still open, ask questions and wait. If the work is large and the route is unclear, fetch Matt Pocock wayfinder from `settings/references.md`. Do not clone his repo.

Proceed with the supplied task once setup and any necessary clarification are complete. Wait only if no task was supplied.
