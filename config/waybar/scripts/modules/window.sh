#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

action="${1:-left}"

case "$action" in
    left|kill)
        launch_terminal "$module_dir/window-panel.sh"
        ;;
    *)
        notify_info "Unknown window action: $action"
        exit 64
        ;;
esac
