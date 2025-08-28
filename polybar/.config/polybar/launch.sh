#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Map monitor descriptions to current connector names
LEFT_MONITOR=$(hyprctl monitors | grep -B5 "0x31434635" | grep "Monitor" | awk '{print $2}')
RIGHT_MONITOR=$(hyprctl monitors | grep -B5 "U733018L" | grep "Monitor" | awk '{print $2}')

echo "Detected monitors: Left=$LEFT_MONITOR, Right=$RIGHT_MONITOR"

# Update config with current monitor names
sed -i "s/^monitor = Lenovo Group Limited LEN D27-20B 0x31434635$/monitor = $LEFT_MONITOR/" ~/.config/polybar/config.ini
sed -i "s/^monitor = Lenovo Group Limited LEN D27-20B U733018L$/monitor = $RIGHT_MONITOR/" ~/.config/polybar/config.ini

# Launch left and right bars
echo "---" | tee -a /tmp/polybar-left.log /tmp/polybar-right.log
polybar -c ~/.config/polybar/config.ini left 2>&1 | tee -a /tmp/polybar-left.log & disown
polybar -c ~/.config/polybar/config.ini right 2>&1 | tee -a /tmp/polybar-right.log & disown

echo "Polybar bars launched..."
