{
  lib,
  fetchFromGitHub,
  hyprlandPlugins,
  pkg-config,
}:
hyprlandPlugins.mkHyprlandPlugin (_: {
  pluginName = "fix-hdr-screenshare";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "yayuuu";
    repo = "hyprland-fix-hdr-screenshare";
    rev = "cd6a8fbae550a970420679b4b71bf6f79194bf76";
    hash = "sha256-Nodgm1/BvDB/BQcvJY0+pm1IuMgnI3RdB11lNcBc7ok=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildPhase = "make";
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp fix-hdr-screenshare.so "$out/lib/"
    runHook postInstall
  '';

  meta = {
    description = "Hyprland HDR screenshare/screenshot workaround for 0.55";
    homepage = "https://github.com/yayuuu/hyprland-fix-hdr-screenshare";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
