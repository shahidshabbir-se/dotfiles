#!/run/current-system/sw/bin/bash

selected_path="$1"
matugen_delay="${MATUGEN_DELAY:-0.6}"

if [[ -z "$selected_path" || ! -f "$selected_path" ]]; then
    exit 1
fi

if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

cursor_pos=$(hyprctl cursorpos 2>/dev/null | tr -d ' ')
if [[ ! "$cursor_pos" =~ ^[0-9]+,[0-9]+$ ]]; then
    cursor_pos="center"
fi

if [ -x "$HOME/dotfiles/config/matugen/run.sh" ]; then
    (
        sleep "$matugen_delay"
        "$HOME/dotfiles/config/matugen/run.sh" "$selected_path"
    ) &
fi

awww img "$selected_path" \
    --transition-type grow \
    --transition-pos "$cursor_pos" \
    --transition-step 90

(
    cp -f "$selected_path" "$HOME/.cache/hyprlock.png"
    if command -v magick > /dev/null; then
        magick "$selected_path" "$HOME/.cache/hyprlock.png"
        mkdir -p "$HOME/.cache/amadeus-bar"
        magick "$HOME/.cache/hyprlock.png" \
            -resize "380x168^" \
            -gravity center \
            -extent "380x168" \
            "$HOME/.cache/amadeus-bar/menu-banner.png"
    fi
) &

pkill -x glava 2>/dev/null || true
