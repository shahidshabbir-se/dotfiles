#!/usr/bin/env bash
# Launch rofi-bluetooth with custom theme

# shellcheck source=./_x11-wrapper.sh
. "${0%/*}/_x11-wrapper.sh"

if [ "$XDG_SESSION_TYPE" = "x11" ] || [ -z "$WAYLAND_DISPLAY" ]; then
	rofi-bluetooth -theme ~/.config/rofi/bluetooth-x11.rasi
else
	rofi-bluetooth -theme ~/.config/rofi/bluetooth.rasi
fi
