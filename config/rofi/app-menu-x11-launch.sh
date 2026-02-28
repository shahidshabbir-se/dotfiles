#!/usr/bin/env bash
#  █████╗ ██████╗ ██████╗     ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
# ██╔══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝████╗  ██║██║   ██║
# ███████║██████╔╝██████╔╝    ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
# ██╔══██║██╔═══╝ ██╔═══╝     ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
# ██║  ██║██║     ██║         ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
# ╚═╝  ╚═╝╚═╝     ╚═╝         ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝
#
# Application Menu Launcher (X11 version)
# Tokyo Night Theme

# Get current wallpaper from feh's last bg
current_wall=""
if [ -f "$HOME/.fehbg" ]; then
    current_wall=$(grep -oP "'[^']+'" "$HOME/.fehbg" | tail -n 1 | tr -d "'")
fi

# Fallback to wallpaper directory
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
    if [ -n "$current_wall" ] && [ -f "$current_wall" ]; then
        rofi -show drun \
             -theme ~/.config/rofi/app-menu.rasi \
             -theme-str '* { font: "JetBrainsMono NF Bold 12"; }' \
             -theme-str "inputbar { background-image: url(\"$current_wall\", width); }" \
             -show-icons
    else
        rofi -show drun \
             -theme ~/.config/rofi/app-menu.rasi \
             -theme-str '* { font: "JetBrainsMono NF Bold 12"; }' \
             -show-icons
    fi
fi
