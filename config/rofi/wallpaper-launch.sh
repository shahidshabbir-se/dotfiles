#!/run/current-system/sw/bin/bash
#  ██╗    ██╗ █████╗ ██╗     ██╗     ██████╗  █████╗ ██████╗ ███████╗██████╗
#  ██║    ██║██╔══██╗██║     ██║     ██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
#  ██║ █╗ ██║███████║██║     ██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝
#  ██║███╗██║██╔══██║██║     ██║     ██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗
#  ╚███╔███╔╝██║  ██║███████╗███████╗██║     ██║  ██║██║     ███████╗██║  ██║
#   ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


# Set some variables
wall_dir="${HOME}/Pictures/Wallpapers"
cacheDir="${HOME}/.cache/jp/${theme}"
rofi_command="rofi -x11 -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi -theme-str ${rofi_override}"

# Create cache dir if not exists
if [ ! -d "${cacheDir}" ] ; then
        mkdir -p "${cacheDir}"
    fi

# Calculate monitor resolution for proper thumbnail sizing
physical_monitor_size=24
monitor_res=$(hyprctl monitors 2>/dev/null | grep -A2 "Monitor" | head -n 2 | awk '{print $1}' | grep -oE '^[0-9]+' | head -n 1)

# Fallback if hyprctl is not available or returns empty
if [ -z "$monitor_res" ]; then
    monitor_res=1920
fi

# Calculate DPI with fallback (avoid bc dependency)
if command -v bc >/dev/null 2>&1; then
    dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc 2>/dev/null | xargs printf "%.0f" 2>/dev/null)
else
    # Fallback calculation without bc
    dotsperinch=$((monitor_res / physical_monitor_size))
fi

# Fallback for DPI calculation
if [ -z "$dotsperinch" ] || [ "$dotsperinch" -eq 0 ]; then
    dotsperinch=80
fi

monitor_res=$(( $monitor_res * $physical_monitor_size / $dotsperinch ))

rofi_override="element-icon{size:${monitor_res}px;border-radius:0px;}"

# Convert images in directory and save to cache dir
for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$imagen" ]; then
		nombre_archivo=$(basename "$imagen")
			if [ ! -f "${cacheDir}/${nombre_archivo}" ] ; then
				convert -strip "$imagen" -thumbnail 500x500^ -gravity center -extent 500x500 "${cacheDir}/${nombre_archivo}"
			fi
    fi
done

# Select a picture with rofi
wall_selection=$(find "${wall_dir}"  -maxdepth 1  -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do  echo -en "$A\x00icon\x1f""${cacheDir}"/"$A\n" ; done | $rofi_command)

# Set the wallpaper
[[ -n "$wall_selection" ]] || exit 1
swww img "${wall_dir}/${wall_selection}" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-fps 60 \
    --transition-duration 0.8

# Update hyprlock wallpaper symlink
ln -sf "${wall_dir}/${wall_selection}" "${HOME}/.config/rofi/.current_wallpaper"

# Optional notification
if command -v notify-send >/dev/null 2>&1; then
    notify-send -i "${wall_dir}/${wall_selection}" "Wallpaper Applied" "${wall_selection}" -t 2000
fi

exit 0
