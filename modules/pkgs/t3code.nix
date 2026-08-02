{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "0.0.31";
  pname = "t3code";

  desktopEntry = pkgs.writeText "t3code.desktop" ''
    [Desktop Entry]
    Name=T3 Code
    Comment=T3 Code desktop build
    GenericName=Text Editor
    Exec=t3code --no-sandbox %U
    Icon=t3code
    Type=Application
    Terminal=false
    StartupNotify=true
    StartupWMClass=T3 Code (Alpha)
    Categories=Development;
    MimeType=text/plain;inode/directory;
  '';

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    sha256 = "sha256-AqTkoSKeQwmql3L9F5SbD1XyqeFyqe11ciq9Tp04Zyw=";
    name = "t3code-${version}.AppImage";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
    squashfsTools
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    dbus-glib
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    gtk3
    libdbusmenu-gtk2
    libdrm
    libGL
    libnotify
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libxkbfile
    zlib
  ];

  # The bundled sharp binaries expect a non-standard libvips soname
  # (8.17.3 vs the real 42.x), and the musl variant needs musl libc.
  # Both are safe to ignore — sharp falls back gracefully at runtime.
  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libvips-cpp.so.8.17.3"
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/t3code

    # Extract the AppImage squashfs (second 'hsqs' magic at offset 188392)
    unsquashfs -offset 188392 -dest $out/opt/t3code $src

    # Wrap the main binary
    mkdir -p $out/bin
    makeWrapper $out/opt/t3code/t3code $out/bin/t3code \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --run 'export PATH="$HOME/.local/bin:$PATH"' \
      --add-flags "--no-sandbox"

    # Desktop entry
    mkdir -p $out/share/applications
    cp ${desktopEntry} $out/share/applications/t3code.desktop

    # Icon
    mkdir -p $out/share/pixmaps
    icon=$(find $out/opt/t3code -type f -name t3code.png -print -quit)
    if [ -n "$icon" ]; then
      cp "$icon" $out/share/pixmaps/t3code.png
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "T3 Code - AI-powered desktop coding app by Ping";
    homepage = "https://github.com/pingdotgg/t3code";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "t3code";
  };
}
