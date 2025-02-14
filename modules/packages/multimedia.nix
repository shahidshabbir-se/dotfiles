{ pkgs }: {
  multimediaPackages = with pkgs; [
    discord
    obsidian
    pavucontrol
    spicetify-cli
    playerctl
    noto-fonts-emoji
    vlc
    # alacritty
    # ghostty
    wezterm
    feh
    # kitty
  ];
}
