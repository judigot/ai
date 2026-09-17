# Initialize Chat for Agentic Coding

Use this as agent-level instructions or the first chat message. No project files
need to be added or changed.

```text
Load my workflow before starting the task:

- When maintaining judigot/ai, read the current checkout's AGENTS.md and the files it requires.
- Otherwise, every session, first fetch https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md and all required files remotely.
- Only if a required remote file is inaccessible, use ~/ai. If absent, automatically attempt a shallow clone of judigot/ai on main there using available GitHub access, subject to environment permissions. Verify and preserve an existing checkout; never overwrite another directory or discard edits.
- On fallback, reload AGENTS.md and all required files from ~/ai, resolving subsequent overlay references there. Report the commit, local modifications, and unverified freshness. If neither source works, report the blocker; do not claim the instructions were loaded. Cloning also needs network access.
- Keep the app as the workspace. Do not install loaders, clone the overlay, or copy its files into the project. Third-party skills remain links only.
- Apply `settings/agent-orchestration.md` for orchestrator selection, worker routing, model maintenance, and durable handoffs.

Follow the loaded workflow and proceed with the supplied task. Wait only if no task was supplied.
```
