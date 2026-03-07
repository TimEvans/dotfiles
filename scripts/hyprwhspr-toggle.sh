#!/bin/bash
# Simple toggle for hyprwhspr using the FIFO control file
CONTROL_FILE="$HOME/.config/hyprwhspr/recording_control"
STATE_FILE="/tmp/hyprwhspr-toggle-state"

if [[ -f "$STATE_FILE" ]]; then
    echo "stop" > "$CONTROL_FILE"
    rm -f "$STATE_FILE"
else
    echo "start" > "$CONTROL_FILE"
    touch "$STATE_FILE"
fi
