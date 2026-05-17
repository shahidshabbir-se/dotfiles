#!/usr/bin/env bash
# Bootstrap script for Ubuntu WSL with standalone Home Manager.

set -euo pipefail

USER_NAME="shahid"
WSL_DISTRO="${WSL_DISTRO_NAME:-Ubuntu}"
DOTFILES="$HOME/dotfiles"
SSH_DIR="$HOME/.ssh"
GITHUB_USER="shahidshabbir-se"
DOTFILES_REPO_HTTPS="https://github.com/$GITHUB_USER/dotfiles.git"
DOTFILES_REPO_SSH="git@github.com:$GITHUB_USER/dotfiles.git"
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_REPO_HTTPS="https://github.com/$GITHUB_USER/opencode-ai.git"
OPENCODE_REPO_SSH="git@github.com:$GITHUB_USER/opencode-ai.git"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
WALLPAPERS_REPO_HTTPS="https://github.com/$GITHUB_USER/wallpapers.git"
WALLPAPERS_REPO_SSH="git@github.com:$GITHUB_USER/wallpapers.git"
WINDOWS_WALLPAPERS_DIR="/mnt/c/Users/$USER_NAME/Pictures/Wallpapers"
HOME_MANAGER_CONFIG="$DOTFILES/hosts/wsl/home.nix"
ENCRYPTED_KEY="$DOTFILES/secrets/id_ed25519.age"
NIX_PROFILE="$HOME/.nix-profile/etc/profile.d/nix.sh"
WINDOWS_AHK_DIR="/mnt/c/Users/$USER_NAME/.config/autohotkey"
WINDOWS_AHK_SCRIPT="$WINDOWS_AHK_DIR/wsl.ahk"
WINDOWS_STARTUP_DIR="/mnt/c/Users/$USER_NAME/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
WINDOWS_GLAZEWM_DIR="/mnt/c/Users/$USER_NAME/.glzr/glazewm"
WINDOWS_HOME_LINK="/mnt/c/home"

POWERSHELL_EXE="$(command -v powershell.exe || true)"
WINGET_EXE="$(command -v winget.exe || true)"
SUDO_EXE="$(command -v sudo.exe || true)"

