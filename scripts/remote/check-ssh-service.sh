#!/usr/bin/env bash

set -u

if ! command -v systemctl >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: systemctl is unavailable; cannot inspect sshd.service.' >&2
    exit 1
fi

if ! systemctl list-unit-files sshd.service --no-legend 2>/dev/null | grep -q '^sshd\.service'; then
    printf '%s\n' 'ERROR: sshd.service is not installed.' >&2
    exit 1
fi

enabled="$(systemctl is-enabled sshd.service 2>/dev/null || true)"
active="$(systemctl is-active sshd.service 2>/dev/null || true)"

printf 'SSH SERVICE\n\n'
printf 'Enabled: %s\n' "${enabled:-unknown}"
printf 'Active:  %s\n' "${active:-unknown}"

if [[ "$enabled" != "enabled" || "$active" != "active" ]]; then
    printf '%s\n' 'ACTION: enable and start sshd.service after validating SSH configuration.' >&2
    exit 1
fi
