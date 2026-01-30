#!/bin/sh

# Simplified init-worktrees.sh
# Creates git worktrees from JSON configuration - no extra files, just git

usage() {
  printf '%s\n' "Usage: $0 <config.json>"
  printf '%s\n' "Creates git worktrees from JSON configuration file"
  printf '%s\n' ""
  printf '%s\n' "Config format:"
  printf '%s\n' '  {'
  printf '%s\n' '    "baseDir": ".worktrees",'
  printf '%s\n' '    "baseBranch": "main",'
  printf '%s\n' '    "worktrees": ['
  printf '%s\n' '      { "branch": "feat/auth", "dir": "feat-auth" }'
  printf '%s\n' '    ]'
  printf '%s\n' '  }'
  exit 1
}

main() {
  if [ $# -lt 1 ]; then
    usage
  fi

  CONFIG_FILE="$1"
  if [ ! -f "$CONFIG_FILE" ]; then
    printf '%s\n' "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
  fi

  BASE_DIR=$(jq -r '.baseDir // ".worktrees"' "$CONFIG_FILE")
  BASE_BRANCH=$(jq -r '.baseBranch // "main"' "$CONFIG_FILE")

  mkdir -p "$BASE_DIR"

  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$REPO_ROOT" ]; then
    printf '%s\n' "Error: Not in a git repository" >&2
    exit 1
  fi

  cd "$REPO_ROOT" || exit 1

  WORKTREES_COUNT=$(jq '.worktrees | length' "$CONFIG_FILE")
  printf '%s\n' "Creating $WORKTREES_COUNT worktrees..."

  i=0
  while [ $i -lt "$WORKTREES_COUNT" ]; do
    BRANCH=$(jq -r ".worktrees[$i].branch // \"\"" "$CONFIG_FILE")
    DIR=$(jq -r ".worktrees[$i].dir // \"\"" "$CONFIG_FILE")

    if [ -z "$BRANCH" ] || [ "$BRANCH" = "null" ]; then
      printf '%s\n' "Error: branch is required for worktree $i" >&2
      i=$((i + 1))
      continue
    fi

    # Auto-generate dir from branch if not specified
    if [ -z "$DIR" ] || [ "$DIR" = "null" ]; then
      DIR=$(echo "$BRANCH" | tr '/' '-')
    fi

    WORKTREE_PATH="$BASE_DIR/$DIR"

    if [ -d "$WORKTREE_PATH" ]; then
      printf '%s\n' "  ✓ $WORKTREE_PATH (already exists)"
      i=$((i + 1))
      continue
    fi

    printf '%s\n' "  Creating: $WORKTREE_PATH -> $BRANCH"

    if git worktree add "$WORKTREE_PATH" -b "$BRANCH" 2>/dev/null; then
      printf '%s\n' "    ✓ Created worktree and branch"
    elif git worktree add "$WORKTREE_PATH" "$BRANCH" 2>/dev/null; then
      printf '%s\n' "    ✓ Created worktree (branch existed)"
    else
      printf '%s\n' "    ✗ Failed to create worktree" >&2
    fi

    i=$((i + 1))
  done

  printf '%s\n' ""
  printf '%s\n' "Done. Worktrees:"
  git worktree list
}

main "$@"
