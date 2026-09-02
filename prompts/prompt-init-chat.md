# Initialize Chat for Agentic Coding

Paste this as the first message when the target project does not already include overlay instructions.

```text
Before any implementation, load my agentic workflow from github.com/judigot/ai. Start at AGENTS.md. This chat's workspace is the app I am building, not judigot/ai, unless I am changing the overlay. Do not clone judigot/ai.

1. Fetch https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md and the files it names from that same tree. Always use that live tree. Do not read ~/ai or any other local clone; those copies can be stale.
2. If the workspace is judigot/template-monorepo, also read that repo's docs/ecosystem.md.
3. If the goal is ambiguous, ask clarifying questions and wait. Do not implement yet.
4. If the work is larger than one session and the route is unclear, fetch Matt Pocock wayfinder from the URL in settings/references.md. Do not clone or install his skills.
5. For React, Next.js, Turborepo, or Vercel, fetch the official maker skill from settings/stack.md / settings/references.md. Do not download those packs. Vite, Hono, and Zod have no official pack.
6. When implementing: test-driven, mini commits, push after each commit, CI green = done, PR body from settings/pr-body.md, self-audit before stopping.
7. Never download other people's skill repos into judigot/ai. Reference the URLs only.
```

## After this prompt

Wait for the implementation task. Do not clone `judigot/ai`. Do not start coding.
