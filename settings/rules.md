# General

- I want the code to be self-documenting.
- Agents should always run terminal commands by sourcing the ~/.devrc file first. It is needed to be able to use aliases:

```bash
. ~/.devrc; eval "hi" # For running aliases
```

- I prefer readable code that I can go back to after a long time and still be able to understand it.
- Use "current datetime" for chat titles.
- Show code before explanations.
- Avoid Nano; use Vim-compatible instructions.
- ESLint: Follow 'plugin:@typescript-eslint/strict-type-checked'.
- Use short, semantic git commit messages following Conventional Commits format

## Strict TypeScript Enforcement

- Assume TypeScript strict mode is non-negotiable (`strict`, `noImplicitAny`, `strictNullChecks`, `noUncheckedIndexedAccess` mindset).
- Prefer narrowing and type guards over assertions.
- Favor compile-time safety over convenience shortcuts.

### Common Lint Traps (with fixes)

#### 1) `no-explicit-any`

```ts
// Bad
function parse(value: any): any {
  return value.data;
}

// Good
function parse(value: unknown): { data: unknown } | null {
  if (typeof value === "object" && value !== null && "data" in value) {
    return value as { data: unknown };
  }
  return null;
}
```

Rule: never introduce `any` unless user explicitly requests it for a known interoperability boundary.

#### 2) Unsafe type assertions

```ts
// Bad
const userId = (payload as { user: { id: string } }).user.id;

// Good
if (typeof payload === "object" && payload !== null && "user" in payload) {
  const user = (payload as { user: unknown }).user;
  if (
    typeof user === "object" &&
    user !== null &&
    "id" in user &&
    typeof (user as { id: unknown }).id === "string"
  ) {
    const userId = (user as { id: string }).id;
  }
}
```

Rule: do not use `as` to skip validation; validate first, narrow second.

#### 3) `eslint-disable-next-line` / `@ts-ignore`

```ts
// Bad
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const x: any = foo;

// Bad
// @ts-ignore
dangerousCall();
```

```ts
// Good (last resort, documented, scoped)
// @ts-expect-error -- third-party typing bug: upstream issue #1234
knownBrokenTypedCall();
```

Rule: do not use `eslint-disable-next-line` or `@ts-ignore` by default. If unavoidable, use the narrowest suppression with a specific reason and prefer `@ts-expect-error`.

#### 4) `require-await` in tests and mocks

```ts
// Bad
verifyAuthToken: async () => ({ ok: true, status: 200, auth0UserId: "u1" });

// Good
verifyAuthToken: () =>
  Promise.resolve({ ok: true, status: 200, auth0UserId: "u1" });
```

Rule: if a function has no `await`, do not mark it `async`.

#### 5) Prefer object literals with `as const` over enums (default)

```ts
// Prefer
export const WORKSPACE_STATUS = {
  QUEUED: "queued",
  READY: "ready",
  FAILED: "failed",
} as const;

export type IWorkspaceStatus =
  (typeof WORKSPACE_STATUS)[keyof typeof WORKSPACE_STATUS];

// Avoid by default
enum WorkspaceStatus {
  QUEUED = "queued",
  READY = "ready",
  FAILED = "failed",
}
```

Rule: use enums only when interop explicitly requires enum semantics.

#### 6) Narrow HTTP status types

```ts
// Bad
interface IErrorResult {
  status: number;
}

// Good
interface IErrorResult {
  status: 400 | 401 | 404 | 500;
}
```

Rule: prefer literal unions over broad primitive types when values are finite.

### TypeScript Dos and Don'ts

- Do: use `unknown` at trust boundaries (request bodies, external API responses).
- Do: validate with schema/type guards before property access.
- Do: model finite states with `as const` object literals + union types.
- Do: make impossible states impossible with discriminated unions.
- Don't: widen types early (`string`, `number`) when literal unions are available.
- Don't: use non-null assertions (`!`) unless proven safe by control flow.
- Don't: hide type errors with blanket assertions or disable comments.

### Pre-Finish Type Safety Checklist

Before marking any TypeScript task complete, run:

```sh
bun run lint:tsc
bun run lint:eslint
bun test <affected-tests>
```

Do not finalize while any type/lint errors remain.

## Runtime Validation (Zod)

- Use Zod at untrusted boundaries and business-critical flows.
- Do not add Zod everywhere by default; validate where data enters or crosses trust boundaries.

### Where Zod is Required

- API request/response validation (server routes, webhooks, external callbacks).
- Auth/session payloads and permission-critical claims.
- Payment/billing/infra provisioning payloads.
- DB write inputs from user or external systems.
- Environment/config parsing at startup.

