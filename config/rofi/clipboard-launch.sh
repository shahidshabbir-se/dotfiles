#!/usr/bin/env bash
# Launch cliphist with rofi - fast and simple version

# shellcheck source=./_x11-wrapper.sh
. "${0%/*}/_x11-wrapper.sh"

selection=$(cliphist list | head -n 50 | rofi -dmenu -i -p "Clipboard" -theme ~/.config/rofi/clipboard.rasi)

# If something was selected, decode and copy it
if [ -n "$selection" ]; then
	decoded=$(echo "$selection" | cliphist decode)
	if [ -z "$WAYLAND_DISPLAY" ] && command -v xclip &>/dev/null; then
		# Under XWayland (GNOME) — use xclip
		echo "$decoded" | xclip -selection clipboard
	else
		# Under native Wayland (Hyprland) — use wl-copy
		echo "$decoded" | wl-copy
	fi
fi
