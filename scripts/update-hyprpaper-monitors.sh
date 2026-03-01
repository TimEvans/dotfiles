#!/usr/bin/env bash
# Updates hyprpaper.conf by converting monitor descriptions to current monitor names
# This is needed because hyprpaper 0.8.x no longer supports desc: syntax

TEMPLATE="$HOME/.config/hypr/hyprpaper.conf.template"
CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Check if template exists, if not create it from current config
if [[ ! -f "$TEMPLATE" ]]; then
    if [[ -f "$CONFIG" ]]; then
        cp "$CONFIG" "$TEMPLATE"
        echo "Created template from existing config: $TEMPLATE"
    else
        echo "Error: No template or config file found"
        exit 1
    fi
fi

# Get monitor information as JSON
monitors=$(hyprctl monitors -j)

# Start with the template content
output=$(cat "$TEMPLATE")

# Extract all unique descriptions from the template (works with both old and new syntax)
descriptions=$(grep -oP 'desc:\K.+' "$TEMPLATE" | sed 's/[, ]*$//' | sort -u)

# For each description, find the corresponding monitor name and replace
while IFS= read -r desc; do
    [[ -z "$desc" ]] && continue

    # Find the monitor name for this description
    monitor_name=$(echo "$monitors" | jq -r --arg desc "$desc" '.[] | select(.description == $desc) | .name')

    if [[ -n "$monitor_name" ]]; then
        # Replace desc:description with monitor_name in output
        output=$(echo "$output" | sed "s|desc:$desc|$monitor_name|g")
        echo "Mapped: '$desc' -> '$monitor_name'"
    else
        echo "Warning: No monitor found for description: '$desc'"
    fi
done <<< "$descriptions"

# Write the updated config
echo "$output" > "$CONFIG"
echo "Updated: $CONFIG"
