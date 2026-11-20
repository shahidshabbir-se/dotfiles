{ pkgs, lib, inputs }:
let
  version = "3.4.0";
  releases = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-f4EyoiAjOMG1LDYRPSPXQDz5HyILzb2e7IK8cm9fgCk=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-vVSeiWh0xBe4Qc2OHnJLuspZBGl44K0rfnKSHeQQHgw=";
    };
  };
  release = releases.${pkgs.stdenv.hostPlatform.system} or (throw "Unsupported Hex release platform");
  alsaPlugins = pkgs.symlinkJoin {
    name = "hex-alsa-plugins";
    paths = [ "${pkgs.pipewire}/lib/alsa-lib" "${pkgs.alsa-plugins}/lib/alsa-lib" ];
  };
in
pkgs.stdenv.mkDerivation {
  pname = "hex";
  inherit version;
  src = pkgs.fetchurl {
    url = "https://github.com/anomalyco/hex/releases/download/v${version}/hex-${version}-linux-${release.arch}";
    inherit (release) hash;
  };
  dontUnpack = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper pkgs.autoAddDriverRunpath ];
  buildInputs = with pkgs; [ stdenv.cc.cc.lib vulkan-loader openssl libxkbcommon alsa-lib ];
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/hex
    install -Dm644 ${inputs.hex}/packaging/anomaly.hex.desktop $out/share/applications/anomaly.hex.desktop
    mkdir -p $out/share/icons
    cp -R ${inputs.hex}/packaging/linux/icons/hicolor $out/share/icons/hicolor
    substituteInPlace $out/share/applications/anomaly.hex.desktop --replace-fail '@HEX_BIN@' "$out/bin/hex"
    runHook postInstall
  '';
  postFixup = ''
    wrapProgram $out/bin/hex \
      --prefix PATH : ${lib.makeBinPath (with pkgs; [ curl wl-clipboard wtype ffmpeg-headless ])} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (with pkgs; [ vulkan-loader openblas alsa-lib wayland libxkbcommon fontconfig pipewire libva ])} \
      --set ALSA_PLUGIN_DIR ${alsaPlugins}
  '';
  meta = {
    description = "Local-first voice dictation";
    homepage = "https://anoma.ly/hex/";
    license = lib.licenses.mit;
    mainProgram = "hex";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
