{
  pkgs,
  lib ? pkgs.lib,
  scale ? 1.0,
}:

let
  version = "26.825.51511";
  pname = "chatgpt";

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.requireFile {
    name = "chatgpt_amd64.deb";
    hash = "sha256-NVSwAixs+1EzJvQ/0R9xiDWncIasTXyi/z67ui1Mf0U=";
    message = "Download ChatGPT ${version} for amd64, then run: nix-store --add-fixed sha256 chatgpt_amd64.deb";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    graphite2
    gtk3
    libdrm
    libgbm
    libGL
    libglvnd
    libnotify
    libusb1
    libxkbcommon
    mesa
    nspr
    nss
    openssl
    pango
    qt5.qtbase.out
    qt6.qtbase.out
    stdenv.cc.cc.lib
    systemd
    wayland
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    xdg-utils
    zlib
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];
  dontWrapQtApps = true;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src $out
    mv $out/usr/share $out/share

    mv $out/usr/lib/chatgpt/ChatGPT $out/usr/lib/chatgpt/ChatGPT.bin
    makeWrapper $out/usr/lib/chatgpt/ChatGPT.bin $out/usr/lib/chatgpt/ChatGPT \
      --set ELECTRON_OZONE_PLATFORM_HINT "wayland" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
      --add-flags "--force-color-profile=srgb" \
      --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations,WaylandLinuxDrmSyncobj" \
      --prefix PATH : ${
        lib.makeBinPath [
          pkgs.glib
          pkgs.xdg-utils
        ]
      }

    mkdir -p $out/bin
    ln -s $out/usr/lib/chatgpt/ChatGPT $out/bin/chatgpt

    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail 'Exec=chatgpt %U' "Exec=$out/bin/chatgpt %U"

    runHook postInstall
  '';

  meta = with lib; {
    description = "ChatGPT desktop application";
    homepage = "https://chatgpt.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}
