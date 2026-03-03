#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗  
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, inputs, device, ... }:

let
  homeDirectory = "/Users/shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  # wallpaperPath = "${homeDirectory}/Pictures/Wallpapers/1.png";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  imports = [
    # ../../modules/cliproxyapi.nix
    ../../modules/karabiner.nix
    ../../modules/node.nix
  ];

  # ───────────────────────────────────────────────
  # ▶ Home Directory & Package Set
  # ───────────────────────────────────────────────
  home = {
    username = "shahid";
    homeDirectory = homeDirectory;
    stateVersion = "24.05";

    packages = (import ../../modules/pkgs/common.nix { inherit pkgs; }) ++ ([
      inputs.home-manager.packages.${pkgs.system}.home-manager
    ]);
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
  xdg.configFile.yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";
  xdg.configFile.zed.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zed";


  # ───────────────────────────────────────────────
  # ▶ Dotfiles Mapping
  # ───────────────────────────────────────────────
  home.file.".p10k.zsh".source = ../../config/p10k.zsh;
  home.file.".zsh/aliases".source = ../../config/zsh/aliases;

  # ───────────────────────────────────────────────
  # ▶ Program Configurations
  # ───────────────────────────────────────────────
  programs = {
    git = import ../../modules/git.nix {
      inherit config pkgs homeDirectory userGmail userGithub;
    };
    delta = import ../../modules/delta.nix { inherit pkgs; };
    zsh = import ../../modules/zsh.nix { inherit config pkgs lib; };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
    bat = import ../../modules/bat.nix { inherit pkgs lib; };
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    aerospace = import ../../modules/aerospace.nix;
    spicetify = import ../../modules/spicetify.nix { inherit inputs pkgs lib; };
    wezterm = import ../../modules/wezterm.nix { inherit pkgs device; };
    # ghostty = import ../../modules/ghostty.nix { inherit config pkgs device; };
    # alacritty = import ../../modules/alacritty.nix { inherit pkgs; };
  };
}
