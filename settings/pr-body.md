# Pull request body template

Copy this structure. Write in plain language. Do not assume the reader can use a terminal.

```markdown
## What changed

- [One sentence: what a person will notice]
- [Optional: what did not change]

## Why

[One or two sentences. Skip if obvious.]

## How to verify (manual)

Do these in order. Check each box when that step matches.

- [ ] Open the site / app the way you usually do.
- [ ] Go to: **[exact screen or menu path, e.g. Settings → Profile]**.
- [ ] **[Action a non-technical person can do, e.g. click Save]**.
- [ ] You should see: **[what appears, in everyday words]**.
- [ ] If it is broken you will see: **[what "wrong" looks like]**.

Add more boxes for extra paths (empty state, error, mobile, another role). One box = one action + one expected result.

## Automated checks

CI must be green. That is how we know the implementation succeeded.

## Out of scope

- [Anything this PR does not do, so nobody hunts for it]
```
