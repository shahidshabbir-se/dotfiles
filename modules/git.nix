{ config
, pkgs
, ...
}: {
  enable = true;
  lfs.enable = true;
  userName = "shahidshabbir-se";
  userEmail = "shahidshabbirse@gmail.com";
  signing.key = null;
  signing.signByDefault = true;

  extraConfig = {
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "master";
    };

    # url = {
    #   "git@github.com:" = {
    #     insteadOf = "https://github.com/";
    #   };
    # };
  };
}
