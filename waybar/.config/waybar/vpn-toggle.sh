#!/bin/bash
# Toggle ProtonVPN connection

is_connected() {
    ip link show ipv6leakintrf0 &>/dev/null && return 0
    ip link show proton0 &>/dev/null && return 0
    ip link show type wireguard 2>/dev/null | grep -q proton && return 0
    return 1
}

if is_connected; then
    protonvpn disconnect
else
    protonvpn connect --random
fi
