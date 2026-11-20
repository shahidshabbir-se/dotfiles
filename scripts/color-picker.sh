#!/usr/bin/env bash
set -euo pipefail

# Pick a pixel color, copy the hex value to the clipboard and report it.
color="$(hyprpicker -f hex)" || exit 0
[ -n "$color" ] || exit 0

printf '%s' "$color" | wl-copy
notify-send -t 3000 \
  -h string:x-canonical-private-synchronous:colorpicker \
  "Color picked: ${color}" \
  "Copied to clipboard"
