{
  pkgs,
  lib ? pkgs.lib,
}:

let
  version = "0.226.4";
  pname = "zed-editor";

  appDir = "zed.app";
  appId = "dev.zed.Zed";
  arch =
    if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then
      "x86_64"
    else if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then
      "aarch64"
    else
      throw "Zed binary package is only supported on x86_64-linux and aarch64-linux";

  runtimeLibraryPath = lib.makeLibraryPath [
    pkgs.vulkan-loader
    pkgs.wayland
    pkgs.libglvnd
    pkgs.libGL
  ];

in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://cloud.zed.dev/releases/stable/${version}/download?asset=zed&arch=${arch}&os=linux&source=nix";
    hash = "sha256-w7m50geqnI6JtDPUvelD+YkTRJQ2cqBBURt80nKt4jw=";
    name = "zed-${version}-${arch}-linux.tar.gz";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    fontconfig
    freetype
    libdrm
    libGL
    libglvnd
    libgbm
    libgit2
    libxkbcommon
    openssl
    stdenv.cc.cc.lib
    vulkan-loader
    wayland
    xkeyboard_config
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    zlib
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    tar -xzf $src -C $out/opt

    mkdir -p $out/bin
    makeWrapper $out/opt/${appDir}/bin/zed $out/bin/zed \
      --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --prefix LD_LIBRARY_PATH : ${runtimeLibraryPath}
    makeWrapper $out/opt/${appDir}/bin/zed $out/bin/zeditor \
      --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --prefix LD_LIBRARY_PATH : ${runtimeLibraryPath}

    mkdir -p $out/share/applications
    if [ -f "$out/opt/${appDir}/share/applications/${appId}.desktop" ]; then
      cp "$out/opt/${appDir}/share/applications/${appId}.desktop" "$out/share/applications/${appId}.desktop"
    else
      cp "$out/opt/${appDir}/share/applications/zed.desktop" "$out/share/applications/${appId}.desktop"
    fi

    substituteInPlace "$out/share/applications/${appId}.desktop" \
      --replace-fail "Exec=zed" "Exec=$out/bin/zed" \
      --replace-fail "Icon=zed" "Icon=$out/opt/${appDir}/share/icons/hicolor/512x512/apps/zed.png"

    runHook postInstall
  '';

  meta = with lib; {
    description = "High-performance, multiplayer code editor";
    homepage = "https://zed.dev";
    license = licenses.gpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "zed";
  };
}
