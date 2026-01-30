#!/bin/sh

# Simplified merge-order.sh
# Shows branches ready to merge (branches with commits ahead of base)

usage() {
  printf '%s\n' "Usage: $0 [config.json]"
  printf '%s\n' "Shows worktree branches that have commits ahead of base branch"
  printf '%s\n' ""
  printf '%s\n' "Without config: scans .worktrees/ directory"
  printf '%s\n' "With config: uses baseDir and baseBranch from config"
  exit 1
}

main() {
  CONFIG_FILE="${1:-}"

  if [ -n "$CONFIG_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    BASE_DIR=$(jq -r '.baseDir // ".worktrees"' "$CONFIG_FILE")
    BASE_BRANCH=$(jq -r '.baseBranch // "main"' "$CONFIG_FILE")
  else
    BASE_DIR=".worktrees"
    BASE_BRANCH="main"
  fi

  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$REPO_ROOT" ]; then
    printf '%s\n' "Error: Not in a git repository" >&2
    exit 1
  fi

  cd "$REPO_ROOT" || exit 1

  if [ ! -d "$BASE_DIR" ]; then
    printf '%s\n' "No worktrees directory found at $BASE_DIR"
    exit 0
  fi

  printf '%s\n' "Branches ready to merge into $BASE_BRANCH:"
  printf '%s\n' ""

  # Fetch to ensure we have latest remote info
  git fetch origin 2>/dev/null || true

  for worktree in "$BASE_DIR"/*/; do
    [ -d "$worktree" ] || continue

    dir_name=$(basename "$worktree")

    # Get branch name from worktree
    branch=$(cd "$worktree" && git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && continue

    # Count commits ahead of base branch
    ahead=$(git rev-list --count "$BASE_BRANCH..$branch" 2>/dev/null || echo "0")

    if [ "$ahead" -gt 0 ]; then
      # Check if pushed to remote
      remote_exists=$(git branch -r --list "origin/$branch" 2>/dev/null)
      if [ -n "$remote_exists" ]; then
        pushed="[pushed]"
      else
        pushed="[local only]"
      fi

      printf '%s\n' "  $branch ($ahead commits ahead) $pushed"
    fi
  done

  printf '%s\n' ""
  printf '%s\n' "To merge: git checkout $BASE_BRANCH && git merge --no-ff <branch>"
}

main "$@"
