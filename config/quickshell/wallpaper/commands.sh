#!/run/current-system/sw/bin/bash

selected_path="$1"

if [[ -z "$selected_path" || ! -f "$selected_path" ]]; then
    exit 1
fi

if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 0.5
fi

cursor_pos=$(hyprctl cursorpos 2>/dev/null | tr -d ' ')
if [[ ! "$cursor_pos" =~ ^[0-9]+,[0-9]+$ ]]; then
    cursor_pos="center"
fi

swww img "$selected_path" \
    --transition-type grow \
    --transition-pos "$cursor_pos" \
    --transition-step 90

cp -f "$selected_path" "$HOME/.cache/hyprlock.png"

if command -v magick > /dev/null; then
    mkdir -p "$HOME/.cache/amadeus-bar"
    magick "$HOME/.cache/hyprlock.png" \
        -resize "380x168^" \
        -gravity center \
        -extent "380x168" \
        "$HOME/.cache/amadeus-bar/menu-banner.png"
fi

if command -v matugen > /dev/null; then
    matugen image --config "$HOME/dotfiles/config/matugen/config.toml" "$selected_path" &
fi

pkill -x glava 2>/dev/null || true
