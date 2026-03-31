# bslink — Design Spec

**Date:** 2026-03-31
**Status:** Approved

## Overview

`bslink` is a bash script that lets you symlink selected folders from `~/Github/backseat-docs` into any working directory. Running `bslink` from a project directory presents an interactive multi-select (via `gum`) showing all available doc folders, with currently active symlinks pre-ticked. You can add or remove links in a single interaction.

## Location & Invocation

- Script: `dotfiles/scripts/bslink` (no extension, matching `pshot` convention)
- Already on `$PATH` via `export PATH="$HOME/dotfiles/scripts:$PATH"` in `.zshrc`
- Invoked as: `bslink` from any directory

## Source & Target

- **Source:** `~/Github/backseat-docs/` — top-level directories only
- **Target:** `<cwd>/backseat-docs/<folder>` — symlinks inside a `backseat-docs/` subdirectory of the current working directory

Example after selecting `strategy` and `personas`:
```
cwd/
  backseat-docs/
    strategy  ->  ~/Github/backseat-docs/strategy
    personas  ->  ~/Github/backseat-docs/personas
```

## Core Flow

1. Check `gum` is available; exit with install hint if not
2. Verify `~/Github/backseat-docs` exists; exit with error if not
3. Scan source for top-level directories; exit cleanly if none found
4. Scan `<cwd>/backseat-docs/` for existing symlinks pointing into backseat-docs
5. Present `gum choose --no-limit` with all folders, pre-ticking existing ones
6. If user cancels (ESC / gum exits non-zero), exit with no changes
7. Diff old selection vs new selection:
   - Remove symlinks for unticked folders
   - Create `<cwd>/backseat-docs/` if it doesn't exist
   - Add symlinks for newly ticked folders
8. Remove `<cwd>/backseat-docs/` if it ends up empty

## Interactive UI

Uses `gum choose --no-limit --selected=<comma-separated-existing>` to display all available folders. Pre-selected items reflect currently active symlinks so the user can see and adjust the full state in one prompt.

## Error Handling

| Condition | Behaviour |
|---|---|
| `gum` not found | Print install hint and exit 1 |
| `~/Github/backseat-docs` missing | Print error and exit 1 |
| No folders in source | Print message and exit 0 |
| User cancels (ESC, gum non-zero exit) | Exit 0, no changes |
| User confirms empty selection (Enter with nothing ticked) | Remove all existing symlinks, remove dir if empty |
| Target exists but is not a symlink | Warn and skip — do not overwrite |

## Script Style

Follows existing dotfiles script conventions:
- Shebang: `#!/usr/bin/env bash`
- Strict mode: `set -euo pipefail`
- Header comment with name and usage
- No external dependencies beyond `gum`
