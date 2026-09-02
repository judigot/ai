# Initialize Chat for Agentic Coding

Paste this as the first message when the target project does not already include `~/ai`.

```text
Before any implementation, load my agentic workflow from github.com/judigot/ai. Start at AGENTS.md. This chat's workspace is the app I am building, not judigot/ai, unless I am changing the overlay.

1. If ~/ai exists, read ~/ai/AGENTS.md and follow the files it names.
2. Else fetch https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md and the files it names from that same tree.
3. If the workspace is judigot/template-monorepo, also read that repo's docs/ecosystem.md.
4. If the goal is ambiguous, ask clarifying questions and wait. Do not implement yet.
5. If the work is larger than one session and the route is unclear, fetch Matt Pocock wayfinder from the URL in settings/references.md. Do not clone or install his skills.
6. For React, Next.js, Turborepo, or Vercel, fetch the official maker skill from settings/stack.md / settings/references.md. Do not download those packs. Vite, Hono, and Zod have no official pack.
7. When implementing: test-driven, mini commits, push after each commit, CI green = done, PR body from settings/pr-body.md, self-audit before stopping.
8. Never download other people's skill repos into judigot/ai. Reference the URLs only.
```

## After this prompt

Wait for the implementation task. Do not clone `judigot/ai` as the project workspace. Do not start coding.