### Where Zod is Usually Not Needed

- Internal values already typed and produced in the same trusted module.
- Tight inner loops/hot paths with no untrusted input.
- Purely local transformations after prior validated parsing.

### Zod Usage Rules

```ts
// Prefer safeParse for request handlers (no exceptions for control flow)
const parsed = WorkspaceProvisionRequestSchema.safeParse(body);
if (!parsed.success) {
  return c.json(
    { error: "Invalid request body", details: parsed.error.issues },
    400,
  );
}
const data = parsed.data;
```

```ts
// Use parse when failure should throw and fail fast (startup/config)
const env = EnvSchema.parse(process.env);
```

- Default object behavior strips unknown keys; use `strictObject` / `.strict()` when unknown keys must be rejected.
- Use `.passthrough()` only when extra keys are intentionally allowed.
- Define schemas once per module and reuse; avoid rebuilding schemas repeatedly in handlers.
- Derive TS types from schemas (`z.infer`) to avoid drift.

### Example: Strict boundary schema

```ts
import { z } from "zod";

export const WorkspaceProvisionRequestSchema = z.strictObject({
  workspaceName: z.string().trim().min(1),
  domain: z.string().trim().min(1),
  region: z.string().trim().min(1).optional(),
});

export type IWorkspaceProvisionRequest = z.infer<
  typeof WorkspaceProvisionRequestSchema
>;
```

# Token Efficiency

## Response Rules

- No preambles ("Let me...", "I'll...", "Sure!", "Great question!")
- No summaries after completing tasks
- No repeating the user's request back
- No "Here's what I found" phrases
- Code blocks only - skip prose when code is self-explanatory
- One-line answers when possible
- Prefer explicit rules over implicit assumptions; restate key rules when asked
- Use ai\_\* aliases when they map to the requested action

## Tool Usage

- Batch file reads in parallel
- Don't re-read files already in context
- Use grep/codebase_search before reading large files
- Skip node_modules, dist, .git, lock files, generated files
- Prefer targeted reads and diffs; avoid full-file dumps
- Use Context7 for docs lookup to avoid verbose explanations

## Git Stash Over Re-editing

- When changes need to be temporarily reverted (e.g. switching branches, resetting to HEAD for a clean diff), use `git stash` / `git stash pop` instead of discarding edits and reapplying them from scratch.
- Re-reading files and re-applying edits wastes tokens and time when the changes already exist in the working tree.
- Rule: if you already have working uncommitted changes, **stash them** — never throw them away and redo them.

## Code Output

- Show only changed lines with context, not full files
- Skip unchanged imports/boilerplate in explanations

# Defaults (Don't Ask, Just Do)

- TypeScript strict mode, ESM imports
- Latest stable versions
- Bun as package manager
- Follow existing project patterns
- Auto-create directories when writing files

# MCP Tools

- Always use Context7 MCP for library/API documentation, code generation, setup, or configuration steps without requiring explicit request
- MCP server binaries can be shared across tools, but each client (OpenCode, Claude Code, Codex) requires its own config pointing to those servers
- Required MCP servers: Context7, GitHub
- Required CLI tools for agents: gh

# File Operations

- If files should have the same content, move them instead of rewriting (saves tokens)
- Safe file relocation: copy file first, then delete the original
- Use terminal `mv` command for simple moves/renames
- Use terminal `cp` then `rm` for safe cloning when needed

# Comment Rules

- Only add useful comments.
- Don't add obvious comments.
- Comment like how a senior-level engineer would
- Don't comment on architectural decisions that are self-evident from code structure
- Don't add "explanation comments" that restate what the code already makes clear

# Terminal

- Write all shell scripts and command examples as POSIX-compliant `sh` scripts, avoiding Bash/Zsh-specific features.
- Always use MSYS2 bash instead of PowerShell for shell commands
- Use bash syntax
- If you need to change the same code like one-liners across multiple files, use terminal commands rather than changing the files manually.

## Destructive Commands (STRICT SAFETY RULE)

**NEVER run destructive commands without explicit prior approval in the same conversation.**

If the user has NOT explicitly instructed you to run destructive commands, you MUST:

1. Stop and explain what you intend to do
2. List the exact command(s) and their consequences
3. Wait for explicit approval before proceeding

Skip permission only if the user explicitly requested the destructive action beforehand.

### Destructive Commands List

