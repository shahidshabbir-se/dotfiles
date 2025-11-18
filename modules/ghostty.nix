{ config, pkgs, ... }:
{
  enable = true;
  enableZshIntegration = true;

  package = pkgs.ghostty;

  settings = {
    theme = "Catppuccin Mocha";
    title = " ";

    # Font
    font-family = "JetBrainsMono Nerd Font";
    font-size = if pkgs.stdenv.isDarwin then 15 else 14;
    font-feature = [ "-calt" "+liga" "+dlig" "+hlig" "+ss01" "+ss02" "+ss03" "+ss04" "+ss05" "+ss06" "+ss07" "+ss08" "+ss09" ];
    font-style = "regular";
    font-style-bold = "bold";
    font-style-italic = "italic";
    font-style-bold-italic = "bold italic";

    # Shell + command
    shell-integration = "zsh";
    shell-integration-features = "cursor,sudo,title";
    command =
      if pkgs.stdenv.isDarwin
      then "/etc/profiles/per-user/shahid/bin/zsh -c \"tmux attach -t mini || tmux new -s mini\""
      else "${pkgs.tmux}/bin/tmux";

    # Window
    window-inherit-working-directory = true;
    window-inherit-font-size = false;
    background-opacity = 1.0;
    window-decoration = true;
    window-padding-x = 6;
    window-padding-y = 4;
    window-padding-balance = true;

    # Cursor
    cursor-style = "block";
    cursor-style-blink = false;
    cursor-color = "#f5e0dc";

    # Misc
    confirm-close-surface = false;
    quit-after-last-window-closed = true;
    mouse-hide-while-typing = true;
    unfocused-split-opacity = 0.8;
    macos-option-as-alt = true;

    # Keybinds
    keybind = [
      "shift+enter=text:\x1b\r"
      "ctrl+shift+r=reload_config"
    ];
  };
}
