{ config
, pkgs
, userGmail
, userGithub
, ...
}: {
  enable = true;
  lfs.enable = true;
  userName = userGithub;
  userEmail = userGmail;

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
