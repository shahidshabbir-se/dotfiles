#!/usr/bin/env sh
set -eu

url=${1:-}
[ -n "$url" ] || exit 1

case "$url" in
  file://*|qrc:*|image://*)
    printf '%s\n' "$url"
    exit 0
    ;;
  /*)
    printf 'file://%s\n' "$url"
    exit 0
    ;;
esac

case "$url" in
  http://*|https://*) ;;
  *)
    printf '%s\n' "$url"
    exit 0
    ;;
esac

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell-island/covers"
mkdir -p "$cache_dir"

key=$(printf '%s' "$url" | sha256sum | cut -d ' ' -f 1)
target="$cache_dir/$key.img"

if [ ! -s "$target" ]; then
  temporary=$(mktemp "$cache_dir/.${key}.XXXXXX")
  trap 'rm -f "$temporary"' EXIT HUP INT TERM
  curl --fail --location --silent --show-error --max-time 20 --output "$temporary" "$url"
  [ -s "$temporary" ] || exit 1
  mv "$temporary" "$target"
  trap - EXIT HUP INT TERM
fi

printf 'file://%s\n' "$target"
