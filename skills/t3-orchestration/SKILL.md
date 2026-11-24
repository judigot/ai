---
name: t3-orchestration
description: Use when orchestrating authorized T3 tasks from ordinary ChatGPT through the private Sites-hosted T3 plugin. Discover registered projects and threads, delegate within scope, and verify results independently.
---

# T3 orchestration

This is an optional orchestration route. Follow `settings/rules.md` and
`settings/agent-orchestration.md`, including model routing and approval rules.
The [runtime setup](https://github.com/judigot/agent-workspace/blob/main/docs/chatgpt-t3-orchestrator.md)
is maintained separately; do not duplicate it here.

On 2026-11-24 ordinary ChatGPT discovered projects, retrieved threads, created
a harmless task, and read its completed reply. The Site reported replay and
follow-up testing; those reports are not independent ChatGPT verification.
Do not claim native model selection or subagent features unless verified in the
actual runtime. A chat being available does not mean its host, server, or
tunnel is available.

## Operate

1. Use `listProjects` to discover the registered project and its scope. Use
   `listThreads` and `getThread` to inspect existing work before deciding where
   to act. Preserve exact project, thread, and task IDs; do not guess or treat a
   similar name as an ID. A tunnel error is not proof that a thread is missing.
2. Create work with `createTask` only within the registered scope and with
   authorization for the requested action. If creation has an uncertain result,
   reconcile the thread and tasks first; retry an identical creation only after
   establishing that it was not created.
3. Use `getTask` to inspect status and result. Use `sendTaskMessage` for an
   authorized follow-up, retaining the exact IDs. If its result is uncertain,
   inspect the task and thread before retrying so the message is not duplicated.
   Poll only with a bounded interval and limit; report a pending task or a
   connectivity blocker when the limit is reached.
4. Independently inspect the actual changes, exact commit and relevant CI
   results. A worker reply is not proof that work or checks succeeded. Preserve
   the existing approval policy and report missing evidence.

Never put credentials or secrets in tasks, messages, logs, or repository files.
Do not push directly to the default branch, perform infrastructure or destructive
operations, bypass quotas, or incur paid overages without authorization.
