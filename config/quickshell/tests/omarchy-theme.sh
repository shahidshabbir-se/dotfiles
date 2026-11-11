#!/usr/bin/env bash

# Static checks for ticket #57: Tokyo Night theme state and Omarchy idle/lock
# ownership. No live session is required. Set ACTIVATION_PACKAGE to a built
# home-manager activation package to also inspect the generated state links.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../../.." && pwd)"
jq_bin="${JQ_BIN:-jq}"
config="$repo/config/omarchy/shell.json"
theme="$repo/config/quickshell/themes/tokyo-night"
shell_toml="$theme/shell.toml"
activation="${ACTIVATION_PACKAGE:-}"

fails=0
ok() { printf 'ok - %s\n' "$1"; }
fail() {
  printf 'not ok - %s\n' "$1"
  fails=$((fails + 1))
}

disabled() {
  "$jq_bin" -e --arg id "$1" \
    '(.disabledPlugins? // [] | type == "array") and (.disabledPlugins | index($id) != null)' \
    "$config" >/dev/null 2>&1
}

if disabled "omarchy.idle"; then
  ok "shell.json disables omarchy.idle"
else
  fail "shell.json disables omarchy.idle"
fi

if disabled "omarchy.lock"; then
  ok "shell.json disables omarchy.lock"
else
  fail "shell.json disables omarchy.lock"
fi

if [[ -f "$theme/colors.toml" ]]; then
  ok "theme ships colors.toml"
else
  fail "theme ships colors.toml"
fi

for key in background foreground accent red; do
  if grep -Eq "^${key}[[:space:]]*=[[:space:]]*\"#" "$theme/colors.toml" 2>/dev/null; then
    ok "colors.toml defines $key"
  else
    fail "colors.toml defines $key"
  fi
done

if [[ -f "$shell_toml" ]]; then
  ok "theme ships shell.toml"
else
  fail "theme ships shell.toml"
fi

if ! grep -q '{{' "$shell_toml" 2>/dev/null; then
  ok "shell.toml has no unresolved template tokens"
else
  fail "shell.toml has no unresolved template tokens"
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$shell_toml" 2>/dev/null; then
    ok "shell.toml parses as TOML"
  else
    fail "shell.toml parses as TOML"
  fi
fi

for section in bar lock polkit; do
  if grep -q "^\[${section}\]" "$shell_toml" 2>/dev/null; then
    ok "shell.toml defines [$section]"
  else
    fail "shell.toml defines [$section]"
  fi
done

palette_background="$(awk -F'"' '/^background[[:space:]]*=/{print $2; exit}' "$theme/colors.toml" 2>/dev/null || true)"
surface_background="$(awk -F'"' '/^background[[:space:]]*=/{print $2; exit}' "$shell_toml" 2>/dev/null || true)"
if [[ -n "$palette_background" && "$palette_background" == "$surface_background" ]]; then
  ok "shell.toml derives [bar] background from colors.toml"
else
  fail "shell.toml derives [bar] background from colors.toml"
fi

if grep -q '\.local/state/omarchy/current/theme\.name' "$repo/modules/quickshell.nix" \
  && grep -q '\.local/state/omarchy/current/theme"' "$repo/modules/quickshell.nix"; then
  ok "home-manager owns theme and theme.name state"
else
  fail "home-manager owns theme and theme.name state"
fi

if awk '/services\.hypridle = {/,/};/' "$repo/modules/hypridle.nix" | grep -q 'enable = true;' \
  && grep -q 'qylock-lock' "$repo/modules/hypridle.nix" \
  && grep -q 'qylock-lock' "$repo/modules/qylock.nix"; then
  ok "Hypridle and Qylock remain the lock/idle owners"
else
  fail "Hypridle and Qylock remain the lock/idle owners"
fi

if [[ -n "$activation" ]]; then
  home_files="$activation/home-files"
  theme_link="$home_files/.local/state/omarchy/current/theme"
  name_file="$home_files/.local/state/omarchy/current/theme.name"

  resolved_theme="$(readlink -f "$theme_link" 2>/dev/null || true)"
  if [[ -L "$theme_link" && "$resolved_theme" == */config/quickshell/themes/tokyo-night ]]; then
    ok "activation links theme to the vendored Tokyo Night tree"
  else
    fail "activation links theme to the vendored Tokyo Night tree"
  fi

  if [[ -f "$name_file" && "$(tr -d '\n' <"$name_file")" == "tokyo-night" ]]; then
    ok "activation writes theme.name = tokyo-night"
  else
    fail "activation writes theme.name = tokyo-night"
  fi
fi

if (( fails > 0 )); then
  printf '%d check(s) failed\n' "$fails" >&2
  exit 1
fi
