#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
default_sound="${script_dir}/../assets/sounds/notification.mp3"
sound_file="${NOTIFICATION_SOUND_FILE:-$default_sound}"

if ! command -v pw-play >/dev/null 2>&1; then
  exit 0
fi

if [ -f "$sound_file" ]; then
  pw-play "$sound_file" >/dev/null 2>&1 &
  exit 0
fi

exit 0
