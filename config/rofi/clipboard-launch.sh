#!/usr/bin/env bash
# Clipboard history via cliphist + rofi (text and images).
# https://wiki.hypr.land/Useful-Utilities/Clipboard-Managers/

set -euo pipefail

theme="${HOME}/.config/rofi/clipboard.rasi"

if pgrep -x rofi >/dev/null 2>&1; then
	pkill -x rofi
	exit 0
fi

# shellcheck source=./_x11-wrapper.sh
. "${0%/*}/_x11-wrapper.sh"

copy_to_clipboard() {
	if [ -n "${WAYLAND_DISPLAY:-}" ]; then
		wl-copy
	elif command -v xclip >/dev/null 2>&1; then
		xclip -selection clipboard -i
	else
		wl-copy
	fi
}

# Pipe end-to-end — never store decoded bytes in shell variables (breaks images).
cliphist list \
	| rofi -dmenu -i -display-columns 2 -p "Clipboard" -theme "$theme" \
	| cliphist decode \
	| copy_to_clipboard
