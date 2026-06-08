#  ███╗   ██╗███████╗██╗   ██╗ ██████╗ ███╗   ███╗
#  ████╗  ██║██╔════╝██║   ██║██╔═══██╗████╗ ████║
#  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██╔████╔██║
#  ██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██║   ██║██║╚██╔╝██║
#  ██║ ╚████║███████╗ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║
#  ╚═╝  ╚═══╝╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, ... }:

{
  enable = true;

  # Dotfiles nvim config is symlinked via xdg.configFile.nvim — do not write
  # init.lua into that tree (HM 26.x would resolve it outside $HOME at build time).
  sideloadInitLua = true;

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
}
