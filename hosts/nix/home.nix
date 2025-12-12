#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗  
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{ config, pkgs, lib, inputs, device, ... }:

let
  homeDirectory = "/home/shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Allow unfree packages for corefonts
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "corefonts" ];
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
    package = pkgs.catppuccin-cursors.mochaDark;
    size = 24;
    name = "catppuccin-mocha-dark-cursors";
  };
  home = {
    username = "shahid";
    homeDirectory = homeDirectory;
    stateVersion = "24.05";

    packages = (import ../../modules/pkgs/common.nix { inherit pkgs; }) ++ (with pkgs; [
      corefonts
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
      xfce.thunar
      nitch
      playerctl
      python3
      swaynotificationcenter
      swww
      (pkgs.catppuccin-gtk.override { variant = "mocha"; accents = [ "blue" ]; size = "standard"; })
      onlyoffice-desktopeditors
      unzip
      vlc
      wl-clipboard
      wofi
      rofi
      rofi-bluetooth
      rofi-network-manager
      catppuccin-papirus-folders
      zip
    ]);
  };

  # ───────────────────────────────────────────────
  # ▶ XDG Configuration
  # ───────────────────────────────────────────────
  xdg.enable = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
  xdg.configFile.zed.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zed";
  xdg.configFile.waybar.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/waybar";
  xdg.configFile.yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";
  xdg.configFile.rofi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/rofi";

  # ───────────────────────────────────────────────
  # ▶ Dotfiles Mapping
  # ───────────────────────────────────────────────
  home.file.".p10k.zsh".source = ../../config/p10k.zsh;
  home.file.".zsh/aliases".source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zsh/aliases";

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
    bat = import ../../modules/bat.nix { inherit pkgs lib; };
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    spicetify = import ../../modules/spicetify.nix { inherit inputs lib pkgs; };
    # wezterm = import ../../modules/wezterm.nix { inherit pkgs; };
    # kitty = import ../../modules/kitty.nix { inherit pkgs; };
    ghostty = import ../../modules/ghostty.nix { inherit config device pkgs; };
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
      gtk-theme = "catppuccin-mocha-blue-standard";
      icon-theme = "Papirus-Dark";
      cursor-theme = "catppuccin-mocha-dark-cursors";
      cursor-size = 24;
      font-name = "Inter 11";
      document-font-name = "Inter 11";
      monospace-font-name = "JetBrainsMono Nerd Font 11";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard";
      package = (pkgs.catppuccin-gtk.override { variant = "mocha"; accents = [ "blue" ]; size = "standard"; });
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}

