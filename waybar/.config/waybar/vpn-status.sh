#!/bin/bash
# Waybar custom module script for ProtonVPN status
# Outputs JSON for waybar's return-type: json

is_connected() {
    ip link show ipv6leakintrf0 &>/dev/null && return 0
    ip link show proton0 &>/dev/null && return 0
    ip link show type wireguard 2>/dev/null | grep -q proton && return 0
    return 1
}

if is_connected; then
    tooltip="ProtonVPN: Connected\nClick to disconnect"
    echo "{\"text\": \"connected\", \"tooltip\": \"${tooltip}\", \"class\": \"connected\", \"alt\": \"connected\"}"
else
    tooltip="ProtonVPN: Disconnected\nClick to connect"
    echo "{\"text\": \"disconnected\", \"tooltip\": \"${tooltip}\", \"class\": \"disconnected\", \"alt\": \"disconnected\"}"
fi
