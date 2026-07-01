#!/usr/bin/env bash
# Screenshot menu with rofi using grimblast

SCREENSHOT_CAPTURE="$HOME/dotfiles/scripts/screenshot-capture.sh"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOT_DIR"

screen="󰹑"
area="󰩬"
window="󰖲"
screen_delay="󱎫"
area_delay="󰄉"

chosen=$(echo -e "$screen\n$area\n$window\n$screen_delay\n$area_delay" | rofi -dmenu -i -p "Screenshot" -theme ~/.config/rofi/screenshot.rasi)

filename="$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

case $chosen in
    "$screen")
        sh "$SCREENSHOT_CAPTURE" copysave screen "$filename"
        ;;
    "$area")
        sh "$SCREENSHOT_CAPTURE" copysave area "$filename"
        ;;
    "$window")
        sh "$SCREENSHOT_CAPTURE" copysave active "$filename"
        ;;
    "$screen_delay")
        sleep 5 && sh "$SCREENSHOT_CAPTURE" copysave screen "$filename"
        ;;
    "$area_delay")
        sleep 5 && sh "$SCREENSHOT_CAPTURE" copysave area "$filename"
        ;;
esac
