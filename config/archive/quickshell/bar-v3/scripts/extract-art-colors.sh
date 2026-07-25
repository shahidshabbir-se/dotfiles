#!/usr/bin/env bash

set -euo pipefail

url="${1:-}"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/art-colors"

if [[ -z "$url" ]]; then
  exit 0
fi

mkdir -p "$cache_dir"

cache_key="$(printf '%s' "$url" | md5sum | awk '{print $1}')"
color_cache="$cache_dir/$cache_key.colors"

if [[ -f "$color_cache" ]]; then
  cat "$color_cache"
  exit 0
fi

resolve_source() {
  local src hash

  if [[ "$url" == file://* ]]; then
    src="${url#file://}"
    [[ -f "$src" ]] && printf '%s' "$src"
    return
  fi

  if [[ "$url" == /* && -f "$url" ]]; then
    printf '%s' "$url"
    return
  fi

  if [[ "$url" == http://* || "$url" == https://* ]]; then
    hash="$(printf '%s' "$url" | md5sum | awk '{print $1}')"
    src="$cache_dir/$hash.img"
    if [[ ! -f "$src" ]]; then
      curl -sfL --max-time 8 "$url" -o "$src" || return
    fi
    printf '%s' "$src"
  fi
}

src="$(resolve_source || true)"
[[ -n "$src" && -f "$src" ]] || exit 0

flattened() {
  magick "$src" -background "#141414" -alpha remove -alpha off "$@"
}

accent="$(
  flattened -resize 48x48! \
    -format "%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]" info:
)"

vibrant="$(
  flattened -gravity center -crop 68%x68%+0+0 +repage \
    -resize 32x32! -modulate 100,145,105 \
    -format "%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]" info:
)"

background="$(
  flattened -resize 12x12! -blur 0x2 \
    -modulate 58,95,100 \
    -format "%[fx:int(255*r+.5)],%[fx:int(255*g+.5)],%[fx:int(255*b+.5)]" info:
)"

{
  printf '%s\n%s\n%s\n' "$accent" "$vibrant" "$background"
} | tee "$color_cache"
