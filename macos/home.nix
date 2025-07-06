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
      eza
      fzf
      bat
      ripgrep
      coreutils
      jq
      htop
    ];
  };

  # ───────────────────────────────────────────────
  # ▶ Dotfiles Mapping
  # ───────────────────────────────────────────────
  home.file.".p10k.zsh".source = ../.p10k.zsh;
  home.file.".wezterm.lua".source = ../.wezterm.lua;

  # ───────────────────────────────────────────────
  # ▶ Program Configurations
  # ───────────────────────────────────────────────
  programs = {
    git = import ./modules/git.nix {
      inherit
        config
        pkgs
        homeDirectory
        userGmail
        userGithub;
    };

    zsh = import ../modules/zsh.nix {
      inherit config pkgs lib;
    };

    tmux = import ../modules/tmux.nix {
      inherit pkgs;
    };

    atuin = import ../modules/atuin.nix;

    neovim = import ../modules/neovim.nix {
      inherit config pkgs;
    };

    eza = {
      enableZshIntegration = true;
    };

    fzf = import ../modules/fzf.nix {
      inherit pkgs;
    };

    zoxide = import ../modules/zoxide.nix {
      inherit pkgs;
    };

    password-store.enable = true;
  };
}
