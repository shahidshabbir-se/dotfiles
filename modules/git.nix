#   ██████╗ ██╗████████╗
#  ██╔════╝ ██║╚══██╔══╝
#  ██║  ███╗██║   ██║   
#  ██║   ██║██║   ██║   
#  ╚██████╔╝██║   ██║   
#   ╚═════╝ ╚═╝   ╚═╝   
#  https://github.com/shahidshabbir-se/dotfiles

{ config
, pkgs
, userGmail
, userGithub
, homeDirectory
, ...
}: {
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ Extensions
  # ───────────────────────────────────────────────
  lfs.enable = true;

  # ───────────────────────────────────────────────
  # ▶ Git Identity & Configuration
  # ───────────────────────────────────────────────
  settings = {
    user = {
      name = userGithub;
      email = userGmail;
    };

    init.defaultBranch = "master";

    color.ui = "auto";

    diff = {
      tool = "vimdiff";
      mnemonicprefix = true;
    };

    merge.tool = "splice";

    push.default = "simple";

    pull.rebase = true;

    core.excludesfile = "~/.gitignore_global";

    branch.autosetupmerge = true;

    rerere.enabled = true;
  };

  # ───────────────────────────────────────────────
  # ▶ Additional Git Includes
  # ───────────────────────────────────────────────
  includes = [
    { path = "${homeDirectory}/.config/themes.gitconfig"; }
  ];
}
