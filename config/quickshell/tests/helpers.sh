#!/usr/bin/env bash

# Ticket #58 smoke checks for the vendored Omarchy helpers on NixOS.
#
# These do not need a live Hyprland session or a running desktop bus. They
# prove that:
#   - the bash shebangs in config/quickshell/bin work without /bin/bash;
#   - the menu, audio, network, bluetooth, battery/power, and brightness
#     helpers exist and run their status/help path;
#   - the adaptation does not reach for Arch-only paths (pacman, /usr/bin)
#     or fail on a missing interpreter.
#
# Commands expected to change machine state (audio output cycling, bluetooth
# power, brightness set, service restarts) are not run here.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/../../.." && pwd)"
omarchy_path="${OMARCHY_PATH:-$repo_root/config/quickshell}"
bin="$omarchy_path/bin"
timeout_bin="${TIMEOUT_BIN:-timeout}"

export OMARCHY_PATH="$omarchy_path"
export PATH="$bin:$PATH"

tmp="$(mktemp -d "${OMARCHY_HELPER_TEST_TMPDIR:-/tmp}/omarchy-helpers.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# A read-only TMPDIR breaks helpers that shell out to tools using a temp file
# (for example tac in powerprofiles-list). Keep it inside the test directory.
export TMPDIR="$tmp"

# The helpers cache under XDG_RUNTIME_DIR. Use it when the session provides a
# writable one, otherwise give them a writable directory so a read-only
# sandbox does not look like an Arch failure.
if [[ -z ${XDG_RUNTIME_DIR:-} || ! -w $XDG_RUNTIME_DIR ]]; then
  mkdir -p "$tmp/runtime"
  export XDG_RUNTIME_DIR="$tmp/runtime"
fi

fails=0
checks=0
ok() {
  checks=$((checks + 1))
  printf 'ok - %s\n' "$1"
}
fail() {
  checks=$((checks + 1))
  fails=$((fails + 1))
  printf 'not ok - %s\n' "$1"
}

# Stderr patterns that mean the helper still assumes Arch. A clear "missing
# command, install this package" message is fine; a broken interpreter and a
# bare pacman/Arch path are not.
arch_only() {
  grep -E -i \
    'bad interpreter|/usr/bin/|pacman|omarchy-pkg-|: command not found' \
    "$1" >/dev/null 2>&1
}

# run <label> <acceptable-statuses> <command...>
run() {
  local label="$1" expected="$2"
  shift 2

  local out="$tmp/out" err="$tmp/err" status reason=""
  : >"$out"
  : >"$err"

  timeout 10 "$@" >"$out" 2>"$err"
  status=$?

  if ((status == 124)); then
    reason="timed out"
  elif [[ " $expected " != *" $status "* ]]; then
    reason="exit $status (expected: $expected)"
  elif arch_only "$err"; then
    reason="Arch-only error: $(head -n 1 "$err")"
  fi

  if [[ -n $reason ]]; then
    fail "$label - $reason"
  else
    ok "$label"
  fi
}

# --- shebangs ---------------------------------------------------------------

bash_scripts=0
python_scripts=0
while IFS= read -r script; do
  first="$(timeout 5 head -n 1 "$script")"
  case "$first" in
    '#!/usr/bin/env bash')
      bash_scripts=$((bash_scripts + 1))
      ;;
    '#!/usr/bin/python3')
      # The Python interpreters are ticket #61's tracked gap; this ticket
      # deliberately does not patch them.
      python_scripts=$((python_scripts + 1))
      ;;
    *)
      fail "unexpected shebang in ${script#"$bin"/}: $first"
      ;;
  esac
done < <(grep -r -I -l '^#!' "$bin" 2>/dev/null | sort)

if ((bash_scripts > 0)); then
  ok "bash shebangs use /usr/bin/env bash ($bash_scripts scripts)"
else
  fail "no bash scripts found under $bin"
fi
if ((python_scripts > 0)); then
  ok "python3 shebangs left for the tracked known-broken list ($python_scripts scripts)"
fi