| Git (can lose history/commits)           | System (can lose data/corrupt files) |
| ---------------------------------------- | ------------------------------------ |
| `git reset --hard`                       | `rm -rf`, `rm -r`                    |
| `git push --force`, `--force-with-lease` | `del /s /q`, `rmdir /s`              |
| `git clean -fd`, `-fx`                   | `format`, `diskpart`                 |
| `git rebase` (on pushed/shared branches) | `shutdown`, `reboot`                 |
| `git branch -D` (force delete)           | `chmod -R`, `chown -R`               |
| `git stash drop`, `stash clear`          | `mkfs`, `dd`                         |
| `git reflog expire`, `gc --prune`        | Registry edits (`reg delete`)        |
| `git filter-branch`, `filter-repo`       | `takeown`, `icacls` (permissions)    |

### Pre-Flight Checklist (MANDATORY before any destructive git command)

Even with explicit user approval, you MUST complete these steps IN ORDER before running any destructive git command:

1. Run `git status` — if there are uncommitted changes, STOP and stash them first (`git stash push -m "backup before <command>"`)
2. Run `git log --oneline -5` — confirm which commits exist and will be affected
3. Run `git stash list` — note existing stashes so they aren't accidentally dropped
4. Show the user exactly what will be lost/changed and get final confirmation
5. ONLY THEN execute the destructive command

**If `git reset --hard` is requested:**

- ALWAYS run `git stash push -u -m "backup before reset"` FIRST (includes untracked files)
- Record the current HEAD SHA in the conversation so it can be recovered via reflog
- Prefer `git reset --soft` or `git reset --mixed` when the goal is just to uncommit (not discard changes)

**If `git clean` is requested:**

- Run `git clean -nd` (dry run) first and show the user what will be deleted
- Never run `git clean -fx` without showing dry run output first

### Why This Rule Exists

- Prevent accidental deletion of git history
- Prevent repository corruption
- Prevent loss of uncommitted work
- Prevent system file damage

## MSYS2 Bash from PowerShell

When in PowerShell, use `bash` function (defined in ~/profile.ps1):

```powershell
bash "

cd ~/ai
git status

"
```

For snippets:

```powershell
bash "

. ~/.devrc
downloadGithubRepo judigot/project-core

"
```

**Formatting rules:**

- Use newlines as padding (empty line after opening quote, before closing quote)
- One command per line for human readability and easy copy-paste

When already in MSYS2 bash, run commands directly.

**How to detect terminal:**

- PowerShell errors contain `At C:\...\ps-script-...`
- PowerShell rejects `&&` with "not a valid statement separator"

## Git SSH

- ALWAYS use SSH URLs, never HTTPS: `git@github.com:user/repo.git`
- When cloning: `git clone git@github.com:user/repo.git`
- If git asks for credentials, the remote is HTTPS. Fix with: `git remote set-url origin git@github.com:user/repo.git`

## Git Commits (Conventional Commits)

Format: `<type>: <description>`

| Type       | Purpose                           |
| ---------- | --------------------------------- |
| `feat`     | New feature                       |
| `fix`      | Bug fix                           |
| `docs`     | Documentation                     |
| `style`    | Formatting (no code change)       |
| `refactor` | Code restructure (no feature/fix) |
| `perf`     | Performance improvement           |
| `test`     | Add/update tests                  |
| `chore`    | Maintenance, deps, config         |

Examples: `feat: add user auth`, `fix: null check in parser`, `chore: update deps`

# Snippets (~/.devrc)

- Location: `~/.devrc`
- Prefer using existing snippets over writing new scripts
- When adding new utilities, add them to `~/.devrc` with descriptive function names and multiple aliases. But always ask permission first.
- Usage: `bash -c ". ~/.devrc && functionName"`
- Always source `~/.devrc` at the start of every agent CLI session (OpenCode, Claude Code, Codex, etc.) and before running shell commands so aliases are available.

## User Aliases

| Command                        | Purpose                           |
| ------------------------------ | --------------------------------- |
| `helloWorld`                   | Test greeting                     |
| `updateCurrentBranch`          | Merge origin/main and push        |
| `updater`                      | Update shell configs from GitHub  |
| `bbvite`                       | Scaffold Vite project             |
| `bblaravel`                    | Scaffold Laravel project          |
| `getssh`                       | Display SSH public key            |
| `generatessh`                  | Create new SSH key                |
| `testssh`                      | Test GitHub SSH connection        |
| `personalssh`                  | Switch to personal SSH key        |
| `workssh`                      | Switch to work SSH key            |
| `deleteall`                    | Delete all files in cwd (confirm) |
| `loadsnippets`                 | Add devrc to .bashrc              |
| `newagent`                     | Create Cursor/agents structure    |
| `downloadGithubRepo user/repo` | Download GitHub repo without .git |

