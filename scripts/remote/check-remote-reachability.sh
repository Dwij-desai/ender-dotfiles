#!/usr/bin/env bash

set -u

if [[ "$#" -ne 1 ]]; then
    printf '%s\n' 'Usage: check-remote-reachability.sh TAILSCALE_HOST' >&2
    exit 64
fi

target="$1"

if ! command -v tailscale >/dev/null 2>&1; then
    printf '%s\n' 'UNAVAILABLE: Tailscale is not installed.' >&2
    exit 2
fi

if ! command -v ssh >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: OpenSSH client is not installed.' >&2
    exit 1
fi

printf 'TAILSCALE REACHABILITY\n\n'
tailscale ping --until-direct=false --timeout=10s "$target"

printf '\nSSH REACHABILITY\n\n'
ssh -o BatchMode=yes -o ConnectTimeout=10 "$target" true
printf '%s\n' 'READY: Tailscale and key-based SSH reachability verified.'
