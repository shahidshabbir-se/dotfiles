#  ███████╗██╗  ██╗██╗  ██╗██████╗ 
#  ██╔════╝██║ ██╔╝██║  ██║██╔══██╗
#  ███████╗█████╔╝ ███████║██║  ██║
#  ╚════██║██╔═██╗ ██╔══██║██║  ██║
#  ███████║██║  ██╗██║  ██║██████╔╝
#  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ 
#   https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, ... }:

{
  services.skhd = {
    enable = true;

    skhdConfig = ''
      # ───────────────────────────────────────────────
      # ▶ Service Controls
      # ───────────────────────────────────────────────
      cmd + alt - r : skhd --restart-service
      cmd + alt - y : yabai --restart-service
      ctrl + cmd - l : osascript -e 'tell application "System Events" to keystroke "q" using {command down, control down}'

      # ───────────────────────────────────────────────
      # ▶ Move focused window to space N and focus it
      # ───────────────────────────────────────────────
      shift + cmd - 1 : yabai -m window --space 1; yabai -m space --focus 1
      shift + cmd - 2 : yabai -m window --space 2; yabai -m space --focus 2
      shift + cmd - 3 : yabai -m window --space 3; yabai -m space --focus 3
      shift + cmd - 4 : yabai -m window --space 4; yabai -m space --focus 4
      shift + cmd - 5 : yabai -m window --space 5; yabai -m space --focus 5
      shift + cmd - 6 : yabai -m window --space 6; yabai -m space --focus 6
      shift + cmd - 7 : yabai -m window --space 7; yabai -m space --focus 7
      shift + cmd - 8 : yabai -m window --space 8; yabai -m space --focus 8
      shift + cmd - 9 : yabai -m window --space 9; yabai -m space --focus 9

      # ───────────────────────────────────────────────
      # ▶ App Launchers by Space
      # ───────────────────────────────────────────────
      cmd - b             : yabai -m space --focus 1; open -na "Firefox"
      cmd + shift - b     : yabai -m space --focus 9; open -na "Firefox" --args --private-window
      cmd - m             : yabai -m space --focus 9; open -na "Spotify"
      cmd - return        : yabai -m space --focus 2; open -na "Wezterm"
      cmd + shift - l     : yabai -m space --focus 3; open -na "AnythingLLM"
      cmd - q             : yabai -m window --close

      # ───────────────────────────────────────────────
      # ▶ Window Focus Movement
      # ───────────────────────────────────────────────
      cmd - h : yabai -m window --focus west
      cmd - j : yabai -m window --focus south
      cmd - k : yabai -m window --focus north
      cmd - l : yabai -m window --focus east
    '';
  };
}
