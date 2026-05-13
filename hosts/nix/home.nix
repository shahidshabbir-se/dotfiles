#  ███╗   ██╗██╗██╗  ██╗    ██╗  ██╗ ██████╗ ███╗   ███╗███████╗
#  ████╗  ██║██║╚██╗██╔╝    ██║  ██║██╔═══██╗████╗ ████║██╔════╝
#  ██╔██╗ ██║██║ ╚███╔╝     ███████║██║   ██║██╔████╔██║█████╗
#  ██║╚██╗██║██║ ██╔██╗     ██╔══██║██║   ██║██║╚██╔╝██║██╔══╝
#  ██║ ╚████║██║██╔╝ ██╗    ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗
#  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
#  https://github.com/shahidshabbir-se/dotfiles

{
  config,
  pkgs,
  lib,
  inputs,
  device,
  atuin,
  ...
}:

let
  # ───────────────────────────────────────────────
  # User identity and host paths
  # ───────────────────────────────────────────────
  username = "shahid";
  homeDirectory = "/home/${username}";
  workspaceDirectory = "${homeDirectory}/Projects";
  dotfilesDirectory = "${homeDirectory}/dotfiles";
  opencodeDirectory = "${homeDirectory}/.config/opencode";

  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";

  # ───────────────────────────────────────────────
  # Application defaults
  # ───────────────────────────────────────────────
  browser = "zen-beta";
  browserDesktopFile = "${browser}.desktop";
  imageViewerDesktopFile = "com.github.weclaw1.ImageRoll.desktop";

  # ───────────────────────────────────────────────
  # Theme defaults
  # ───────────────────────────────────────────────
  gtkTheme = "catppuccin-mocha-blue-standard";
  iconTheme = "Papirus-Dark";
  font = "SF Pro Display 10";
  monospaceFont = "JetBrainsMono Nerd Font 10";

  cursorTheme = if device.type == "laptop" then "Banana" else "catppuccin-mocha-dark-cursors";
  cursorSize = if device.type == "laptop" then 48 else 24;
  cursorPackage =
    if device.type == "laptop" then
      import ../../modules/banana-cursor.nix { inherit pkgs; }
    else
      pkgs.catppuccin-cursors.mochaDark;

  gtkThemePackage = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" ];
    size = "standard";
  };

  # ───────────────────────────────────────────────
  # Package helpers
  # ───────────────────────────────────────────────
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  commonPackages = import ../../modules/pkgs/common.nix { inherit pkgs; };
  zenBrowserPackage = inputs.zen-browser.packages.${system}.default;

  # Use absolute store paths in activation scripts so they do not depend on PATH.
  git = "${pkgs.git}/bin/git";
  grep = "${pkgs.gnugrep}/bin/grep";
  mkdir = "${pkgs.coreutils}/bin/mkdir";
  ssh = "${pkgs.openssh}/bin/ssh";
