## What changed

-

## Why

-

## How to verify (manual)

Do these in order. Check each box when that step matches. Written so someone who does not write code can follow.

- [ ] Open this pull request on GitHub.
- [ ] Read `settings/workflow.md`. You should see the session steps: setup → clarify or wayfinder → TDD → mini commits → PR checklist → self-audit.
- [ ] Open `settings/ecosystem.md`. You should see that product repos must not include this file.
- [ ] Open `prompts/prompt-init-chat.md`. You should see a first message you can paste into a new agent chat. Ecosystem is listed only for `judigot/template-monorepo`.
- [ ] Open `settings/pr-body.md`. You should see a checklist template meant for non-technical testers.
- [ ] Open `settings/references.md`. You should see links to skills.sh and Matt Pocock pages, and a rule not to download those repos.
- [ ] Confirm there is no `scripts/install-external-skills.sh`.

## Automated checks

- [ ] CI is green, or this repo has no CI and the listed files exist.

## Out of scope

- Downloading or vendoring Matt Pocock / skills.sh files into this repository. URLs only.
