{ pkgs, lib, inputs, nixpkgs, ... }:

{
  home.username = "shahid";
  home.homeDirectory = "/home/shahid";


  imports = [
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


  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    kitty
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
    kanshi
    nodePackages.prisma
    gcc
    feh
    nitch
    stylua
    go
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
    # power-profiles-daemon
    grimblast
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    cava
  ];

  programs.git = {
    enable = true;
    userName = "shahidshabbir-se";
    userEmail = "shahidshabbirse@gmail.com";
  };

  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    overwrite.enable = true;
    theme = "tokyo_night";
    layout = {
      "bar.layouts" = {
        "*" = {
          "left" = [
            "dashboard"
            "media"
            "windowtitle"
          ];
          "middle" = [
            "cava"
            "workspaces"
            "cava"
          ];
          "right" = [
            "network"
            "bluetooth"
            "volume"
            "battery"
            "clock"
            "power"
          ];
        };
      };
    };



    settings = {
      bar.workspaces.show_icons = true;
      theme = {
        font.size = "13px";
        font.name = "JetBrainsMono Nerd Font";
        bar = {
          transparent = true;
          outer_spacing = "0.4rem";
        };
      };
      wallpaper.enable = false;
      bar.bluetooth.label = false;
      bar.network.label = false;
      bar.clock.format = "%a %b %d %I:%M %p";
      bar.media.show_active_only = true;
      bar.customModules.cava.showIcon = false;
      bar.customModules.cava.showActiveOnly = true;
      menus.dashboard.powermenu.avatar.image = "/home/shahid/Pictures/unnamed.png";
      menus.dashboard.powermenu.avatar.name = "Shahid Shabbir";

      theme.bar.menus.menu.clock.scaling = 80;
      theme.bar.menus.menu.dashboard.scaling = 80;
      bar.media.truncation_size = 20;
      bar.launcher.autoDetectIcon = true;
      bar.workspaces.showApplicationIcons = false;
      theme.bar.buttons.modules.power.spacing = "0";
      bar.workspaces.monitorSpecific = false;
      bar.workspaces.applicationIconEmptyWorkspace = "";

      menus.clock = {
        time = {
          military = true;
          hideSeconds = true;
        };
        weather = {
          enabled = false;
          location = "14000";
          unit = "metric";
        };
      };
    };
  };

  home.file = {
    ".zshrc".source = ./.config/.zshrc;
    ".p10k.zsh".source = ./.config/.p10k.zsh;
    ".config/kitty".source = ./.config/kitty;
    ".config/gtk-3.0".source = ./.config/gtk-3.0;
    ".config/gtk-4.0".source = ./.config/gtk-4.0;
    ".config/rofi".source = ./.config/rofi;
    ".config/alacritty".source = ./.config/alacritty;
    ".config/yazi".source = ./.config/yazi;
    # ".config/nvim".source = ./.config/nvim;
    ".local/share/fonts".source = ./.local/share/fonts;
    ".local/share/themes".source = ./.local/share/themes;
    ".local/share/icons".source = ./.local/share/icons;
    # ".config/hypr".source = ./config/hypr;
    ".config/bat".source = ./.config/bat;
    ".config/hypr/hyprlock.conf".source = ./.config/hypr/hyprlock.conf;
    ".config/hypr/mocha.conf".source = ./.config/hypr/mocha.conf;
  };
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;
}
