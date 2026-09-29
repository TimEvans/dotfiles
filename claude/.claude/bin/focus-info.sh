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

# focus writes the card's title and status into the binding, and ship flips
# the status to closed. These are display hints (bd stays the source of truth)
# that let the card render on the first redraw with no bd call at all.
BINDING_TITLE=$(jq -r '.title // empty' "$BINDING" 2>/dev/null | tr -d '\n\r')
BINDING_STATUS=$(jq -r '.status // empty' "$BINDING" 2>/dev/null | tr -d '\n\r')

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

# Owner-repo fallback (S156 follow-up): bindings written before the vault field
# existed, and worktrees created before symlink mirroring, satisfy neither path
# above. The OWNER repo (parent of git's --git-common-dir) always has docs/stories
# on disk, and is derivable from any worktree with no fresh focus required.
if [ -z "$STORY_FILE" ]; then
  COMMON=$(git rev-parse --git-common-dir 2>/dev/null || true)
  if [ -n "$COMMON" ]; then
    OWNER=$(cd "$(dirname "$COMMON")" 2>/dev/null && pwd)
    if [ -n "$OWNER" ]; then
      STORY_FILE=$(find -L "$OWNER/docs/stories" -maxdepth 1 -name "${STORY}-*.md" 2>/dev/null | head -1)
      if [ -z "$STORY_FILE" ]; then
        STORY_FILE=$(find -L "$OWNER/docs/stories" -maxdepth 1 -name "${STORY}.md" 2>/dev/null | head -1)
      fi
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

# Bead fallback: a constellation vault has no stories/*.md; the card lives in
# Beads. `bd show` costs ~0.5s (process start + Dolt open), which is over
# starship's command timeout, so it is never run inline. The answer is cached
# per story under the runtime dir and refreshed in the background when older
# than BEAD_CACHE_TTL seconds. The binding's own title/status are the base
# values; the cache overrides them only when it is the newer of the two files,
# so a binding just rewritten by focus or ship wins over a cache seconds old.
BEAD_CACHE_TTL=30
BEAD_LOCK_STALE_AFTER=60
if [ -z "$STORY_FILE" ]; then
  TITLE="$BINDING_TITLE"
  STATUS="$BINDING_STATUS"
  BEAD_VAULT=$(jq -r '.vault // empty' "$BINDING" 2>/dev/null)
  if [ -n "$BEAD_VAULT" ] && [ -d "$BEAD_VAULT/.beads" ]; then
    CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/focus-info"
    CACHE="$CACHE_DIR/${STORY}.json"
    mkdir -p "$CACHE_DIR" 2>/dev/null

    now=$(date +%s)
    fresh=0
    if [ -s "$CACHE" ]; then
      cache_mtime=$(stat -c %Y "$CACHE" 2>/dev/null || echo 0)
      binding_mtime=$(stat -c %Y "$BINDING" 2>/dev/null || echo 0)
      if [ "$cache_mtime" -ge "$binding_mtime" ]; then
        TITLE=$(jq -r '.[0].title // empty' "$CACHE" 2>/dev/null | tr -d '\n\r')
        STATUS=$(jq -r '.[0].status // empty' "$CACHE" 2>/dev/null | tr -d '\n\r')
        [ $((now - cache_mtime)) -lt "$BEAD_CACHE_TTL" ] && fresh=1
      fi
    fi

    # A refresh that died leaves its lock behind; sweep one older than the
    # stale threshold so the card cannot be frozen forever.
    if [ -d "$CACHE.lock" ]; then
      lock_mtime=$(stat -c %Y "$CACHE.lock" 2>/dev/null || echo 0)
      [ $((now - lock_mtime)) -ge "$BEAD_LOCK_STALE_AFTER" ] && rmdir "$CACHE.lock" 2>/dev/null
    fi

    # Refresh in the background; the lock dir stops the label and status
    # segments (which starship runs concurrently) from both spawning bd.
    if [ "$fresh" = 0 ] && mkdir "$CACHE.lock" 2>/dev/null; then
      (
        BEADS_DIR="$BEAD_VAULT/.beads" bd show "$STORY" --json >"$CACHE.tmp.$$" 2>/dev/null \
          && [ -s "$CACHE.tmp.$$" ] && mv -f "$CACHE.tmp.$$" "$CACHE"
        rm -f "$CACHE.tmp.$$"
        rmdir "$CACHE.lock" 2>/dev/null
      ) >/dev/null 2>&1 </dev/null &
      disown 2>/dev/null || true
    fi
  fi
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
