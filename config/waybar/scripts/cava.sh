#!/usr/bin/env bash

set -euo pipefail

side="${1:-full}"
bars="▁▂▃▄▅▆▇█"
config_dir="${XDG_RUNTIME_DIR:-/tmp}"
config_file="${config_dir}/waybar-cava-config"

cleanup() {
  rm -f "$config_file"
}

trap cleanup EXIT INT TERM

cat > "$config_file" <<'EOF'
[general]
bars = 24
framerate = 60
sensitivity = 120

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[smoothing]
integral = 65
monstercat = 1
waves = 0
EOF

cava -p "$config_file" | while IFS= read -r line; do
  line=${line//;/}
  output=""
  for ((i = 0; i < ${#line}; i++)); do
    digit="${line:i:1}"
    [[ "$digit" =~ [0-7] ]] || continue
    output+="${bars:$digit:1}"
  done

  half=$(( ${#output} / 2 ))
  left_part="${output:0:half}"
  right_part="${output:half}"

  case "$side" in
    left)
      reversed=""
      for ((i = ${#left_part} - 1; i >= 0; i--)); do
        reversed+="${left_part:i:1}"
      done
      printf '%s\n' "$reversed"
      ;;
    right)
      printf '%s\n' "$right_part"
      ;;
    *)
      printf '%s\n' "$output"
      ;;
  esac
done
