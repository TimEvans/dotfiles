#!/usr/bin/env bash
# Trampoline: the status-line segment ships with the timekeeper plugin
# (cc-plugins/plugins/timekeeper/bin/focus-info.sh). The plugin's SessionStart
# bootstrap publishes its root to ~/.cache/timekeeper/plugin-root; until a
# session with that plugin has started, render the unbound card.
root=$(cat "$HOME/.cache/timekeeper/plugin-root" 2>/dev/null)
if [ -n "$root" ] && [ -x "$root/bin/focus-info.sh" ]; then
  exec "$root/bin/focus-info.sh" "$@"
fi
case "${1:-}" in
  label) echo "What are we working on?" ;;
  check | nofocus) exit 1 ;;
esac
exit 0
