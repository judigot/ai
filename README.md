# AI — Centralized Claude Code Plugin

A centralized Claude Code plugin containing agents, skills, hooks, and coding rules. Use this across **all your projects** without duplicating setup.

## Quick Start

### 1. Clone to a permanent location

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

### 4. Attach official + Matt Pocock skills (once per machine)

```sh
~/ai/scripts/install-external-skills.sh
```

This overlay does **not** vendor those skill files. Install them globally, then in each app repo run `/setup-matt-pocock-skills` once.

### 5. Point other agents at this overlay

In each app repo, keep a short `AGENTS.md` (and `CLAUDE.md` → `@AGENTS.md`):

```md
@~/ai/settings/rules.md
@~/ai/settings/workflow.md
```

Do not start implementation chats with `github.com/judigot/ai` as the workspace unless you are changing this plugin. Load this overlay first, then work in the app.

First-message fallback: `prompts/prompt-init-chat.md`.

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
│   ├── find-skills/          # skills.sh registry
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

Session start loads `settings/rules.md` and `settings/workflow.md`. Agents clarify before coding, implement test-driven, push mini commits, and self-audit before stopping.

Matt Pocock `/grill-with-docs` may create a `CONTEXT.md` in the **app** repo. That is domain language, not worktree state. Worktrees still use git only.

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
| `find-skills` | Search and install from [skills.sh](https://skills.sh) |
| `tdd-ci` | Red-green-refactor; CI is the success signal |
| `self-audit` | Pre-stop checklist: commits, push, CI, PR |
| `lint-master` | Multi-tool linting workflow (ESLint > Oxlint > Biome) |
| `test-master` | Testing infrastructure and implementation |

### External skills (not in this repo)

| Pack | Why |
| --- | --- |
| [skills.sh](https://skills.sh) / `npx skills` | Official registry. Use `find-skills` instead of inventing a catalog. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | `/setup-matt-pocock-skills`, `/grill-with-docs`, `/tdd`, `/wayfinder`, `/ask-matt` |

Install once with `~/ai/scripts/install-external-skills.sh`. Do not copy those files into `~/ai`. Pick either the Claude Code plugin **or** `npx skills add` for Matt Pocock, not both.

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
my-project/
├── AGENTS.md                 # @~/ai/settings/rules.md and workflow.md
├── CLAUDE.md                 # @AGENTS.md
├── .claude/
│   └── settings.local.json   # Project-specific settings
└── agents/                   # Project-specific agents (optional)
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
