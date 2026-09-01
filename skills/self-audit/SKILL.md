---
name: self-audit
description: Use this skill before finishing a task, opening a PR, or claiming the work is done. Check commits, push, tests/CI, PR checklist, scope, and coding-rule regressions. Fix failures before stopping.
---

# Self-audit

Run this before you stop. Fix every failure. Do not ask the user to notice.

## Git

- [ ] Working tree matches what you intend to ship (no leftover debug files)
- [ ] Every logical slice is its own commit (not one large dump)
- [ ] Every commit is pushed to the remote branch
- [ ] `git status` is clean, or the leftover is explained and unstaged on purpose

## Tests and CI

- [ ] New behavior has a test that failed before the fix/feature
- [ ] The project's test/lint commands pass for the affected area
- [ ] CI is green, or you have triggered it and will not claim success until it is

## Product and PR

- [ ] Scope matches the request; extras are listed as out of scope, not silently shipped
- [ ] PR body follows `settings/pr-body.md`
- [ ] Manual testing checklist is written for a non-technical reader (no unexplained commands)
- [ ] You could follow those steps yourself and they match the change

## Coding rules

- [ ] No `console.log` (use `console.error` only when needed)
- [ ] No `any`; null/undefined handled; interfaces prefixed with `I`
- [ ] No secrets, generated junk, or unrelated reformatting

If any box is unchecked, keep working. Then run this list again.
