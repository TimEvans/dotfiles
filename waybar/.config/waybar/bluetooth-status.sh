#!/usr/bin/env bash
# Waybar custom bluetooth module - shows icons per connected device

get_property() {
    busctl get-property org.bluez "$1" org.bluez.Device1 "$2" 2>/dev/null | sed 's/^[a-z] "//;s/"$//'
}

# Check if bluetooth controller exists
if ! busctl tree org.bluez 2>/dev/null | grep -q "hci0"; then
    echo '{"text": "", "tooltip": "No bluetooth controller", "class": "no-controller"}'
    exit 0
fi

# Check if powered
powered=$(busctl get-property org.bluez /org/bluez/hci0 org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}')
if [[ "$powered" != "true" ]]; then
    echo '{"text": "󰂲", "tooltip": "Bluetooth off", "class": "off"}'
    exit 0
fi

bt_icon="󰂯"

# Find connected devices via D-Bus
icons=""
tooltip_lines=""

while IFS= read -r dev_path; do
    connected=$(busctl get-property org.bluez "$dev_path" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
    [[ "$connected" != "true" ]] && continue

    name=$(get_property "$dev_path" Alias)
    icon_type=$(get_property "$dev_path" Icon)
    name_lower="${name,,}"

    # Get battery if available
    battery=""
    battery_pct=$(busctl get-property org.bluez "$dev_path" org.bluez.Battery1 Percentage 2>/dev/null | awk '{print $2}')
    if [[ -n "$battery_pct" && "$battery_pct" != *"No such"* ]]; then
        battery=" ${battery_pct}%"
    fi

    # Determine icon - known devices first, then generic type
    icon=""
    if [[ "$name_lower" == *"wh-1000xm4"* || "$name_lower" == *"1000xm4"* || "$name_lower" == *"sony"*"xm"* ]]; then
        icon="󰋋"  # nf-md-headphones (over-ear)
    elif [[ "$name_lower" == *"oneplus buds"* || "$name_lower" == *"beats"*"pro"* ]]; then
        icon="󱡏"  # nf-md-earbuds
    else
        case "$icon_type" in
            audio-headset|audio-headphones)
                icon="󰋋" ;;
            input-keyboard)
                icon="󰌌" ;;
            input-mouse)
                icon="󰍽" ;;
            input-gaming)
                icon="󰊗" ;;
            phone)
                icon="󰏲" ;;
            *)
                icon="󰂱" ;;
        esac
    fi

    icons+=" ${icon}"
    tooltip_lines+="${name}${battery}\n"
done < <(busctl tree org.bluez 2>/dev/null | grep -oP '/org/bluez/hci0/dev_[A-F0-9_]+$')

if [[ -z "$icons" ]]; then
    echo "{\"text\": \"${bt_icon}\", \"tooltip\": \"Bluetooth on, no devices\", \"class\": \"on\"}"
    exit 0
fi

icons="${icons# }"
tooltip_lines="${tooltip_lines%\\n}"
tooltip_lines="${tooltip_lines//\"/\\\"}"

echo "{\"text\": \"${bt_icon} ${icons}\", \"tooltip\": \"${tooltip_lines}\", \"class\": \"connected\"}"
