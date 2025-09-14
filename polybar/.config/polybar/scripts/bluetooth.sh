#!/bin/bash

get_icon() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        echo "󰂯"
    else
        echo "󰂲"
    fi
}

get_status() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        # Check if any device is connected
        if bluetoothctl info | grep -q "Connected: yes"; then
            echo "Connected"
        else
            echo "On"
        fi
    else
        echo "Off"
    fi
}

toggle_bluetooth() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
}

case "$1" in
    --toggle)
        toggle_bluetooth
        ;;
    *)
        icon=$(get_icon)
        status=$(get_status)
        echo "$icon $status"
        ;;
esac