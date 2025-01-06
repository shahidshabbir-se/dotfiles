{  pkgs, lib, inputs, nixpkgs, ... }:

{
  home.username = "shahid";
  home.homeDirectory = "/home/shahid";


  imports = [
    # For NixOS
    inputs.spicetify-nix.homeManagerModules.default
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
  
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle 
    ];
    enabledCustomApps = with spicePkgs.apps; [
      newReleases
      ncsVisualizer
    ];
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
    ];
  
    theme = spicePkgs.themes.text;
      colorScheme = "TokyoNight";
  };

  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    hyprland.enable = true;
    overwrite.enable = true;
    theme = "tokyo_night";
      override = {
        theme.bar.menus.text = "#123ABC";
      };
    layout = {
      "bar.layouts" = {
        "0" = {
          left = [ "dashboard" "workspaces" ];
          middle = [ "media" ];
          right = [ "volume" "network" "bluetooth" "powerdropdown" "energy" "calendar" "battery" "clock" "notifications" ];
        };
      };
    };
  
    settings = {
      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;
      menus.clock = {
        time = {
          military = true;
          hideSeconds = true;
          };
          weather.unit = "metric";
        };
        menus.dashboard.directories.enabled = false;
        menus.dashboard.stats.enable_gpu = true;
        theme.bar.transparent = true;
        theme.font = {
          name = "CaskaydiaCove NF";
          size = "16px";
        };
      };
    };

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    fastfetch
    kitty
    raffi
    tmux
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
    yazi
    brightnessctl
    blueman
    wget
    wofi
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
    corepack_22
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
    inputs.zen-browser.packages."x86_64-linux".default
    kanshi
    nodePackages.prisma
    swaylock
  ];

  programs.git = {
    enable = true;
    userName = "shahidshabbir-se";
    userEmail = "shahidshabbirse@gmail.com";
  };

  home.file = {
    ".zshrc".source = ./.config/.zshrc;
    # ".tmux.conf".source = ./.config/.tmux.conf;
    ".p10k.zsh".source = ./.config/.p10k.zsh;
    ".config/kitty".source = ./.config/kitty;
    ".config/alacritty".source = ./.config/alacritty;
    ".config/yazi".source = ./.config/yazi;
    # ".config/nvim".source = ./.config/nvim;
    ".local/share/fonts/JetBrainsMono".source = ./.local/share/fonts/JetBrainsMono;
    # ".config/hypr".source = ./config/hypr;
    ".config/fastfetch".source = ./.config/fastfetch;
    ".config/bat".source = ./.config/bat;
    ".config/swaylock".source = ./.config/swaylock/;
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
