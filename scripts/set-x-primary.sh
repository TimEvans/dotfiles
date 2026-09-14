#!/usr/bin/env bash
# Mark the landscape Lenovo as the Xwayland primary output after docking.
#
# Wine sizes exclusive-fullscreen games to whatever X calls the primary monitor.
# Xwayland never sets one, so Wine falls back to the first output in its list,
# which while docked is the laptop panel rotated to portrait. Games then build
# their mouse hit-test map for a 1500x2400 screen while drawing 1920x1080 on the
# Lenovo, and clicks land nowhere near the cursor. Xwayland also drops the
# primary flag whenever outputs change, so this has to run on every dock, not
# once at startup.
#
# The monitor is matched by its EDID serial rather than connector name because
# DP-N numbering can shift between docks.

landscape_lenovo_serial="0x31434635"

# Xwayland can lag the compositor by a moment when outputs change, so retry
# briefly instead of assuming the output already exists on the X side.
for _ in $(seq 1 20); do
    output_name=$(hyprctl monitors -j 2>/dev/null \
        | jq -r --arg serial "$landscape_lenovo_serial" \
            '.[] | select(.description | contains($serial)) | .name')

    if [ -n "$output_name" ] \
        && DISPLAY="${DISPLAY:-:0}" xrandr --output "$output_name" --primary 2>/dev/null; then
        exit 0
    fi
    sleep 0.5
done

echo "set-x-primary: landscape Lenovo not found in Xwayland outputs" >&2
exit 1
