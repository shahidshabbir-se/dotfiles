#!/usr/bin/env bash
# X11 screenshot script (replaces grimblast)
# Usage: screenshot-x11.sh [screen|area|window]

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
filename="$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

case "${1:-area}" in
    screen)
        maim "$filename"
        ;;
    area)
        maim -s "$filename"
        ;;
    window)
        maim -i "$(xdotool getactivewindow)" "$filename"
        ;;
esac

if [ -f "$filename" ]; then
    xclip -selection clipboard -t image/png < "$filename"
    notify-send -t 3000 "Screenshot saved" "$filename"
fi
