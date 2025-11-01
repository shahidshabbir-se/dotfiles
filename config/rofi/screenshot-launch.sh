#!/usr/bin/env bash
# Screenshot menu with rofi using grimblast

# Screenshot directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Create directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

# Options - icons only
screen="󰹑"
area="󰩬"
window="󰖲"
screen_delay="󱎫"
area_delay="󰄉"

# Rofi prompt
chosen=$(echo -e "$screen\n$area\n$window\n$screen_delay\n$area_delay" | rofi -dmenu -i -p "Screenshot" -theme ~/.config/rofi/screenshot.rasi)

# Generate filename with timestamp
filename="$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Execute action
case $chosen in
    "$screen")
        grimblast --notify copysave screen "$filename"
        ;;
    "$area")
        grimblast --notify copysave area "$filename"
        ;;
    "$window")
        grimblast --notify copysave active "$filename"
        ;;
    "$screen_delay")
        sleep 5 && grimblast --notify copysave screen "$filename"
        ;;
    "$area_delay")
        sleep 5 && grimblast --notify copysave area "$filename"
        ;;
esac
