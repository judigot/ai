# Initialize Chat for Agentic Coding

Paste this as the first message when the target project does not already include `~/ai`.

```text
Before any implementation, load my agentic workflow from github.com/judigot/ai:

1. If ~/ai exists, read:
   - ~/ai/settings/rules.md
   - ~/ai/settings/workflow.md
   - ~/ai/settings/stack.md
   - ~/ai/settings/references.md
   - ~/ai/settings/ecosystem.md
   Then follow skills/setup-entrypoint if present.
2. Else fetch and follow:
   - https://raw.githubusercontent.com/judigot/ai/main/settings/rules.md
   - https://raw.githubusercontent.com/judigot/ai/main/settings/workflow.md
   - https://raw.githubusercontent.com/judigot/ai/main/settings/stack.md
   - https://raw.githubusercontent.com/judigot/ai/main/settings/references.md
   - https://raw.githubusercontent.com/judigot/ai/main/settings/ecosystem.md
3. This chat's workspace must be the app I am building, not judigot/ai, unless I am changing the workflow itself.
4. If the goal is ambiguous, ask clarifying questions and wait. Do not implement yet.
5. If the work is larger than one session and the route is unclear, fetch Matt Pocock wayfinder from the URL in settings/references.md. Do not clone or install his skills.
6. For React, Next.js, Turborepo, or Vercel, fetch the official maker skill from settings/stack.md / settings/references.md. Do not download those packs. Vite, Hono, and Zod have no official pack.
7. Before inventing a foundation piece, search the current project, then judigot/template-monorepo, then other active products, then previous projects. Do not copy product code into the template unless it is proven and generic.
8. When implementing: test-driven, mini commits, push after each commit, CI green = done, PR body from settings/pr-body.md, self-audit before stopping.
9. Never download other people's skill repos into judigot/ai. Reference the URLs only.
```

## After this prompt

Wait for the implementation task. Do not clone `judigot/ai` as the project workspace. Do not start coding.
