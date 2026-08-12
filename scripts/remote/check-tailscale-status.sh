#!/usr/bin/env bash

set -u

if ! command -v tailscale >/dev/null 2>&1; then
    printf '%s\n' 'UNAVAILABLE: Tailscale is not installed. SSH remains available through another configured network path.' >&2
    exit 2
fi

if ! command -v systemctl >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: systemctl is unavailable; cannot inspect tailscaled.service.' >&2
    exit 1
fi

service_state="$(systemctl is-active tailscaled.service 2>/dev/null || true)"

printf 'TAILSCALE\n\n'
printf 'Service: %s\n' "${service_state:-unknown}"

if [[ "$service_state" != "active" ]]; then
    printf '%s\n' 'ACTION: start tailscaled.service, then run tailscale up to authenticate or reconnect.' >&2
    exit 1
fi

tailscale status
