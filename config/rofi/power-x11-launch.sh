#!/usr/bin/env bash
# Power menu with rofi for i3/X11 (replaces hyprlock/hyprctl)

# Options - icons only
shutdown="󰐥"
reboot="󰜉"
lock="󰌾"
suspend="󰤄"
logout="󰍃"

# Rofi prompt
chosen=$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/power.rasi -theme-str '* { font: "JetBrainsMono NF Bold 12"; }')

# Execute action
case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        $HOME/dotfiles/scripts/i3lock-screen.sh
        ;;
    $suspend)
        systemctl suspend
        ;;
    $logout)
        i3-msg exit
        ;;
esac
