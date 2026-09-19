# Optional TypeSafe / Jev integration

Use the upstream `typesafe-ai` skill when TypeSafe/Jev is requested or a task
needs semantic judgments such as routing, ranking, extraction, or verification.
Jev is an API model for typed answers and probabilities, not a local coding
agent or a replacement for the orchestrator and implementation workers.

## Load on demand

1. Open the official skill linked in [external references](../settings/references.md)
   and read its complete `SKILL.md` for the task. A link alone does not load it.
2. Record the upstream commit/revision used in the task handoff or PR when
   implementing an integration. Review upstream changes before updating a
   previously recorded revision; do not maintain a copied skill in this overlay.
3. Follow the skill's live documentation index. Read the relevant API/SDK page
   and cookbook before implementing; report unavailable documentation rather
   than inventing contracts. Do not preload unrelated cookbooks every session.
4. Keep deterministic rules and execution in code. Evaluate probabilistic
   decisions on representative data, including uncertain outcomes and service
   failures. Typed output does not guarantee correctness or permission to act.

## Optional agent-environment installation

Remote reading is the default under this overlay's links-only policy. If the
user explicitly requests installation into an agent environment, upstream
documents this command:

```sh
npx skills add typesafe-ai/skills --skill typesafe-ai
```

It defaults to project-local installation; upstream documents `-g` for global
installation. Select the intended agent and scope before running it. Do not run
it in `judigot/ai` or a product repo merely to satisfy the route. Installation
and updates are explicit environment setup work, not automatic side effects of
loading the overlay. Consult the upstream README for current installer options.

## Application boundary

Only add the SDK to the consuming application when implementing a requested
integration. Keep credentials server-side and in the environment's secret store.
Loading this skill does not authorize paid API calls, transmitting project data,
or changing worker-provider mappings. Apply the existing authorization and cost
policy in [agent orchestration](../settings/agent-orchestration.md).
