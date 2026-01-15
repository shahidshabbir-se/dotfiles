{ pkgs }:

let
  version = "0.48.0";
  
  sources = {
    x86_64-linux = {
      url = "https://github.com/shahidshabbir-se/factory-cli/releases/download/v${version}/droid-linux-x64";
      sha256 = "ddefebdf60884021e308586f4aa23eff8136a0701e2d4aefce177e047976c164";
    };
    aarch64-darwin = {
      url = "https://github.com/shahidshabbir-se/factory-cli/releases/download/v${version}/droid-darwin-arm64";
      sha256 = "187cbb079064a27efddd4d0fb99c3ca40a8b5e84e55a7245da7693bdd472ac66";
    };
    x86_64-darwin = {
      url = "https://github.com/shahidshabbir-se/factory-cli/releases/download/v${version}/droid-darwin-x64";
      sha256 = "1b608e9c4250ff16c74178ed8b5f3e376433477ea03fa03abf9f086f46aca398";
    };
  };
  
  source = sources.${pkgs.stdenv.hostPlatform.system} or (throw "Unsupported platform: ${pkgs.stdenv.hostPlatform.system}");
in
pkgs.runCommand "droid" {
  buildInputs = [ pkgs.makeWrapper ];
  src = pkgs.fetchurl {
    url = source.url;
    sha256 = source.sha256;
  };
} ''
  mkdir -p $out/bin
  cp $src $out/bin/droid
  chmod +x $out/bin/droid
''
