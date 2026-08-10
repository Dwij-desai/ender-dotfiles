#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

output='Unavailable'
input='Unavailable'
mic_level='Unavailable'

if have_cmd wpctl; then
    output="$(wpctl status | awk '/Sinks:/,/Sources:/ { if ($0 ~ /\*/ ) { sub(/^.*\*\s*/, "", $0); print; exit } }')"
    input="$(wpctl status | awk '/Sources:/,/Filters:/ { if ($0 ~ /\*/ ) { sub(/^.*\*\s*/, "", $0); print; exit } }')"
    mic_level="$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null | awk '{ printf "%.0f%%", $2 * 100 }')"
elif have_cmd pactl; then
    output="$(pactl get-default-sink 2>/dev/null || printf 'Unavailable')"
    input="$(pactl get-default-source 2>/dev/null || printf 'Unavailable')"
    mic_level="$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk -F/ 'NR==1 { gsub(/ /, "", $2); print $2; exit }')"
fi

print_panel_header "AUDIO"
printf 'Output device: %s\n' "${output:-Unavailable}"
printf 'Input device: %s\n' "${input:-Unavailable}"
printf 'Microphone level: %s\n' "${mic_level:-Unavailable}"

printf '\n[1] Open pavucontrol\n[2] Switch output\n[3] Toggle microphone mute\n[Enter] Close\n'
printf 'Select action: '
read -r choice

case "$choice" in
    1)
        if have_cmd pavucontrol; then
            pavucontrol
        else
            printf 'pavucontrol is not installed\n'
            pause_panel
        fi
        ;;
    2)
        "$module_dir/audio.sh" right
        pause_panel
        ;;
    3)
        "$module_dir/audio.sh" middle
        pause_panel
        ;;
    *)
        ;;
esac
