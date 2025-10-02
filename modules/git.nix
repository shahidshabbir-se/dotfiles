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
  delta.enable = true;
  lfs.enable = true;

  # ───────────────────────────────────────────────
  # ▶ Git Identity
  # ───────────────────────────────────────────────
  userName = userGithub;
  userEmail = userGmail;

  # ───────────────────────────────────────────────
  # ▶ Git Configuration
  # ───────────────────────────────────────────────
  extraConfig = {
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

  # ───────────────────────────────────────────────
  # ▶ Additional Git Includes
  # ───────────────────────────────────────────────
  includes = [
    { path = "${homeDirectory}/.config/themes.gitconfig"; }
  ];
}
