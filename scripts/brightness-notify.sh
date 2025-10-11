#!/usr/bin/env bash

# Get current brightness percentage
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
percentage=$((brightness * 100 / max_brightness))

notify-send -t 2000 -h string:x-canonical-private-synchronous:brightness "Brightness: ${percentage}%" -h int:value:"${percentage}"
