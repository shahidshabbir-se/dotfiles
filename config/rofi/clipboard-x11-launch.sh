#!/usr/bin/env bash
# Launch clipboard history with rofi using greenclip (supports images)

if pgrep -x rofi > /dev/null; then
    pkill -x rofi
else
    rofi -modi "clipboard:greenclip print" -show clipboard \
         -theme ~/.config/rofi/clipboard.rasi \
         -theme-str '* { font: "JetBrainsMono NF Bold 12"; }'
fi
