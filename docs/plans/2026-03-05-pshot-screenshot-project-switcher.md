# pshot - Screenshot Project Switcher Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CLI tool to switch which project screenshots are saved to, with interactive selection via gum.

**Architecture:** Two bash scripts - `pshot` (project switcher CLI) and `screenshot.sh` (Hyprland wrapper that reads the active project from a state file). Hyprland bindings call the wrapper instead of hyprshot directly.

**Tech Stack:** Bash, gum (TUI), hyprshot (screenshots)

---

### Task 1: Create the `pshot` project switcher script

**Files:**
- Create: `scripts/pshot`

**Step 1: Create the script**

```bash
#!/usr/bin/env bash
# pshot - Switch active screenshot project
# Usage: pshot [project]  (direct)
#        pshot            (interactive gum menu)

set -euo pipefail

GITHUB_DIR="$HOME/Github"
STATE_FILE="$HOME/.config/screen-project"
HISTORY_FILE="$HOME/.config/screen-projects"

# Ensure history file exists with defaults
if [[ ! -f "$HISTORY_FILE" ]]; then
    mkdir -p "$(dirname "$HISTORY_FILE")"
    printf '%s\n' notime met dotfiles > "$HISTORY_FILE"
fi

# Ensure state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    mkdir -p "$(dirname "$STATE_FILE")"
    head -1 "$HISTORY_FILE" > "$STATE_FILE"
fi

set_project() {
    local project="$1"

    # Validate project directory exists
    if [[ ! -d "$GITHUB_DIR/$project" ]]; then
        echo "Error: $GITHUB_DIR/$project does not exist"
        exit 1
    fi

    # Write to state file
    echo "$project" > "$STATE_FILE"

    # Update history: move project to top
    local tmp
    tmp=$(grep -vx "$project" "$HISTORY_FILE" 2>/dev/null || true)
    { echo "$project"; echo "$tmp"; } | sed '/^$/d' > "$HISTORY_FILE"

    echo "Screenshot project set to: $project"
    echo "Screenshots will save to: $GITHUB_DIR/$project/context/screenshots/"
}

# Direct mode: pshot <project>
if [[ $# -ge 1 ]]; then
    set_project "$1"
    exit 0
fi

# Interactive mode
if ! command -v gum &>/dev/null; then
    echo "Error: gum is required for interactive mode. Install it or use: pshot <project>"
    exit 1
fi

current=$(cat "$STATE_FILE" 2>/dev/null || echo "none")
echo "Current project: $current"

# Build choices: history entries + "Add new"
choices=$(cat "$HISTORY_FILE")
choice=$(printf '%s\n' $choices "-- Add new --" | gum choose --header "Select screenshot project")

if [[ "$choice" == "-- Add new --" ]]; then
    # List Github repos not already in history
    all_repos=$(ls "$GITHUB_DIR")
    history_repos=$(cat "$HISTORY_FILE")
    new_repos=$(comm -23 <(echo "$all_repos" | sort) <(echo "$history_repos" | sort))

    if [[ -z "$new_repos" ]]; then
        echo "All Github projects are already in your list."
        exit 0
    fi

    choice=$(echo "$new_repos" | gum choose --header "Select new project to add")
fi

set_project "$choice"
```

**Step 2: Make it executable**

Run: `chmod +x scripts/pshot`

**Step 3: Verify it runs**

Run: `./scripts/pshot --help || true && head -3 scripts/pshot`
Expected: shebang line visible, script is executable

**Step 4: Commit**

```bash
git add scripts/pshot
git commit -m "feat(scripts): add pshot project switcher with gum TUI"
```

---

### Task 2: Create the `screenshot.sh` Hyprland wrapper

**Files:**
- Create: `scripts/screenshot.sh`

**Step 1: Create the wrapper script**

```bash
#!/usr/bin/env bash
# screenshot.sh - Hyprland screenshot wrapper
# Reads active project from ~/.config/screen-project
# Usage: screenshot.sh region|output

set -euo pipefail

STATE_FILE="$HOME/.config/screen-project"
GITHUB_DIR="$HOME/Github"
MODE="${1:-region}"

# Read active project
if [[ ! -f "$STATE_FILE" ]]; then
    notify-send "pshot" "No project set. Run: pshot <project>"
    exit 1
fi

project=$(cat "$STATE_FILE")
output_dir="$GITHUB_DIR/$project/context/screenshots"

# Ensure output directory exists
mkdir -p "$output_dir"

# Run hyprshot based on mode
case "$MODE" in
    region)
        hyprshot -m region -o clipboard -o "$output_dir"
        ;;
    output)
        hyprshot -m active -m output -o clipboard -o "$output_dir"
        ;;
    *)
        echo "Usage: screenshot.sh region|output"
        exit 1
        ;;
esac
```

**Step 2: Make it executable**

Run: `chmod +x scripts/screenshot.sh`

**Step 3: Commit**

```bash
git add scripts/screenshot.sh
git commit -m "feat(scripts): add screenshot wrapper that reads active project"
```

---

### Task 3: Update Hyprland config bindings

**Files:**
- Modify: `hypr/.config/hypr/hyprland.conf:174-175`

**Step 1: Update the keybindings**

Change lines 174-175 from:
```
bind = $SUPER_SHIFT, P, exec, hyprshot -m region -o clipboard -o ~/Github/notime/context/screenshots
bind = $SUPER CTRL, P, exec, hyprshot -m active -m output -o clipboard -o ~/Github/notime/context/screenshots
```

To:
```
bind = $SUPER_SHIFT, P, exec, ~/dotfiles/scripts/screenshot.sh region
bind = $SUPER CTRL, P, exec, ~/dotfiles/scripts/screenshot.sh output
```

**Step 2: Commit**

```bash
git add hypr/.config/hypr/hyprland.conf
git commit -m "feat(hypr): use screenshot wrapper for project-aware screenshots"
```

---

### Task 4: Add `pshot` to PATH

**Files:**
- Modify: `zsh/.zshrc`

**Step 1: Add scripts dir to PATH**

Add after the existing PATH exports (around line 132):
```bash
export PATH="$HOME/dotfiles/scripts:$PATH"
```

**Step 2: Commit**

```bash
git add zsh/.zshrc
git commit -m "feat(zsh): add dotfiles scripts to PATH"
```

---

### Task 5: Seed initial state

**Step 1: Create initial state files**

Run:
```bash
echo "notime" > ~/.config/screen-project
printf '%s\n' notime met dotfiles > ~/.config/screen-projects
```

**Step 2: Test the full flow**

Run: `~/dotfiles/scripts/pshot notime`
Expected: "Screenshot project set to: notime"

Run: `~/dotfiles/scripts/pshot met`
Expected: "Screenshot project set to: met" and met is now at top of history

Run: `cat ~/.config/screen-project`
Expected: `met`

Run: `cat ~/.config/screen-projects`
Expected: met at top, then notime, then dotfiles
