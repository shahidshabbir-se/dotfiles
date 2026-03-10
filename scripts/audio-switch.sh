#!/usr/bin/env bash
# Toggle default audio sink between USB Speaker and Bluetooth

USB_SINK=$(wpctl status | grep "USB Composite Device Analog Stereo" | awk '{print $1}' | tr -d '.')
BT_SINK=$(wpctl status | grep "Wave" | grep -v "input\|capture\|monitor" | awk '{print $1}' | tr -d '.')

CURRENT=$(wpctl status | grep '^\s*\*' | awk '{print $2}' | tr -d '.')

if [ "$CURRENT" = "$USB_SINK" ]; then
    if [ -n "$BT_SINK" ]; then
        wpctl set-default "$BT_SINK"
        notify-send -i audio-headphones "Audio Output" "Switched to Bluetooth (Wave)" -t 2000
    else
        notify-send -i audio-headphones "Audio Output" "Bluetooth not connected" -t 2000
    fi
else
    if [ -n "$USB_SINK" ]; then
        wpctl set-default "$USB_SINK"
        notify-send -i audio-speakers "Audio Output" "Switched to USB Speaker" -t 2000
    else
        notify-send -i audio-speakers "Audio Output" "USB Speaker not connected" -t 2000
    fi
fi
