#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗  
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, inputs, ... }:

let
  homeDirectory = "/home/shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  # imports = [
  #   ../../modules/pkgs/kubernetes.nix
  # ];

  # ───────────────────────────────────────────────
  # ▶ Home Directory & Package Set
  # ───────────────────────────────────────────────
  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = import ../../modules/banana-cursor.nix { inherit pkgs; };
    size = 36;
    name = "Banana-Catppuccin-Mocha";
  };
  home = {
    username = "shahid";
    homeDirectory = homeDirectory;
    stateVersion = "24.05";

    packages = (import ../../modules/pkgs/common.nix { inherit pkgs; }) ++ (with pkgs; [
      waybar
      fastfetch
      wlogout
      hyprlock
      alsa-utils
      brightnessctl
      cliphist
      feh
      gcc
      gnumake
      grimblast
      inputs.zen-browser.packages."${system}".default
      inter
      libnotify
      mpvpaper
      nitch
      playerctl
      python3
      swaynotificationcenter
      swww
      tokyonight-gtk-theme
      unzip
      vlc
      wl-clipboard
      wofi
      rofi
      rofi-bluetooth
      rofi-network-manager
      zip
    ]);
  };

  # ───────────────────────────────────────────────
  # ▶ XDG Configuration
  # ───────────────────────────────────────────────
  xdg.enable = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
  xdg.configFile.waybar.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/waybar";
  xdg.configFile.yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";
  xdg.configFile.rofi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/rofi";

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
    delta = import ../../modules/delta.nix { inherit pkgs; };
    zsh = import ../../modules/zsh.nix { inherit config pkgs lib; };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
    atuin = import ../../modules/atuin.nix;
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    spicetify = import ../../modules/spicetify.nix { inherit inputs pkgs; };
    kitty = import ../../modules/kitty.nix { inherit pkgs; };
    # ghostty = import ../../modules/ghostty.nix { inherit pkgs; };
  };

  services.swaync = import ../../modules/swaync.nix {
    inherit pkgs homeDirectory;
  };

  wayland.windowManager.hyprland = import ../../modules/hyprland.nix {
    inherit config pkgs homeDirectory;
  };

  # ───────────────────────────────────────────────
  # ▶ dconf Settings
  # ───────────────────────────────────────────────
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Tokyonight-Dark-BL";
      cursor-theme = "Banana-Catppuccin-Mocha";
      cursor-size = 36;
      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark-BL";
      package = pkgs.tokyonight-gtk-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}

