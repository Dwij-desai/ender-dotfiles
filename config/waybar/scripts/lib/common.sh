#!/usr/bin/env bash

set -u

lib_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
scripts_dir="$(cd -- "$lib_dir/.." && pwd)"

log_info() {
    printf '%s\n' "$1"
}

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

notify_info() {
    local message="$1"
    if have_cmd notify-send; then
        notify-send "EnderOS" "$message"
    else
        log_info "$message"
    fi
}

launch_terminal() {
    "$scripts_dir/launch-terminal.sh" "$@"
}

copy_to_clipboard() {
    local value="$1"

    if have_cmd wl-copy; then
        printf '%s' "$value" | wl-copy
        return 0
    fi

    if have_cmd xclip; then
        printf '%s' "$value" | xclip -selection clipboard
        return 0
    fi

    if have_cmd xsel; then
        printf '%s' "$value" | xsel --clipboard --input
        return 0
    fi

    return 1
}

active_interface() {
    ip -4 route show default 2>/dev/null | awk '/default/ { print $5; exit }'
}

local_ip_for_interface() {
    local interface="$1"
    ip -4 -o addr show dev "$interface" scope global 2>/dev/null | awk 'NR == 1 { sub(/\/.*/, "", $4); print $4 }'
}

run_if_available_terminal() {
    local missing_message="$1"
    shift

    if have_cmd "$1"; then
        launch_terminal "$@"
    else
        notify_info "$missing_message"
    fi
}

print_panel_header() {
    local title="$1"
    printf '%s\n' "EnderOS Console"
    printf '%s\n' "------------------------------"
    printf '%s\n\n' "$title"
}

pause_panel() {
    printf '\nPress Enter to close.'
    read -r
}
