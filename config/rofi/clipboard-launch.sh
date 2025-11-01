#!/usr/bin/env bash
# Launch cliphist with rofi - fast and simple version

# Simple approach: just show cliphist list directly
selection=$(cliphist list | head -n 50 | rofi -dmenu -i -p "Clipboard" -theme ~/.config/rofi/clipboard.rasi)

# If something was selected, decode and copy it
if [ -n "$selection" ]; then
    echo "$selection" | cliphist decode | wl-copy
fi
