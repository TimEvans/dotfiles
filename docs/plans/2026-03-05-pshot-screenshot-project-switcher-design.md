# pshot - Screenshot Project Switcher

## Problem

Screenshot keybindings in Hyprland hardcode the output path to a single project (`~/Github/notime/context/screenshots`). Switching projects requires manually editing `hyprland.conf`.

## Solution

A CLI tool (`pshot`) to switch the active screenshot project, plus a wrapper script that Hyprland calls instead of `hyprshot` directly.

## Components

### 1. `pshot` (~/dotfiles/scripts/pshot)

Bash script for switching the active project.

**Direct mode:** `pshot notime` - sets project immediately
**Interactive mode:** `pshot` - gum-powered TUI menu showing:
- Previously used projects (MRU order)
- "Add new" option -> lists remaining ~/Github/ repos

**State:** `~/.config/screen-project` (single line: project name)
**History:** `~/.config/screen-projects` (one per line, MRU order)
**Pre-seeded history:** notime, met, dotfiles

### 2. `screenshot.sh` (~/dotfiles/scripts/screenshot.sh)

Hyprland screenshot wrapper:
1. Reads project from `~/.config/screen-project`
2. Ensures `~/Github/$project/context/screenshots/` exists
3. Calls `hyprshot` with correct `-o` path
4. Accepts `region` or `output` as argument

### 3. Hyprland config update

```
bind = $SUPER_SHIFT, P, exec, ~/dotfiles/scripts/screenshot.sh region
bind = $SUPER CTRL, P, exec, ~/dotfiles/scripts/screenshot.sh output
```

## Dependencies

- `gum` (installed)
- `hyprshot` (already in use)