## Agent Aliases (Token-Efficient)

| Command                         | Purpose                                      |
| ------------------------------- | -------------------------------------------- |
| `ai_diffnav [branch]`           | Show raw PR diff between main/current branch |
| `ai_prdiff [branch]`            | Alternative alias for ai_diffnav             |
| `ai_gitdiff [branch]`           | Alternative alias for ai_diffnav             |
| `ai_gc "msg"`                   | Stage all + commit (no push)                 |
| `ai_gcp`                        | Preview staged changes                       |
| `ai_gpr`                        | Create PR (gh cli)                           |
| `ai_nr "script"`                | Run bun script                               |
| `ai_status`                     | Git status (short)                           |
| `ai_diff`                       | Git diff (unstaged)                          |
| `ai_diffstaged`                 | Git diff (staged)                            |
| `ai_log`                        | Git log (recent)                             |
| `ai_add`                        | Git add all                                  |
| `ai_pull`                       | Git pull with rebase                         |
| `ai_search "pattern" [path]`    | Ripgrep search                               |
| `ai_replace "file" "old" "new"` | Replace string in file                       |
| `ai_mkdir "dir"`                | Make directory (parents)                     |
| `ai_touch "file"`               | Touch file                                   |
| `ai_copy "src" "dest"`          | Copy file/dir                                |
| `ai_move "src" "dest"`          | Move/rename file/dir                         |

# TypeScript/JavaScript

- Never add console.log. You can add console.error
- Use unknown instead of any.
- Prefer interfaces (prefix with "I") over types.
- Wrap variables in String() when interpolating.
- Avoid unnecessary type casts.
- Handle null, undefined, 0, or NaN explicitly.
- Always use braces for void arrow functions.
- Always escape dollar signs when using template literals

# React

- Use function components only.
- Include all dependencies in hooks.
- Fix click handlers on non-interactive elements.

## Invariant-First UI State Workflow

- For interaction-heavy UI (chat heads, toggles, wizards, tab/panel systems), define invariants before editing code.
- Write 3-7 invariants in plain language, then map every user action path to one invariant.
- Prefer explicit state fields over inferred visual state.
- If multiple states become coupled (`selected` vs `active` vs `collapsed`), move to `useReducer`.

### Required Invariant Loop

1. Define invariants first.
2. Enumerate interaction paths (tap, second tap, drag end, open/close).
3. Implement transitions only after path→invariant mapping is complete.
4. Verify each invariant manually after build/deploy.

### Example Invariants (Bubble/Panel UX)

- Closed identity: when closed, all panel identity fields match.
- Selection first: first tap selects/activates, not minimize.
- Minimize on second tap: minimize only on second tap of selected+active bubble.
- Collapse ownership: bubble that triggered minimize becomes collapsed identity.
- Stable positions: bubble positions are deterministic and only mirror by dock side.
- Active highlight: highlighted bubble always matches active panel.

### Anti-Patterns

- Do not drive behavior by icon swapping alone.
- Do not encode state implicitly in CSS classes without state variables.
- Do not patch interaction bugs with one-off conditionals before writing invariants.

# Formatting

- Block Comments: Use `/* This is a comment */` for inline comments.
- SQL: Use heredoc syntax.

# Shell/Bash

- Avoid grep; prefer awk.
- Follow this structure in script files:

  ```sh
  #!/bin/sh

  readonly GLOBAL_VARIABLE="Hello, World!"

  readonly PROJECT_DIRECTORY=$(cd "$(dirname "$0")" || exit 1; pwd) # Directory of this script

  main() {
      action1
      action2
  }

  action1() {
      cd "$PROJECT_DIRECTORY" || exit 1
      printf '%s\n' "Action 1"
  }

  action2() {
      cd "$PROJECT_DIRECTORY" || exit 1
      printf '%s\n' "Action 2"
  }

  main "$@"
  ```

  \*the main function should be at the very top to easily have an idea on what the script is all about

- Omit unused global variables.

# SPA Content Extraction

- For JavaScript-rendered SPAs: use Jina Reader first (prepend `https://r.jina.ai/` to URL)
- Handle hash routes with POST requests; wait for stable selectors if loading
- Fallback: headless browser → wait for ready → extract outerHTML/innerText/accessibility tree
- Auth required: only use user-provided access; never guess credentials
- Output: clean docs with source, URL, timestamp, summary, structured content
- Mark unavailable sections explicitly; don't invent content
