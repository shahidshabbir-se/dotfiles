{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "26.803.81509";
  pname = "chatgpt";

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.requireFile {
    name = "chatgpt_amd64.deb";
    hash = "sha256-qb+Ro2j598Tuo4CCqfuPtGuNAFtxmm13FdLloZgsOOs=";
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
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
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

    mkdir -p $out/bin
    makeWrapper $out/usr/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --prefix PATH : ${lib.makeBinPath [ pkgs.glib pkgs.xdg-utils ]}

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
