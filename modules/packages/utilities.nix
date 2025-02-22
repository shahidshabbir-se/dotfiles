{ pkgs }: {
  utilityPackages = with pkgs; [
    grimblast
    hyprpicker
    # eww
    hyprlock
    cloudflare-warp
    power-profiles-daemon
    ntfs3g
    qbittorrent
    rofi
    cliphist
    swww
    wl-clipboard
    brightnessctl
    noto-fonts-emoji
    btop
    hyprcursor
    carapace
  ];
}
