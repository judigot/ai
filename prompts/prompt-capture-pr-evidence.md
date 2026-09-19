# Capture PR evidence

```text
Capture and publish unattended UI evidence for this product change.

1. Read the current remote `skills/pr-evidence/SKILL.md` from judigot/ai and follow it.
2. Identify the pull-request number, feature branch, ticket, acceptance criteria, and the existing Playwright test title or grep pattern that demonstrates the change. Ask only for a missing value that prevents a truthful capture.
3. Keep the product clone in `app/`. Create or reuse a sibling local-only `pr-evidence/` wrapper directory. Copy and customize the skill's `attach-pr-video.sh.template` there as needed; run it unattended, optionally with `nohup` and a log file.
4. Use the product-local Playwright runner. Do not add video/demo packages to the product `package.json` and do not globally install Playwright.
5. Record the focused journey, convert the final WebM to H.264 MP4, inspect screenshots and the playable MP4, then attach the MP4 (and useful PNGs) to the GitHub PR with `gh pr comment --attach`.
6. Open the resulting PR comment to verify the inline attachment. Add a Linear comment linking to that GitHub comment.
7. Report the acceptance criteria each artifact proves, test status, artifact paths, PR comment URL, and any limitations honestly. Do not commit evidence binaries.
```