if [ -z "$POWERSHELL_EXE" ] && [ -x /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
  POWERSHELL_EXE="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
fi

if [ -z "$WINGET_EXE" ] && [ -x "/mnt/c/Users/$USER_NAME/AppData/Local/Microsoft/WindowsApps/winget.exe" ]; then
  WINGET_EXE="/mnt/c/Users/$USER_NAME/AppData/Local/Microsoft/WindowsApps/winget.exe"
fi

if [ -z "$SUDO_EXE" ] && [ -x /mnt/c/Windows/System32/sudo.exe ]; then
  SUDO_EXE="/mnt/c/Windows/System32/sudo.exe"
fi

mkdir -p "$HOME/tmp"
export TMPDIR="$HOME/tmp"

echo "=== WSL Home Manager Bootstrap ==="

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo "This script is intended for WSL. Continuing anyway."
fi

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

ensure_repo() {
  local name="$1"
  local dir="$2"
  local https_url="$3"
  local ssh_url="$4"

  if [ ! -d "$dir/.git" ]; then
    echo "Cloning $name..."
    mkdir -p "$(dirname "$dir")"
    if ! git clone "$ssh_url" "$dir"; then
      echo "SSH clone failed for $name, trying HTTPS..."
      git clone "$https_url" "$dir" || {
        echo "Could not clone $name. Skipping."
        return 0
      }
    fi
  fi

  if [ -d "$dir/.git" ]; then
    echo "Setting $name remote to SSH..."
    git -C "$dir" remote set-url origin "$ssh_url"
  fi
}

ensure_repo "dotfiles" "$DOTFILES" "$DOTFILES_REPO_HTTPS" "$DOTFILES_REPO_SSH"

if [ -f "$NIX_PROFILE" ]; then
  # shellcheck source=/dev/null
  . "$NIX_PROFILE"
fi

if ! command -v nix >/dev/null 2>&1; then
  if [ ! -d /nix ]; then
    echo "Creating /nix. sudo may prompt for your password."
    sudo mkdir -m 0755 /nix
    sudo chown "$USER_NAME" /nix
  fi

  echo "Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

if [ ! -f "$SSH_DIR/id_ed25519" ] && [ -f "$ENCRYPTED_KEY" ]; then
  if [ -t 0 ]; then
    echo "Decrypting SSH key..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    nix-shell -p age --run "age -d -o '$SSH_DIR/id_ed25519' '$ENCRYPTED_KEY'"
    chmod 600 "$SSH_DIR/id_ed25519"
  else
    echo "Skipping SSH key decrypt because this shell is non-interactive."
    echo "Run this script from a WSL terminal to decrypt the key and clone private repos."
  fi
fi

if [ -f "$SSH_DIR/id_ed25519" ] && [ ! -f "$SSH_DIR/id_ed25519.pub" ]; then
  echo "Generating SSH public key..."
  ssh-keygen -y -f "$SSH_DIR/id_ed25519" > "$SSH_DIR/id_ed25519.pub"
fi

ensure_repo "opencode" "$OPENCODE_DIR" "$OPENCODE_REPO_HTTPS" "$OPENCODE_REPO_SSH"
ensure_repo "wallpapers" "$WALLPAPERS_DIR" "$WALLPAPERS_REPO_HTTPS" "$WALLPAPERS_REPO_SSH"

install_windows_app() {
  local name="$1"
  local winget_id="$2"
  local check_path="$3"

  if [ -z "$POWERSHELL_EXE" ] || [ -z "$WINGET_EXE" ]; then
    echo "Skipping $name install because Windows PowerShell or winget is unavailable."
    return 0
  fi

  if "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "Test-Path '$check_path'" | grep -qi true; then
    echo "$name already installed."
    return 0
  fi

  echo "Installing $name on Windows..."
  "$WINGET_EXE" install --id "$winget_id" --exact --silent --accept-package-agreements --accept-source-agreements || {
    echo "Could not install $name with winget. Skipping."
    return 0
  }
}

install_windows_app "Zen Browser" "Zen-Team.Zen-Browser" "C:\\Program Files\\Zen Browser\\zen.exe"
install_windows_app "WezTerm" "wez.wezterm" "C:\\Program Files\\WezTerm\\wezterm-gui.exe"
install_windows_app "AutoHotkey" "AutoHotkey.AutoHotkey" "C:\\Users\\$USER_NAME\\AppData\\Local\\Programs\\AutoHotkey\\v2\\AutoHotkey64.exe"
install_windows_app "GlazeWM" "glzr-io.glazewm" "C:\\Program Files\\glzr.io\\GlazeWM\\glazewm.exe"
install_windows_app "Spotify" "Spotify.Spotify" "C:\\Users\\$USER_NAME\\AppData\\Roaming\\Spotify\\Spotify.exe"
install_windows_app "VLC" "VideoLAN.VLC" "C:\\Program Files\\VideoLAN\\VLC\\vlc.exe"

ensure_windows_key_policy() {
  local ps_script

  ps_script="\
    \$ErrorActionPreference = 'Stop'; \
    \$systemPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System'; \
    \$explorerPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer'; \
    New-Item -Path \$systemPath -Force | Out-Null; \
    New-Item -Path \$explorerPath -Force | Out-Null; \
    New-ItemProperty -Path \$systemPath -Name DisableLockWorkstation -Value 1 -PropertyType DWord -Force | Out-Null; \
    New-ItemProperty -Path \$explorerPath -Name NoWinKeys -Value 1 -PropertyType DWord -Force | Out-Null"

  if [ -z "$POWERSHELL_EXE" ]; then
    echo "Skipping Windows key policy because PowerShell is unavailable."
    return 0
  fi

  if "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "\
    \$system = Get-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System' -Name DisableLockWorkstation -ErrorAction SilentlyContinue; \
    \$explorer = Get-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer' -Name NoWinKeys -ErrorAction SilentlyContinue; \
    if (\$system.DisableLockWorkstation -eq 1 -and \$explorer.NoWinKeys -eq 1) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
    return 0
  fi

  echo "Configuring Windows key policy. Approve the Windows sudo/UAC prompt if shown."
  "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "$ps_script" >/dev/null 2>&1 || \
    { [ -n "$SUDO_EXE" ] && "$SUDO_EXE" --new-window "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "$ps_script" >/dev/null 2>&1; } || true
}

