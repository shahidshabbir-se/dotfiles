#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗  
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, ... }:

let
  homeDirectory = "/Users/shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  wallpaperPath = "/Users/shahid/dotfiles/wallpapers/lighthouse.jpg";
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
      zoxide
      atuin
      tmux
      lsd
      typtea
      btop
      fd
      fzf
      bat
      yazi
      ripgrep
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
  xdg.configFile.kitty.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/kitty";
  # xdg.configFile.alacritty.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/alacritty";

  # ───────────────────────────────────────────────
  # ▶ Dotfiles Mapping
  # ───────────────────────────────────────────────
  home.file.".p10k.zsh".source = ../../config/p10k.zsh;
  # home.file.".wezterm.lua".source = ../.wezterm.lua;

  # ───────────────────────────────────────────────
  # ▶ Program Configurations
  # ───────────────────────────────────────────────
  programs = {
    git = import ./git.nix {
      inherit config pkgs homeDirectory userGmail userGithub;
    };

    zsh = import ../../modules/zsh.nix { inherit config pkgs lib; };

    tmux = import ../../modules/tmux.nix { inherit pkgs; };

    atuin = import ../../modules/atuin.nix;

    neovim = import ../../modules/nvim.nix { inherit config pkgs; };

    fzf = import ../../modules/fzf.nix { inherit pkgs; };

    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };

    alacritty = import ../../modules/alacritty.nix { inherit pkgs; };
  };
}
