#!/usr/bin/env bash
# Reads timekeeper binding + story frontmatter for starship prompt segments.
# Usage: focus-info.sh label|status|spent|check <status-value>
set -uo pipefail

# Strip one surrounding pair of YAML quotes, e.g. spent: '1:01' -> 1:01.
# (YAML quotes values like 1:01 because they would otherwise parse as base-60.)
_unquote() { sed -e "s/^'\(.*\)'$/\1/" -e 's/^"\(.*\)"$/\1/'; }

# Resolve the binding by session ID, not PWD. After focus cds into a worktree
# (S135), PWD diverges from the session's start cwd, so a PWD-slug lookup would
# miss the binding and the card would vanish. Glob every project dir for the
# session's binding; on multiple matches prefer the most recently modified.
SID="${CLAUDE_SESSION_ID:-${CLAUDE_CODE_SESSION_ID:-none}}"
BINDING=$(ls -t "$HOME/.claude/projects"/*/"${SID}.binding.json" 2>/dev/null | head -1)

if [ ! -f "$BINDING" ]; then
  case "${1:-}" in
    label)  echo "What are we working on?" ;;
    check)  exit 1 ;;
    status) echo "" ;;
    spent)  echo "" ;;
    nofocus) exit 0 ;;
  esac
  exit 0
fi

STORY=$(jq -r '.story' "$BINDING" 2>/dev/null)
[ -z "$STORY" ] && exit 1

STORY_FILE=$(find -L "$PWD/docs/stories" -maxdepth 1 -name "${STORY}-*.md" 2>/dev/null | head -1)
if [ -z "$STORY_FILE" ]; then
  STORY_FILE=$(find -L "$PWD/docs/stories" -maxdepth 1 -name "${STORY}.md" 2>/dev/null | head -1)
fi

# Worktree fallback (S156): the cwd-relative docs/stories may not exist inside
# a focus-created worktree. Resolve via the vault root recorded in the binding.
if [ -z "$STORY_FILE" ]; then
  VAULT=$(jq -r '.vault // empty' "$BINDING" 2>/dev/null)
  if [ -n "$VAULT" ]; then
    STORY_FILE=$(find -L "$VAULT/stories" -maxdepth 1 -name "${STORY}-*.md" 2>/dev/null | head -1)
    if [ -z "$STORY_FILE" ]; then
      STORY_FILE=$(find -L "$VAULT/stories" -maxdepth 1 -name "${STORY}.md" 2>/dev/null | head -1)
    fi
  fi
fi

TITLE=""
STATUS=""
SPENT=""
if [ -n "$STORY_FILE" ]; then
  TITLE=$(grep -m1 '^title:' "$STORY_FILE" | sed 's/^title:[[:space:]]*//' | tr -d '\n\r' | _unquote)
  STATUS=$(grep -m1 '^status:' "$STORY_FILE" | sed 's/^status:[[:space:]]*//' | tr -d '\n\r' | _unquote)
  SPENT=$(grep -m1 '^spent:' "$STORY_FILE" | sed 's/^spent:[[:space:]]*//' | tr -d '\n\r' | _unquote)
fi

case "${1:-}" in
  label)
    if [ -n "$TITLE" ]; then
      echo "${STORY} - ${TITLE}"
    else
      echo "${STORY}"
    fi
    ;;
  status)
    if [ -n "$SPENT" ]; then
      echo "${STATUS} (${SPENT})"
    else
      echo "${STATUS}"
    fi
    ;;
  spent)
    echo "${SPENT}"
    ;;
  check)
    [ "$STATUS" = "${2:-}" ]
    ;;
  nofocus)
    exit 1
    ;;
esac
