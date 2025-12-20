#  ██╗   ██╗ █████╗ ██████╗  █████╗ ██╗
#  ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗██║
#   ╚████╔╝ ███████║██████╔╝███████║██║
#    ╚██╔╝  ██╔══██║██╔══██╗██╔══██║██║
#     ██║   ██║  ██║██████╔╝██║  ██║██║
#     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ pkgs, ... }:

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
    # ▶ Rules & Signals
    # ───────────────────────────────────────────────
    extraConfig = ''
      # ───────────────────────────────────────────────
      # ▶ Window Rules (Exclude from Management)
      # ───────────────────────────────────────────────
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="Zen" title="Extension: (Bitwarden Password Manager) - Bitwarden" manage=off

      # ───────────────────────────────────────────────
      # ▶ Signals (Move + Focus App Windows)
      # ───────────────────────────────────────────────

      # Auto-reload scripting addition if Dock restarts
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      # Move Kitty to space 1 and focus
      yabai -m signal --add event=window_created app="^Kitty$" action="yabai -m window --space 1; yabai -m space --focus 1"

      # Move Zen Browser to space 2 and focus
      yabai -m signal --add event=window_created title="Zen Browser$" action="yabai -m window --space 2; yabai -m space --focus 2"

      # Move Zen Browser (Private) to space 8 and focus
      yabai -m signal --add event=window_created title="Zen Browser — Private Browsing" action="yabai -m window --space 8; yabai -m space --focus 8"

      # Move Spotify to space 9 and focus
      yabai -m signal --add event=window_created app="^Spotify$" action="yabai -m window --space 9; yabai -m space --focus 9"
    '';
  };
}

