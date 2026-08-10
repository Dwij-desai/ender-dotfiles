#!/usr/bin/env bash

set -u

if [[ "$#" -eq 0 ]]; then
    printf '%s\n' 'Usage: launch-terminal.sh COMMAND [ARGUMENT...]' >&2
    exit 64
fi

if command -v ghostty >/dev/null 2>&1; then
    exec ghostty -e "$@"
elif command -v foot >/dev/null 2>&1; then
    exec foot "$@"
elif command -v kitty >/dev/null 2>&1; then
    exec kitty "$@"
elif command -v alacritty >/dev/null 2>&1; then
    exec alacritty -e "$@"
elif command -v wezterm >/dev/null 2>&1; then
    exec wezterm start -- "$@"
elif command -v konsole >/dev/null 2>&1; then
    exec konsole -e "$@"
elif command -v kgx >/dev/null 2>&1; then
    exec kgx -- "$@"
elif command -v xterm >/dev/null 2>&1; then
    exec xterm -e "$@"
fi

printf '%s\n' 'EnderOS requires a supported terminal emulator.' >&2
exit 1
