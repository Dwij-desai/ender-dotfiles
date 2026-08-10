#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

toggle_mic_mute() {
    if have_cmd wpctl; then
        wpctl set-mute @DEFAULT_SOURCE@ toggle
        return 0
    fi

    if have_cmd pactl; then
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        return 0
    fi

    return 1
}

switch_output() {
    if have_cmd wpctl; then
        current_id="$(wpctl status | awk '/Sinks:/,/Sources:/ { if ($0 ~ /\*/ && $1 ~ /[0-9]+\./) { gsub("\\.", "", $1); print $1; exit } }')"
        mapfile -t sink_ids < <(wpctl status | awk '/Sinks:/,/Sources:/ { if ($1 ~ /[0-9]+\./) { gsub("\\.", "", $1); print $1 } }')

        if ((${#sink_ids[@]} < 2)); then
            notify_info "No alternate output sink available"
            return 0
        fi

        for sink_id in "${sink_ids[@]}"; do
            if [[ "$sink_id" != "$current_id" ]]; then
                wpctl set-default "$sink_id" >/dev/null 2>&1 && notify_info "Switched output sink"
                return 0
            fi
        done
    elif have_cmd pactl; then
        mapfile -t sinks < <(pactl list short sinks | awk '{ print $1 }')
        current_name="$(pactl get-default-sink 2>/dev/null || printf '')"
        current_id="$(pactl list short sinks | awk -v name="$current_name" '$2 == name { print $1; exit }')"

        if ((${#sinks[@]} < 2)); then
            notify_info "No alternate output sink available"
            return 0
        fi

        for sink_id in "${sinks[@]}"; do
            if [[ "$sink_id" != "$current_id" ]]; then
                sink_name="$(pactl list short sinks | awk -v sid="$sink_id" '$1 == sid { print $2; exit }')"
                pactl set-default-sink "$sink_name" >/dev/null 2>&1 && notify_info "Switched output sink"
                return 0
            fi
        done
    else
        notify_info "No supported audio control tool found"
        return 1
    fi

    notify_info "Unable to switch output sink"
    return 1
}

action="${1:-left}"

case "$action" in
    left)
        launch_terminal "$module_dir/audio-panel.sh"
        ;;
    right)
        switch_output
        ;;
    middle)
        if toggle_mic_mute; then
            notify_info "Toggled microphone mute"
        else
            notify_info "No supported microphone control tool found"
            exit 1
        fi
        ;;
    *)
        notify_info "Unknown audio action: $action"
        exit 64
        ;;
esac
