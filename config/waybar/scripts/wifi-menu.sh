#!/usr/bin/env bash

# Get list of available networks
networks=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | awk -F: '{
    ssid=$1
    signal=$2
    security=$3
    if (ssid != "") {
        if (signal >= 75) icon="󰤨"
        else if (signal >= 50) icon="󰤥"
        else if (signal >= 25) icon="󰤢"
        else icon="󰤟"

        lock=""
        if (security != "") lock=" 󰌾"

        printf "%s %s%s (%s%%)\n", icon, ssid, lock, signal
    }
}')

# Get current connection
current=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)

# Add disconnect option if connected
if [[ -n "$current" ]]; then
    options="󰖪 Disconnect\n$networks"
else
    options="$networks"
fi

# Show rofi menu
selected=$(echo -e "$options" | rofi -dmenu -i -p "WiFi Networks" -theme-str 'window {width: 400px;}')

if [[ -z "$selected" ]]; then
    exit 0
fi

# Handle disconnect
if [[ "$selected" == "󰖪 Disconnect" ]]; then
    nmcli device disconnect wlan0
    notify-send "WiFi" "Disconnected" -i network-wireless-disconnected
    exit 0
fi

# Extract SSID from selection
ssid=$(echo "$selected" | awk '{print $2}' | sed 's/ 󰌾//')

# Check if network requires password
security=$(nmcli -t -f SSID,SECURITY device wifi list | grep "^$ssid:" | cut -d':' -f2)

if [[ -n "$security" && "$security" != "--" ]]; then
    # Prompt for password
    password=$(rofi -dmenu -password -p "Password for $ssid" -theme-str 'window {width: 400px;}')

    if [[ -n "$password" ]]; then
        nmcli device wifi connect "$ssid" password "$password" && \
            notify-send "WiFi" "Connected to $ssid" -i network-wireless || \
            notify-send "WiFi" "Failed to connect to $ssid" -i dialog-error
    fi
else
    # Connect without password
    nmcli device wifi connect "$ssid" && \
        notify-send "WiFi" "Connected to $ssid" -i network-wireless || \
        notify-send "WiFi" "Failed to connect to $ssid" -i dialog-error
fi
