#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/cpu-panel.sh"
        ;;
    right)
        run_if_available_terminal "htop is not installed" htop
        ;;
    middle)
        launch_terminal bash -lc 'printf "TOP CPU PROCESSES\\n\\n"; ps -eo pid,ppid,comm,%cpu,%mem --sort=-%cpu | head -n 6; printf "\\nPress Enter to close."; read -r'
        ;;
    *)
        notify_info "Unknown CPU action: $action"
        exit 64
        ;;
esac
