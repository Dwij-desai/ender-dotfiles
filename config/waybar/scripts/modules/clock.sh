#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

state_dir="${XDG_RUNTIME_DIR:-/tmp}/enderos-waybar"
state_file="$state_dir/clock-utc-mode"

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/clock-panel.sh"
        ;;
    right)
        timestamp="$(date +"%Y-%m-%dT%H:%M:%S%z")"
        if copy_to_clipboard "$timestamp"; then
            notify_info "Copied timestamp: $timestamp"
        else
            notify_info "No clipboard tool found (wl-copy/xclip/xsel)"
            exit 1
        fi
        ;;
    middle)
        mkdir -p "$state_dir"
        if [[ -f "$state_file" ]]; then
            rm -f "$state_file"
            notify_info "Clock UTC mode: off"
        else
            printf '1\n' >"$state_file"
            notify_info "Clock UTC mode: on"
        fi
        ;;
    *)
        notify_info "Unknown clock action: $action"
        exit 64
        ;;
esac
