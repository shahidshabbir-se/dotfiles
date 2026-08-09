#!/usr/bin/env sh
set -eu

entry_id="${1:-}"
case "$entry_id" in
    ""|*[!0-9]*) exit 2 ;;
esac

cache_dir="${XDG_RUNTIME_DIR:?}/quickshell-island/clipboard-images"
cache_path="$cache_dir/$entry_id"

umask 077
mkdir -p "$cache_dir"

if [ ! -s "$cache_path" ]; then
    temporary_path="$cache_path.$$"
    trap 'rm -f "$temporary_path"' EXIT HUP INT TERM
    cliphist decode "$entry_id" > "$temporary_path"
    mv "$temporary_path" "$cache_path"
    trap - EXIT HUP INT TERM
fi

printf 'file://%s\n' "$cache_path"
