#!/usr/bin/env sh
set -eu

file="${1:-}"
[ -n "$file" ] && [ -f "$file" ] || exit 1

quickshell ipc -c bar call screenshot showPath "$file"
