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
  browser = "zen-beta";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  system = pkgs.stdenv.hostPlatform.system;

  unstable = import inputs.unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # Allow unfree packages for corefonts
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "corefonts" ];
in
{
  imports = [
    ../../modules/node.nix
    # ../../modules/cliproxyapi.nix
  ];

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
  # home.pointerCursor = {
  #   x11.enable = true;
  #   gtk.enable = true;
  #   package = import ../../modules/banana-cursor.nix { inherit pkgs; };
  #   size = 36;
  #   name = "Banana";
  # };
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
      postgresql
      gcc
      gnumake
      grimblast
      inputs.zen-browser.packages.${system}.default
      chromium
      protonvpn-gui
      # poppins
      eww
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
      wl-clipboard
      wofi
      rofi
      rofi-bluetooth
      catppuccin-papirus-folders
      zip
      # X11 / i3 session packages
      i3lock-color
      maim
      xclip
      xsel
      xdotool
      xorg.xrandr
      numlockx
      haskellPackages.greenclip
      autorandr
      xsettingsd
      libinput-gestures
      xbindkeys
      bc
      # (import ../../modules/void.nix { inherit pkgs; })
    ]);
  };

  # ───────────────────────────────────────────────
  # ▶ XDG Configuration
  # ───────────────────────────────────────────────
  xdg.enable = true;
  xdg.configFile.nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
  # xdg.configFile.zed.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zed";
  xdg.configFile.waybar.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/waybar";
  xdg.configFile.yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";
  xdg.configFile.eww.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/eww";
  xdg.configFile.rofi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/rofi";
  # picom config is loaded directly via extraArgs in picom.nix (no symlink needed)
  # polybar config is loaded directly via --config flag for fast iteration

  # ───────────────────────────────────────────────
  # ▶ libinput-gestures (touchpad 3-finger swipe to switch workspaces)
  # ───────────────────────────────────────────────
  xdg.configFile."libinput-gestures.conf".text = ''
    gesture swipe right 3 i3-msg workspace prev
    gesture swipe left 3 i3-msg workspace next
  '';

  # ───────────────────────────────────────────────
  # ▶ xbindkeys (Super+scroll to switch workspaces)
  # ───────────────────────────────────────────────
  home.file.".xbindkeysrc".text = ''
    "i3-msg workspace prev"
      Mod4 + b:4

    "i3-msg workspace next"
      Mod4 + b:5
  '';

  # ───────────────────────────────────────────────
  # ▶ xsettingsd (bridges GTK/font settings to X11)
  # ───────────────────────────────────────────────
  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Net/ThemeName "catppuccin-mocha-blue-standard"
    Net/IconThemeName "Papirus-Dark"
    Gtk/CursorThemeName "catppuccin-mocha-dark-cursors"
    Gtk/CursorThemeSize 24
    Gtk/FontName "SF Pro Display 10"
    Net/EnableEventSounds 0
    Net/EnableInputFeedbackSounds 0
    Xft/Antialias 1
    Xft/Hinting 1
    Xft/HintStyle "hintfull"
    Xft/DPI ${builtins.toString (112 * 1024)}
  '';

  # ───────────────────────────────────────────────
  # ▶ Developer Workspace
  # ───────────────────────────────────────────────
  home.activation.createDevWorkspace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${homeDirectory}/Developer/{freelance,personal,opensource,learning}

    # Auto-clone repos if not present (SSH key decrypted via age)
    export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -o StrictHostKeyChecking=accept-new"

    if [ ! -d "${homeDirectory}/dotfiles/.git" ]; then
      ${pkgs.git}/bin/git clone git@github.com:shahidshabbir-se/dotfiles.git ${homeDirectory}/dotfiles || true
    fi

    # Ensure dotfiles remote is SSH (in case it was cloned via HTTPS on fresh install)
    DOTFILES_REMOTE=$(${pkgs.git}/bin/git -C ${homeDirectory}/dotfiles remote get-url origin 2>/dev/null || true)
    if echo "$DOTFILES_REMOTE" | grep -q "^https://"; then
      ${pkgs.git}/bin/git -C ${homeDirectory}/dotfiles remote set-url origin git@github.com:shahidshabbir-se/dotfiles.git
    fi

    if [ ! -d "${homeDirectory}/.config/opencode/.git" ]; then
      ${pkgs.git}/bin/git clone git@github.com:shahidshabbir-se/opencode-ai.git ${homeDirectory}/.config/opencode || true
    fi
  '';

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
    zsh = import ../../modules/zsh.nix { inherit config pkgs lib browser; };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
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
    inherit config pkgs homeDirectory browser device;
  };

  # ───────────────────────────────────────────────
  # i3 (X11 session - for Upwork compatibility)
  # ───────────────────────────────────────────────
  xsession.windowManager.i3 = import ../../modules/i3.nix {
    inherit config pkgs lib homeDirectory browser;
  };

  services.picom = import ../../modules/picom.nix { };

  services.dunst = import ../../modules/dunst.nix { };

  # Polybar config is managed as a raw file via xdg symlink for fast iteration
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    script = ''
      polybar-msg cmd quit 2>/dev/null
      for m in $(polybar --list-monitors | cut -d":" -f1); do
        MONITOR=$m polybar --config=${homeDirectory}/dotfiles/config/polybar/config.ini main &
      done
    '';
  };

  # ───────────────────────────────────────────────
  # ▶ X11 DPI / Xresources (scaling for i3)
  # ───────────────────────────────────────────────
  xresources.properties = {
    "Xft.dpi" = 112;
    "Xft.autohint" = 0;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
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
      # cursor-theme = "Banana";
      cursor-size = 24;
      font-name = "SF Pro Display 10";
      document-font-name = "SF Pro Display 10";
      monospace-font-name = "JetBrainsMono Nerd Font 10";
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

