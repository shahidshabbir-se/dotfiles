#!/usr/bin/env bash
set -eu

read -r uptime_seconds _ < /proc/uptime
total="${uptime_seconds%.*}"

hours=$((total / 3600))
minutes=$(((total % 3600) / 60))

if (( hours > 0 )); then
  printf '%dh %dm\n' "$hours" "$minutes"
else
  printf '%dm\n' "$minutes"
fi

boot_epoch=$(( $(date +%s) - total ))
printf 'Since %s\n' "$(date -d "@$boot_epoch" '+%H:%M')"
