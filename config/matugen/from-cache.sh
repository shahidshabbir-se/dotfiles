#!/usr/bin/env sh
set -eu

RUN="$HOME/dotfiles/config/matugen/run.sh"
WALL="${1:-$HOME/.cache/hyprlock.png}"

if [ ! -f "$WALL" ]; then
    WALL="$(find "$HOME/Pictures/Wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | head -1)"
fi

[ -n "$WALL" ] && [ -f "$WALL" ] || exit 0
[ -x "$RUN" ] || exit 0

exec "$RUN" "$WALL"
