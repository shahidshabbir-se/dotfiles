#!/usr/bin/env bash

# Power menu options
options="󰐥 Shutdown\n󰜉 Reboot\n󰤄 Suspend\n󰍃 Logout\n Lock"

# Show rofi menu
selected=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 250px;}')

case "$selected" in
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
    "󰜉 Reboot")
        systemctl reboot
        ;;
    "󰤄 Suspend")
        systemctl suspend
        ;;
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    " Lock")
        hyprlock
        ;;
esac
