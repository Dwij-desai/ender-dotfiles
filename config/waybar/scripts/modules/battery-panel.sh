#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"
# shellcheck source=/dev/null
source "$module_dir/../lib/battery.sh"

mode="${1:-summary}"
battery_path=""

if battery_path="$(battery_device_path 2>/dev/null || printf '')"; then
    :
fi

print_panel_header "BATTERY"

backend="$(battery_backend_detect)"
backend_label="$(battery_backend_label "$backend")"

if [[ -z "$battery_path" ]]; then
    printf 'Battery: Not detected\n'
    printf 'Backend: %s\n' "$backend_label"
    printf 'Battery Life: Unavailable\n'
    printf 'Charge Threshold: Unavailable\n'
    printf '\nRecommendations\n'
    printf '- No battery device was detected.\n'
    printf '- No action required.\n'
    pause_panel
    exit 0
fi

status="$(battery_read_value "$battery_path/status" 2>/dev/null || printf 'Unavailable')"
capacity="$(battery_read_value "$battery_path/capacity" 2>/dev/null || printf 'Unavailable')"
cycles="$(battery_read_value "$battery_path/cycle_count" 2>/dev/null || printf 'Unavailable')"
temperature="$(battery_temperature "$battery_path" 2>/dev/null || printf 'Unavailable')"
power_draw="$(battery_power_draw "$battery_path" 2>/dev/null || printf 'Unavailable')"
time_remaining="$(battery_time_remaining "$battery_path" 2>/dev/null || printf 'Unavailable')"
health="$(battery_health_percent "$battery_path" 2>/dev/null || printf 'Unavailable')"
life_rating="$(battery_life_rating "$health" 2>/dev/null || printf 'Unavailable')"
threshold="$(battery_charge_threshold "$battery_path" 2>/dev/null || printf 'Unavailable')"
charging_state='No'

if [[ "$status" == 'Charging' ]]; then
    charging_state='Yes'
fi

printf 'Charge          %s%%\n' "$capacity"
printf 'Health          %s\n' "$health"
printf 'Cycles          %s\n' "$cycles"
printf 'Temperature     %s\n' "$temperature"
printf 'Power Draw      %s\n' "$power_draw"
printf 'Remaining Time  %s\n' "$time_remaining"
printf 'Charging        %s\n' "$charging_state"
printf 'Backend         %s\n' "$backend_label"
printf 'Battery Life    %s\n' "$life_rating"
printf 'Charge Threshold %s\n' "$threshold"

printf '\nRecommendations\n'
battery_recommendations "$health" "$threshold" "$backend_label"

configure_action() {
    case "$backend" in
        powerprofilesctl)
            if ! have_cmd powerprofilesctl; then
                printf 'powerprofilesctl is not installed\n'
                return 1
            fi

            printf '\nPower Profile\n\n'
            printf 'Current: %s\n' "$(powerprofilesctl get 2>/dev/null || printf 'Unavailable')"
            printf 'Select profile:\n'
            printf '[1] power-saver\n[2] balanced\n[3] performance\n[Enter] Cancel\n'
            printf 'Choice: '
            read -r choice
            case "$choice" in
                1) powerprofilesctl set power-saver ;;
                2) powerprofilesctl set balanced ;;
                3) powerprofilesctl set performance ;;
                *) ;;
            esac
            pause_panel
            ;;
        tlp)
            threshold_file="$(battery_charge_threshold_file "$battery_path" 2>/dev/null || printf '')"
            if [[ -z "$threshold_file" ]]; then
                printf 'No writable charge threshold is exposed by this battery\n'
                pause_panel
                return 1
            fi

            if ! have_cmd pkexec; then
                printf 'Changing charge thresholds requires pkexec\n'
                pause_panel
                return 1
            fi

            printf '\nCharge Threshold Configuration\n\n'
            printf 'Current: %s\n' "$threshold"
            printf 'Enter new end threshold (0-100, blank to cancel): '
            read -r new_threshold

            case "$new_threshold" in
                "")
                    return 0
                    ;;
                *[!0-9]*)
                    printf 'Invalid threshold\n'
                    return 1
                    ;;
            esac

            if [[ "$new_threshold" -lt 0 || "$new_threshold" -gt 100 ]]; then
                printf 'Threshold must be between 0 and 100\n'
                pause_panel
                return 1
            fi

            pkexec sh -c 'printf "%s" "$1" > "$2"' sh "$new_threshold" "$threshold_file"
            pause_panel
            ;;
        *)
            printf 'No power-management backend detected\n'
            pause_panel
            return 1
            ;;
    esac
}

diagnostics_action() {
    case "$backend" in
        powerprofilesctl)
            if ! have_cmd powerprofilesctl; then
                printf 'powerprofilesctl is not installed\n'
                return 1
            fi

            printf '\nDiagnostics\n\n'
            powerprofilesctl get
            printf '\n'
            powerprofilesctl list
            pause_panel
            ;;
        tlp)
            printf '\nAdministrator Action\n\n'
            printf 'This operation requires elevated privileges.\n\n'
            printf '[1] Open detailed TLP statistics (root)\n'
            printf '[2] Cancel\n'
            printf 'Choice: '
            read -r choice
            case "$choice" in
                1)
                    if have_cmd pkexec && have_cmd tlp-stat; then
                        pkexec tlp-stat -b
                    else
                        printf 'Detailed TLP diagnostics require pkexec and tlp-stat\n'
                        pause_panel
                        return 1
                    fi
                    pause_panel
                    ;;
                *) ;;
            esac
            ;;
        *)
            printf '\nDiagnostics\n\n'
            printf 'No power-management backend detected\n'
            pause_panel
            ;;
    esac
}

case "$mode" in
    summary)
        printf '\nAvailable Actions\n'
        printf '[1] Configure power settings\n'
        printf '[2] Detailed diagnostics\n'
        printf '[3] Cancel\n'
        printf 'Choice: '
        read -r choice
        case "$choice" in
            1) configure_action ;;
            2) diagnostics_action ;;
            *) ;;
        esac
        ;;
    configure)
        printf '\nAvailable Actions\n'
        printf '[1] Configure power settings\n'
        printf '[2] Cancel\n'
        printf 'Choice: '
        read -r choice
        case "$choice" in
            1) configure_action ;;
            *) ;;
        esac
        ;;
    diagnostics)
        diagnostics_action
        ;;
    *)
        printf '\nAvailable Actions\n'
        printf '[1] Configure power settings\n'
        printf '[2] Detailed diagnostics\n'
        printf '[3] Cancel\n'
        ;;
esac
