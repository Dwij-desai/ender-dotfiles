#!/usr/bin/env bash

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$script_dir/common.sh"

battery_backend_detect() {
    if have_cmd powerprofilesctl; then
        printf '%s\n' 'powerprofilesctl'
        return 0
    fi

    if have_cmd tlp-stat; then
        printf '%s\n' 'tlp'
        return 0
    fi

    printf '%s\n' 'none'
}

battery_backend_label() {
    case "$1" in
        powerprofilesctl)
            printf '%s\n' 'Power Profiles Daemon'
            ;;
        tlp)
            printf '%s\n' 'TLP'
            ;;
        *)
            printf '%s\n' 'None'
            ;;
    esac
}

battery_device_path() {
    local entry

    for entry in /sys/class/power_supply/BAT*; do
        if [[ -d "$entry" ]]; then
            printf '%s\n' "$entry"
            return 0
        fi
    done

    return 1
}

battery_read_value() {
    local file_path="$1"

    if [[ -r "$file_path" ]]; then
        cat "$file_path"
    fi
}

battery_temperature() {
    local battery_path="$1"
    local raw_value=""

    raw_value="$(battery_read_value "$battery_path/temp" 2>/dev/null || printf '')"
    if [[ -z "$raw_value" ]]; then
        raw_value="$(battery_read_value "$battery_path/temperature" 2>/dev/null || printf '')"
    fi

    if [[ -z "$raw_value" ]]; then
        printf '%s\n' 'Unavailable'
        return 0
    fi

    awk -v value="$raw_value" 'BEGIN {
        if (value > 10000) {
            printf "%.1f°C", value / 1000
        } else if (value > 1000) {
            printf "%.1f°C", value / 1000
        } else if (value > 100) {
            printf "%.1f°C", value / 10
        } else {
            printf "%s°C", value
        }
    }'
}

battery_charge_threshold_file() {
    local battery_path="$1"

    if [[ -e "$battery_path/charge_control_end_threshold" ]]; then
        printf '%s\n' "$battery_path/charge_control_end_threshold"
        return 0
    fi

    if [[ -e "$battery_path/charge_stop_threshold" ]]; then
        printf '%s\n' "$battery_path/charge_stop_threshold"
        return 0
    fi

    if [[ -e "$battery_path/charge_threshold_stop" ]]; then
        printf '%s\n' "$battery_path/charge_threshold_stop"
        return 0
    fi

    return 1
}

battery_charge_threshold() {
    local battery_path="$1"
    local start_threshold=""
    local end_threshold=""

    start_threshold="$(battery_read_value "$battery_path/charge_control_start_threshold" 2>/dev/null || printf '')"
    if [[ -z "$start_threshold" ]]; then
        start_threshold="$(battery_read_value "$battery_path/charge_start_threshold" 2>/dev/null || printf '')"
    fi

    end_threshold="$(battery_read_value "$battery_path/charge_control_end_threshold" 2>/dev/null || printf '')"
    if [[ -z "$end_threshold" ]]; then
        end_threshold="$(battery_read_value "$battery_path/charge_stop_threshold" 2>/dev/null || printf '')"
    fi

    if [[ -n "$start_threshold" && -n "$end_threshold" ]]; then
        printf '%s-%s%%\n' "$start_threshold" "$end_threshold"
        return 0
    fi

    if [[ -n "$end_threshold" ]]; then
        printf '%s%%\n' "$end_threshold"
        return 0
    fi

    if [[ -n "$start_threshold" ]]; then
        printf '%s%%\n' "$start_threshold"
        return 0
    fi

    printf '%s\n' 'Unavailable'
}

