{
  pkgs,
  lib,
}:

let
  pname = "limusic";
  version = "0.7.0";

  src = pkgs.fetchurl {
    url = "https://github.com/SimoHypers/limusic/releases/download/v${version}/limusic_${version}_amd64.AppImage";
    hash = "sha256-/Z8Kk3mZhmf0kbJkxWcXpeuS+FYtPkHeHMF+9kODp+8=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname version src;
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 \
      ${appimageContents}/usr/share/icons/hicolor/128x128/apps/limusic.png \
      $out/share/icons/hicolor/128x128/apps/limusic.png 2>/dev/null || true

    install -Dm644 \
      ${appimageContents}/usr/share/applications/limusic.desktop \
      $out/share/applications/limusic.desktop 2>/dev/null || true

    substituteInPlace \
      $out/share/applications/limusic.desktop \
      --replace-fail \
        "Exec=limusic" \
        "Exec=$out/bin/limusic" 2>/dev/null || true
  '';

  extraPkgs =
    pkgs: with pkgs; [
      libmpv
      mpv
      alsa-lib
      pulseaudio
      pipewire
      libva
      vulkan-loader
    ];

  meta = {
    description = "Feature-rich native YouTube Music desktop client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
}
