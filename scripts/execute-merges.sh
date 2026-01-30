#!/bin/sh

# Simplified execute-merges.sh
# Merges all worktree branches that have commits ahead of base

usage() {
  printf '%s\n' "Usage: $0 [config.json] [--dry-run]"
  printf '%s\n' "Merges worktree branches into base branch"
  printf '%s\n' ""
  printf '%s\n' "Without config: scans .worktrees/ directory, merges into main"
  printf '%s\n' "With config: uses baseDir and baseBranch from config"
  printf '%s\n' "--dry-run: show what would be merged without executing"
  exit 1
}

main() {
  CONFIG_FILE=""
  DRY_RUN=false

  for arg in "$@"; do
    case "$arg" in
      --dry-run)
        DRY_RUN=true
        ;;
      --help|-h)
        usage
        ;;
      *)
        if [ -f "$arg" ]; then
          CONFIG_FILE="$arg"
        fi
        ;;
    esac
  done

  if [ -n "$CONFIG_FILE" ]; then
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

  # Collect branches to merge
  branches_to_merge=""
  for worktree in "$BASE_DIR"/*/; do
    [ -d "$worktree" ] || continue

    branch=$(cd "$worktree" && git branch --show-current 2>/dev/null)
    [ -z "$branch" ] && continue

    ahead=$(git rev-list --count "$BASE_BRANCH..$branch" 2>/dev/null || echo "0")
    if [ "$ahead" -gt 0 ]; then
      branches_to_merge="$branches_to_merge $branch"
    fi
  done

  if [ -z "$branches_to_merge" ]; then
    printf '%s\n' "No branches with commits ahead of $BASE_BRANCH"
    exit 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    printf '%s\n' "DRY RUN: Would merge these branches into $BASE_BRANCH:"
    for branch in $branches_to_merge; do
      printf '%s\n' "  - $branch"
    done
    printf '%s\n' ""
    printf '%s\n' "Run without --dry-run to execute."
    exit 0
  fi

  # Execute merges
  printf '%s\n' "Merging branches into $BASE_BRANCH..."
  printf '%s\n' ""

  git fetch origin 2>/dev/null || true
  git checkout "$BASE_BRANCH" || exit 1
  git pull origin "$BASE_BRANCH" 2>/dev/null || true

  for branch in $branches_to_merge; do
    printf '%s\n' "Merging $branch..."

    if git merge --no-ff "$branch" -m "Merge $branch into $BASE_BRANCH"; then
      printf '%s\n' "  ✓ Merged successfully"
    else
      printf '%s\n' "  ✗ Merge failed (conflicts)" >&2
      printf '%s\n' "  Resolve conflicts, then run: git merge --continue"
      exit 1
    fi
  done

  printf '%s\n' ""
  printf '%s\n' "All merges complete. Review with: git log --oneline -10"
  printf '%s\n' "Push with: git push origin $BASE_BRANCH"
}

main "$@"
