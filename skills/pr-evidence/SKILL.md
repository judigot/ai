---
name: pr-evidence
description: Capture and publish unattended screenshots or demo video as review evidence when a user asks for PR or ticket UI evidence, a demo video, a screenshot for GitHub or Linear, proof that a UI fix works, or Playwright recording for review.
---

# PR and ticket UI evidence

Use this skill for review evidence, not product functionality. Capture a real,
meaningful journey using the product's existing Playwright installation, inspect
the artifacts, and publish them without polluting the product repository.

## Principles

- Do not add packages whose primary purpose is demo video (`human-cursor`,
  `testreel`, `demohunter`, or `playwright-recast`) to the product app's
  `package.json`. Playwright remains allowed when it is the app's real E2E tool.
- Keep PNG, WebM, and MP4 artifacts in a local wrapper directory such as
  `pr-evidence/out/`. Never commit them to the product repository unless the
  user explicitly asks.
- Make the GitHub PR comment the default video surface. Attach an MP4 so the
  reviewer can play it inline. Comment on the Linear ticket with the PR comment
  URL; do not assume Linear provides equivalent inline playback.
- Watch screenshots and inspect the final video. State which acceptance criteria
  each artifact proves and what the reviewer should see.
- Make capture fully unattended: a wrapper script must run bootstrap, recording,
  conversion, upload, and reporting without prompts. It may be started with
  `nohup` or `&` and a log file.

## Prerequisites

- Use the product-local `./node_modules/.bin/playwright` or `pnpm exec
  playwright` from the app directory. Do not globally install Playwright for an
  app test; its browser and runner versions must match the project.
- Install `ffmpeg` on the workstation for WebM-to-MP4 conversion.
- Require a current `gh` that exposes `gh pr comment --attach`; verify with
  `gh pr comment --help` rather than assuming a version number. Uploads need a
  GitHub.com or GHE.com account token with repository write, maintain, or admin
  permission; GitHub App tokens and GHES are unsupported for attachments.
- Use Docker or a project bootstrap only when the existing E2E flow already
  needs it. Keep credentials and secret entry out of screenshots and recordings.

## Record the journey

1. List the ticket acceptance criteria. Select a short, meaningful Playwright
   test or grep pattern that proves them, using test data and an isolated test
   environment.
2. Add an evidence-only environment switch to the existing Playwright config if
   needed. Keep CI's normal retention policy unchanged. For evidence runs use
   one worker, `video: 'on'`, a stable 1280×720 viewport, and
   `preserveOutput: 'always'`. Playwright finalizes video when its browser
   context closes. For example:

   ```ts
   const evidenceRun = process.env.PW_RECORD_VIDEO === '1';

   export default defineConfig({
     preserveOutput: evidenceRun ? 'always' : 'failures-only',
     use: {
       video: evidenceRun
         ? { mode: 'on', size: { width: 1280, height: 720 } }
         : 'retain-on-failure',
     },
   });
   ```
3. For readable pacing, make an existing config's launch `slowMo` conditional
   on `PW_SLOW_MO`; use `pressSequentially` with a short delay for login or PIN
   fields and short evidence-only waits after meaningful saves or navigation.
   Prefer locator and condition waits over arbitrary long sleeps.
4. On current Playwright versions, prefer native video annotations before adding
   a sidecar: `video.show.actions.cursor: 'pointer'` displays a cursor
   decoration and action labels. This is the cleanest unattended cursor option.
   If a project is pinned to an older version or needs a polished narrated tour,
   use a separate tools/wrapper install instead.
5. Run only the selected test. Find the newest `.webm` under the run's output
   directory, then make a compatible, streaming-friendly MP4:

   ```sh
   ffmpeg -y -i "$webm" -c:v libx264 -pix_fmt yuv420p -movflags +faststart -an "$mp4"
   ```

   Keep clips focused (roughly 30–90 seconds) and compressed enough for the
   repository's GitHub attachment allowance.
6. Inspect representative screenshots and play the converted MP4. A passing
   assertion is not visual confirmation. For failures, keep a Playwright trace
   for debugging, but do not use it as executive review evidence.

## Publish

Use the wrapper template as a starting point. Its final action should attach the
video, not commit it:

```sh
gh pr comment "$PR_NUMBER" \
  --body "**Evidence (video)** — click Play below." \
  --attach "$mp4"
```

Repeat `--attach` for PNG screenshots when they add useful still-state evidence.
Capture the comment URL from `gh` output or `gh pr view --json comments`, open
it to confirm the attachment rendered, then place that URL in a Linear comment.
If upload partially fails, treat the command as failed even if earlier files
were attached; inspect the PR before retrying to avoid duplicate comments.

## Wrapper layout

Keep the app and evidence tooling adjacent but separate:

```text
~/work/<project>/
  app/                 # product clone
  pr-evidence/         # local-only wrapper: scripts, logs, out/, optional tools
```

Copy and customize
[`attach-pr-video.sh.template`](scripts/attach-pr-video.sh.template) into the
wrapper. It can bootstrap the existing E2E dependencies, execute one test by
grep, locate the artifact, transcode it, and attach it to the PR. It must not be
copied into products automatically.

## Choose the artifact

| Need | Use |
| --- | --- |
| Still UI or one screen | PNG attached to the PR comment |
| Multi-step admin or customer flow | MP4 attached to the PR comment |
| Diagnose a test failure | Playwright trace, not a review video |

## Optional sidecar tools

Install these only in `~/tools/<name>/`, a wrapper `package.json`, or another
dedicated tools location. Link to their documentation; do not clone or vendor
them into the product.

- [demo-machine](https://github.com/45ck/demo-machine): YAML-driven demos with cursor capture.
- [testreel](https://github.com/sneg55/testreel): JSON workflows and a Playwright fixture with cursor support.
- [playwright-recast](https://github.com/Andy2003/playwright-recast): post-processes traces or WebM for a polished result.
- [demohunter](https://github.com/emilwareus/demohunter): heavier narrated tours.

## Before declaring evidence done

- [ ] Acceptance criteria are mapped to screenshots or phases of the video.
- [ ] Screenshots were visually inspected; the expected viewer experience is stated for every video phase.
- [ ] The E2E test is green, or its failure is disclosed honestly in the PR comment.
- [ ] The MP4 and any PNGs are attached to the PR, and the rendered PR comment was opened and verified.
- [ ] The Linear ticket has a link to that GitHub PR comment.
- [ ] No evidence binary or demo-only package was added to the product repository.

## Anti-patterns

- Adding video capture packages to the product app.
- Globally installing Playwright for an app test.
- Posting only a Drive or Loom URL when the reviewer needs GitHub inline playback.
- Claiming visual verification without opening the artifacts.
