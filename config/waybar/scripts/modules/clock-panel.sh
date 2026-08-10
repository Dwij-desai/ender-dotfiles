#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

boot_time="$(uptime -s 2>/dev/null || printf 'Unavailable')"
uptime_info="$(uptime -p 2>/dev/null || printf 'Unavailable')"

print_panel_header "CLOCK"
printf 'Local time: %s\n' "$(date +"%Y-%m-%d %H:%M:%S %Z")"
printf 'UTC time: %s\n' "$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
printf 'ISO timestamp: %s\n' "$(date +"%Y-%m-%dT%H:%M:%S%z")"
printf 'Week number: %s\n' "$(date +"%V")"
printf 'Boot time: %s\n' "$boot_time"
printf 'Uptime: %s\n' "$uptime_info"

printf '\n[1] Show calendar\n[2] Copy timestamp\n[3] Toggle UTC mode\n[Enter] Close\n'
printf 'Select action: '
read -r choice

case "$choice" in
    1)
        cal -3
        pause_panel
        ;;
    2)
        "$module_dir/clock.sh" right
        pause_panel
        ;;
    3)
        "$module_dir/clock.sh" middle
        pause_panel
        ;;
    *)
        ;;
esac
