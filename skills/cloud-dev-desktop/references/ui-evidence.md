# Visible UI testing and evidence

For GitHub PR attachments, Linear cross-links, and a local wrapper-repository
workflow, see [PR and ticket UI evidence](../../pr-evidence/SKILL.md). This
runbook stays focused on EC2 and headed desktop capture.

Read this when connecting browser tools, running a demonstration, or capturing
evidence. A headed browser has a visible window; a headless browser does not.
Both can record browser video, but live observation requires the visible browser
to use the desktop session being streamed.

## Choose the capture method

| Need | Method | Limitation |
| --- | --- | --- |
| Watch the agent interact live | Headed Chromium in the shared desktop | Does not automatically save video |
| Review a UI journey afterward | Playwright video | Captures the page viewport, not the whole desktop |
| Diagnose a failure | Playwright trace, assertions, console/network inspection | Trace files may contain sensitive test data |
| Judge layout and appearance | Screenshots at selected viewport sizes | DOM success alone is insufficient |
| Record terminal and desktop too | FFmpeg X11 capture or OBS | Extra CPU/storage; configure the correct display |

Use test accounts and representative non-sensitive data. Start recording after
provider login/secret entry. Desktop video does not reveal every shell operation;
retain agent tool logs and git diffs when that visibility is required.

## Configure a demonstration run

Reuse the project's Playwright setup. Merge these settings into a dedicated
demonstration config or the selected run; do not overwrite unrelated projects,
fixtures, reporters, or application startup configuration.

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  workers: 1,
  outputDir: 'artifacts/ui-demo',
  use: {
    headless: false,
    viewport: { width: 1280, height: 720 },
    video: { mode: 'on', size: { width: 1280, height: 720 } },
    screenshot: 'on',
    trace: 'on',
  },
});
```

Use a unique output directory per run: the test runner may clean its output
directory at the start. Keep successful demo videos; failure-only or retry-only
recording would discard the success evidence the user wants. For routine CI,
use the project's lighter retention policy instead of recording everything.

For scripts using the Playwright library directly, configure `recordVideo` on
the browser context, start context tracing before navigation, capture screenshots,
stop tracing with an output path, and await `context.close()` in cleanup. Video
files are finalized when the context closes. Preserve the original test error
even if capture cleanup also fails.

For browser MCP tools, consult the installed server's schema and recording
options. Configure headed mode and the correct session environment in that
client's MCP configuration. A `playwright.config.ts` file does not automatically
configure an unrelated MCP server. If its recording support is insufficient,
run a dedicated Playwright test or desktop capture for the evidence.

## Verify one complete journey

1. Read the actual app's routes and existing tests. Choose one meaningful journey,
   for example creating a draft item and finding it in the list. State the expected
   outcome and use a test environment; do not invent selectors or submit real
   purchases/messages as a smoke test.
2. Start the app and wait for readiness. Confirm the URL from the browser's
   network environment, not just from a different container or machine.
3. Start any optional desktop capture on the existing X11 display. Match its
   capture area to the real desktop resolution. Make a short clip first and play
   it back; do not assume a running encoder means usable footage.
4. Run the journey with one worker so the viewer can follow it. Use stable role,
   label, or test-ID locators and condition-based waits. Assert the actual outcome.
5. Save screenshots of meaningful before/after states, including a narrow/mobile
   viewport when relevant. Inspect images for clipping, spacing, hierarchy,
   legibility, empty/error states, and responsive behavior. Mobile emulation does
   not replace testing on a real mobile device when device behavior matters.
6. Stop the desktop recorder gracefully and await file finalization. Close the
   browser context. Play the video, inspect screenshots, and open the trace.
7. Report the journey, pass/fail, observed visual issues, and artifact paths.
   Upload and verify using the workstation runbook before teardown.

## Troubleshooting

| Symptom | Check and action |
| --- | --- |
| Tests pass but desktop is empty | Check headless mode, actual `DISPLAY`, user/X11 authorization, and whether an MCP server started a separate browser/display |
| Browser cannot reach app | Check app readiness, port mapping, and which machine/container owns `localhost` |
| Missing or zero-byte video | Check recording enabled before context creation, context closure, output path, and free disk space |
| No video from a passing test | Change the demo's retry/failure-only policy to `on` |
| No screenshots available to agent | Confirm the tool returns images or the agent can read saved images; text-only snapshots do not provide visual review |
| Black desktop recording | Check the capture display, X11 authorization, session type, capture dimensions, and reconnect behavior |
| Slow chat or tests | Distinguish provider response time from CPU, memory, CPU credits, encoding, and network latency before resizing |

After one targeted repair and rerun, if the same failure remains, retain logs and
state the blocker. Do not bypass authentication, disable browser sandboxing, or
claim verification succeeded to finish the workflow.
