#!/usr/bin/env sh
set -eu

if ! quickshell ipc -c bar call launcher toggle >/dev/null 2>&1; then
  sh "$HOME/.config/quickshell/bar/launch.sh" >/dev/null 2>&1 &

  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if quickshell ipc -c bar call launcher toggle >/dev/null 2>&1; then
      exit 0
    fi
    sleep 0.15
  done

  exit 1
fi