ensure_windows_key_policy

ensure_windows_symlink() {
  local link_path="$1"
  local target_path="$2"
  local link_path_win="$3"
  local target_path_win="$4"
  local ps_script

  if [ -z "$POWERSHELL_EXE" ]; then
    echo "Could not create symlink $link_path because PowerShell is unavailable; falling back where possible."
    return 1
  fi

  if "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "\
    \$link = '$link_path_win'; \
    \$target = '$target_path_win'; \
    \$item = Get-Item -LiteralPath \$link -Force -ErrorAction SilentlyContinue; \
    if (\$item -and ((\$item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) -and (([string]\$item.Target).Replace('UNC\\', '\\\\') -eq \$target)) { exit 0 } else { exit 1 }" >/dev/null 2>&1; then
    return 0
  fi

  ps_script="\
    \$ErrorActionPreference = 'Stop'; \
    \$link = '$link_path_win'; \
    \$target = '$target_path_win'; \
    \$parent = Split-Path -Parent \$link; \
    if (\$parent -and -not (Test-Path -LiteralPath \$parent)) { New-Item -ItemType Directory -Force \$parent | Out-Null; } \
    if (Test-Path -LiteralPath \$link) { \
      \$item = Get-Item -LiteralPath \$link -Force; \
      if ((\$item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { \
        Remove-Item -LiteralPath \$link -Force -Recurse; \
      } else { \
        Move-Item -LiteralPath \$link -Destination (\$link + '.backup') -Force; \
      } \
    } \
    New-Item -ItemType SymbolicLink -Path \$link -Target \$target -Force | Out-Null"

  "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "$ps_script" >/dev/null 2>&1 || {
    echo "Could not create symlink $link_path. Existing link is missing or points elsewhere; falling back where possible."
    return 1
  }
}

copy_windows_file() {
  local source_path="$1"
  local target_path="$2"

  rm -f "$target_path" 2>/dev/null || true
  cp "$source_path" "$target_path" || {
    echo "Could not copy $source_path to $target_path. Skipping."
    return 0
  }
}

