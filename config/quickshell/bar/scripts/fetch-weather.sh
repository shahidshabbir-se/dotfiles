#!/usr/bin/env bash
set -eu

# One value per line: location, condition, temp, feels_like, humidity, wind_kmh
curl -sf --max-time 8 "https://wttr.in/?format=%l|%C|%t|%f|%h|%w" \
  | tr '|' '\n' \
  | sed 's/^ *//;s/ *$//' \
  | head -n 6
