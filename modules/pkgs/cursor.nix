{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "3.7";
  pname = "cursor";

  schemaPath = lib.concatStringsSep ":" [
    "${pkgs.gtk3}/share/gsettings-schemas/gtk+3-${pkgs.gtk3.version}/glib-2.0/schemas"
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}/glib-2.0/schemas"
  ];

  runtimeLibraryPath = lib.makeLibraryPath [
    pkgs.libGL
    pkgs.libgbm
    pkgs.libglvnd
    pkgs.mesa
    pkgs.vulkan-loader
    pkgs.wayland
  ];

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
    sha256 = "sha256-uWd8m9lH+nu9iZw0Zwuja9qthFGUsRPBIbt6FHMUHHE=";
    name = "cursor-${version}.AppImage";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
    python3
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
    gsettings-desktop-schemas
    gtk3
    libdrm
    libgbm
    libglvnd
    vulkan-loader
    wayland
    libGL
    libnotify
    libuuid
    libxkbcommon
    mesa
    musl
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

        # Dynamically find the squashfs offset in the AppImage.
        # The first 'hsqs' occurrence at ~194KB is a false positive inside the ELF
        # stub.  Scan for a valid squashfs superblock (s_major == 4) to find the
        # real filesystem — this works across Type 1 and Type 2 AppImages and
        # survives Cursor version bumps.
        SQUASHFS_OFFSET=$(${pkgs.python3}/bin/python3 -c "
    import struct
    with open('$src', 'rb') as f:
        data = f.read()
    pos = 0
    while True:
        pos = data.find(b'hsqs', pos)
        if pos == -1:
            break
        if pos + 30 <= len(data):
            # squashfs superblock: offset 28 = s_major (u16), offset 20 = compression (u16)
            s_major = struct.unpack('<H', data[pos+28:pos+30])[0]
            if s_major == 4:
                print(pos)
                break
        pos += 1
    ")
        echo "Found squashfs at offset $SQUASHFS_OFFSET"
        unsquashfs -offset "$SQUASHFS_OFFSET" -dest $out/opt/cursor $src

        # Wrap the main binary (located at usr/bin/cursor inside the AppImage)
        mkdir -p $out/bin
        makeWrapper $out/opt/cursor/usr/bin/cursor $out/bin/cursor \
          --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
          --set GSETTINGS_SCHEMA_DIR "${schemaPath}" \
          --prefix LD_LIBRARY_PATH : ${runtimeLibraryPath} \
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
