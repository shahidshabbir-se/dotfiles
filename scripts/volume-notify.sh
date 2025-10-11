#!/usr/bin/env bash

# Get current volume and mute status
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")

if [ "$muted" = "MUTED" ]; then
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume "Volume: Muted" -h int:value:0
else
    notify-send -t 2000 -h string:x-canonical-private-synchronous:volume "Volume: ${volume}%" -h int:value:"${volume}"
fi
