#!/usr/bin/env bash

set -u

get_default_interface() {
    ip -4 route show default 2>/dev/null | awk '/default/ { print $5; exit }'
}

format_rate() {
    awk -v bytes="$1" 'BEGIN {
        rate = bytes / 1000000
        printf "%.1f MB/s", rate
    }'
}

interface="$(get_default_interface)"

if [[ -z "$interface" ]]; then
    printf 'NETWORK\n\nSTATUS\nDisconnected\n'
    exit 0
fi

connection_type="$(nmcli -g GENERAL.TYPE device show "$interface" 2>/dev/null | head -n 1)"

if [[ "$connection_type" == "wifi" ]]; then
    ssid="$(nmcli -t -f IN-USE,SSID device wifi list ifname "$interface" 2>/dev/null | awk -F: '$1 == "*" { print substr($0, 3); exit }')"
else
    ssid="Ethernet"
fi

local_ip="$(ip -4 -o addr show dev "$interface" scope global 2>/dev/null | awk 'NR == 1 { sub(/\/.*/, "", $4); print $4 }')"
gateway="$(ip route show default dev "$interface" 2>/dev/null | awk '/default/ { print $3; exit }')"
dns="$(nmcli -g IP4.DNS device show "$interface" 2>/dev/null | paste -sd ', ' -)"
public_ip="$(curl --fail --silent --show-error --max-time 4 https://api.ipify.org 2>/dev/null || printf 'Unavailable')"

rx_path="/sys/class/net/$interface/statistics/rx_bytes"
tx_path="/sys/class/net/$interface/statistics/tx_bytes"

download_rate='Unavailable'
upload_rate='Unavailable'

if [[ -r "$rx_path" && -r "$tx_path" ]]; then
    rx_start="$(<"$rx_path")"
    tx_start="$(<"$tx_path")"
    sleep 1
    rx_end="$(<"$rx_path")"
    tx_end="$(<"$tx_path")"
    download_rate="$(format_rate "$((rx_end - rx_start))")"
    upload_rate="$(format_rate "$((tx_end - tx_start))")"
fi

clear
printf '%s\n\n' 'NETWORK'
printf '%-12s %s\n' 'SSID' "${ssid:-Unavailable}"
printf '%-12s %s\n' 'LOCAL IP' "${local_ip:-Unavailable}"
printf '%-12s %s\n' 'PUBLIC IP' "$public_ip"
printf '%-12s %s\n' 'DOWNLOAD' "$download_rate"
printf '%-12s %s\n' 'UPLOAD' "$upload_rate"
printf '%-12s %s\n' 'GATEWAY' "${gateway:-Unavailable}"
printf '%-12s %s\n' 'DNS' "${dns:-Unavailable}"

if [[ -t 0 ]]; then
    printf '\nPress Enter to close.'
    read -r
fi
