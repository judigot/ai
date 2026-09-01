---
name: tdd-ci
description: Use this skill when implementing a feature or bugfix that can be covered by tests. Drive red-green-refactor, commit each slice, and treat CI as the success signal. Prefer Matt Pocock /tdd when that skill is installed.
---

# Test-driven delivery

Users often only look at CI. A change is not done because it looks right locally. It is done when the suite that CI runs is green for this change.

If Matt Pocock `/tdd` is installed, follow that skill for the red-green-refactor loop. This file adds the overlay's CI and commit rules.

## Loop (one vertical slice)

1. **Red** — Write one failing test for the behavior. Run it. Confirm it fails for the right reason. Commit `test: …`. Push.
2. **Green** — Write the minimum production code to pass. Run the same test. Commit `feat:` / `fix:`. Push.
3. **Refactor** — Clean up with tests still green. Commit `refactor:` if there is a real cleanup. Push.
4. Repeat for the next slice. Do not stack several features in one commit.

## CI is the definition of done

- Run the same commands CI runs (from the project's workflow or `package.json`).
- If the repo has GitHub Actions (or equivalent), the PR must show green. Local green is a preview.
- Do not skip tests because the change "is only wiring." If it can break, it needs a failing test first.
- If the project has no test runner yet, add the thinnest suite that CI can run before feature work. Do not invent a second framework when one exists.

## What not to do

- Tests written after a large untested implementation
- One giant commit that mixes tests and five features
- Mocking so much that the test cannot fail
- Declaring done while CI is red, pending, or not triggered
