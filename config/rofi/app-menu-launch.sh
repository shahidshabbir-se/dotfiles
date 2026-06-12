#!/usr/bin/env sh
set -eu

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

export CHROMIUM_FLAGS="--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb"
export CHROMIUM_USER_FLAGS="--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb"

exec rofi -show drun -theme "$HOME/.config/rofi/app-menu.rasi" -show-icons
