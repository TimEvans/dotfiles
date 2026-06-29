#!/usr/bin/env bash
# Mirror the ephemeral Hyprland session log to persistent storage.
#
# Hyprland writes its log to $XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log,
# which lives on tmpfs and is wiped on every reboot. When the compositor
# hard-hangs on dock-unplug (black screen, force power-off), that log -- and
# the aquamarine DRM teardown lines it contains -- vanishes before we can read
# it. The kernel side already survives via persistent journald; this fills the
# remaining gap by streaming the userspace log to ~/.local/state and fsyncing
# it periodically, so a freeze loses at most a couple of seconds of trace.
#
# Started from hyprland.conf (exec-once). Safe to run standalone too.
set -u

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-crashlog"
src="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/hyprland.log"
dest="$state_dir/session-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$state_dir"

# Keep only the 10 most recent session mirrors.
ls -1t "$state_dir"/session-*.log 2>/dev/null | tail -n +11 | xargs -r rm -f

# Wait up to ~10s for the session log to appear.
for _ in $(seq 1 50); do
    [ -e "$src" ] && break
    sleep 0.2
done
[ -e "$src" ] || { echo "persist-hypr-log: source log never appeared: $src" >&2; exit 1; }

# Flush this file's dirty pages to disk every 2s so a freeze loses minimal tail.
# sync with a file argument only flushes that file -- cheap, unlike a global sync.
( while :; do sync "$dest" 2>/dev/null; sleep 2; done ) &
syncer=$!
trap 'kill "$syncer" 2>/dev/null' EXIT INT TERM

# Stream the full log (line-buffered) into the persistent mirror, following
# rotation. -n +1 includes everything already written this session.
exec stdbuf -oL tail -n +1 -F "$src" >> "$dest"
