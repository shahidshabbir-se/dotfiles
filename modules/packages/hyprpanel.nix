{ pkgs }: {
  hyprpanelPackages = with pkgs; [
    ags
    wireplumber
    libgtop
    bluez
    bluetui
    dart-sass
    upower
    hyprsunset
    hypridle
    cava
    gvfs
    gpu-screen-recorder
  ];
}
