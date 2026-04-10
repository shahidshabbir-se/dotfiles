{ pkgs, lib }:

{
  enable = true;
  config = {
    theme = "TokyoNight";
    style = "numbers,changes,header";
    italic-text = "always";
    pager = "less -FR";
  };

  themes = {
    TokyoNight = {
      src = pkgs.fetchFromGitHub {
        owner = "shahidshabbir-se";
        repo = "tokyonight.nvim";
        rev = "main";
        sha256 = "sha256-a9iRWue7DB7s/wNdxqqB51Jya5P9X6sDftqhdmKggU0=";
      };
      file = "extras/sublime/tokyonight_night.tmTheme";
    };
  };
}
