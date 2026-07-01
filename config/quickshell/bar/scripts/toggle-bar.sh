#!/usr/bin/env sh
set -eu

if ! quickshell ipc -c bar call bar toggleBar >/dev/null 2>&1; then
  sh "$HOME/.config/quickshell/bar/launch.sh" >/dev/null 2>&1 &
fi
