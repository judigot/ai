# AI Scripts

Simple scripts for managing git worktrees in parallel development workflows.

## Philosophy

**Git is the only source of truth:**

- Worktree exists = task exists
- Branch name = task identity
- Commit history = task progress
- PR merged = task done

No extra files needed. No Context.md, no .state files, no metadata.

## Available Scripts

### init-worktrees.sh

Creates git worktrees from a JSON configuration file.

```sh
~/ai/scripts/init-worktrees.sh worktree-config.json
```

**Config format:**

```json
{
  "baseDir": ".worktrees",
  "baseBranch": "main",
  "worktrees": [
    { "branch": "feat/auth", "dir": "feat-auth" },
    { "branch": "feat/dashboard" }
  ]
}
```

- `baseDir`: Where worktrees are created (default: `.worktrees`)
- `baseBranch`: Base branch for merges (default: `main`)
- `worktrees[].branch`: Branch name (required)
- `worktrees[].dir`: Directory name (optional, auto-generated from branch)

### merge-order.sh

Shows which worktree branches have commits ready to merge.

```sh
# Without config (uses .worktrees/ and main)
~/ai/scripts/merge-order.sh

# With config
~/ai/scripts/merge-order.sh worktree-config.json
```

Output shows branches with commits ahead of base, and whether they've been pushed.

### execute-merges.sh

Merges all ready worktree branches into the base branch.

```sh
# Dry run (preview)
~/ai/scripts/execute-merges.sh --dry-run

# Execute merges
~/ai/scripts/execute-merges.sh

# With config
~/ai/scripts/execute-merges.sh worktree-config.json
```

## Workflow

### Option 1: Using multitasker agent (Recommended)

Just tell the multitasker what you want to work on:

```
"I need to work on auth, dashboard, and API features"
```

The multitasker will:

1. Create worktrees for each task
2. Spawn parallel subagents via Task tool
3. Report results when done

### Option 2: Manual with scripts

```sh
# 1. Create config
cat > worktree-config.json << 'EOF'
{
  "baseDir": ".worktrees",
  "baseBranch": "main",
  "worktrees": [
    { "branch": "feat/auth" },
    { "branch": "feat/dashboard" }
  ]
}
EOF

# 2. Create worktrees
~/ai/scripts/init-worktrees.sh worktree-config.json

# 3. Work on each worktree (in separate terminals or via Task tool)
cd .worktrees/feat-auth && claude
cd .worktrees/feat-dashboard && claude

# 4. Check what's ready to merge
~/ai/scripts/merge-order.sh

# 5. Merge completed work
~/ai/scripts/execute-merges.sh --dry-run
~/ai/scripts/execute-merges.sh
```

### Option 3: Pure git commands

```sh
# Create worktrees manually
mkdir -p .worktrees
git worktree add .worktrees/feat-auth -b feat/auth
git worktree add .worktrees/feat-dashboard -b feat/dashboard

# Work on them
cd .worktrees/feat-auth && claude

# Check status
git worktree list

# Merge when done
git checkout main
git merge --no-ff feat/auth
git merge --no-ff feat/dashboard

# Cleanup
git worktree remove .worktrees/feat-auth
git branch -d feat/auth
```

## Ralph Loop (Sequential Tasks)

For tasks that touch the same files or need strict ordering, use the Ralph Loop in `ralph/`.

See `ralph/README.md` for details.

## Compatibility

Works with both **Claude Code** and **OpenCode**:

- Both support the Task tool for spawning subagents
- Both support parallel tool calls
- Both work in git worktrees

## Tips

1. **Keep worktrees limited (2-4)** to avoid resource strain
2. **Always push branches** so work isn't lost
3. **Never run parallel tasks that touch the same files**
4. **Use git log to check progress** instead of status files
