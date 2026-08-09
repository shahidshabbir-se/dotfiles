#!/usr/bin/env sh
set -eu

config_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

export QML2_IMPORT_PATH="/etc/profiles/per-user/$USER/lib/qt-6/qml${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}"
export QS_ICON_THEME="Papirus-Dark"
export QS_NO_RELOAD_POPUP=1

if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
    hyprland_signature=$(command hyprctl -j instances 2>/dev/null \
        | jq -r '.[0].instance // empty')
    if [ -n "$hyprland_signature" ]; then
        export HYPRLAND_INSTANCE_SIGNATURE="$hyprland_signature"
    fi
fi

systemctl --user stop swaync 2>/dev/null || true

exec quickshell --no-duplicate -p "$config_dir"
