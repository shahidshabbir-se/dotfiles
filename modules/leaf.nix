{ lib, pkgs, ... }:

let
  leaf = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "leaf-markdown-viewer";
    version = "1.29.1";

    src = pkgs.fetchFromGitHub {
      owner = "RivoLink";
      repo = "leaf";
      tag = finalAttrs.version;
      hash = "sha256-+J8c6aoM2GqZMJe2XUiY4A6T1qqw1s1+kVMhdHKSt8o=";
    };

    cargoHash = "sha256-pbzCRd6BoImGL2DXInGRiiobk1CnMEmmeH1tetzNLnQ=";
    nativeBuildInputs = [ pkgs.pkg-config ];

    meta = {
      description = "Interactive terminal Markdown previewer";
      homepage = "https://leaf.rivolink.mg/";
      license = lib.licenses.mit;
      mainProgram = "leaf";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  });
in
{
  home.packages = [ leaf ];

  xdg.configFile = {
    "leaf/config.toml".source = ../config/leaf/config.toml;
    "leaf/themes/tokyonight.toml".source = ../config/leaf/tokyonight.toml;
  };
}
