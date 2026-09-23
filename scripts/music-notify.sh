#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null) || exit 0
artist=$(playerctl metadata xesam:artist 2>/dev/null)
title=$(playerctl metadata xesam:title 2>/dev/null)
art_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
identity=$(playerctl metadata --format '{{playerIdentity}}' 2>/dev/null)
player_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

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

icon_args=()
if [ -n "$icon_name" ]; then
    icon_args=(-i "$icon_name")
fi

hint_args=(
    -h "string:desktop-entry:${desktop_entry}"
    -h "string:x-bar-media-key:1"
)

# Quickshell only treats image-path as a file if it starts with file:;
# anything else (including https album art) is loaded as an icon name and
# renders as a missing texture. notify-send also drops https -i values.
art_file=""
case "$art_url" in
    "") ;;
    file://*) art_file="${art_url#file://}" ;;
    /*) art_file="$art_url" ;;
    http://*|https://*)
        cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/music-notify"
        mkdir -p "$cache_dir"
        art_id=$(printf '%s' "$art_url" | sha256sum | cut -d' ' -f1)
        art_file="$cache_dir/$art_id"
        if [ ! -s "$art_file" ] && command -v curl >/dev/null; then
            if ! curl -fsSL --max-time 3 -o "$art_file.part" "$art_url"; then
                rm -f "$art_file.part"
                art_file=""
            else
                mv "$art_file.part" "$art_file"
            fi
        fi
        ;;
esac

if [ -n "$art_file" ] && [ -s "$art_file" ]; then
    icon_args=(-i "$art_file")
    hint_args+=(-h "string:image-path:file://${art_file}")
fi

notify-send -a "$app_name" -t 3000 "${icon_args[@]}" "${hint_args[@]}" "$action" "$body"
