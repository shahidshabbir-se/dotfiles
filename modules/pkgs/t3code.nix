{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "0.1.6";
  pname = "t3code";

  desktopEntry = pkgs.writeText "t3code.desktop" ''
    [Desktop Entry]
    Name=T3 Code
    Comment=T3 Code desktop build
    GenericName=Text Editor
    Exec=t3code %U
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
    sha256 = "sha256-CeJQcgjHeTCbOWvoRq6h2UUUS9eAYGiZwvSByW3fNNA=";
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
    gtk3
    libdbusmenu-gtk3
    libdrm
    libGL
    libnotify
    libsecret
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

    # Extract the AppImage squashfs
    offset=$(LC_ALL=C readelf -h "$src" | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
    unsquashfs -offset "$offset" -dest $out/opt/t3code $src

    # Wrap the Electron binary
    mkdir -p $out/bin

    makeWrapper $out/opt/t3code/t3code $out/bin/t3code \
      --set ELECTRON_OZONE_PLATFORM_HINT "wayland" \
      --set OZONE_PLATFORM "wayland" \
      --run 'export PATH="$HOME/.local/bin:$PATH"' \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
      --add-flags "--force-color-profile=srgb" \
      --add-flags "--enable-features=WaylandLinuxDrmSyncobj" \
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
