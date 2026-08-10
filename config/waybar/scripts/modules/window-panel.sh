#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

print_panel_header "WINDOW"

if ! have_cmd hyprctl; then
    printf 'hyprctl is not available\n'
    pause_panel
    exit 1
fi

details="$(hyprctl activewindow 2>/dev/null || true)"
if [[ -z "$details" ]]; then
    printf 'No active window\n'
    pause_panel
    exit 0
fi

class="$(printf '%s\n' "$details" | awk -F': ' '/class:/ { print $2; exit }')"
title="$(printf '%s\n' "$details" | awk -F': ' '/title:/ { print $2; exit }')"
pid="$(printf '%s\n' "$details" | awk -F': ' '/pid:/ { print $2; exit }')"
workspace="$(printf '%s\n' "$details" | awk -F': ' '/workspace:/ { print $2; exit }')"

printf 'Class: %s\n' "${class:-Unavailable}"
printf 'Title: %s\n' "${title:-Unavailable}"
printf 'PID: %s\n' "${pid:-Unavailable}"
printf 'Workspace: %s\n' "${workspace:-Unavailable}"

printf '\n[1] Kill application\n[2] Copy report\n[Enter] Close\n'
printf 'Select action: '
read -r choice

report="WINDOW class=${class:-NA} title=${title:-NA} pid=${pid:-NA} workspace=${workspace:-NA}"

case "$choice" in
    1)
        printf 'Confirm kill? [y/N]: '
        read -r reply
        case "$reply" in
            y|Y)
                if [[ -n "$pid" ]] && kill "$pid" 2>/dev/null; then
                    printf 'Application terminated\n'
                else
                    printf 'Failed to terminate application\n'
                fi
                ;;
            *)
                printf 'Cancelled\n'
                ;;
        esac
        pause_panel
        ;;
    2)
        if copy_to_clipboard "$report"; then
            printf 'Report copied\n'
        else
            printf 'Clipboard tool unavailable\n'
        fi
        pause_panel
        ;;
    *)
        ;;
esac