in
{
  # ───────────────────────────────────────────────
  # Imported Home Manager modules
  # ───────────────────────────────────────────────
  imports = [
    ../../modules/node.nix
    ../../modules/i3.nix
    ../../modules/hyprland.nix
    # ../../modules/cliproxyapi.nix
    # ../../modules/television.nix
  ];

  home = {
    # ───────────────────────────────────────────────
    # Account and Home Manager state
    # ───────────────────────────────────────────────
    inherit username homeDirectory;
    stateVersion = "24.05";

    # ───────────────────────────────────────────────
    # Cursor theme
    # ───────────────────────────────────────────────
    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
      package = cursorPackage;
      size = cursorSize;
      name = cursorTheme;
    };

    # ───────────────────────────────────────────────
    # User packages
    # ───────────────────────────────────────────────
    packages =
      commonPackages
      ++ [ (import ../../modules/pkgs/cursor.nix { inherit pkgs lib; }) ]
      ++ (with pkgs; [
        upwork

        # Development tools
        fastfetch
        gcc
        git-filter-repo
        gnumake
        python3
        unzip
        zip

        # Desktop applications
        anydesk
        chromium
        image-roll
        onlyoffice-desktopeditors
        protonvpn-gui
        qbittorrent
        vlc
        xfce.thunar
        zenBrowserPackage

        # Media and system utilities
        cava
        libnotify
        matugen
        nitch
        ollama
        pulsemixer
        wmctrl

        # Fonts and themes
        catppuccin-papirus-folders
        corefonts
        gtkThemePackage
      ]);

    # ───────────────────────────────────────────────
    # Workspace and repository bootstrap
    # ───────────────────────────────────────────────
    activation.createProjectsWorkspace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${mkdir} -p "${workspaceDirectory}"

      # Auto-clone repos if not present. SSH host keys are accepted on first use
      # so fresh machines can complete activation non-interactively.
      export GIT_SSH_COMMAND="${ssh} -o StrictHostKeyChecking=accept-new"

      if [ ! -d "${dotfilesDirectory}/.git" ]; then
        ${git} clone git@github.com:${userGithub}/dotfiles.git "${dotfilesDirectory}" || true
      fi

      # Ensure dotfiles use SSH even if the repo was cloned with HTTPS earlier.
      DOTFILES_REMOTE=$(${git} -C "${dotfilesDirectory}" remote get-url origin 2>/dev/null || true)
      if printf '%s\n' "$DOTFILES_REMOTE" | ${grep} -q "^https://"; then
        ${git} -C "${dotfilesDirectory}" remote set-url origin git@github.com:${userGithub}/dotfiles.git
      fi

      if [ ! -d "${opencodeDirectory}/.git" ]; then
        ${git} clone git@github.com:${userGithub}/opencode-ai.git "${opencodeDirectory}" || true
      fi
    '';

    # ───────────────────────────────────────────────
    # Managed files in $HOME
    # ───────────────────────────────────────────────
    file = {
      ".p10k.zsh".source = ../../config/p10k.zsh;
      ".zsh/aliases".source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/zsh/aliases";
    };
  };

  # ───────────────────────────────────────────────
  # XDG configuration and default applications
  # ───────────────────────────────────────────────
  xdg = {
    enable = true;

    configFile = {
      nvim.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/nvim";
      yazi.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/yazi";
      eww.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/eww";
      rofi.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/rofi";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ browserDesktopFile ];
        "x-scheme-handler/https" = [ browserDesktopFile ];
        "x-scheme-handler/chrome" = [ browserDesktopFile ];
        "text/html" = [ browserDesktopFile ];
        "application/x-extension-htm" = [ browserDesktopFile ];
        "application/x-extension-html" = [ browserDesktopFile ];
        "application/x-extension-shtml" = [ browserDesktopFile ];
        "application/xhtml+xml" = [ browserDesktopFile ];
        "application/x-extension-xhtml" = [ browserDesktopFile ];
        "application/x-extension-xht" = [ browserDesktopFile ];
        "application/pdf" = [ browserDesktopFile ];

        "image/png" = [ imageViewerDesktopFile ];
        "image/jpeg" = [ imageViewerDesktopFile ];
        "image/gif" = [ imageViewerDesktopFile ];
        "image/webp" = [ imageViewerDesktopFile ];
        "image/bmp" = [ imageViewerDesktopFile ];
        "image/svg+xml" = [ imageViewerDesktopFile ];
        "image/tiff" = [ imageViewerDesktopFile ];
        "image/avif" = [ imageViewerDesktopFile ];
        "image/heic" = [ imageViewerDesktopFile ];
      };
    };
  };

  # ───────────────────────────────────────────────
  # Program configurations
  # ───────────────────────────────────────────────
  programs = {
    git = import ../../modules/git.nix {
      inherit
        config
        pkgs
        homeDirectory
        userGmail
        userGithub
        ;
    };
    delta = import ../../modules/delta.nix { inherit pkgs; };
    zsh = import ../../modules/zsh.nix {
      inherit
        config
        pkgs
        lib
        browser
        ;
    };
    tmux = import ../../modules/tmux.nix { inherit config pkgs lib; };
    bat = import ../../modules/bat.nix { inherit pkgs lib; };
    neovim = import ../../modules/nvim.nix { inherit config pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    atuin = import ../../modules/atuin.nix { inherit atuin; };
    spicetify = import ../../modules/spicetify.nix { inherit inputs lib pkgs; };
    ghostty = import ../../modules/ghostty.nix { inherit config device pkgs; };
  };

  # ───────────────────────────────────────────────
  # GNOME/dconf desktop settings
  # ───────────────────────────────────────────────
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = gtkTheme;
      icon-theme = iconTheme;
      cursor-theme = cursorTheme;
      cursor-size = cursorSize;
      font-name = font;
      document-font-name = font;
      monospace-font-name = monospaceFont;
    };
  };

  # ───────────────────────────────────────────────
  # GTK theme integration
  # ───────────────────────────────────────────────
  gtk = {
    enable = true;

    theme = {
      name = gtkTheme;
      package = gtkThemePackage;
    };

    iconTheme = {
      name = iconTheme;
      package = pkgs.catppuccin-papirus-folders;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}