battery_health_percent() {
    local battery_path="$1"
    local full_value=""
    local design_value=""

    full_value="$(battery_read_value "$battery_path/energy_full" 2>/dev/null || printf '')"
    if [[ -z "$full_value" ]]; then
        full_value="$(battery_read_value "$battery_path/charge_full" 2>/dev/null || printf '')"
    fi

    design_value="$(battery_read_value "$battery_path/energy_full_design" 2>/dev/null || printf '')"
    if [[ -z "$design_value" ]]; then
        design_value="$(battery_read_value "$battery_path/charge_full_design" 2>/dev/null || printf '')"
    fi

    if [[ -z "$full_value" || -z "$design_value" || "$design_value" == "0" ]]; then
        printf '%s\n' 'Unavailable'
        return 0
    fi

    awk -v full="$full_value" -v design="$design_value" 'BEGIN {
        printf "%.1f%%", (full / design) * 100
    }'
}

battery_power_draw() {
    local battery_path="$1"
    local raw_value=""

    raw_value="$(battery_read_value "$battery_path/power_now" 2>/dev/null || printf '')"
    if [[ -z "$raw_value" ]]; then
        printf '%s\n' 'Unavailable'
        return 0
    fi

    awk -v value="$raw_value" 'BEGIN { printf "%.1f W", value / 1000000 }'
}

battery_time_remaining() {
    local battery_path="$1"
    local energy_now=""
    local power_now=""

    energy_now="$(battery_read_value "$battery_path/energy_now" 2>/dev/null || printf '')"
    if [[ -z "$energy_now" ]]; then
        energy_now="$(battery_read_value "$battery_path/charge_now" 2>/dev/null || printf '')"
    fi

    power_now="$(battery_read_value "$battery_path/power_now" 2>/dev/null || printf '')"
    if [[ -z "$power_now" ]]; then
        power_now="$(battery_read_value "$battery_path/current_now" 2>/dev/null || printf '')"
    fi

    if [[ -z "$energy_now" || -z "$power_now" || "$power_now" == "0" ]]; then
        printf '%s\n' 'Unavailable'
        return 0
    fi

    awk -v energy="$energy_now" -v power="$power_now" 'BEGIN {
        total_minutes = (energy / power) * 60
        hours = int(total_minutes / 60)
        minutes = int(total_minutes % 60)

        if (hours > 0) {
            printf "%dh %dm", hours, minutes
        } else {
            printf "%dm", minutes
        }
    }'
}

battery_life_rating() {
    local health_value="$1"

    case "$health_value" in
        Unavailable)
            printf '%s\n' 'Unavailable'
            ;;
        *)
            health_value="${health_value%%%}"
            if awk -v value="$health_value" 'BEGIN { exit !(value >= 90) }'; then
                printf '%s\n' 'Excellent'
            elif awk -v value="$health_value" 'BEGIN { exit !(value >= 80) }'; then
                printf '%s\n' 'Good'
            elif awk -v value="$health_value" 'BEGIN { exit !(value >= 70) }'; then
                printf '%s\n' 'Fair'
            else
                printf '%s\n' 'Attention'
            fi
            ;;
    esac
}

battery_recommendations() {
    local health_value="$1"
    local threshold_value="$2"
    local backend_label="$3"

    health_value="${health_value%%%}"

    case "$health_value" in
        ''|Unavailable)
            printf '%s\n' '- Battery health data unavailable.'
            ;;
        *)
            if awk -v value="$health_value" 'BEGIN { exit !(value >= 90) }'; then
                printf '%s\n' '- Battery health is excellent.'
                printf '%s\n' '- No action required.'
            elif awk -v value="$health_value" 'BEGIN { exit !(value >= 80) }'; then
                printf '%s\n' '- Battery health is good.'
                printf '%s\n' '- Review charge thresholds if you want more longevity.'
            else
                printf '%s\n' '- Battery health needs attention.'
                printf '%s\n' '- Consider reviewing charge thresholds or replacing the pack.'
            fi
            ;;
    esac

    if [[ "$threshold_value" != 'Unavailable' ]]; then
        printf '%s\n' "- Charge threshold: $threshold_value"
    fi

    if [[ "$backend_label" == 'None' ]]; then
        printf '%s\n' '- No power-management backend detected.'
    fi
}
