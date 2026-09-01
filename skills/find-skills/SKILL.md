---
name: find-skills
description: Use this skill when the user asks how to do X, whether a skill exists for X, or wants to extend agent capabilities. Look skills up on skills.sh and fetch the published page. Do not install or copy third-party skills into this repo.
---

# Find skills (skills.sh, reference only)

Discover skills at [skills.sh](https://skills.sh). Follow the published page. **Do not download, clone, or `npx skills add`.**

URLs: `settings/references.md`.

## How to look up

1. Identify domain and task.
2. Open https://skills.sh (leaderboard) or a catalog such as https://www.skills.sh/mattpocock/skills.
3. Fetch the skill page. Prefer well-known publishers (`vercel-labs`, `anthropics`, `mattpocock`, `microsoft`) and high install counts.
4. Show the user the name, what it does, and the URL.
5. If the user wants that workflow **this chat**, fetch the page and follow it. Leave the files where they are (on GitHub / skills.sh).

## Do not

- `npx skills add`, `npx skills update`, or `git clone` of a skills repo
- Copy `SKILL.md` into `judigot/ai` or the app repo
- Invent a second catalog

If nothing fits, do the task with this overlay's rules.
