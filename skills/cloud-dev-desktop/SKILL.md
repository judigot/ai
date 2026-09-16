---
name: cloud-dev-desktop
description: Set up or operate an ephemeral AWS EC2 development desktop where a user can watch an OpenCode agent test a web UI, capture screenshots and videos, and preserve evidence before teardown. Use for visible cloud development workstations and browser-testing workflows.
---

# Cloud development desktop

## Outcome

Give the user a cloud development machine with a visible browser, an agent chat,
repeatable UI tests, and recordings that survive the machine's termination.
Use plain language and numbered steps. Explain unfamiliar terms when first used.
For each stage, report the expected result and verify it before advancing.

This skill describes a workflow; it does not provide AWS access or authorize
spending. A request to write a plan or PR means prepare files only. Reuse existing
authorization to provision or terminate; otherwise obtain it for those actions
after preparing a concrete plan. Do not deploy merely because this skill is loaded.

## Default design

| Component | Role | Default |
| --- | --- | --- |
| Ubuntu Server | Operating system | 24.04 LTS, x86_64; verify current support |
| Xfce | Lightweight desktop installed on Ubuntu | One X11 desktop session |
| Amazon DCV | Lets the user view and control that desktop | Private, authenticated access; browser client where supported |
| OpenCode | Agent chat, edits, and shell commands | Runs on EC2; ChatGPT subscription login if available |
| Headed Chromium | Browser with a visible window | Same desktop session the user watches |
| Playwright | Browser automation and test evidence | Screenshots, browser video, trace |
| FFmpeg or OBS | Optional complete-desktop recording | Use only when browser video is insufficient |
| Git and private S3 | Durable code and artifacts | Save and verify before termination |

Xfce does not replace Ubuntu. EC2 price depends on the instance and other AWS
resources, not the desktop name. The models run at the provider; EC2 runs the
agent tools, builds, browsers, and encoders. A GPU is not normally required.

Start planning around 2 vCPU / 8 GiB for one light session; prefer 4 vCPU / 16 GiB
for simultaneous builds, containers, and desktop encoding. These are starting
estimates, not guarantees. Check CPU/RAM during a representative run. Consider
non-burstable instances for sustained work; check T-family CPU credit costs.
Start with On-Demand. Use Spot only when interruptions and incremental backups
are acceptable. Do not promise that changing the desktop or agent client will
speed up model inference or remove provider limits.

## Execute in order

1. **Establish scope.** Identify the target application/infra repository, AWS
   account, region, network access method, instance budget, artifact destination,
   retention, and maximum session lifetime. Reuse known choices. Ask only for
   missing inputs that prevent a correct or authorized action. Do not infer AWS
   resource IDs or deploy application code into this overlay repository.
2. **Prepare reproducible infrastructure.** Read
   [the workstation runbook](references/workstation.md). Prefer the user's
   existing Terraform/cloud-init layout. Prepare the changes and plan before
   provisioning. Keep credentials out of git, user data, recordings, and AMIs.
3. **Verify the visible session.** Establish Xfce/DCV compatibility using current
   AWS instructions. Open Chromium inside the exact desktop the user can see.
   Disconnect and reconnect; the session must remain usable. Do not silently
   replace Xfce if the selected OS/DCV combination fails.
4. **Connect the agent.** In OpenCode, use `/connect` → OpenAI → ChatGPT Plus/Pro
   if the installed release offers it. Verify with `/models` and a small task.
   Use the browser/device login supplied by the tool. Plus has usage limits;
   API-key billing is separate. If subscription authentication fails, report
   the error and offer Codex CLI with ChatGPT login; never switch to paid API
   usage silently. Verify current provider docs rather than assuming support.
5. **Attach browser tools.** Read
   [the UI evidence runbook](references/ui-evidence.md). Give the agent either
   direct Playwright script execution or a configured browser MCP server.
   Installing a desktop alone does not give an agent browser control. Do not
   assume MCP sessions inherit Playwright Test's recording settings.
6. **Prove the workflow.** Run one real UI journey with an expected outcome.
   Verify both the live visible browser and saved screenshots/video/trace.
   Inspect the rendered page for layout quality; DOM assertions alone do not
   establish good visual design. Record failures honestly and keep their evidence.
7. **Preserve, then tear down.** Finalize recordings, upload artifacts, verify
   remote objects, and push permitted code. Preserve chat history or export it
   separately; git does not save it. Follow the runbook's teardown gates.

## Completion evidence

Report what was actually completed:

- For a documentation/PR task: changed files, validation, PR link, and the fact
  that live provisioning was not performed.
- For a deployed workstation: instance/region, access instructions without
  secrets, tool versions, observed browser session, test results, durable artifact
  locations, and expiry/teardown status.
- Distinguish `prepared`, `provisioned`, `verified`, and `terminated`. Never call
  a plan a working workstation, or a screenshot a passing end-to-end test.

## Current documentation

Use Context7 when available for library/configuration details, then official
documentation for missing coverage. Pin the versions actually installed and
record which documentation was consulted. Fetch pages; do not copy external
skills into this repository.

- [DCV Linux prerequisites](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html)
- [DCV sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html)
- [OpenCode providers](https://opencode.ai/docs/providers/)
- [OpenCode web access](https://opencode.ai/docs/web/)
- [OpenCode MCP configuration](https://opencode.ai/docs/mcp-servers/)
- [Codex authentication](https://developers.openai.com/codex/auth)
- [Playwright videos](https://playwright.dev/docs/videos)
- [Playwright traces](https://playwright.dev/docs/trace-viewer)
