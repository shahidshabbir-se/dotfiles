{
  pkgs,
  lib ? pkgs.lib,
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (pkgs) stdenvNoCC fetchurl autoPatchelfHook;

  version = "0.8.2";

  assets = {
    x86_64-linux = {
      name = "herdr-linux-x86_64";
      hash = "sha256-l2FQoU1JDJSyQ+ouGn6y37Z/EuNrGC25CTb2co5q7PQ=";
    };
    aarch64-linux = {
      name = "herdr-linux-aarch64";
      hash = "sha256-9VYQZY4cLg0qrvcwtLKriF9/i6AChas3K/sU8uPVtA0=";
    };
    x86_64-darwin = {
      name = "herdr-macos-x86_64";
      hash = "sha256-q1AmLIGQzXqpBW0knSVcCMMow+hxbenPop208TG44sE=";
    };
    aarch64-darwin = {
      name = "herdr-macos-aarch64";
      hash = "sha256-pdT01QTYswnJH4EQUFWTAPq6MSWEJfU8UIUvyW9q5XQ=";
    };
  };

  asset =
    assets.${system} or (throw "herdr: no release asset for system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl {
    url = "https://github.com/herdrdev/herdr/releases/download/v${version}/${asset.name}";
    inherit (asset) hash;
  };

  dontUnpack = true;
  nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/herdr"
    runHook postInstall
  '';

  meta = {
    description = "Terminal-native agent runtime packaged from official release binaries";
    homepage = "https://github.com/herdrdev/herdr";
    license = lib.licenses.agpl3Plus;
    platforms = builtins.attrNames assets;
    mainProgram = "herdr";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
