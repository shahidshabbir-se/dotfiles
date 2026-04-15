{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "1.21.9";
  pname = "antigravity";

  desktopEntry = pkgs.writeText "antigravity.desktop" ''
    [Desktop Entry]
    Name=Antigravity
    Comment=Agentic development platform
    GenericName=Text Editor
    Exec=antigravity %F
    Icon=antigravity
    Type=Application
    StartupNotify=true
    StartupWMClass=antigravity
    Categories=TextEditor;Development;IDE;
    MimeType=text/plain;inode/directory;
  '';

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.21.9-4905428782546944/linux-x64/Antigravity.tar.gz";
    sha256 = "85ea4d55f52d32fbbf9d92fddc747f10e8d04c1bd00a07721b571fa7f2ef5226";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
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
    gtk3
    libdrm
    libGL
    libnotify
    libsecret
    libuuid
    libxkbcommon
    libsoup_3
    mesa
    nspr
    nss
    pango
    systemd
    webkitgtk_4_1
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps

    cp -r . $out/

    makeWrapper $out/antigravity $out/bin/antigravity \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto"

    cp $out/resources/app/resources/linux/antigravity.png $out/share/pixmaps/antigravity.png 2>/dev/null || true

    # Desktop entry
    cp ${desktopEntry} $out/share/applications/antigravity.desktop

    runHook postInstall
  '';

  meta = with lib; {
    description = "Agentic development platform, evolving the IDE into the agent-first era";
    homepage = "https://antigravity.google";
    downloadPage = "https://antigravity.google/download";
    changelog = "https://antigravity.google/changelog";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "antigravity";
  };
}
