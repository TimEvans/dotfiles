#!/usr/bin/env bash
# Gracefully switch to the laptop panel BEFORE physically unplugging the dock.
#
# kanshi owns display configuration here and re-applies its active profile the
# instant any output changes, so driving monitors directly with `hyprctl keyword
# monitor` does not stick -- kanshi reverts it. Instead we ask kanshi itself to
# switch to the `undocked` profile, which enables eDP-1 and disables the dock
# outputs while everything is still connected and stable. The later physical
# unplug then has nothing live to tear down (which is what crashes/hangs
# Hyprland 0.55.4 on a surprise removal).
#
# Self-verifying: it only says "safe to unplug" once eDP-1 is actually lit. If
# the panel does not come up it switches back to `docked` so you are never left
# staring at a black screen.
#
# Run this, wait for the "safe to unplug" toast, THEN unplug.
set -u

INTERNAL="eDP-1"
PROFILE_UNDOCKED="undocked"
PROFILE_DOCKED="docked"

edp_enabled() {
    [ "$(hyprctl monitors all -j | jq -r --arg i "$INTERNAL" \
        '.[] | select(.name==$i) | .disabled')" = "false" ]
}

# Ask kanshi to bring the laptop panel up and drop the dock outputs.
kanshictl switch "$PROFILE_UNDOCKED" >/dev/null 2>&1

# Wait up to ~5s for eDP-1 to actually come up.
for _ in $(seq 1 25); do
    edp_enabled && break
    sleep 0.2
done

if edp_enabled; then
    hyprctl notify 1 4000 0 "Dock released - safe to unplug" 2>/dev/null || true
else
    # Panel never lit -- restore the docked layout rather than risk a black screen.
    kanshictl switch "$PROFILE_DOCKED" >/dev/null 2>&1
    hyprctl notify 3 6000 0 "UNDOCK FAILED - laptop panel did not come up. Do NOT unplug." \
        2>/dev/null || true
fi
