{ pkgs, lib }:

{
  enable = true;
  config = {
    theme = "TokyoNight";
    style = "numbers,changes,header";
    italic-text ="always";
    pager = "less -FR";
  };

  themes = {
    TokyoNight = {
      src = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "tokyonight.nvim";
        rev = "main";
        sha256 = "sha256-4zfkv3egdWJ/GCWUehV0MAIXxsrGT82Wd1Qqj1SCGOk=";
      };
        file = "extras/sublime/tokyonight_night.tmTheme";
    };
  };
}
