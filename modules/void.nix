{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "void";
  version = "1.99.30044";

  src = pkgs.fetchurl {
    url =
      "https://github.com/voideditor/binaries/releases/download/${version}/Void-linux-x64-${version}.tar.gz";
    sha256 = "013aq1k0f5mayz73wfb5acadfpk20g0y0874jxryfsvia95rgsvv";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.libsecret
    pkgs.krb5
    pkgs.at-spi2-atk
    pkgs.nss
    pkgs.nspr
    pkgs.mesa
    pkgs.gtk3
    pkgs.systemd
    pkgs.alsa-lib
    pkgs.libdrm
    pkgs.libglvnd
    pkgs.libxkbcommon
    pkgs.xorg.libX11
    pkgs.xorg.libXcomposite
    pkgs.xorg.libXdamage
    pkgs.xorg.libXext
    pkgs.xorg.libXfixes
    pkgs.xorg.libXrandr
    pkgs.xorg.libxcb
    pkgs.xorg.libxkbfile
  ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/opt/void
    cp -r ./* $out/opt/void/

    mkdir -p $out/bin
    ln -s $out/opt/void/bin/void $out/bin/void
  '';

  postFixup = ''
    wrapProgram $out/bin/void \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
  '';
}
