#!/usr/bin/env bash

set -u

module_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$module_dir/../lib/common.sh"

read_cpu_temp() {
    local zone
    for zone in /sys/class/thermal/thermal_zone*/temp; do
        if [[ -r "$zone" ]]; then
            awk '{ printf "%.1f C", $1/1000 }' "$zone"
            return 0
        fi
    done
    printf 'Unavailable'
}

usage="$(awk '/^cpu / { total=$2+$3+$4+$5+$6+$7+$8; idle=$5; if (total > 0) printf "%.0f", (100*(total-idle)/total); else print "0" }' /proc/stat)"
governor="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || printf 'Unavailable')"
frequency="$(awk '/cpu MHz/ { sum += $4; n += 1 } END { if (n > 0) printf "%.0f MHz", sum/n; else print "Unavailable" }' /proc/cpuinfo)"
threads="$(nproc 2>/dev/null || printf 'Unavailable')"
cores="$(lscpu 2>/dev/null | awk -F: '/Core\(s\) per socket/ { gsub(/^[ \t]+/, "", $2); print $2; exit }')"
load_avg="$(cut -d' ' -f1-3 /proc/loadavg 2>/dev/null || printf 'Unavailable')"
uptime_info="$(uptime -p 2>/dev/null || printf 'Unavailable')"
top_proc="$(ps -eo comm,%cpu --sort=-%cpu 2>/dev/null | sed -n '2p' | awk '{ print $1 " (" $2 "%)" }')"

print_panel_header "CPU"
printf 'Usage: %s%%\n' "${usage:-Unavailable}"
printf 'Temperature: %s\n' "$(read_cpu_temp)"
printf 'Governor: %s\n' "$governor"
printf 'Frequency: %s\n' "$frequency"
printf 'Cores: %s\n' "${cores:-Unavailable}"
printf 'Threads: %s\n' "$threads"
printf 'Load Avg: %s\n' "$load_avg"
printf 'Uptime: %s\n' "$uptime_info"
printf 'Top Process: %s\n' "${top_proc:-Unavailable}"

printf '\n[1] Open btop\n[2] Open htop\n[3] Kill process by PID\n[4] Copy report\n[Enter] Close\n'
printf 'Select action: '
read -r choice

report="CPU usage=${usage:-NA}% temp=$(read_cpu_temp) governor=$governor freq=$frequency load=$load_avg top=${top_proc:-NA}"

case "$choice" in
    1)
        if have_cmd btop; then btop; else printf 'btop is not installed\n'; pause_panel; fi
        ;;
    2)
        if have_cmd htop; then htop; else printf 'htop is not installed\n'; pause_panel; fi
        ;;
    3)
        printf 'Enter PID to kill: '
        read -r pid
        if [[ -n "$pid" ]]; then
            if kill "$pid" 2>/dev/null; then
                printf 'Process %s terminated\n' "$pid"
            else
                printf 'Failed to terminate PID %s\n' "$pid"
            fi
        fi
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
