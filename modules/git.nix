{ config
, pkgs
, userGmail
, userGithub
, homeDirectory
, ...
}: {
  enable = true;
  delta.enable = true;
  lfs.enable = true;
  userName = userGithub;
  userEmail = userGmail;

  extraConfig = {
    init = {
      defaultBranch = "master";
    };
    color = {
      ui = "auto";
    };
    diff = {
      tool = "vimdiff";
      mnemonicprefix = true;
    };
    merge = {
      tool = "splice";
    };
    push = {
      default = "simple";
    };
    pull = {
      rebase = true;
    };
    core = {
      excludesfile = "~/.gitignore_global";
    };
    branch = {
      autosetupmerge = true;
    };
    rerere = {
      enabled = true;
    };
    delta = {
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
    pager = {
      diff = "delta";
      log = "delta";
      reflog = "delta";
      show = "delta";
    };
  };
  includes = [
    { path = "$homeDirectory/.config/themes.gitconfig"; }
  ];
}
