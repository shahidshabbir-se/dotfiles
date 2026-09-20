{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "2.12.0";
  pname = "antigravity";

  antigravityBase = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.21.9-4905428782546944/linux-x64/Antigravity.tar.gz";
      sha256 = "sha256-hepNVfUtMvu/nZL93HR/EOjQTBvQCgdyG1cfp/LvUiY=";
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
      libx11
      libxcb
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxscrnsaver
      libxshmfence
      libxtst
      libxkbfile
      zlib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/applications
      mkdir -p $out/share/pixmaps

      cp -r . $out/

      makeWrapper $out/antigravity $out/bin/antigravity-ide \
        --set ELECTRON_OZONE_PLATFORM_HINT "auto"

      cp $out/resources/app/resources/linux/antigravity.png $out/share/pixmaps/antigravity.png 2>/dev/null || true

      cat <<EOF > $out/share/applications/antigravity.desktop
      [Desktop Entry]
      Name=Antigravity
      Comment=Agentic development platform
      GenericName=Text Editor
      Exec=$out/bin/antigravity-ide %F
      Icon=antigravity
      Type=Application
      StartupNotify=true
      StartupWMClass=antigravity
      Categories=TextEditor;Development;IDE;
      MimeType=text/plain;inode/directory;
      EOF

      runHook postInstall
    '';

    meta = with lib; {
      description = "Agentic development platform, evolving the IDE into the agent-first era";
      homepage = "https://antigravity.google";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "antigravity-ide";
    };
  };

in
pkgs.symlinkJoin {
  name = "antigravity-ide-fhs";

  paths = [
    antigravityBase
  ];

  buildInputs = [
    pkgs.makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/antigravity-ide \
      --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
      --add-flags "--force-color-profile=srgb" \
      --add-flags "--enable-features=WaylandLinuxDrmSyncobj"
  '';
}
