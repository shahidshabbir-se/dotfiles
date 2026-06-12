#  ███╗   ██╗███████╗██╗   ██╗ ██████╗ ███╗   ███╗
#  ████╗  ██║██╔════╝██║   ██║██╔═══██╗████╗ ████║
#  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██╔████╔██║
#  ██║╚██╗██║██╔══╝  ╚██╗ ██╔╝██║   ██║██║╚██╔╝██║
#  ██║ ╚████║███████╗ ╚████╔╝ ╚██████╔╝██║ ╚═╝ ██║
#  ╚═╝  ╚═══╝╚══════╝  ╚═══╝   ╚═════╝ ╚═╝     ╚═╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, ... }:

{
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

  # Keep Home Manager's Neovim package/wrapper, but do not let it write
  # ~/.config/nvim/init.lua over the symlinked LazyVim configuration.
  xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
}
