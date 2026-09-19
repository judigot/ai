# AI — Agent overlay

Rules, workflow, skills, and stack for every agentic chat. This is not an app
workspace.

## How agents load this overlay

Agent instructions: [AGENTS.md](AGENTS.md). Agents do not need to read this README
for required behavior.

1. Supply the [initialization prompt](prompts/prompt-init-chat.md) as agent-level
   instructions or the first chat message. No project files need to be added or
   changed. The bootstrap must be available before attempting remote access.
2. Try the remote overlay and all required files first, on every session.
3. Only if remote loading fails, use `~/ai`. Clone `judigot/ai` there if absent;
   otherwise verify the existing checkout and preserve its contents. Report the
   local version and any modifications; its freshness may be unverified.
4. If neither source is usable, report the blocker. Cloning also requires network
   access. The app remains the workspace; `~/ai` supplies instructions only.

When maintaining the overlay itself, use its current checkout. See
[the loading policy](AGENTS.md#loading-policy) for the authoritative rules.

Product apps stay standalone. Do not include `settings/ecosystem.md` from a
product repo. That file is for `judigot/template-monorepo` and for maintaining
this overlay.

First-message fallback: `prompts/prompt-init-chat.md`.

Third-party skills are **links only** — `settings/references.md`. Stack and which official skill to fetch are in `settings/stack.md`. Do not clone or install third-party skills into this repo.

## Directory Structure

```
ai/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest (required)
├── agents/                   # Agent definitions (.md files)
│   ├── founder-ideator.md    # Astra-tier short original ideas
│   ├── spec-compiler.md      # Terra-tier specs, PR shells, TDD contracts
│   ├── overnight-orchestrator.md # Unattended dependency-aware coordinator
│   ├── code-reviewer.md      # Git-based PR review
│   ├── task-master.md        # Worktree task execution
│   ├── multitasker.md        # Parallel worktree management
│   └── agentic-workflow.md   # Multi-agent coordination
├── skills/                   # Overlay skills (subdirectories)
│   ├── setup-entrypoint/     # Load overlay, clarify, route
│   ├── find-skills/          # skills.sh lookup (URLs only)
│   ├── use-ai-skills/        # Dynamic live-repository skill router
│   ├── cloud-dev-desktop/    # Visible EC2 agent workstation and UI evidence
│   ├── sleep-and-forget/     # Unattended PR-shell execution
│   ├── tdd-ci/               # Red-green-refactor; CI = done
│   ├── self-audit/           # Pre-stop checklist
│   ├── scaffolder/           # MVP schema → Scaffolder draft PR
│   ├── lint-master/
│   └── test-master/
├── hooks/
│   └── hooks.json            # SessionStart, PreToolUse, Stop hooks
├── commands/                 # Slash commands (.md files)
├── scripts/                  # Helper scripts
├── settings/
│   ├── rules.md              # Coding rules
│   ├── workflow.md           # Session protocol
│   ├── agent-orchestration.md # Provider-neutral worker routing and verified model mappings
│   ├── stack.md              # Current packages → official skills.sh packs
│   ├── references.md         # URLs to official + other skills (no downloads)
│   ├── ecosystem.md          # Template-only charter; not included from product repos
│   └── pr-body.md            # PR template with manual checklist
├── prompts/
│   └── prompt-init-chat.md   # First message when includes are missing
├── AGENTS.md                 # First file agents read
├── CLAUDE.md                 # Points at AGENTS.md
└── README.md
```

## How It Works

### Personal Settings (Compartmentalized)

Your personal coding rules are stored in `settings/rules.md`, separate from `~/.claude`. This provides:
- **Single source of truth**: One repository for all global settings
- **Version control**: Track changes to your rules over time
- **Portability**: Same settings across all machines

Session start loads this overlay from `AGENTS.md`. Agents clarify before coding, implement test-driven, push mini commits, and self-audit before stopping. The template's `docs/ecosystem.md` applies when the workspace is `judigot/template-monorepo`.

`settings/agent-orchestration.md` is the canonical model-economy policy:
Astra handles short founder/ideation decisions, Terra compiles specs and
coordinates unattended work, Luna performs token-heavy implementation, and CI
is the completion authority. Tool-specific configuration stays in each CLI's
supported location; the overlay never copies credentials between clients.

If a Matt Pocock grilling session (fetched from `settings/references.md`) produces a `CONTEXT.md` in the **app** repo, that is domain language, not worktree state. Worktrees still use git only.

### Optional: Claude Code plugin while editing this overlay

If this workspace **is** https://github.com/judigot/ai because you are
changing the overlay, Claude Code can load it with `--plugin-dir` pointed at
this checkout. Apps use the remote-first loading policy, with a clone fallback when needed.

## Available Agents

| Agent | Purpose |
|-------|---------|
| `founder-ideator` | Produce short Astra-tier original product/architecture pitches |
| `spec-compiler` | Compile pitches into Terra-tier FRDs, PR shells, DAGs, and TDD contracts |
| `overnight-orchestrator` | Coordinate unattended PR-shell execution without keeping Astra resident |
| `code-reviewer` | Git-based PR review with enterprise-grade analysis |
| `task-master` | Execute single task in a worktree autonomously |
| `multitasker` | Sprint orchestrator - creates worktrees and spawns parallel subagents |
| `agentic-workflow` | Multi-agent coordination architecture |
| `ui-to-react` | Convert static HTML into React using existing components and tokens |
| `ui-mock-iframe` | Preview served HTML in an existing mock gallery |
| `design-creation-agent` | Create design-system components, pages, and examples |

**Compatibility:** All agents work with both **Claude Code** and **OpenCode**.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `setup-entrypoint` | Load this overlay, clarify, route to wayfinder/TDD before coding |
| `sleep-and-forget` | Run dependency-aware PR shells unattended with Terra coordination and Luna implementation |
| `find-skills` | Look up skills on [skills.sh](https://skills.sh) and fetch the page. Do not install. |
| `use-ai-skills` | Discover and execute the smallest sufficient set of live repository skills |
| `cloud-dev-desktop` | Set up a visible EC2 development desktop with OpenCode, UI tests, recordings, and verified artifact preservation |
| `tdd-ci` | Red-green-refactor; CI is the success signal |
| `self-audit` | Pre-stop checklist: commits, push, CI, PR |
| `scaffolder` | Build `schemaInfo`, call the Scaffolder agent API, open a draft PR |
| `lint-master` | Multi-tool linting workflow (ESLint > Oxlint > Biome) |
| `test-master` | Testing infrastructure and implementation |
| `frontend-design` | Build localized React UI using the app's existing design system |
| `junit-test-implementation` | Find and close Java/JUnit test coverage gaps |

Layer-specific guidance: [frontend conventions](settings/frontend.md) and
[Java backend conventions](settings/backend-java.md). These are loaded by task
through the workflow router. [STP extraction notes](docs/stp-extraction.md)
record the sources, duplicate rules, adaptations, and intentionally excluded
project-specific instructions.

### External work (URLs only)

TypeSafe / Jev is available as an optional skill reference for typed AI judgments.
See [on-demand loading and environment setup](docs/typesafe-jev.md). The upstream
skill stays external; no SDK or API access is enabled by loading this overlay.

Listed in `settings/references.md`. Fetch the page when the route needs it. Never clone those repos into `judigot/ai`.

| Pack | URL |
| --- | --- |
| Official makers | https://skills.sh/official |
| React performance | https://www.skills.sh/vercel-labs/agent-skills/vercel-react-best-practices |
| Next.js | https://www.skills.sh/vercel/next.js |
| Turborepo | https://www.skills.sh/vercel/turborepo |
| Vercel deploy | https://www.skills.sh/vercel-labs/agent-skills/deploy-to-vercel |
| Matt Pocock | https://www.skills.sh/mattpocock/skills |

## Sprint Modes

### Mode A: Parallel Worktrees (Recommended)

Give the multitasker a list of tasks - it creates worktrees and spawns subagents:

```
"I need to work on auth, dashboard, and API features"
```

The multitasker will:
1. Create `.worktrees/feat-auth`, `.worktrees/feat-dashboard`, `.worktrees/feat-api`
2. Spawn task-master subagents via Task tool (in parallel)
3. Report results when done

**Philosophy:** Git is the only source of truth for worktrees. No `.state` files. An app-level `CONTEXT.md` from Matt Pocock grilling is optional domain language, not sprint metadata.

### Mode B: Sequential Ralph Loop

For tasks that touch the same files or need strict sequencing:

```sh
./ai/scripts/ralph/ralph.sh 10
```

**Start here:** `ai/scripts/ralph/`

## Combining with Project-Specific Config

Keep existing project-specific instructions. Load this overlay through agent-level
instructions or the initialization prompt; do not add an overlay loader or copy
settings into the project. Try remote loading every session and use `~/ai` only
when remote loading is unavailable.

To change the overlay, edit this repository and follow the applicable Git
permissions and delivery workflow.

## Adding New Components

### New Agent

Create a new `.md` file in `agents/`:

```markdown
---
name: my-agent
description: Use this agent when [conditions]. Examples:

<example>
Context: [Situation]
user: "[Request]"
assistant: "[Response]"
<commentary>
[Why this agent triggers]
</commentary>
</example>

model: inherit
color: blue
tools: ["Read", "Write", "Bash"]
---

You are an expert at...

[Agent instructions here]
```

### New Skill

Create a new subdirectory in `skills/` with a `SKILL.md` file:

```
skills/
└── my-skill/
    └── SKILL.md
```

The skill file follows the same format as agents.

### New Command

Create a new `.md` file in `commands/` for slash commands.

## License

MIT
