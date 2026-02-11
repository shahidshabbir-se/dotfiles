#  ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗████████╗██╗   ██╗
# ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝╚══██╔══╝╚██╗ ██╔╝
# ██║  ███╗███████║██║   ██║███████╗   ██║      ██║    ╚████╔╝ 
# ██║   ██║██╔══██║██║   ██║╚════██║   ██║      ██║     ╚██╔╝  
# ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║      ██║      ██║   
#  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝      ╚═╝      ╚═╝   
# https://github.com/shahidshabbir-se/dotfiles

{ pkgs
, device
, ...
}:
let
  # Use device-specific font size, or fall back to scale-based calculation
  fontSize =
    if device ? fontSize
    then device.fontSize
    else if device.display.scale >= 2.0 then 17.0 else 14.0;
in
{
  enable = true;
  enableZshIntegration = true;

  # pkg
  package =
    if pkgs.stdenv.isDarwin
    then pkgs.ghostty-bin
    else pkgs.ghostty;

  settings = {
    theme = "TokyoNight";
    # theme = "Catppuccin Mocha";
    title = " ";

    # Font
    font-family = "Lilex Nerd Font";
    font-size = fontSize;
    font-feature = [ "+calt" "+liga" ];
    font-style = "regular";
    font-style-bold = "bold";
    font-style-italic = "italic";
    font-style-bold-italic = "bold italic";

    # Shell + command
    shell-integration-features = "no-cursor,sudo,title";
    command = [
      "${pkgs.zsh}/bin/zsh"
      "-c"
      "${pkgs.tmux}/bin/tmux attach -t main || ${pkgs.tmux}/bin/tmux new -s main"
    ];

    # Window
    window-inherit-working-directory = true;
    window-inherit-font-size = false;
    background-opacity = 1.0;
    window-decoration = false;
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
      "shift+enter=text:\\x1b\\r"
      "ctrl+shift+r=reload_config"
    ];
  };
}
