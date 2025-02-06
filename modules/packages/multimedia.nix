{ pkgs }: {
  multimediaPackages = with pkgs; [
    discord
    obsidian
    pavucontrol
    spicetify-cli
    playerctl
    noto-fonts-emoji
    alacritty
    ghostty
    feh
    kitty
  ];
}