if [ -d "/mnt/c/Users/$USER_NAME" ]; then
  echo "Setting up Spicetify on Windows..."
  if [ -n "$POWERSHELL_EXE" ]; then
  "$POWERSHELL_EXE" -NoProfile -ExecutionPolicy Bypass -Command "\
    \$ErrorActionPreference = 'Continue'; \
    \$spotify = 'C:\\Users\\$USER_NAME\\AppData\\Roaming\\Spotify\\Spotify.exe'; \
    \$spotifyDir = 'C:\\Users\\$USER_NAME\\AppData\\Roaming\\Spotify'; \
    \$prefs = 'C:\\Users\\$USER_NAME\\AppData\\Roaming\\Spotify\\prefs'; \
    \$spicetifyExe = 'C:\\Users\\$USER_NAME\\AppData\\Local\\spicetify\\spicetify.exe'; \
    \$spicetifyVersion = 'lucid-adblock-hidepodcasts-keyboard-shuffle-newreleases-ncs-rotating-v1'; \
    \$spicetifyMarker = Join-Path \$env:APPDATA 'spicetify\\.dotfiles-applied'; \
    if (Test-Path \$spotify) { \
      if (-not (Test-Path \$spicetifyExe)) { \
        try { Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/spicetify/cli/main/install.ps1' | Invoke-Expression } catch { Write-Output \$_.Exception.Message }; \
      } \
      \$env:PATH = \$env:PATH + ';' + \$env:LOCALAPPDATA + '\\spicetify'; \
      if (Test-Path \$spicetifyExe) { \
        if ((Test-Path \$spicetifyMarker) -and ((Get-Content \$spicetifyMarker -Raw).Trim() -eq \$spicetifyVersion)) { \
          Write-Output 'Spicetify already applied; skipping.'; \
        } else { \
        if (-not (Test-Path \$prefs)) { \
          Write-Output 'Starting Spotify once so it can create prefs...'; \
          Start-Process -FilePath \$spotify; \
          for (\$i = 0; \$i -lt 30 -and -not (Test-Path \$prefs); \$i++) { Start-Sleep -Seconds 2 }; \
          Stop-Process -Name Spotify -Force -ErrorAction SilentlyContinue; \
        } \
        if (Test-Path \$prefs) { \
          & \$spicetifyExe config spotify_path \$spotifyDir; \
          & \$spicetifyExe config prefs_path \$prefs; \
          & \$spicetifyExe config current_theme marketplace; \
          if (-not (Test-Path (Join-Path \$env:APPDATA 'spicetify\\CustomApps\\marketplace'))) { \
            try { Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1' | Invoke-Expression } catch { Write-Output \$_.Exception.Message }; \
          } \
          \$themeDir = Join-Path \$env:APPDATA 'spicetify\\Themes\\Lucid'; \
          New-Item -ItemType Directory -Force \$themeDir | Out-Null; \
          Invoke-WebRequest -UseBasicParsing 'https://spicetify-lucid.sanooj.uk/spice/user.css' -OutFile (Join-Path \$themeDir 'user.css'); \
          Invoke-WebRequest -UseBasicParsing 'https://spicetify-lucid.sanooj.uk/spice/color.ini' -OutFile (Join-Path \$themeDir 'color.ini'); \
          Invoke-WebRequest -UseBasicParsing 'https://spicetify-lucid.sanooj.uk/spice/theme.js' -OutFile (Join-Path \$themeDir 'theme.js'); \
          Add-Content -Path (Join-Path \$themeDir 'user.css') -Value '@keyframes rotating {from {transform: rotate(0deg);}to {transform: rotate(360deg);}}.cover-art, .main-nowPlayingView-coverArtContainer::after, .main-nowPlayingView-coverArtContainer::before {animation: rotating 10s linear infinite;border-radius: 50%;}.cover-art {clip-path: circle(50% at 50% 50%);} .main-nowPlayingBar-left button {background: transparent;} .main-nowPlayingView-coverArt {box-shadow:none; filter: drop-shadow(0 9px 9px rgba(0,0,0,.271));}'; \
          \$extensionDir = Join-Path \$env:APPDATA 'spicetify\\Extensions'; \
          New-Item -ItemType Directory -Force \$extensionDir | Out-Null; \
          Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/spicetify/cli/main/Extensions/keyboardShortcut.js' -OutFile (Join-Path \$extensionDir 'keyboardShortcut.js'); \
          Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/spicetify/cli/main/Extensions/shuffle%2B.js' -OutFile (Join-Path \$extensionDir 'shuffle+.js'); \
          Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/rxri/spicetify-extensions/main/adblock/adblock.js' -OutFile (Join-Path \$extensionDir 'adblock.js'); \
          Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/theRealPadster/spicetify-hide-podcasts/main/hidePodcasts.js' -OutFile (Join-Path \$extensionDir 'hidePodcasts.js'); \
          \$tmp = Join-Path \$env:TEMP 'spicetify-cli-main.zip'; \
          \$extract = Join-Path \$env:TEMP 'spicetify-cli-main'; \
          Remove-Item -Recurse -Force \$extract -ErrorAction SilentlyContinue; \
          try { \
            Invoke-WebRequest -UseBasicParsing 'https://github.com/spicetify/cli/archive/refs/heads/main.zip' -OutFile \$tmp; \
            Expand-Archive -Force \$tmp \$extract; \
            \$newReleases = Join-Path \$extract 'cli-main\\CustomApps\\new-releases'; \
            if (Test-Path \$newReleases) { Copy-Item -Recurse -Force \$newReleases (Join-Path \$env:APPDATA 'spicetify\\CustomApps\\new-releases') } \
          } catch { Write-Output ('Skipping new-releases refresh: ' + \$_.Exception.Message) }; \
          Remove-Item -Force \$tmp -ErrorAction SilentlyContinue; \
          Remove-Item -Recurse -Force \$extract -ErrorAction SilentlyContinue; \
          \$ncsDir = Join-Path \$env:APPDATA 'spicetify\\CustomApps\\ncs-visualizer'; \
          New-Item -ItemType Directory -Force \$ncsDir | Out-Null; \
          try { \
            Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Konsl/spicetify-ncs-visualizer/dist/manifest.json' -OutFile (Join-Path \$ncsDir 'manifest.json'); \
            Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Konsl/spicetify-ncs-visualizer/dist/index.js' -OutFile (Join-Path \$ncsDir 'index.js'); \
            Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/Konsl/spicetify-ncs-visualizer/dist/style.css' -OutFile (Join-Path \$ncsDir 'style.css'); \
          } catch { Write-Output ('Skipping ncs-visualizer refresh: ' + \$_.Exception.Message) }; \
          & \$spicetifyExe config current_theme Lucid; \
          & \$spicetifyExe config color_scheme dark; \
          & \$spicetifyExe config inject_css 1 inject_theme_js 1 replace_colors 1; \
          & \$spicetifyExe config extensions 'adblock.js|hidePodcasts.js|keyboardShortcut.js|shuffle+.js'; \
          & \$spicetifyExe config custom_apps 'marketplace|new-releases|ncs-visualizer'; \
          & \$spicetifyExe backup apply; \
          & \$spicetifyExe apply; \
          Set-Content -Path \$spicetifyMarker -Value \$spicetifyVersion; \
        } else { \
          Write-Output 'Spotify prefs still missing; open Spotify once, wait for it to finish first launch, then rerun bootstrap.'; \
        } \
        } \
      } \
    } else { \
      Write-Output 'Spotify executable not found yet; rerun bootstrap after Spotify finishes installing.'; \
    }" || true
  else
    echo "Skipping Spicetify setup because PowerShell is unavailable."
  fi

  echo "Linking Windows config files to WSL dotfiles..."
  ensure_windows_symlink \
    "$WINDOWS_HOME_LINK" \
    "$HOME" \
    "C:\\home" \
    "\\\\wsl$\\$WSL_DISTRO\\home\\$USER_NAME" || true

  ensure_windows_symlink \
    "/mnt/c/Users/$USER_NAME/.wezterm.lua" \
    "$DOTFILES/config/wsl/wezterm.lua" \
    "C:\\Users\\$USER_NAME\\.wezterm.lua" \
    "\\\\wsl$\\$WSL_DISTRO\\home\\$USER_NAME\\dotfiles\\config\\wsl\\wezterm.lua" || copy_windows_file "$DOTFILES/config/wsl/wezterm.lua" "/mnt/c/Users/$USER_NAME/.wezterm.lua"

  mkdir -p "$WINDOWS_AHK_DIR"
  ensure_windows_symlink \
    "$WINDOWS_AHK_SCRIPT" \
    "$DOTFILES/config/wsl/autohotkey.ahk" \
    "C:\\Users\\$USER_NAME\\.config\\autohotkey\\wsl.ahk" \
    "\\\\wsl$\\$WSL_DISTRO\\home\\$USER_NAME\\dotfiles\\config\\wsl\\autohotkey.ahk" || copy_windows_file "$DOTFILES/config/wsl/autohotkey.ahk" "$WINDOWS_AHK_SCRIPT"

  if [ -d "$WINDOWS_STARTUP_DIR" ]; then
    ensure_windows_symlink \
      "$WINDOWS_STARTUP_DIR/wsl.ahk" \
      "$DOTFILES/config/wsl/autohotkey.ahk" \
      "C:\\Users\\$USER_NAME\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\wsl.ahk" \
      "\\\\wsl$\\$WSL_DISTRO\\home\\$USER_NAME\\dotfiles\\config\\wsl\\autohotkey.ahk" || copy_windows_file "$DOTFILES/config/wsl/autohotkey.ahk" "$WINDOWS_STARTUP_DIR/wsl.ahk"
    echo "AutoHotkey startup file: C:\\Users\\$USER_NAME\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\wsl.ahk"
  fi
  echo "AutoHotkey file: C:\\Users\\$USER_NAME\\.config\\autohotkey\\wsl.ahk"

  if [ -n "$POWERSHELL_EXE" ]; then
  "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "\
    \$script = 'C:\\Users\\$USER_NAME\\.config\\autohotkey\\wsl.ahk'; \
    \$exe = 'C:\\Users\\$USER_NAME\\AppData\\Local\\Programs\\AutoHotkey\\v2\\AutoHotkey64.exe'; \
    \$running = Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue; \
    if (\$running) { \
      Write-Output 'Reloading AutoHotkey script if permissions allow.'; \
      Stop-Process -Name 'AutoHotkey*' -Force -ErrorAction SilentlyContinue; \
      Start-Sleep -Milliseconds 300; \
      \$stillRunning = Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue; \
      if (\$stillRunning) { \
        Write-Output 'AutoHotkey is still running, likely elevated. Skipping duplicate launch.'; \
      } elseif ((Test-Path \$exe) -and (Test-Path \$script)) { \
        Start-Process -FilePath \$exe -ArgumentList ('\"' + \$script + '\"'); \
      } \
    } elseif ((Test-Path \$exe) -and (Test-Path \$script)) { \
      Start-Process -FilePath \$exe -ArgumentList ('\"' + \$script + '\"'); \
    }" || true
  else
    echo "Skipping AutoHotkey launch because PowerShell is unavailable."
  fi
