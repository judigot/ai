## What changed

-

## Why

-

## How to verify (manual)

Do these in order. Check each box when that step matches. Written so someone who does not write code can follow.

- [ ] Open this pull request on GitHub.
- [ ] Read `settings/workflow.md`. You should see the session steps: setup → clarify or wayfinder → TDD → mini commits → PR checklist → self-audit.
- [ ] Open `prompts/prompt-init-chat.md`. You should see a first message you can paste into a new agent chat.
- [ ] Open `settings/pr-body.md`. You should see a checklist template meant for non-technical testers.
- [ ] If this change is only documentation/skills: there is nothing to click in an app. Success is that the files above match what this PR describes.

## Automated checks

- [ ] CI is green, or this repo has no CI and `shellcheck scripts/install-external-skills.sh` was run.

## Out of scope

- Installing Matt Pocock or skills.sh files into this repository (they stay external).
