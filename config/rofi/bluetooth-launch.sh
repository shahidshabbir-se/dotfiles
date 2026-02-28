#!/usr/bin/env bash
# Launch rofi-bluetooth with custom theme

if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    rofi-bluetooth -theme ~/.config/rofi/bluetooth-x11.rasi
else
    rofi-bluetooth -theme ~/.config/rofi/bluetooth.rasi
fi
