#  ███╗   ██╗██╗██╗  ██╗    ██╗    ██╗███████╗██╗
#  ████╗  ██║██║╚██╗██╔╝    ██║    ██║██╔════╝██║
#  ██╔██╗ ██║██║ ╚███╔╝     ██║ █╗ ██║███████╗██║
#  ██║╚██╗██║██║ ██╔██╗     ██║███╗██║╚════██║██║
#  ██║ ╚████║██║██╔╝ ██╗    ╚███╔███╔╝███████║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝     ╚══╝╚══╝ ╚══════╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{
  config,
  pkgs,
  lib,
  ...
}:

let
  username = "shahid";
  homeDirectory = "/home/${username}";
  dotfilesDirectory = "${homeDirectory}/dotfiles";

  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";

  inherit (config.lib.file) mkOutOfStoreSymlink;

  commonPackages = import ../../modules/pkgs/common.nix { inherit pkgs; };
  npmGlobal = "${homeDirectory}/.npm-global";
in
{
  nixpkgs.config.allowUnfree = true;

  home = {
    inherit username homeDirectory;
    stateVersion = "24.05";

    packages =
      commonPackages
      ++ (with pkgs; [
        bun
        fastfetch
        gcc
        git-filter-repo
        gnumake
        ripgrep
        chromium
        home-manager
        neovim
        nodejs_24
        python3
        unzip
        zip
      ]);

    file = {
      ".p10k.zsh".source = ../../config/p10k.zsh;
      ".npmrc".text = ''
        prefix=${npmGlobal}
      '';
      "${npmGlobal}/.keep".text = "";
    };

    sessionVariables = {
      PATH = "${homeDirectory}/.nix-profile/bin:${npmGlobal}/bin:$PATH";
    };

    activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${homeDirectory}/.config" "${homeDirectory}/.zsh"

      backup_if_real_path() {
        target="$1"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$target" "$target.backup"
        fi
      }

      backup_if_real_path "${homeDirectory}/.config/nvim"
      backup_if_real_path "${homeDirectory}/.config/yazi"
      backup_if_real_path "${homeDirectory}/.zsh/aliases"

      $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfnT "${dotfilesDirectory}/config/nvim" "${homeDirectory}/.config/nvim"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfnT "${dotfilesDirectory}/config/yazi" "${homeDirectory}/.config/yazi"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/ln -sfnT "${dotfilesDirectory}/config/zsh/aliases" "${homeDirectory}/.zsh/aliases"

    '';
  };

  xdg = {
    enable = true;
  };

  programs = {
    git = import ../../modules/git.nix {
      inherit
        config
        pkgs
        homeDirectory
        userGmail
        userGithub
        ;
    };
    delta = import ../../modules/delta.nix { inherit pkgs; };
    zsh =
      import ../../modules/zsh.nix {
        inherit config pkgs lib;
        browser = "xdg-open";
      }
      // {
        dotDir = config.home.homeDirectory;
        shellAliases =
          (import ../../modules/zsh.nix {
            inherit config pkgs lib;
            browser = "xdg-open";
          }).shellAliases
          // {
            hms = "~/.nix-profile/bin/home-manager switch -b backup -f ~/dotfiles/hosts/wsl/home.nix";
          };
      };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
    bat = import ../../modules/bat.nix { inherit pkgs lib; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
  };
}
