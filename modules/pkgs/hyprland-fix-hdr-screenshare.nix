{
  lib,
  fetchFromGitHub,
  hyprlandPlugins,
  pkg-config,
}:
hyprlandPlugins.mkHyprlandPlugin (_: {
  pluginName = "fix-hdr-screenshare";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "yayuuu";
    repo = "hyprland-fix-hdr-screenshare";
    rev = "dbce003830d18be5272c135cd00fa05976144cee";
    hash = "sha256-t6Oe1vyegvE/4Un2QfXYC1Okb5v2X9W5IdKGz5slIDI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildPhase = "make";
  installPhase = ''
    runHook preInstall
    install -Dm755 fix-hdr-screenshare.so "$out/lib/libfix-hdr-screenshare.so"
    runHook postInstall
  '';

  meta = {
    description = "Hyprland HDR screenshare/screenshot workaround";
    homepage = "https://github.com/yayuuu/hyprland-fix-hdr-screenshare";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
