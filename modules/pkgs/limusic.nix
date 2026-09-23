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

  extraPkgs =
    pkgs: with pkgs; [
      mpv
      pipewire
      pulseaudio
      alsa-lib
      libva
      vulkan-loader
    ];

  extraInstallCommands = ''
    rm -rf "$out/share/applications" "$out/share/icons"
    mkdir -p "$out/share/applications" "$out/share/icons"

    if [ -f "${appimageContents}/limusic.desktop" ]; then
      cp "${appimageContents}/limusic.desktop" \
        "$out/share/applications/limusic.desktop"
    elif [ -f "${appimageContents}/usr/share/applications/limusic.desktop" ]; then
      cp "${appimageContents}/usr/share/applications/limusic.desktop" \
        "$out/share/applications/limusic.desktop"
    fi

    if [ -d "${appimageContents}/usr/share/icons" ]; then
      cp -rL "${appimageContents}/usr/share/icons/." "$out/share/icons/"
    fi

    chmod -R u+w "$out/share"

    srcIcon=""
    for candidate in \
      "$out/share/icons/hicolor/512x512/apps/limusic-app.png" \
      "$out/share/icons/hicolor/512x512/apps/limusic.png" \
      "${appimageContents}/limusic.png" \
      "${appimageContents}/limusic-app.png"
    do
      if [ -f "$candidate" ]; then
        srcIcon="$candidate"
        break
      fi
    done

    if [ -n "$srcIcon" ]; then
      for sz in 16 24 32 48 64 128 256 512; do
        mkdir -p "$out/share/icons/hicolor/''${sz}x''${sz}/apps"
        ${lib.getExe pkgs.imagemagick} "$srcIcon" -resize "''${sz}x''${sz}" \
          "$out/share/icons/hicolor/''${sz}x''${sz}/apps/limusic-app.png"
        ln -sfn limusic-app.png \
          "$out/share/icons/hicolor/''${sz}x''${sz}/apps/limusic.png"
      done
    fi

    desktop="$out/share/applications/limusic.desktop"
    if [ -f "$desktop" ]; then
      sed -i \
        -e "s|^Exec=.*|Exec=$out/bin/limusic|" \
        -e "s|^Icon=.*|Icon=$out/share/icons/hicolor/512x512/apps/limusic-app.png|" \
        -e "s|^Categories=.*|Categories=AudioVideo;Audio;Player;|" \
        -e "s|^Name=.*|Name=Limusic|" \
        -e '/^NoDisplay=/d' \
        -e '/^Hidden=/d' \
        "$desktop"
      printf '%s\n' 'NoDisplay=false' >> "$desktop"
    fi
  '';

  meta = {
    description = "Feature-rich native YouTube Music desktop client";
    homepage = "https://github.com/SimoHypers/limusic";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "limusic";
  };
}
