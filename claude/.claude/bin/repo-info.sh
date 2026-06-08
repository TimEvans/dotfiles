#!/usr/bin/env bash
# Prints the OWNER repository name for the Claude Code starship statusline.
#
# Inside a linked git worktree the working dir is the worktree itself, so a
# plain basename would show the worktree slug (e.g. "s156-..."). git's
# --git-common-dir points at the OWNER repo's .git regardless of which
# worktree you're in; its parent is the owner working tree, whose basename
# is the repo name (e.g. "timekeeper"). Falls back to the current directory
# name outside a git repo.
set -uo pipefail

common=$(git rev-parse --git-common-dir 2>/dev/null || true)
if [ -n "$common" ]; then
  owner=$(cd "$(dirname "$common")" 2>/dev/null && pwd)
  if [ -n "$owner" ]; then
    basename "$owner"
    exit 0
  fi
fi
basename "$PWD"
