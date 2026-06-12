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
  unstable,
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
  imageViewerDesktopFile = "org.gnome.gThumb.desktop";

  gtkBookmarks = ''
    file://${homeDirectory}/Documents Documents
    file://${dotfilesDirectory} Dotfiles
    file://${homeDirectory}/Downloads Downloads
    file://${homeDirectory}/Extras Extras
    file://${homeDirectory}/Music Music
    file://${homeDirectory}/Pictures Pictures
    file://${workspaceDirectory} Projects
    file://${homeDirectory}/Videos Videos
  '';

  # ───────────────────────────────────────────────
  # Theme defaults
  # ───────────────────────────────────────────────
  gtkTheme = "catppuccin-mocha-blue-standard";
  iconTheme = "Papirus-Dark";
  font = "SF Pro Display 10";
  monospaceFont = "JetBrainsMono Nerd Font 10";

  cursorTheme = "Banana";
  cursorSize = if device.type == "laptop" then 48 else 36;
  cursorPackage = import ../../modules/banana-cursor.nix { inherit pkgs; };

  # cursorTheme = if device.type == "laptop" then "Banana" else "catppuccin-mocha-dark-cursors";
  # cursorSize = if device.type == "laptop" then 48 else 24;
  # cursorPackage =
  #   if device.type == "laptop" then
  #     import ../../modules/banana-cursor.nix { inherit pkgs; }
  #   else
  #     pkgs.catppuccin-cursors.mochaDark;

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

  unstablePackages = import unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # Hyprland HDR/color management makes Electron apps render dim unless these
  # flags are passed (same fix as CHROMIUM_FLAGS in hyprland.nix).
  codeCursorFhs = pkgs.symlinkJoin {
    name = "code-cursor-fhs";
    paths = [ unstablePackages.code-cursor-fhs ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cursor \
        --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
        --add-flags "--force-color-profile=srgb"
    '';
  };

  commonPackages = import ../../modules/pkgs/common.nix { inherit pkgs; };
  zedPackage = import ../../modules/pkgs/zed.nix { inherit pkgs lib; };
  zenBrowserPackage = inputs.zen-browser.packages.${system}.default;

  # Use absolute store paths in activation scripts so they do not depend on PATH.
  git = "${pkgs.git}/bin/git";
  gio = "${pkgs.glib}/bin/gio";
  grep = "${pkgs.gnugrep}/bin/grep";
  mkdir = "${pkgs.coreutils}/bin/mkdir";
  papirusPlaces = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/places";
  ssh = "${pkgs.openssh}/bin/ssh";
in
{
  # ───────────────────────────────────────────────
  # Imported Home Manager modules
  # ───────────────────────────────────────────────
  imports = [
    ../../modules/node.nix
    # ../../modules/i3.nix  # disabled in favor of GNOME
    ../../modules/hyprland.nix
    ../../modules/wlogout.nix
    # ../../modules/cliproxyapi.nix
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
      # ++ [ (import ../../modules/pkgs/cursor.nix { inherit pkgs lib; }) ]
      ++ (with pkgs; [
        # upwork

        # Development tools
        fastfetch
        codeCursorFhs
        obsidian
        zenity
        gcc
        git-filter-repo
        gnumake
        python3
        unzip
        zip

        # Desktop applications
        anydesk
        chromium
        nautilus
        gnome-online-accounts-gtk
        glycin-loaders
        gthumb
        onlyoffice-desktopeditors
        protonvpn-gui
        qbittorrent
        vlc
        webp-pixbuf-loader
        zedPackage
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
      ${mkdir} -p \
        "${workspaceDirectory}" \
        "${homeDirectory}/Desktop" \
        "${homeDirectory}/Documents" \
        "${homeDirectory}/Downloads" \
        "${homeDirectory}/Extras" \
        "${homeDirectory}/Music" \
        "${homeDirectory}/Pictures" \
        "${homeDirectory}/Public" \
        "${homeDirectory}/Templates" \
        "${homeDirectory}/Videos"

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

    activation.setNautilusFolderIcons =
      lib.hm.dag.entryAfter [ "writeBoundary" "createProjectsWorkspace" ]
        ''
          set_folder_icon() {
            folder="$1"
            icon="$2"
            [ -d "$folder" ] || return 0
            [ -f "$icon" ] || return 0
            ${gio} set -t string "$folder" metadata::custom-icon "file://$icon" 2>/dev/null || true
          }

          set_folder_icon "${homeDirectory}/Desktop" "${papirusPlaces}/user-desktop.svg"
          set_folder_icon "${homeDirectory}/Documents" "${papirusPlaces}/folder-documents.svg"
          set_folder_icon "${dotfilesDirectory}" "${papirusPlaces}/folder-git.svg"
          set_folder_icon "${homeDirectory}/Downloads" "${papirusPlaces}/folder-download.svg"
          set_folder_icon "${homeDirectory}/Extras" "${papirusPlaces}/folder-favorites.svg"
          set_folder_icon "${homeDirectory}/Music" "${papirusPlaces}/folder-music.svg"
          set_folder_icon "${homeDirectory}/Pictures" "${papirusPlaces}/folder-pictures.svg"
          set_folder_icon "${workspaceDirectory}" "${papirusPlaces}/folder-code.svg"
          set_folder_icon "${homeDirectory}/Storage" "${papirusPlaces}/folder-remote.svg"
          set_folder_icon "${homeDirectory}/Public" "${papirusPlaces}/folder-publicshare.svg"
          set_folder_icon "${homeDirectory}/Templates" "${papirusPlaces}/folder-templates.svg"
          set_folder_icon "${homeDirectory}/Videos" "${papirusPlaces}/folder-videos.svg"
        '';

    # ───────────────────────────────────────────────
    # Managed files in $HOME
    # ───────────────────────────────────────────────
    file = {
      ".hidden".text = ''
        go
        tmp
      '';
      ".p10k.zsh".source = ../../config/p10k.zsh;
      ".zsh/aliases".source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/zsh/aliases";
    };

    sessionVariables = {
      AGENT_BROWSER_EXECUTABLE_PATH = "/etc/profiles/per-user/shahid/bin/chromium";
      CHROMIUM_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb";
      CHROMIUM_USER_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb";
      # Lutris 0.5.x still trips over newer protobuf Python bindings on NixOS.
      PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
    };
  };

  # ───────────────────────────────────────────────
  # XDG configuration and default applications
  # ───────────────────────────────────────────────
  xdg = {
    enable = true;

    configFile = {
      "chromium-flags.conf".text = ''
        --disable-features=WaylandWpColorManagerV1,WaylandColorManagement
        --force-color-profile=srgb
      '';
      "gtk-3.0/bookmarks".text = gtkBookmarks;
      "gtk-4.0/bookmarks".text = gtkBookmarks;
      nvim.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/nvim";
      yazi.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/yazi";
      eww.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/eww";
      rofi.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/rofi";
      zed.source = mkOutOfStoreSymlink "${dotfilesDirectory}/config/zed";
      "Cursor/User/settings.json".source =
        mkOutOfStoreSymlink "${dotfilesDirectory}/config/cursor/settings.json";
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
    wezterm = import ../../modules/wezterm.nix { inherit config device pkgs; };
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

    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
    };

    # GNOME: default terminal → WezTerm
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "wezterm";
      exec-arg = "-e";
    };

    # GNOME: custom keybindings (migrated from Hyprland)
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      binding = "<Super>Return";
      command = "wezterm";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Browser";
      binding = "<Super>b";
      command = "zen-beta";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "VS Code";
      binding = "<Super>x";
      command = "code";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "Obsidian";
      binding = "<Super>o";
      command = "obsidian";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      name = "Spotify";
      binding = "<Super>m";
      command = "spotify";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      name = "System Monitor";
      binding = "<Ctrl><Shift>Escape";
      command = "ghostty -e btop";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      name = "Bluetooth";
      binding = "<Alt><Shift>b";
      command = "${homeDirectory}/dotfiles/config/rofi/bluetooth-launch.sh";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      name = "WiFi";
      binding = "<Alt><Shift>n";
      command = "${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh";
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
