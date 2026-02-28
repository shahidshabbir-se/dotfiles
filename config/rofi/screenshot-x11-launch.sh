#!/usr/bin/env bash
# Screenshot menu with rofi using maim (X11 replacement for grimblast)

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Options - icons only
screen="󰹑"
area="󰩬"
window="󰖲"
screen_delay="󱎫"
area_delay="󰄉"

# Rofi prompt
chosen=$(echo -e "$screen\n$area\n$window\n$screen_delay\n$area_delay" | rofi -dmenu -i -p "Screenshot" -theme ~/.config/rofi/screenshot.rasi -theme-str '* { font: "JetBrainsMono NF Bold 12"; }')

filename="$SCREENSHOT_DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

case $chosen in
    "$screen")
        maim "$filename" && xclip -selection clipboard -t image/png < "$filename" && notify-send -t 3000 "Screenshot" "Full screen saved"
        ;;
    "$area")
        maim -s "$filename" && xclip -selection clipboard -t image/png < "$filename" && notify-send -t 3000 "Screenshot" "Area saved"
        ;;
    "$window")
        maim -i "$(xdotool getactivewindow)" "$filename" && xclip -selection clipboard -t image/png < "$filename" && notify-send -t 3000 "Screenshot" "Window saved"
        ;;
    "$screen_delay")
        sleep 5 && maim "$filename" && xclip -selection clipboard -t image/png < "$filename" && notify-send -t 3000 "Screenshot" "Delayed screen saved"
        ;;
    "$area_delay")
        sleep 5 && maim -s "$filename" && xclip -selection clipboard -t image/png < "$filename" && notify-send -t 3000 "Screenshot" "Delayed area saved"
        ;;
esac
