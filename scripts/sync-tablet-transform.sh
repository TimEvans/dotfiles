#!/usr/bin/env bash
# Match the built-in pen/touchscreen input rotation to eDP-1's current rotation.
#
# Hyprland applies a monitor's `transform` to the OUTPUT only. Tablet and touch
# input rotation is an independent libinput calibration matrix that never reads
# the monitor transform, so rotating eDP-1 leaves the digitizer mapped to the
# old axes and the cursor lands 90 degrees away from the pen tip.
#
# Reading the transform back from the compositor (rather than hardcoding it per
# kanshi profile) means this stays correct for any rotation, including ones set
# by hand via hyprctl.
#
# Note: `hyprctl keyword` is runtime-only. A `hyprctl reload` resets these to the
# config defaults (0), so re-run this afterwards while rotated -- kanshi does it
# automatically on the next profile switch.
set -u

transform=$(hyprctl monitors all -j 2>/dev/null \
  | jq -r '.[] | select(.name=="eDP-1") | .transform')

if [ -z "$transform" ] || [ "$transform" = "null" ]; then
  echo "sync-tablet-transform: eDP-1 not present, leaving input transform alone" >&2
  exit 0
fi

for device in wacom-hid-53b7-pen wacom-hid-53b7-finger; do
  hyprctl keyword "device[$device]:transform" "$transform" >/dev/null
done
