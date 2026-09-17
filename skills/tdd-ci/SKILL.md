---
name: tdd-ci
description: Use this skill when implementing a feature or bugfix that can be covered by tests. Drive red-green-refactor, commit each slice, and treat CI as the success signal. Fetch Matt Pocock tdd from settings/references.md if you want his loop; do not install it.
---

# Test-driven delivery

Users often only look at CI. A change is not done because it looks right locally. It is done when the suite that CI runs is green for this change.

If you want Matt Pocock's red-green-refactor detail, fetch the tdd URL in `settings/references.md`. Do not install it. This file is the overlay's CI and commit rules.

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

## CI parity and browser-test discipline

- Read the workflow and root `package.json` before choosing verification commands.
  Run the repository's exact scripts, including every chained linter; do not
  substitute a package-local command or rely on truncated terminal output.
- Treat lint, typecheck, unit tests, build, and browser tests as separate gates.
  Record each command's exit status, and inspect the CI job log when a local
  result and CI result disagree.
- For Playwright, keep exhaustive deterministic token/contract matrices in unit
  tests. Use end-to-end tests for real browser behavior and a small, intentional
  representative matrix unless visual regression coverage is the explicit goal.
- Keep browser tests isolated and use web-first assertions. Use retries only in
  CI (normally one); preserve `trace: 'on-first-retry'` so a retry remains
  diagnosable rather than silently masking a regression.
- A passing retry is a signal to investigate, not proof that the test is healthy.
  Do not increase retries to compensate for a flaky selector, timing issue, or
  environment problem.
- When local browser execution is blocked by sandbox port/process limits, say so
  explicitly and use the hosted CI run as the authoritative browser result.

## What not to do

- Tests written after a large untested implementation
- One giant commit that mixes tests and five features
- Mocking so much that the test cannot fail
- Declaring done while CI is red, pending, or not triggered
