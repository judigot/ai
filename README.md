# AI — Centralized Claude Code Plugin

A centralized Claude Code plugin containing agents, skills, hooks, and coding rules. Use this across **all your projects** without duplicating setup.

## Quick Start

### 1. Optional: local Claude Code plugin

Only needed if you run Claude Code with `--plugin-dir`. Agents do not clone
this repo; they fetch `AGENTS.md` from GitHub raw.

```sh
git clone https://github.com/judigot/ai.git ~/ai
```

### 2. Create a shell alias

Add to your `.bashrc`, `.zshrc`, or shell config:

```sh
alias cc='claude --plugin-dir ~/ai'
```

Reload your shell:

```sh
source ~/.bashrc
```

### 3. Use in any project

```sh
cd /path/to/any/project
cc
```

All your agents, skills, hooks, and rules are now available!

### 4. Point other agents at this overlay

Do not copy this overlay into an app. Seed each app from
[`judigot/project-core`](https://github.com/judigot/project-core) so it has
`AGENTS.md`, `CLAUDE.md`, and `agents/`.

Each app `AGENTS.md` should load this overlay **remotely** from one
entrypoint: fetch `https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md`
and the files it names. Then add a short repo-specific section.

Always fetch that live tree. Do not clone this repository to load it, and do
not read `~/ai` or any other local clone (those copies can be stale). Cloning
`~/ai` is only for the optional local Claude Code plugin above.

The app repo is the workspace. Do not clone or treat this overlay as the
project unless you are changing the overlay.

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
│   ├── code-reviewer.md      # Git-based PR review
│   ├── task-master.md        # Worktree task execution
│   ├── multitasker.md        # Parallel worktree management
│   └── agentic-workflow.md   # Multi-agent coordination
├── skills/                   # Overlay skills (subdirectories)
│   ├── setup-entrypoint/     # Load overlay, clarify, route
│   ├── find-skills/          # skills.sh lookup (URLs only)
│   ├── tdd-ci/               # Red-green-refactor; CI = done
│   ├── self-audit/           # Pre-stop checklist
│   ├── lint-master/
│   └── test-master/
├── hooks/
│   └── hooks.json            # SessionStart, PreToolUse, Stop hooks
├── commands/                 # Slash commands (.md files)
├── scripts/                  # Helper scripts
├── settings/
│   ├── rules.md              # Coding rules
│   ├── workflow.md           # Session protocol
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

If a Matt Pocock grilling session (fetched from `settings/references.md`) produces a `CONTEXT.md` in the **app** repo, that is domain language, not worktree state. Worktrees still use git only.

### Global Plugin Loading

The `--plugin-dir` flag tells Claude Code to load this plugin for any project:

```sh
claude --plugin-dir ~/ai
```

This applies your agents, skills, hooks, and settings globally without copying files to each project.

## Available Agents

| Agent | Purpose |
|-------|---------|
| `code-reviewer` | Git-based PR review with enterprise-grade analysis |
| `task-master` | Execute single task in a worktree autonomously |
| `multitasker` | Sprint orchestrator - creates worktrees and spawns parallel subagents |
| `agentic-workflow` | Multi-agent coordination architecture |

**Compatibility:** All agents work with both **Claude Code** and **OpenCode**.

## Available Skills

| Skill | Purpose |
|-------|---------|
| `setup-entrypoint` | Load this overlay, clarify, route to wayfinder/TDD before coding |
| `find-skills` | Look up skills on [skills.sh](https://skills.sh) and fetch the page. Do not install. |
| `tdd-ci` | Red-green-refactor; CI is the success signal |
| `self-audit` | Pre-stop checklist: commits, push, CI, PR |
| `lint-master` | Multi-tool linting workflow (ESLint > Oxlint > Biome) |
| `test-master` | Testing infrastructure and implementation |

### External work (URLs only)

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

Local projects can have their own settings that extend the global ones:

```
my-project/                   # seeded from judigot/project-core
├── AGENTS.md                 # overlay loader + repo-specific section
├── CLAUDE.md                 # Follow AGENTS.md
├── agents/                   # project-specific agents
└── .claude/
    └── settings.local.json   # optional local Claude settings
```

Claude Code loads in this order:
1. Global plugin (from `--plugin-dir`) ← This repository
2. Project `CLAUDE.md`
3. Local `.claude/` settings

## Updating

```sh
cd ~/ai
git pull
```

Changes apply to the next Claude Code session.

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
