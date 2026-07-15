#!/usr/bin/env sh
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
CONFIG="$ROOT/config.toml"
IMAGE="${1:?usage: run.sh /path/to/wallpaper}"

command -v matugen >/dev/null || exit 0

mkdir -p "$HOME/.local/share/vicinae/themes"

exec matugen image \
  --config "$CONFIG" \
  --source-color-index 0 \
  -m dark \
  -q \
  "$IMAGE"
