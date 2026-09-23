#  ███╗   ██╗███████╗██╗   ██╗ ██████╗ ███╗   ███╗
#  ████╗  ██║██╔════╝██║   ██║██╔═══██╗████╗ ████║
#  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██╔████╔██║
#  ██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██║   ██║██║╚██╔╝██║
#  ██║ ╚████║███████╗ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║
#  ╚═╝  ╚═══╝╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, ... }:

{
  # tree-sitter CLI (≥0.26.1) is required by the nvim-treesitter `main` branch
  # to compile parsers at runtime (ensure_installed / :TSInstall / :TSUpdate).
  home.packages = [ pkgs.tree-sitter ];

  programs.neovim = {
    enable = true;

    # LazyVim config lives in ~/dotfiles/config/nvim; skip HM provider bootstrapping.
    withRuby = false;
    withPython3 = false;
    withNodeJs = false;

    # ───────────────────────────────────────────────
    # ▶ Set Vim as the default editor
    # ───────────────────────────────────────────────
    defaultEditor = true;

    # ───────────────────────────────────────────────
    # ▶ Create `vi` and `vim` aliases
    # ───────────────────────────────────────────────
    viAlias = true;
    vimAlias = true;
  };

  # Override Home Manager's nvim/init.lua generation with an empty file so HM doesn't attempt
  # to write provider wrappers outside $HOME or fail on missing source.
  xdg.configFile."nvim/init.lua" = lib.mkForce {
    enable = false;
    text = "";
  };
}
