#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/battery-panel.sh" summary
        ;;
    right)
        launch_terminal "$module_dir/battery-panel.sh" diagnostics
        ;;
    middle)
        launch_terminal "$module_dir/battery-panel.sh" configure
        ;;
    *)
        notify_info "Unknown battery action: $action"
        exit 64
        ;;
esac
