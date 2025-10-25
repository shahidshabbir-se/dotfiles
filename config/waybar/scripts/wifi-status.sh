#!/usr/bin/env bash

# Get WiFi status
wifi_status=$(nmcli -t -f STATE,SIGNAL device wifi | head -n1)
state=$(echo $wifi_status | cut -d':' -f1)
signal=$(echo $wifi_status | cut -d':' -f2)

if [[ "$state" == "connected" ]]; then
    ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

    # Determine icon based on signal strength
    if [[ $signal -ge 75 ]]; then
        icon="󰤨"
    elif [[ $signal -ge 50 ]]; then
        icon="󰤥"
    elif [[ $signal -ge 25 ]]; then
        icon="󰤢"
    else
        icon="󰤟"
    fi

    echo "{\"text\":\"$icon\", \"tooltip\":\"Connected to $ssid\\nSignal: $signal%\"}"
else
    echo "{\"text\":\"󰤮\", \"tooltip\":\"WiFi Disconnected\"}"
fi
