---
name: find-skills
description: Use this skill when the user asks how to do X, whether a skill exists for X, or wants to extend agent capabilities. Search and install from the official skills.sh registry via the Skills CLI. Do not invent a parallel catalog.
---

# Find skills (skills.sh official)

Discover and install skills from [skills.sh](https://skills.sh) using the official CLI (`npx skills`). This overlay does not vendor third-party skill files.

## Commands

```sh
npx skills find [query] [--owner]
npx skills add <owner/repo> --skill <name> -g -y
npx skills update
```

Browse: https://skills.sh/

Install the official finder globally if this chat cannot search:

```sh
npx skills@latest add vercel-labs/skills --skill find-skills -g -y
```

Preferred engineering pack for this overlay:

```sh
~/ai/scripts/install-external-skills.sh
```

That installs `find-skills` and `mattpocock/skills` globally. Pick one install path per pack (Claude plugin **or** `npx skills add`, not both) or every skill appears twice.

## Search order

1. Identify domain and task.
2. Check the [skills.sh leaderboard](https://skills.sh/) for well-known skills (`vercel-labs`, `anthropics`, `mattpocock`, `microsoft`).
3. If needed, `npx skills find [query]`.
4. Recommend only after checking install count (prefer 1K+), publisher, and repo health.
5. Show name, what it does, install count, install command, and skills.sh link.
6. Install only with user approval, using `-g -y` for a global user-level install.

## Quality bar

- Prefer official publishers over unknown authors
- Treat repos with very low stars or installs as untrusted
- If nothing fits, do the task directly; suggest `npx skills init` only if they will reuse it
