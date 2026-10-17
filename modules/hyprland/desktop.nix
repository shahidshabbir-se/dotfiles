{ pkgs, ... }:

let
  swash = pkgs.callPackage ../pkgs/swash.nix { };
  nautilusDesktopWithExtensions = pkgs.runCommand "nautilus-desktop-with-extensions" { } ''
    mkdir -p "$out/share/applications"
    substitute ${pkgs.nautilus}/share/applications/org.gnome.Nautilus.desktop \
      "$out/share/applications/org.gnome.Nautilus.desktop" \
      --replace-fail 'DBusActivatable=true' 'DBusActivatable=false' \
      --replace-fail \
        'Exec=nautilus --new-window %U' \
        'Exec=env NAUTILUS_4_EXTENSION_DIR=/run/current-system/sw/lib/nautilus/extensions-4 nautilus --new-window %U' \
      --replace-fail \
        'Exec=nautilus --new-window' \
        'Exec=env NAUTILUS_4_EXTENSION_DIR=/run/current-system/sw/lib/nautilus/extensions-4 nautilus --new-window'
  '';
in
{
  home.packages = (with pkgs; [
    # Wallpaper
    awww
    mpvpaper

    # Launcher / Menus
    wofi

    # Screenshot (grim is pulled in by grimblast but keep it on PATH for scripts)
    grim
    grimblast
    slurp
    wf-recorder
    tesseract

    # Clipboard
    cliphist
    wl-clipboard

    # Notifications
    swaynotificationcenter
    libnotify

    # Media / Audio / Brightness
    playerctl
    brightnessctl
    alsa-utils

    # Image viewer
    gthumb
  ]) ++ [ swash ];

  xdg.dataFile."applications/org.gnome.Nautilus.desktop".source =
    "${nautilusDesktopWithExtensions}/share/applications/org.gnome.Nautilus.desktop";
}
