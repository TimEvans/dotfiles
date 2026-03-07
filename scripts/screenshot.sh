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
