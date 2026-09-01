---
name: find-skills
description: Use this skill when the user asks how to do X, whether a skill exists for X, or wants to extend agent capabilities. Look skills up on skills.sh and fetch the published page. Do not install or copy third-party skills into this repo.
---

# Find skills (skills.sh, reference only)

Discover skills at [skills.sh](https://skills.sh). Follow the published page. **Do not download, clone, or `npx skills add`.**

URLs: `settings/references.md`.

## How to look up

1. Identify domain and task.
2. If it matches this stack (React, Next.js, Vercel, Neon, AWS), use the official URL in `settings/references.md` first.
3. Otherwise open https://skills.sh/official, then https://skills.sh.
4. Fetch the skill page. Prefer official makers over random catalog hits.
5. Show the user the name, what it does, and the URL.
6. If the user wants that workflow **this chat**, fetch the page and follow it. Leave the files where they are.

## Do not

- `npx skills add`, `npx skills update`, or `git clone` of a skills repo
- Copy `SKILL.md` into `judigot/ai` or the app repo
- Invent a second catalog

If nothing fits, do the task with this overlay's rules.
