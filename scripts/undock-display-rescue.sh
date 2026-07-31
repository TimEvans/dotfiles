#!/usr/bin/env bash
# Force the laptop panel (eDP-1) on after the dock is unplugged, with retries,
# and log exactly what happens so we can see WHY it does/doesn't come up.
#
# Bound to SUPER+SHIFT+F. Because it writes a timestamped rescue-*.log the moment
# it runs, the mere existence of that file tells us the keybind fired at all
# (settling the "did SUPER register?" question with evidence, not theory).
# First arg is just a label for the log.
#
# Each attempt rotates a different lever and records eDP-1's state after it, so
# the log tells us which lever (if any) actually lights the panel.
set -u

caller="${1:-unknown}"
logdir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-crashlog"
mkdir -p "$logdir"
log="$logdir/rescue-$(date +%Y%m%d-%H%M%S).log"

say()    { echo "[$(date +%H:%M:%S.%3N)] $*" >> "$log"; }
state()  { hyprctl monitors all -j 2>>"$log" | jq -rc '[.[]|{name,disabled,dpms:.dpmsStatus}]' 2>>"$log"; }
edp_on() { [ "$(hyprctl monitors all -j 2>/dev/null | jq -r '.[]|select(.name=="eDP-1")|.disabled')" = "false" ]; }

say "=== rescue invoked (trigger: $caller) ==="
say "monitors before: $(state)"

# Levers to try, in order. Each is logged with the resulting eDP-1 state.
levers=(
  'hyprctl keyword monitor "eDP-1,preferred,auto,1.5"'
  'kanshictl reload'
  'hyprctl dispatch dpms on'
  'hyprctl keyword monitor "eDP-1,preferred,auto,1.5"'
)

for i in "${!levers[@]}"; do
  if edp_on; then say "eDP-1 already ON -- stopping"; break; fi
  lever="${levers[$i]}"
  say "attempt $((i+1)): $lever"
  eval "$lever" >>"$log" 2>&1
  sleep 1
  say "  -> after: $(state)"
done

if edp_on; then
  say "RESULT: eDP-1 ENABLED (trigger: $caller)"
else
  say "RESULT: eDP-1 STILL DISABLED after all levers (trigger: $caller)"
  say "tail of compositor log for context:"
  newest_session=$(ls -t "$logdir"/session-*.log 2>/dev/null | head -1)
  [ -n "$newest_session" ] && tail -n 25 "$newest_session" 2>/dev/null | sed 's/^/    /' >> "$log"
fi
