#!/usr/bin/env bash

# Check if bluetooth is powered
bt_power=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

if [[ "$bt_power" == "no" ]]; then
    # Ask to turn on bluetooth
    choice=$(echo -e "Turn On Bluetooth" | rofi -dmenu -i -p "Bluetooth" -theme-str 'window {width: 300px;}')
    if [[ "$choice" == "Turn On Bluetooth" ]]; then
        bluetoothctl power on
        notify-send "Bluetooth" "Bluetooth turned on" -i bluetooth
    fi
    exit 0
fi

# Get paired devices
devices=$(bluetoothctl devices | awk '{$1=""; print substr($0,2)}')

if [[ -z "$devices" ]]; then
    notify-send "Bluetooth" "No paired devices found" -i bluetooth
    exit 0
fi

# Build menu
menu="󰂲 Turn Off Bluetooth\n"
while IFS= read -r device; do
    mac=$(bluetoothctl devices | grep "$device" | awk '{print $2}')
    info=$(bluetoothctl info "$mac")

    if echo "$info" | grep -q "Connected: yes"; then
        menu+="󰂱 $device (Connected)\n"
    else
        menu+="󰂰 $device\n"
    fi
done <<< "$devices"

# Show menu
selected=$(echo -e "$menu" | rofi -dmenu -i -p "Bluetooth Devices" -theme-str 'window {width: 400px;}')

if [[ -z "$selected" ]]; then
    exit 0
fi

# Handle power off
if [[ "$selected" == "󰂲 Turn Off Bluetooth" ]]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Bluetooth turned off" -i bluetooth-disabled
    exit 0
fi

# Extract device name and toggle connection
device_name=$(echo "$selected" | sed 's/^󰂰 //; s/^󰂱 //; s/ (Connected)$//')
mac=$(bluetoothctl devices | grep "$device_name" | awk '{print $2}')

if echo "$selected" | grep -q "Connected"; then
    # Disconnect
    bluetoothctl disconnect "$mac" && \
        notify-send "Bluetooth" "Disconnected from $device_name" -i bluetooth-disabled || \
        notify-send "Bluetooth" "Failed to disconnect" -i dialog-error
else
    # Connect
    bluetoothctl connect "$mac" && \
        notify-send "Bluetooth" "Connected to $device_name" -i bluetooth || \
        notify-send "Bluetooth" "Failed to connect" -i dialog-error
fi
