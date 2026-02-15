#!/usr/bin/env bash
#             __ _              _  __ _
#  _ __ ___  / _(_)    __      _(_)/ _(_)
# | '__/ _ \| |_| |____\ \ /\ / / | |_| |
# | | | (_) |  _| |_____\ V  V /| |  _| |
# |_|  \___/|_| |_|      \_/\_/ |_|_| |_|
#
# A script that generates a rofi menu that uses nmcli to
# connect to wifi networks and display status info.
#
# Inspired by rofi-bluetooth (https://github.com/nickclyde/rofi-bluetooth)
#
# Depends on: rofi, NetworkManager (nmcli), notify-send (optional)

# Theme
THEME="$HOME/.config/rofi/wifi.rasi"

# Constants
divider="---------"
goback="  Back"

# Build rofi command as a function
rofi_menu() {
	local prompt="$1"
	shift
	rofi -dmenu -i -theme "$THEME" -p "$prompt" "$@"
}

# Signal strength icons (nerd font)
signal_icon() {
	local signal=$1
	if ((signal >= 75)); then
		echo "󰤨"
	elif ((signal >= 50)); then
		echo "󰤥"
	elif ((signal >= 25)); then
		echo "󰤢"
	else
		echo "󰤟"
	fi
}

# Notify helper
notify() {
	if command -v notify-send &>/dev/null; then
		notify-send -a "rofi-wifi" -t 5000 "$@"
	fi
}

# Check if wifi is enabled
wifi_on() {
	nmcli radio wifi | grep -q "enabled"
}

# Toggle wifi power
toggle_wifi() {
	if wifi_on; then
		nmcli radio wifi off
		notify "Wi-Fi" "Disabled"
	else
		nmcli radio wifi on
		notify "Wi-Fi" "Enabled"
		sleep 2
	fi
	show_menu
}

# Get current connection name
current_connection() {
	nmcli -t -f NAME,TYPE connection show --active | grep "wireless" | cut -d: -f1
}

# Forget a saved network
forget_menu() {
	local saved
	saved=$(nmcli -t -f NAME,TYPE connection show | grep "wireless" | cut -d: -f1)

	if [[ -z "$saved" ]]; then
		notify "Wi-Fi" "No saved networks"
		show_menu
		return
	fi

	local options="$saved\n$divider\n$goback"
	local chosen
	chosen=$(echo -e "$options" | rofi_menu "Forget")

	case "$chosen" in
	"" | "$divider") ;;
	"$goback") show_menu ;;
	*)
		nmcli connection delete "$chosen"
		notify "Wi-Fi" "Forgot $chosen"
		show_menu
		;;
	esac
}

# Connect to a specific network
connect_to_network() {
	local ssid="$1"
	local current
	current=$(current_connection)

	# If already connected to this network, disconnect
	if [[ "$current" == "$ssid" ]]; then
		nmcli connection down "$ssid"
		notify "Wi-Fi" "Disconnected from $ssid"
		show_menu
		return
	fi

	# Check if we have a saved connection for this network
	if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
		nmcli connection up "$ssid" &&
			notify "Wi-Fi" "Connected to $ssid" ||
			notify "Wi-Fi" "Failed to connect to $ssid"
	else
		# New network — prompt for password
		local security
		security=$(nmcli -t -f SSID,SECURITY device wifi list --rescan no | grep "^${ssid}:" | head -1 | cut -d: -f2)

		if [[ -z "$security" || "$security" == "--" ]]; then
			# Open network
			nmcli device wifi connect "$ssid" &&
				notify "Wi-Fi" "Connected to $ssid" ||
				notify "Wi-Fi" "Failed to connect to $ssid"
		else
			# Secured network — ask for password
			local password
			password=$(rofi -dmenu -p "Password" -password -theme "$THEME" </dev/null)

			if [[ -n "$password" ]]; then
				nmcli device wifi connect "$ssid" password "$password" &&
					notify "Wi-Fi" "Connected to $ssid" ||
					notify "Wi-Fi" "Failed to connect to $ssid"
			fi
		fi
	fi
	show_menu
}

# Rescan wifi networks
rescan_wifi() {
	nmcli device wifi rescan 2>/dev/null
	notify "Wi-Fi" "Scanning..."
	sleep 3
	show_menu
}

# Build and show the main menu
show_menu() {
	local chosen

	if wifi_on; then
		local wifi_toggle="󱛅  Disable Wi-Fi"
		local current
		current=$(current_connection)

		# Get list of available networks
		local networks=""
		local active_line=-1
		local line_num=0

		while IFS=: read -r in_use ssid signal security; do
			[[ -z "$ssid" ]] && continue

			local icon
			icon=$(signal_icon "$signal")

			local lock=""
			[[ -n "$security" && "$security" != "--" ]] && lock="  "

			local entry="${icon}  ${ssid}${lock}"

			if [[ "$in_use" == "*" ]]; then
				entry="󱚽  ${ssid}  Connected${lock}"
				active_line=$line_num
			fi

			if [[ -n "$networks" ]]; then
				networks="${networks}\n${entry}"
			else
				networks="${entry}"
			fi
			((line_num++))
		done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no | sort -t: -k3 -nr)

		local options="${networks}\n${divider}\n${wifi_toggle}\n󰁪  Rescan\n󱛅  Forget network"

		local rofi_args=()
		if ((active_line >= 0)); then
			rofi_args+=("-a" "$active_line")
		fi

		chosen=$(echo -e "$options" | rofi_menu "Wi-Fi" "${rofi_args[@]}")
	else
		local wifi_toggle="󰤨  Enable Wi-Fi"
		chosen=$(echo -e "$wifi_toggle" | rofi_menu "Wi-Fi")
	fi

	# Handle selection
	case "$chosen" in
	"" | "$divider") ;;
	"$wifi_toggle") toggle_wifi ;;
	"󰁪  Rescan") rescan_wifi ;;
	"󱛅  Forget network") forget_menu ;;
	*)
		# Extract SSID from the chosen line
		local ssid
		# Strip: "󱚽  SSID  Connected  " or "󰤨  SSID  " etc
		ssid=$(echo "$chosen" | sed -E 's/^󱚽  //;s/^󰤨  //;s/^󰤥  //;s/^󰤢  //;s/^󰤟  //;s/  Connected//;s/  $//')
		if [[ -n "$ssid" ]]; then
			connect_to_network "$ssid"
		fi
		;;
	esac
}

# Entrypoint
case "$1" in
--status)
	if wifi_on; then
		current=$(current_connection)
		if [[ -n "$current" ]]; then
			echo "󰤨 $current"
		else
			echo "󰤨"
		fi
	else
		echo "󰤭"
	fi
	;;
*)
	show_menu
	;;
esac
