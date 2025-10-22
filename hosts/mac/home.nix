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
      goose-cli
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
