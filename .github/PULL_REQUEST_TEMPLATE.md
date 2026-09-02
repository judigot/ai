## What changed

-

## Why

-

## How to verify (manual)

Do these in order. Check each box when that step matches. Written so someone who does not write code can follow.

- [ ] Open this pull request on GitHub.
- [ ] Open `AGENTS.md`. You should see only the four settings includes. That file is the overlay index apps load.
- [ ] Read `settings/workflow.md`. You should see the session steps: setup → clarify or wayfinder → TDD → mini commits → PR checklist → self-audit.
- [ ] Open `settings/ecosystem.md`. You should see that product repos must not include this file, and that apps start at this overlay's `AGENTS.md`.
- [ ] Open `prompts/prompt-init-chat.md`. You should see a first message that fetches `AGENTS.md` from GitHub raw, ignores local clones, and says not to clone `judigot/ai`. Ecosystem is listed only for `judigot/template-monorepo`.
- [ ] Open `settings/pr-body.md`. You should see a checklist template meant for non-technical testers.
- [ ] Open `settings/references.md`. You should see links to skills.sh and Matt Pocock pages, and a rule not to download those repos.
- [ ] Open `skills/scaffolder/SKILL.md` if this change touches Scaffolder routing. You should see how an agent builds `schemaInfo` and opens a draft PR without writing `main`.
- [ ] Confirm there is no `scripts/install-external-skills.sh`.

## Automated checks

- [ ] CI is green, or this repo has no CI and the listed files exist.

## Out of scope

- Downloading or vendoring Matt Pocock / skills.sh files into this repository. URLs only.
