#!/usr/bin/env bash
# Power menu with rofi

# Options - icons only
shutdown="󰐥"
reboot="󰜉"
lock="󰌾"
suspend="󰤄"
logout="󰍃"

# Rofi prompt
chosen=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/power.rasi)

# Execute action
case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        hyprlock
        ;;
    $suspend)
        systemctl suspend
        ;;
    $logout)
        hyprctl dispatch exit
        ;;
esac
