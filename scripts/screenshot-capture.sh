#!/usr/bin/env bash
set -euo pipefail

# Thin wrapper around grimblast. HDR screenshot tone-mapping is handled by
# Hyprland (PR #12204, 0.54+) — keep sdrbrightness on the monitor config.

exec grimblast "$@"
