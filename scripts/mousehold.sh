#!/bin/bash

# Mouse hold toggle script
# Holds down left mouse button

PIDFILE="/tmp/mousehold.pid"

# Check if already running
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        # Release the mouse button and kill the process
        ydotool click 0x80  # 0x80 = mouse up
        kill "$PID"
        rm "$PIDFILE"
        notify-send "Mouse Hold" "Released" -t 1000
        exit 0
    else
        # Stale PID file, remove it
        rm "$PIDFILE"
    fi
fi

# Ensure ydotoold is running
if ! pgrep -x ydotoold > /dev/null; then
    ydotoold &
    sleep 0.5
fi

# Wait for daemon to be ready and give user time to position cursor
sleep 0.5

# Hold mouse button down (0x40 = mouse down for left button)
ydotool click 0x40

# Keep process alive to track state
(
    while true; do
        sleep 1
    done
) &

# Save the background process PID
echo $! > "$PIDFILE"
notify-send "Mouse Hold" "Active" -t 1000
