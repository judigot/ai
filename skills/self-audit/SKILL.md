---
name: self-audit
description: Use this skill before finishing a task, opening a PR, or claiming the work is done. Check commits, push, tests/CI, PR checklist, scope, and coding-rule regressions. Fix failures before stopping.
---

# Self-audit

Apply only checks relevant to the task and authorized actions. Read-only analysis
needs no commits, tests, CI, or PR. For documentation-only edits, review the text,
links, and diff; do not invent a behavior test. Check PR requirements only when
creating or updating a PR.

Fix applicable failures within scope. Mark irrelevant checks as not applicable.
If a required check or publication step is unavailable or unauthorized, report it
as blocked or not performed, state what was verified, and do not claim full
validation or publication. This audit does not authorize commits or external writes.

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
- [ ] PR body follows `settings/pr-body.md`, or `settings/pr-shell.md` when this is a pre-implementation/delegated shell
- [ ] Manual testing checklist is written for a non-technical reader (no unexplained commands)
- [ ] For PR shells: dependency metadata, ownership boundaries, acceptance criteria, required checks, completion report, and ready-state rules are consistent with the actual work
- [ ] You could follow those steps yourself and they match the change

## Coding rules

- [ ] No `console.log` (use `console.error` only when needed)
- [ ] No `any`; null/undefined handled; interfaces prefixed with `I`
- [ ] No secrets, generated junk, or unrelated reformatting

Finish when applicable checks pass or remaining blockers are clearly reported. Do not keep working solely to satisfy an irrelevant or unavailable check.
