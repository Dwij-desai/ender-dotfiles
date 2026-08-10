#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

summary="$(free -m | awk 'NR==2 { printf "RAM %s/%sMB", $3, $2 } NR==3 { printf " | Swap %s/%sMB", $3, $2 }')"
cached="$(awk '/^Cached:/ { printf "%.0fMB", $2/1024 }' /proc/meminfo 2>/dev/null)"
buffers="$(awk '/^Buffers:/ { printf "%.0fMB", $2/1024 }' /proc/meminfo 2>/dev/null)"
top_proc="$(ps -eo comm,%mem --sort=-%mem 2>/dev/null | sed -n '2p' | awk '{ print $1 " (" $2 "%)" }')"

print_panel_header "MEMORY"
printf 'Summary: %s\n' "${summary:-Unavailable}"
printf 'Cached: %s\n' "${cached:-Unavailable}"
printf 'Buffers: %s\n' "${buffers:-Unavailable}"
printf 'Top Process: %s\n' "${top_proc:-Unavailable}"

printf '\n[1] Open btop\n[2] Open htop\n[3] Show top memory processes\n[4] Copy report\n[Enter] Close\n'
printf 'Select action: '
read -r choice

report="MEMORY ${summary:-NA} cached=${cached:-NA} buffers=${buffers:-NA} top=${top_proc:-NA}"

case "$choice" in
    1)
        if have_cmd btop; then btop; else printf 'btop is not installed\n'; pause_panel; fi
        ;;
    2)
        if have_cmd htop; then htop; else printf 'htop is not installed\n'; pause_panel; fi
        ;;
    3)
        ps -eo pid,ppid,comm,%mem,%cpu --sort=-%mem | head -n 11
        pause_panel
        ;;
    4)
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
