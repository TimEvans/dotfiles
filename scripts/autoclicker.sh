#!/bin/bash

# Auto-clicker toggle script
# Uses ydotool to spam left mouse clicks

PIDFILE="/tmp/autoclicker.pid"

# Check if already running
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        # Kill the existing autoclicker
        kill "$PID"
        rm "$PIDFILE"
        notify-send "Auto-clicker" "Stopped" -t 1000
        exit 0
    else
        # Stale PID file, remove it
        rm "$PIDFILE"
    fi
fi

# Ensure ydotoold is running
if ! pgrep -x ydotoold > /dev/null; then
    ydotoold &
    sleep 0.5  # Give daemon time to start
fi

# Start autoclicker in background
(
    while true; do
        ydotool click 0xC0  # Left mouse button click
        sleep 0.01  # 100 clicks per second
    done
) &

# Save the background process PID
echo $! > "$PIDFILE"
notify-send "Auto-clicker" "Started" -t 1000

