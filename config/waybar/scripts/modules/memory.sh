#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/memory-panel.sh"
        ;;
    right)
        run_if_available_terminal "htop is not installed" htop
        ;;
    middle)
        launch_terminal bash -lc 'printf "TOP MEMORY PROCESSES\\n\\n"; ps -eo pid,ppid,comm,%mem,%cpu --sort=-%mem | head -n 6; printf "\\nPress Enter to close."; read -r'
        ;;
    *)
        notify_info "Unknown memory action: $action"
        exit 64
        ;;
esac
