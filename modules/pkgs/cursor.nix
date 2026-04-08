{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "2.6";
  pname = "cursor";

  desktopEntry = pkgs.writeText "cursor.desktop" ''
    [Desktop Entry]
    Name=Cursor
    Comment=AI-powered code editor
    GenericName=Text Editor
    Exec=cursor %F
    Icon=cursor
    Type=Application
    StartupNotify=true
    StartupWMClass=Cursor
    Categories=TextEditor;Development;IDE;
    MimeType=text/plain;inode/directory;
  '';

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/${version}";
    sha256 = "sha256-rmPXBpIHIp87yF0PDJhqIgvtXOVYT0JXHT66Yynwggg=";
    name = "cursor-${version}.AppImage";
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
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
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
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    xorg.libxkbfile
    zlib
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/cursor

    # The AppImage squashfs starts at offset 193728 (second 'hsqs' magic).
    # The first match at 36081 is a false positive inside the ELF stub.
    unsquashfs -offset 193728 -dest $out/opt/cursor $src

    # Wrap the main binary (located at usr/bin/cursor inside the AppImage)
    mkdir -p $out/bin
    makeWrapper $out/opt/cursor/usr/bin/cursor $out/bin/cursor \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --add-flags "--no-sandbox"

    # Desktop entry
    mkdir -p $out/share/applications
    cp ${desktopEntry} $out/share/applications/cursor.desktop

    # Icon
    mkdir -p $out/share/pixmaps
    cp $out/opt/cursor/co.anysphere.cursor.png $out/share/pixmaps/cursor.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "AI-powered code editor built on VSCode";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "cursor";
  };
}