fi

if [ -d "/mnt/c/Users/$USER_NAME" ]; then
  echo "Linking GlazeWM config to WSL dotfiles..."
  mkdir -p "$WINDOWS_GLAZEWM_DIR"
  ensure_windows_symlink \
    "$WINDOWS_GLAZEWM_DIR/config.yaml" \
    "$DOTFILES/config/wsl/glazewm.yaml" \
    "C:\\Users\\$USER_NAME\\.glzr\\glazewm\\config.yaml" \
    "\\\\wsl$\\$WSL_DISTRO\\home\\$USER_NAME\\dotfiles\\config\\wsl\\glazewm.yaml" || copy_windows_file "$DOTFILES/config/wsl/glazewm.yaml" "$WINDOWS_GLAZEWM_DIR/config.yaml"

  if [ -n "$POWERSHELL_EXE" ]; then
  "$POWERSHELL_EXE" -NoProfile -NonInteractive -Command "\
    \$exe = 'C:\\Program Files\\glzr.io\\GlazeWM\\glazewm.exe'; \
    \$running = Get-Process -Name glazewm -ErrorAction SilentlyContinue; \
    if ((Test-Path \$exe) -and \$running) { & \$exe command wm-reload-config } \
    elseif (Test-Path \$exe) { Start-Process -FilePath \$exe }" || true
  else
    echo "Skipping GlazeWM reload because PowerShell is unavailable."
  fi
fi

if [ -d "$WALLPAPERS_DIR" ] && [ -d "/mnt/c/Users/$USER_NAME/Pictures" ]; then
  echo "Syncing wallpapers to Windows Pictures..."
  mkdir -p "$WINDOWS_WALLPAPERS_DIR"
  for item in "$WALLPAPERS_DIR"/* "$WALLPAPERS_DIR"/.[!.]* "$WALLPAPERS_DIR"/..?*; do
    [ -e "$item" ] || continue
    [ "$(basename "$item")" = ".git" ] && continue
    cp -a "$item" "$WINDOWS_WALLPAPERS_DIR"/
  done
fi

if [ -f "$NIX_PROFILE" ]; then
  # shellcheck source=/dev/null
  . "$NIX_PROFILE"
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Nix is still not available on PATH. Open a new shell and rerun this script."
  exit 1
fi

if ! command -v home-manager >/dev/null 2>&1; then
  echo "Installing Home Manager..."
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
fi

echo "Applying WSL Home Manager config..."
home-manager switch -b backup -f "$HOME_MANAGER_CONFIG"

echo ""
echo "=== WSL bootstrap complete ==="
echo "Future switches: hms"
