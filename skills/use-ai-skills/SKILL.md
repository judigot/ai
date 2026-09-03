---
name: use-ai-skills
description: Dynamically discover and execute the smallest sufficient set of skills from the live public `judigot/ai` GitHub repository. Use only when the user explicitly invokes `@use-ai-skills`, `$use-ai-skills`, or asks to use the skills in `judigot/ai`; do not activate implicitly for ordinary technical tasks.
---

# Use AI Skills

Route the current task through the live skills in `https://github.com/judigot/ai/tree/main/skills`. Optimize for the fastest reliable path to a completed result.

## Discover

1. Read the current task before choosing skills.
2. Fetch the live `skills/` directory from the public repository's `main` branch. Do not clone the repository and do not rely on a cached or local copy.
3. Enumerate directories containing `SKILL.md`. Exclude `use-ai-skills` from candidates to prevent recursion.
4. Read the YAML frontmatter of each candidate `SKILL.md`, especially `name` and `description`. Prefer ranged or line-limited reads when supported so discovery does not load every body.
5. Match the task against the metadata. Select one skill when it covers the task; select multiple only for distinct necessary parts. Use no more than three selected skills by default.
6. If more than three are genuinely necessary, explain why before loading the additional skills.

Use these public endpoints when the provider has no native GitHub reader:

- Directory: `https://api.github.com/repos/judigot/ai/contents/skills?ref=main`
- Skill: `https://raw.githubusercontent.com/judigot/ai/main/skills/<directory>/SKILL.md`

If discovery is unavailable, state the access problem clearly. Do not silently substitute stale instructions.

## Load

1. Briefly name the selected skills and why they apply.
2. Read every selected `SKILL.md` completely before acting.
3. Resolve relative links from the selected skill's directory. Resolve repository-root paths, such as `settings/...`, from `https://github.com/judigot/ai/tree/main/`.
4. Read only referenced files required for the current task. Do not load unrelated resources.
5. Preserve the selected skills' intended order. Run setup or planning skills first, task-specific skills next, and audit or verification skills last.

## Execute

1. Follow the selected skills automatically; do not ask for approval merely to use them.
2. Use safe defaults and existing project patterns. Ask a question only when the answer materially changes cost, risk, architecture, user-visible behavior, data, or success criteria.
3. Reuse scripts, templates, references, and tools named by the selected skills when available.
4. Parallelize independent work only when the runtime supports it and doing so reduces delivery time without creating conflicting edits.
5. Prefer one selected skill over several overlapping skills. Avoid redundant workflows and repeated validation.
6. Treat the user's current instructions and platform safety requirements as higher priority than repository skills. If selected skills conflict, follow the more task-specific instruction; if the conflict is material and cannot be resolved safely, ask once.
7. Never claim a tool-backed action succeeded without verifying its result.

## Handle Capability Gaps

A repository skill provides instructions, not new runtime capabilities.

- Use the provider's equivalent tool when names differ but capabilities match.
- If a required capability is missing, use a safe equivalent only when it preserves the requested result.
- Never invent credentials, tool output, file access, deployments, commits, or external writes.
- If no viable capability exists, identify the blocker and the minimum user action needed.

## No Match

If no repository skill matches, say so briefly and complete the task with the provider's normal capabilities when safe. Use `find-skills` only when the user is asking to discover or extend capabilities, or when its description directly matches the request.

## Finish

Return the completed outcome, relevant verification, and blockers only. Keep routing commentary concise so skill selection saves more time than it costs.
