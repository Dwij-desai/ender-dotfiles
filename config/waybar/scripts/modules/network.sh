#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/network-panel.sh"
        ;;
    right)
        run_if_available_terminal "nmtui is not installed" nmtui
        ;;
    middle)
        iface="$(active_interface)"
        if [[ -z "$iface" ]]; then
            notify_info "Network disconnected"
            exit 0
        fi
        ip_addr="$(local_ip_for_interface "$iface")"
        if [[ -z "$ip_addr" ]]; then
            notify_info "No local IPv4 address found"
            exit 0
        fi
        if copy_to_clipboard "$ip_addr"; then
            notify_info "Copied local IP: $ip_addr"
        else
            notify_info "No clipboard tool found (wl-copy/xclip/xsel)"
            exit 1
        fi
        ;;
    *)
        notify_info "Unknown network action: $action"
        exit 64
        ;;
esac
