{
  pkgs,
  inputs,
  system,
  gtkThemePackage,
}:
let
  commonPackages = import ../../modules/pkgs/common.nix { inherit pkgs; };
  zenBrowserPackage = inputs.zen-browser.packages.${system}.default;

  developmentPackages = with pkgs; [ ];

  desktopPackages = with pkgs; [
    chromium
    obsidian
    # Headless office engine for the docx/xlsx/pptx agent skills (conversion,
    # formula recalc, tracked-change accept). "libreoffice-qt" is the smaller
    # build (Qt VCL only, no GTK plugins). The skills only need headless
    # conversion and Basic macros.
    # Not in common.nix: libreoffice is darwin-unsupported.
    libreoffice-qt
    qbittorrent
    nautilus
    zenBrowserPackage
  ];

  mediaPackages = with pkgs; [
    cava
    gthumb
    vlc
    pulsemixer
  ];

  systemUtilityPackages = with pkgs; [
    fastfetch
    pavucontrol
    glycin-loaders
    libnotify
    matugen
    unzip
    webp-pixbuf-loader
    time
    wmctrl
    zip
  ];

  themePackages = with pkgs; [
    catppuccin-papirus-folders
    gtkThemePackage
  ];
in
{
  inherit
    commonPackages
    developmentPackages
    desktopPackages
    mediaPackages
    systemUtilityPackages
    themePackages
    ;
}
