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

    packages = with pkgs; [
      zsh
      zoxide
      gcc
      atuin
      tmux
      lsd
      typtea
      bun
      go
      doppler
      nitch
      fnm
      btop
      fd
      gnupg
      fzf
      bat
      python3
      poppins
      zip
      feh
      grimblast
      wofi
      unzip
      brightnessctl
      playerctl
      localsend
      ghostty
      yazi
      ripgrep
      wrk
      cliphist
      wl-clipboard
      act
      dogdns
      swww
      fastfetch
      onefetch
      coreutils
      jq
      wezterm
      inputs.zen-browser.packages."${system}".default
      htop
      tokyonight-gtk-theme
    ];
  };

  # ───────────────────────────────────────────────
  # ▶ XDG Configuration
  # ───────────────────────────────────────────────
  xdg.enable = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
  xdg.configFile.yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";

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
    tmux = import ../../modules/tmux.nix { inherit pkgs; };
    atuin = import ../../modules/atuin.nix;
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    spicetify = import ../../modules/spicetify.nix { inherit inputs pkgs; };
    kitty = import ../../modules/kitty.nix { inherit pkgs; };
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
      font-name = "Poppins 11";
      document-font-name = "Poppins 11";
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

