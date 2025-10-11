#!/usr/bin/env bash

# Get player status and metadata
status=$(playerctl status 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

if [ -z "$status" ]; then
    exit 0
fi

# Determine icon and message based on status
case "$status" in
    "Playing")
        icon="🎵"
        action="Now Playing"
        ;;
    "Paused")
        icon="⏸"
        action="Paused"
        ;;
    *)
        icon="🎵"
        action="$status"
        ;;
esac

# Send notification
if [ -n "$artist" ] && [ -n "$title" ]; then
    notify-send -t 3000 "$icon $action" "$artist - $title"
elif [ -n "$title" ]; then
    notify-send -t 3000 "$icon $action" "$title"
else
    notify-send -t 3000 "$icon $action" "Media playback"
fi
