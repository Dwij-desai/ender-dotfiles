#!/usr/bin/env bash

set -u

if ! command -v sshd >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: sshd is not installed.' >&2
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    printf '%s\n' 'ERROR: run this script with sudo so sshd can read its host keys.' >&2
    exit 1
fi

sshd -t
printf '%s\n' 'OpenSSH configuration is valid.'
