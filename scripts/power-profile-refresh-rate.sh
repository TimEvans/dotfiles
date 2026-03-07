#!/bin/bash
# Automatically adjust display refresh rate based on power profile
# Power-saver: 60Hz, Balanced/Performance: 120Hz

MONITOR="eDP-1"
LOW_REFRESH="60.00"
HIGH_REFRESH="120.00"
RESOLUTION="2880x1800"

get_current_profile() {
    cat /sys/firmware/acpi/platform_profile 2>/dev/null
}

apply_profile() {
    local profile=$1
    case "$profile" in
        "low-power")
            echo "Switching to 60Hz (power-saver mode)"
            kanshictl switch undocked-powersave
            ;;
        "balanced"|"performance")
            echo "Switching to 120Hz ($profile mode)"
            kanshictl switch undocked
            ;;
    esac
}

# Apply current profile immediately on start
current_profile=$(get_current_profile)
apply_profile "$current_profile"

# Monitor power profile changes
previous_profile="$current_profile"

while true; do
    current_profile=$(get_current_profile)

    if [[ "$current_profile" != "$previous_profile" ]]; then
        apply_profile "$current_profile"
        previous_profile="$current_profile"
    fi

    sleep 2
done
