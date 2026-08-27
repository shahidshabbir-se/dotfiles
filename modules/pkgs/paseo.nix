{
  pkgs,
  lib ? pkgs.lib,
}:

let
  # Bump this, rebuild, paste the hash nix prints.
  version = "0.6.1";
  hash = "sha256-uARe9YPsZ1lxgz9+SZkKPTpPLDbeYZoPDcIx0ssTTFc=";

  pname = "paseo";

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

  desktopEntry = pkgs.writeText "paseo.desktop" ''
    [Desktop Entry]
    Name=Paseo
    Comment=Paseo desktop app
    Exec=paseo-desktop %U
    Icon=paseo
    Type=Application
    Terminal=false
    StartupNotify=true
    StartupWMClass=Paseo
    MimeType=x-scheme-handler/paseo;
    Categories=Development;
  '';

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://github.com/getpaseo/paseo/releases/download/v${version}/Paseo-${version}-amd64.deb";
    inherit hash;
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
    gsettings-desktop-schemas
    gtk3
    libdrm
    libgbm
    libGL
    libglvnd
    libnotify
    libuuid
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    vulkan-loader
    wayland
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

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt $out/bin $out/share/applications $out/share/pixmaps
    cp -a opt/Paseo $out/opt/Paseo

    makeWrapper $out/opt/Paseo/Paseo $out/bin/paseo-desktop \
      --set ELECTRON_OZONE_PLATFORM_HINT "auto" \
      --set GSETTINGS_SCHEMA_DIR "${schemaPath}" \
      --set PASEO_ELECTRON_FLAGS "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj" \
      --prefix LD_LIBRARY_PATH : ${runtimeLibraryPath} \
      --add-flags "--no-sandbox"

    cp ${desktopEntry} $out/share/applications/paseo.desktop
    cp usr/share/icons/hicolor/128x128/apps/Paseo.png $out/share/pixmaps/paseo.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Paseo desktop app";
    homepage = "https://paseo.sh";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "paseo-desktop";
  };
}
