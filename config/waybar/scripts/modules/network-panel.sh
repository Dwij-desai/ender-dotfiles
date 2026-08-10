#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

get_public_ip() {
    if have_cmd curl; then
        curl --fail --silent --show-error --max-time 4 https://api.ipify.org 2>/dev/null || printf 'Unavailable'
    else
        printf 'Unavailable'
    fi
}

iface="$(active_interface)"

print_panel_header "NETWORK"

if [[ -z "$iface" ]]; then
    printf 'Status: Disconnected\n'
    pause_panel
    exit 0
fi

type="Unknown"
ssid="Unavailable"
signal="Unavailable"
gateway="$(ip route show default dev "$iface" 2>/dev/null | awk '/default/ { print $3; exit }')"
local_ip="$(local_ip_for_interface "$iface")"
dns='Unavailable'
vpn='Inactive'

if have_cmd nmcli; then
    type="$(nmcli -g GENERAL.TYPE device show "$iface" 2>/dev/null | head -n 1)"
    dns="$(nmcli -g IP4.DNS device show "$iface" 2>/dev/null | paste -sd ', ' -)"
    if [[ "$type" == "wifi" ]]; then
        ssid="$(nmcli -t -f IN-USE,SSID device wifi list ifname "$iface" 2>/dev/null | awk -F: '$1 == "*" { print substr($0, 3); exit }')"
        signal="$(nmcli -t -f IN-USE,SIGNAL device wifi list ifname "$iface" 2>/dev/null | awk -F: '$1 == "*" { print $2; exit }')"
    else
        signal='Wired'
        ssid='Ethernet'
    fi

    if nmcli -t -f TYPE,STATE connection show --active 2>/dev/null | grep -q '^vpn:activated'; then
        vpn='Active'
    fi
fi

printf 'Interface: %s\n' "${iface:-Unavailable}"
printf 'Type: %s\n' "${type:-Unavailable}"
printf 'SSID: %s\n' "${ssid:-Unavailable}"
printf 'Signal: %s\n' "${signal:-Unavailable}"
printf 'Local IP: %s\n' "${local_ip:-Unavailable}"
printf 'Gateway: %s\n' "${gateway:-Unavailable}"
printf 'DNS: %s\n' "${dns:-Unavailable}"
printf 'VPN: %s\n' "$vpn"
printf 'Public IP: %s\n' "$(get_public_ip)"

printf '\n[1] Open nmtui\n[2] Copy local IP\n[3] Show routes\n[Enter] Close\n'
printf 'Select action: '
read -r choice

case "$choice" in
    1)
        if have_cmd nmtui; then
            nmtui
        else
            printf 'nmtui is not installed\n'
            pause_panel
        fi
        ;;
    2)
        if copy_to_clipboard "${local_ip:-}"; then
            printf 'Copied local IP\n'
        else
            printf 'Clipboard tool unavailable\n'
        fi
        pause_panel
        ;;
    3)
        ip route show
        pause_panel
        ;;
    *)
        ;;
esac
