#!/usr/bin/env bash
# Refresh wallpaper + bar and force a re-render after a monitor-layout change.
#
# kanshi's `undocked` profiles call this so undocking does the same housekeeping
# docking already does. Without it, after an undock eDP-1 comes up with
# hyprpaper's default wallpaper, no waybar, and the desktop drawn at a stale
# offset -- the state that previously needed a manual SUPER+SHIFT+P repaint.

# 1. Regenerate hyprpaper.conf for the current monitors, then restart hyprpaper.
~/dotfiles/scripts/update-hyprpaper-monitors.sh >/dev/null 2>&1
killall hyprpaper 2>/dev/null
hyprpaper >/dev/null 2>&1 &

# 2. Restart waybar so it re-enumerates the current outputs.
killall waybar 2>/dev/null
sleep 0.3
waybar >/dev/null 2>&1 &

# 3. Force the compositor to re-render -- the programmatic equivalent of the
#    SUPER+SHIFT+P repaint, which corrects any stale post-reposition offset.
hyprctl dispatch forcerendererreload >/dev/null 2>&1
