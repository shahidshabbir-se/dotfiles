#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗  
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, inputs, ... }:

let
  homeDirectory = "/Users/shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  wallpaperPath = "${homeDirectory}/Pictures/Wallpapers/1.png";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  # ───────────────────────────────────────────────
  # ▶ Home Directory & Package Set
  # ───────────────────────────────────────────────
  home = {
    username = "shahid";
    homeDirectory = homeDirectory;
    stateVersion = "24.05";

    packages = with pkgs; [
      zsh
      inputs.home-manager.packages.${pkgs.system}.home-manager
      zoxide
      atuin
      croc
      tmux
      lsd
      rustup
      typtea
      bun
      go
      doppler
      btop
      aerospace
      fd
      gnupg
      wget
      fzf
      bat
      yazi
      ripgrep
      sqlc
      gitleaks
      lazygit
      fnm
      ncdu
      graphite-cli
      wrk
      act
      dogdns
      fastfetch
      onefetch
      coreutils
      jq
      htop
    ];
    # activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #   echo "Setting macOS wallpaper to ${wallpaperPath}"
    #   /usr/bin/osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "${wallpaperPath}"'
    # '';
  };

  # ───────────────────────────────────────────────
  # ▶ XDG Configuration
  # ───────────────────────────────────────────────
  xdg.enable = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
  home.file.".aerospace.toml".source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/aerospace.toml";


  # ───────────────────────────────────────────────
  # ▶ Dotfiles Mapping
  # ───────────────────────────────────────────────
  home.file.".p10k.zsh".source = ../../config/p10k.zsh;

  # ───────────────────────────────────────────────
  # ▶ Program Configurations
  # ───────────────────────────────────────────────
  programs = {
    git = import ../../modules/git.nix {
      inherit config pkgs homeDirectory userGmail userGithub;
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        features = "tokyonight";
        side-by-side = true;
        line-numbers = true;

        # Tokyonight Night theme colors
        tokyonight = {
          syntax-theme = "none";
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow";
          file-decoration-style = "none";
          hunk-header-decoration-style = "blue box";
          hunk-header-file-style = "purple";
          hunk-header-line-number-style = "bold blue";
          hunk-header-style = "file line-number syntax";

          minus-style = "syntax #37222c";
          minus-emph-style = "syntax #713137";
          minus-non-emph-style = "syntax auto";

          plus-style = "syntax #20303b";
          plus-emph-style = "syntax #2c5a66";
          plus-non-emph-style = "syntax auto";

          line-numbers-minus-style = "#914c54";
          line-numbers-plus-style = "#449dab";
          line-numbers-left-style = "#565f89";
          line-numbers-right-style = "#565f89";
          line-numbers-zero-style = "#3b4261";
        };
      };
    };

    zsh = import ../../modules/zsh.nix { inherit config pkgs lib; };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
    atuin = import ../../modules/atuin.nix;
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    spicetify = import ../../modules/spicetify.nix { inherit inputs pkgs; };
    kitty = import ../../modules/kitty.nix { inherit pkgs; };
    # alacritty = import ../../modules/alacritty.nix { inherit pkgs; };
  };
}
