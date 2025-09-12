#  ██╗   ██╗ █████╗ ██████╗  █████╗ ██╗
#  ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║
#   ╚████╔╝ ███████║██████╔╝███████║██║
#    ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║
#     ██║   ██║  ██║██████╔╝██║  ██║██║
#     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, ... }:

{
  services.yabai = {
    enable = true;

    # ───────────────────────────────────────────────
    # ▶ Scripting Addition
    # ───────────────────────────────────────────────
    enableScriptingAddition = true;
    package = pkgs.yabai;

    # ───────────────────────────────────────────────
    # ▶ Core Yabai Configuration
    # ───────────────────────────────────────────────
    config = {
      layout = "bsp";
      window_placement = "second_child";

      top_padding = 15;
      bottom_padding = 15;
      left_padding = 15;
      right_padding = 15;
      window_gap = 15;

      mouse_follows_focus = "on";
      mouse_modifier = "alt";
      mouse_action1 = "move";
      mouse_action2 = "resize";
    };

    # ───────────────────────────────────────────────
    # ▶ Window Management Rules & Signals
    # ───────────────────────────────────────────────
    extraConfig = ''
      # Do not manage some macOS apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="Zen" title="Extension: (Bitwarden Password Manager) - Bitwarden" manage=off

      # App-to-space assignments
      yabai -m rule --add title=".*Zen Browser*" space=2
      yabai -m rule --add app="^Alacritty$" space=1
      yabai -m rule --add app="^Spotify$" space=9
      yabai -m rule --add  title=".*Zen Browser — Private Browsing*" space=8

      # Reload scripting addition if dock restarts
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
    '';
  };
}
