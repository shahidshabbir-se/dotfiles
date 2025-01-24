{ pkgs, lib, inputs, nixpkgs, config, ... }:

let
  bananaCursor = import ./modules/banana-cursor-dreams.nix { inherit pkgs; };
in
{
  home.username = "shahid";
  home.homeDirectory = "/home/shahid";

  imports = [
    inputs.spicetify-nix.homeManagerModules.default
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];


  home.packages = with pkgs; [
    tmux
    discord
    xfce.thunar
    neovim
    git
    swww
    qbittorrent
    conda
    ntfs3g
    cliphist
    git-graph
    prisma-engines
    wl-clipboard
    bat
    keyd
    # yazi
    brightnessctl
    wget
    rofi
    btrfs-progs
    zip
    xz
    spicetify-cli
    eww
    unzip
    ripgrep
    jq
    eza
    fzf
    docker
    zoxide
    nodejs_22
    btop
    mtr
    iperf3
    nmap
    ipcalc
    gnused
    gnutar
    playerctl
    gawk
    zstd
    gnupg
    tree
    noto-fonts-emoji
    alacritty
    nodePackages.prisma
    gcc
    feh
    nitch
    stylua
    rustup
    nixpkgs-fmt
    hyprlock
    power-profiles-daemon
    firefox

    # hyprpanel dependencies
    ags
    wireplumber
    libgtop
    bluez
    bluetui
    dart-sass
    upower
    gvfs

    # additional dependencies
    grimblast
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    cava
  ];

  home.file = {
    ".config/rofi".source = ./.config/rofi;
    # ".config/nvim".source = ./.config/nvim;
    ".local/share/fonts".source = ./.local/share/fonts;
    ".local/share/themes".source = ./.local/share/themes;
    # ".config/hypr".source = ./config/hypr;
    ".config/bat".source = ./.config/bat;
    ".config/hypr/hyprlock.conf".source = ./.config/hypr/hyprlock.conf;
    ".config/hypr/mocha.conf".source = ./.config/hypr/mocha.conf;
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
  programs = {
    tmux = import ./modules/tmux.nix { inherit pkgs; };
    zsh = import ./modules/zsh.nix { inherit config pkgs lib; };
    git = import ./modules/git.nix { inherit config pkgs; };
    alacritty = import ./modules/alacritty.nix { inherit pkgs; };
    fzf = import ./modules/fzf.nix { inherit pkgs; };
    zoxide = import ./modules/zoxide.nix { inherit pkgs; };
    spicetify = import ./modules/spicetify.nix { inherit inputs pkgs; };
    # yazi = import ./modules/yazi.nix { inherit pkgs; };
    hyprpanel = import ./modules/hyprpanel.nix { inherit pkgs; };
  };

  home.pointerCursor = {
    x11.enable = true;
    gtk.enable = true;
    package = bananaCursor;
    size = 48;
    name = "Banana-Catppuccin-Mocha";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;
    theme.name = "Catppuccin-Dark";
  };
}
