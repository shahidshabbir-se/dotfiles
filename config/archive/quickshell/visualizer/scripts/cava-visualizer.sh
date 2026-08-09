#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_RUNTIME_DIR:-/tmp}"
config_file="${config_dir}/quickshell-cava-config"

cleanup() {
  rm -f "$config_file"
}

trap cleanup EXIT INT TERM

cat > "$config_file" <<'EOF'
[general]
bars = 66
framerate = 60
sensitivity = 120

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
mono_option = average

[smoothing]
integral = 65
monstercat = 1
waves = 0
EOF

exec cava -p "$config_file"
