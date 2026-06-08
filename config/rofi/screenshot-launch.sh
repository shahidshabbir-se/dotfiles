#!/usr/bin/env bash
# Screenshot menu with rofi using grimblast

SCREENSHOT_CAPTURE="$HOME/dotfiles/scripts/screenshot-capture.sh"

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
        sh "$SCREENSHOT_CAPTURE" --notify copysave screen "$filename"
        ;;
    "$area")
        sh "$SCREENSHOT_CAPTURE" --notify copysave area "$filename"
        ;;
    "$window")
        sh "$SCREENSHOT_CAPTURE" --notify copysave active "$filename"
        ;;
    "$screen_delay")
        sleep 5 && sh "$SCREENSHOT_CAPTURE" --notify copysave screen "$filename"
        ;;
    "$area_delay")
        sleep 5 && sh "$SCREENSHOT_CAPTURE" --notify copysave area "$filename"
        ;;
esac
