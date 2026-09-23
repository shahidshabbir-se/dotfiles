#  ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗████████╗██╗   ██╗
# ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝╚══██╔══╝╚██╗ ██╔╝
# ██║  ███╗███████║██║   ██║███████╗   ██║      ██║    ╚████╔╝
# ██║   ██║██╔══██║██║   ██║╚════██║   ██║      ██║     ╚██╔╝
# ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║      ██║      ██║
#  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝      ╚═╝      ╚═╝
# https://github.com/shahidshabbir-se/dotfiles

{
  pkgs,
  lib ? pkgs.lib,
  device,
  ...
}:
let
  # Use device-specific font size, or fall back to scale-based calculation
  fontSize =
    if device ? fontSize then
      device.fontSize
    else if device.display.scale >= 2.0 then
      17.0
    else
      14.0;
in
{
  enable = true;
  enableZshIntegration = true;

  # pkg
  package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

  settings = {
    theme = "TokyoNight";
    # theme = "Catppuccin Mocha";
    # theme = "Rose Pine";
    title = " ";

    # Font
    font-family = [
      "SpaceMono Nerd Font"
      "Herdr Agent Icons Max"
    ];
    font-codepoint-map = [
      "U+2722,U+2733,U+2736,U+273B,U+273D=Noto Sans Symbols 2"
      "U+E1A0-U+E1B0=Herdr Agent Icons Max"
    ];
    font-size = fontSize;
    font-feature = [
      "+calt"
      "+liga"
    ];
    font-style = "regular";
    font-style-bold = "bold";
    font-style-italic = "italic";
    font-style-bold-italic = "bold italic";

    # Shell + command
    shell-integration-features = "no-cursor,sudo,title";
    command = [
      "${pkgs.zsh}/bin/zsh"
      "-c"
      "herdr"
    ];

    # Background
    background-opacity = 1.0;
    background-image = "${../assets/starfield_3440x1440.png}";
    background-image-opacity = 0.1;
    background-image-fit = "cover";

    # Window
    window-inherit-working-directory = true;
    window-inherit-font-size = false;
    window-decoration = false;
    window-padding-x = 6;
    window-padding-y = "6,0";
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
      # Forward Shift+Enter as a Kitty/CSI-u modified Enter so pi can use it for new lines.
      "shift+enter=text:\\x1b[13;2u"
      "ctrl+shift+r=reload_config"
    ]
    # Ghostty eats alt/ctrl+1..9 for its own tabs. Pass them through to herdr.
    ++
      lib.concatMap
        (
          n:
          let
            names = [
              n.num
              n.word
              "digit_${n.num}"
            ];
          in
          lib.concatMap (key: [
            "alt+${key}=unbind"
            "ctrl+${key}=unbind"
            "super+${key}=unbind"
          ]) names
        )
        [
          {
            num = "1";
            word = "one";
          }
          {
            num = "2";
            word = "two";
          }
          {
            num = "3";
            word = "three";
          }
          {
            num = "4";
            word = "four";
          }
          {
            num = "5";
            word = "five";
          }
          {
            num = "6";
            word = "six";
          }
          {
            num = "7";
            word = "seven";
          }
          {
            num = "8";
            word = "eight";
          }
          {
            num = "9";
            word = "nine";
          }
        ];
  };
}
