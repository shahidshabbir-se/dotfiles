#!/usr/bin/env bash
#  █████╗ ██████╗ ██████╗     ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
# ██╔══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝████╗  ██║██║   ██║
# ███████║██████╔╝██████╔╝    ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
# ██╔══██║██╔═══╝ ██╔═══╝     ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
# ██║  ██║██║     ██║         ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
# ╚═╝  ╚═╝╚═╝     ╚═╝         ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
#
#  ██╗      █████╗ ██╗   ██╗███╗   ██╗ ██████╗██╗  ██╗███████╗██████╗
#  ██║     ██╔══██╗██║   ██║████╗  ██║██╔════╝██║  ██║██╔════╝██╔══██╗
#  ██║     ███████║██║   ██║██╔██╗ ██║██║     ███████║█████╗  ██████╔╝
#  ██║     ██╔══██║██║   ██║██║╚██╗██║██║     ██╔══██║██╔══╝  ██╔══██╗
#  ███████╗██║  ██║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████╗██║  ██║
#  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
#
# Application Menu Launcher with wallpaper background
# Tokyo Night Theme

# Get current wallpaper from swww
current_wall=$(swww query 2>/dev/null | grep -oP 'image: \K.*' | head -n 1)

# Fallback to default wallpaper directory if swww query fails
if [ -z "$current_wall" ] || [ ! -f "$current_wall" ]; then
    wall_dir="${HOME}/Pictures/Wallpapers"
    if [ -d "$wall_dir" ]; then
        current_wall=$(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | head -n 1)
    fi
fi

# Toggle rofi
if pgrep -x rofi > /dev/null; then
    pkill -x rofi
else
    # Launch rofi with wallpaper background
    if [ -n "$current_wall" ] && [ -f "$current_wall" ]; then
        rofi -show drun \
             -theme ~/.config/rofi/app-menu.rasi \
             -theme-str "inputbar { background-image: url(\"$current_wall\", width); }" \
             -show-icons
    else
        # Fallback without background image
        rofi -show drun \
             -theme ~/.config/rofi/app-menu.rasi \
             -show-icons
    fi
fi