# Every helper the bar surfaces call must be present and executable.
for helper in \
  omarchy omarchy-menu omarchy-menu-select omarchy-shell uwsm-app \
  omarchy-audio-input-mute omarchy-audio-input-set-default \
  omarchy-audio-output-set-default omarchy-audio-output-sink \
  omarchy-audio-output-switch omarchy-audio-output-volume \
  omarchy-audio-sink-availability omarchy-audio-source-switch \
  omarchy-network-band omarchy-network-qr omarchy-network-speedtest \
  omarchy-network-status omarchy-network-wifi-connected omarchy-dns \
  omarchy-bluetooth-device omarchy-bluetooth-power \
  omarchy-battery-status omarchy-battery-present omarchy-power-present \
  omarchy-powerprofiles-list omarchy-powerprofiles-set omarchy-system-stats \
  omarchy-brightness-display omarchy-brightness-display-ddc \
  omarchy-brightness-keyboard omarchy-hw-display; do
  if [[ -x "$bin/$helper" ]]; then
    ok "helper exists: $helper"
  else
    fail "helper is missing or not executable: $helper"
  fi
done

# --- menu -------------------------------------------------------------------

run "menu helper prints usage" 0 omarchy-menu --help
run "menu wrapper prints usage" 0 omarchy menu --help
run "menu select without arguments reports usage" 1 omarchy-menu-select
run "uwsm-app shim runs a command directly" 0 uwsm-app -- true

if timeout 5 grep -q 'uwsm-app -- gtk-launch' "$omarchy_path/shell/services/AppLibrary.qml"; then
  fail "AppLibrary still launches apps through uwsm-app"
else
  ok "AppLibrary launches desktop entries with gtk-launch"
fi

# --- audio ------------------------------------------------------------------

run "audio output sink status" 0 omarchy-audio-output-sink
run "audio sink/source availability status" 0 omarchy-audio-sink-availability
run "audio source availability status" 0 omarchy-audio-sink-availability sources
run "audio volume helper reports usage" 1 omarchy-audio-output-volume

# --- network ----------------------------------------------------------------

run "network status" 0 omarchy-network-status
run "network verbose status" 0 omarchy-network-status --verbose
run "network Wi-Fi connected probe" '0 1' omarchy-network-wifi-connected
run "network band status" '0 1' omarchy-network-band
run "network Wi-Fi QR status" '0 1' omarchy-network-qr
run "network speedtest reports usage" 2 omarchy-network-speedtest
run "DNS provider query" 0 omarchy dns
if [[ -e /etc/NIXOS ]]; then
  # Applying a provider writes generated NixOS files. The helper must refuse
  # instead of making a change the next activation reverts.
  run "DNS provider change is refused on NixOS" 1 omarchy-dns Cloudflare
fi

# --- bluetooth --------------------------------------------------------------

run "bluetooth power state probe" '0 1' omarchy-bluetooth-power is-on
run "bluetooth device helper reports usage" 1 omarchy-bluetooth-device

# --- battery and power ------------------------------------------------------

run "battery present probe" '0 1' omarchy-battery-present
run "external power probe" '0 1' omarchy-power-present
run "battery status" 0 omarchy-battery-status
run "battery shell status" 0 omarchy-battery-status --shell
run "power profile list" 0 omarchy-powerprofiles-list
run "power profile list with active state" 0 omarchy-powerprofiles-list --active-state
run "powerprofile set reports usage for an unknown action" 1 omarchy-powerprofiles-set invalid
run "system stats bar widget" 0 omarchy-system-stats --bar-widget
run "system stats text" 0 omarchy-system-stats

# --- brightness -------------------------------------------------------------

run "backlight device probe" '0 1' omarchy-hw-display
run "display brightness status" '0 1' omarchy-brightness-display
run "keyboard brightness without a device fails clearly" 1 omarchy-brightness-keyboard
run "DDC brightness without ddcutil fails clearly" 1 omarchy-brightness-display-ddc DP-1
run "Apple display brightness without a device fails clearly" 1 omarchy-brightness-display-apple

# --- syntax ----------------------------------------------------------------

for helper in \
  omarchy-menu omarchy-audio-output-sink omarchy-audio-output-volume \
  omarchy-audio-output-switch omarchy-audio-sink-availability \
  omarchy-network-band omarchy-network-qr omarchy-network-speedtest \
  omarchy-dns omarchy-bluetooth-device omarchy-bluetooth-power \
  omarchy-battery-status omarchy-powerprofiles-list \
  omarchy-powerprofiles-set omarchy-brightness-display \
  omarchy-brightness-display-ddc omarchy-brightness-keyboard uwsm-app; do
  if timeout 5 bash -n "$bin/$helper"; then
    ok "bash -n: $helper"
  else
    fail "bash -n: $helper"
  fi
done

printf '\n%s checks, %s failed\n' "$checks" "$fails"
exit $((fails > 0 ? 1 : 0))
