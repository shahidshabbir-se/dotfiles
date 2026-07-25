#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null) || exit 0
artist=$(playerctl metadata xesam:artist 2>/dev/null)
title=$(playerctl metadata xesam:title 2>/dev/null)
identity=$(playerctl metadata --format '{{playerIdentity}}' 2>/dev/null)
player_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

dotfiles="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
find_icon="${dotfiles}/config/quickshell/bar/scripts/find-icon.sh"
music_icon="${dotfiles}/config/quickshell/bar/assets/svg/music.svg"

resolve_app() {
    local id="${identity,,}"
    local bus="${player_name,,}"

    case "$id" in
        *spotify*) printf '%s' "Spotify|spotify|spotify"; return ;;
        *zen*|*firefox*|*mozilla*)
            printf '%s' "Zen Browser|zen-browser|zen-beta"
            return
            ;;
        *chromium*|*google-chrome*|*chrome*)
            printf '%s' "Chromium|chromium|chromium-browser"
            return
            ;;
        *brave*) printf '%s' "Brave|brave-browser|brave-browser"; return ;;
        *vlc*) printf '%s' "VLC|vlc|vlc"; return ;;
    esac

    case "$bus" in
        spotify*) printf '%s' "Spotify|spotify|spotify"; return ;;
        *zen*|*firefox*|*mozilla*)
            printf '%s' "Zen Browser|zen-browser|zen-beta"
            return
            ;;
        chromium*) printf '%s' "Chromium|chromium|chromium-browser"; return ;;
        brave*) printf '%s' "Brave|brave-browser|brave-browser"; return ;;
    esac

    if [ -n "$identity" ]; then
        printf '%s' "${identity}|multimedia-player|multimedia-player"
    else
        printf '%s' "Media Player|multimedia-player|multimedia-player"
    fi
}

resolve_icon_path() {
    local key
    for key in "$@"; do
        [ -n "$key" ] || continue
        if [ -x "$find_icon" ]; then
            local path
            path="$("$find_icon" "$key" 2>/dev/null || true)"
            if [ -n "$path" ] && [ -f "$path" ]; then
                printf '%s' "$path"
                return
            fi
        fi
    done
}

IFS='|' read -r app_name icon_name desktop_entry <<< "$(resolve_app)"

case "$status" in
    Playing) action="Now Playing" ;;
    Paused)  action="Paused" ;;
    *)       action="$status" ;;
esac

if [ -n "$artist" ] && [ -n "$title" ]; then
    body="$artist - $title"
elif [ -n "$title" ]; then
    body="$title"
else
    body="Media playback"
fi

if [ -f "$music_icon" ]; then
    icon_path="$music_icon"
else
    icon_path="$(resolve_icon_path "$desktop_entry" "$icon_name" "zen-beta" "zen-browser")"
fi

icon_args=()
if [ -n "$icon_path" ]; then
    icon_args=(-i "$icon_path")
elif [ -n "$icon_name" ]; then
    icon_args=(-i "$icon_name")
fi

hint_args=(
    -h "string:desktop-entry:${desktop_entry}"
    -h "string:x-bar-media-key:1"
)

notify-send -a "$app_name" -t 3000 "${icon_args[@]}" "${hint_args[@]}" "$action" "$body"
