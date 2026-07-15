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
  ...
}:

let
  # ───────────────────────────────────────────────
  # ▶ User Profile
  # ───────────────────────────────────────────────
  username = "shahid";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";

  # ───────────────────────────────────────────────
  # ▶ Paths
  # ───────────────────────────────────────────────
  paths = rec {
    home = "/home/${username}";
    workspace = "${home}/Projects";
    dotfiles = "${home}/dotfiles";
    opencode = "${home}/.config/opencode";
  };

  homeDirectory = paths.home;
  workspaceDirectory = paths.workspace;
  dotfilesDirectory = paths.dotfiles;
  opencodeDirectory = paths.opencode;

  # ───────────────────────────────────────────────
  # ▶ Application Defaults
  # ───────────────────────────────────────────────
  apps = rec {
    browser = "zen-beta";
    browserDesktopFile = "${browser}.desktop";
    imageViewerDesktopFile = "org.gnome.gThumb.desktop";
  };

  browser = apps.browser;

  # ───────────────────────────────────────────────
  # ▶ Theme Defaults
  # ───────────────────────────────────────────────
  theme = {
    gtk = "catppuccin-mocha-blue-standard";
    icons = "Papirus-Dark";

    font = "SF Pro Display 10";
    monospaceFont = "JetBrainsMono Nerd Font 10";
  };

  cursor = {
    name = "Banana";
    size = if device.type == "laptop" then 48 else 36;
    package = import ../../modules/banana-cursor.nix { inherit pkgs; };
  };

  gtkThemePackage = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" ];
    size = "standard";
  };

  # ───────────────────────────────────────────────
  # ▶ Helpers
  # ───────────────────────────────────────────────
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (pkgs.stdenv.hostPlatform) system;

  dotfileLink = path: mkOutOfStoreSymlink "${dotfilesDirectory}/${path}";

  bin = {
    git = "${pkgs.git}/bin/git";
    gio = "${pkgs.glib}/bin/gio";
    grep = "${pkgs.gnugrep}/bin/grep";
    mkdir = "${pkgs.coreutils}/bin/mkdir";
    ssh = "${pkgs.openssh}/bin/ssh";
  };

  papirusPlaces = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus/64x64/places";

  # ───────────────────────────────────────────────
  # ▶ GTK Bookmarks
  # ───────────────────────────────────────────────
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
  # ▶ Imported Packages
  # ───────────────────────────────────────────────
  commonPackages = import ../../modules/pkgs/common.nix {
    inherit pkgs;
  };

  zedPackage = import ../../modules/pkgs/zed.nix {
    inherit pkgs lib;
  };

  zenBrowserPackage = inputs.zen-browser.packages.${system}.default;

  # Hyprland HDR/color management makes Electron apps render dim unless these
  # flags are passed.
  # codeCursorFhs = pkgs.symlinkJoin {
  #   name = "code-cursor-fhs";
  #
  #   paths = [
  #     pkgs.code-cursor-fhs
  #   ];
  #
  #   buildInputs = [
  #     pkgs.makeWrapper
  #   ];
  #
  #   postBuild = ''
  #     wrapProgram $out/bin/cursor \
  #       --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
  #       --add-flags "--force-color-profile=srgb" \
  #       --add-flags "--enable-features=WaylandLinuxDrmSyncobj"
  #   '';
  # };

  # ───────────────────────────────────────────────
  # ▶ Package Groups
  # ───────────────────────────────────────────────
  developmentPackages = with pkgs; [
    # codeCursorFhs
    gcc
    git-filter-repo
    gnumake
    python3
  ];

  desktopPackages = with pkgs; [
    anydesk
    brave
    gnome-online-accounts-gtk
    nautilus
    obsidian
    onlyoffice-desktopeditors
    proton-vpn
    qbittorrent
    zedPackage
    rustdesk-flutter
    zenBrowserPackage
    zenity
  ];

  mediaPackages = with pkgs; [
    cava
    gthumb
    vlc
    pulsemixer
  ];

  systemUtilityPackages = with pkgs; [
    fastfetch
    glycin-loaders
    libnotify
    matugen
    nitch
    ollama
    unzip
    webp-pixbuf-loader
    wmctrl
    zip
    claude-code
  ];

  themePackages = with pkgs; [
    catppuccin-papirus-folders
    corefonts
    gtkThemePackage
  ];

  # ───────────────────────────────────────────────
  # ▶ MIME Defaults
  # ───────────────────────────────────────────────
  browserMimeTypes = [
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/chrome"
    "text/html"
    "text/markdown"
    "text/x-markdown"
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/xhtml+xml"
    "application/x-extension-xhtml"
    "application/x-extension-xht"
    "application/pdf"
    "application/json"
  ];

  imageMimeTypes = [
    "image/png"
    "image/jpeg"
    "image/gif"
    "image/webp"
    "image/bmp"
    "image/svg+xml"
    "image/tiff"
    "image/avif"
    "image/heic"
  ];

  mimeDefaultApplications =
    lib.genAttrs browserMimeTypes (_: [ apps.browserDesktopFile ])
    // lib.genAttrs imageMimeTypes (_: [ apps.imageViewerDesktopFile ]);

  # ───────────────────────────────────────────────
  # ▶ GNOME Keybindings
  # ───────────────────────────────────────────────
  gnomeKeybindingBase = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";

  gnomeKeybindings = [
    {
      name = "Terminal";
      binding = "<Super>Return";
      command = "wezterm";
    }
    {
      name = "Browser";
      binding = "<Super>b";
      command = apps.browser;
    }
    {
      name = "VS Code";
      binding = "<Super>x";
      command = "code";
    }
    {
      name = "Obsidian";
      binding = "<Super>o";
      command = "obsidian";
    }
    {
      name = "Spotify";
      binding = "<Super>m";
      command = "spotify";
    }
    {
      name = "System Monitor";
      binding = "<Ctrl><Shift>Escape";
      command = "ghostty -e btop";
    }
    {
      name = "Bluetooth";
      binding = "<Alt><Shift>b";
      command = "${dotfilesDirectory}/config/rofi/bluetooth-launch.sh";
    }
    {
      name = "WiFi";
      binding = "<Alt><Shift>n";
      command = "${dotfilesDirectory}/config/rofi/wifi-launch.sh";
    }
  ];

  gnomeKeybindingPaths = lib.imap0 (
    index: _: "${gnomeKeybindingBase}/custom${toString index}/"
  ) gnomeKeybindings;

  gnomeKeybindingSettings = lib.listToAttrs (
    lib.imap0 (index: keybinding: {
      name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString index}";
      value = keybinding;
    }) gnomeKeybindings
  );

  # ───────────────────────────────────────────────
  # ▶ Activation Scripts
  # ───────────────────────────────────────────────
  createProjectsWorkspaceScript = ''
    ${bin.mkdir} -p \
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
    export GIT_SSH_COMMAND="${bin.ssh} -o StrictHostKeyChecking=accept-new"

    if [ ! -d "${dotfilesDirectory}/.git" ]; then
      ${bin.git} clone git@github.com:${userGithub}/dotfiles.git "${dotfilesDirectory}" || true
    fi

    # Ensure dotfiles use SSH even if the repo was cloned with HTTPS earlier.
    DOTFILES_REMOTE=$(${bin.git} -C "${dotfilesDirectory}" remote get-url origin 2>/dev/null || true)

    if printf '%s\n' "$DOTFILES_REMOTE" | ${bin.grep} -q "^https://"; then
      ${bin.git} -C "${dotfilesDirectory}" remote set-url origin git@github.com:${userGithub}/dotfiles.git
    fi

    if [ ! -d "${opencodeDirectory}/.git" ]; then
      ${bin.git} clone git@github.com:${userGithub}/opencode-ai.git "${opencodeDirectory}" || true
    fi
  '';

  setNautilusFolderIconsScript = ''
    set_folder_icon() {
      folder="$1"
      icon="$2"

      [ -d "$folder" ] || return 0
      [ -f "$icon" ] || return 0

      ${bin.gio} set -t string "$folder" metadata::custom-icon "file://$icon" 2>/dev/null || true
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

in
{
  # ───────────────────────────────────────────────
  # ▶ Imports
  # ───────────────────────────────────────────────
  imports = [
    ../../modules/node.nix
    ../../modules/nvim.nix

    # ../../modules/i3.nix
    ../../modules/hyprland.nix
    ../../modules/wlogout.nix

    ../../modules/cliproxyapi.nix
  ];

  # ───────────────────────────────────────────────
  # ▶ Home Manager
  # ───────────────────────────────────────────────
  home = {
    inherit username homeDirectory;

    stateVersion = "26.05";

    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;

      package = cursor.package;
      name = cursor.name;
      size = cursor.size;
    };

    packages =
      commonPackages
      ++ developmentPackages
      ++ desktopPackages
      ++ mediaPackages
      ++ systemUtilityPackages
      ++ themePackages;

    activation = {
      createProjectsWorkspace = lib.hm.dag.entryAfter [ "writeBoundary" ] createProjectsWorkspaceScript;

      setNautilusFolderIcons = lib.hm.dag.entryAfter [
        "writeBoundary"
        "createProjectsWorkspace"
      ] setNautilusFolderIconsScript;
    };

    file = {
      ".hidden".text = ''
        go
        tmp
      '';

      ".p10k.zsh".source = ../../config/p10k.zsh;

      ".zsh/aliases".source = dotfileLink "config/zsh/aliases";
    };

    sessionVariables = {
      AGENT_BROWSER_EXECUTABLE_PATH = "/etc/profiles/per-user/${username}/bin/brave";

      CHROMIUM_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";

      CHROMIUM_USER_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";

      # Lutris 0.5.x still trips over newer protobuf Python bindings on NixOS.
      PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
    };
  };

  # ───────────────────────────────────────────────
  # ▶ XDG
  # ───────────────────────────────────────────────
  xdg = {
    enable = true;

    configFile = {
      "chromium-flags.conf".text = ''
        --disable-features=WaylandWpColorManagerV1,WaylandColorManagement
        --force-color-profile=srgb
        --enable-features=WaylandLinuxDrmSyncobj
      '';

      "gtk-3.0/bookmarks".text = gtkBookmarks;
      "gtk-4.0/bookmarks".text = gtkBookmarks;

      nvim.source = dotfileLink "config/nvim";
      yazi.source = dotfileLink "config/yazi";
      eww.source = dotfileLink "config/eww";
      rofi.source = dotfileLink "config/rofi";
      zed.source = dotfileLink "config/zed";

      # "Cursor/User/settings.json".source = dotfileLink "config/cursor/settings.json";
    };

    mimeApps = {
      enable = true;
      defaultApplications = mimeDefaultApplications;
    };
  };

  # ───────────────────────────────────────────────
  # ▶ Programs
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

    delta = import ../../modules/delta.nix {
      inherit pkgs;
    };

    zsh = import ../../modules/zsh.nix {
      inherit
        config
        pkgs
        lib
        browser
        ;
    };

    tmux = import ../../modules/tmux.nix {
      inherit config pkgs lib;
    };

    bat = import ../../modules/bat.nix {
      inherit pkgs lib;
    };

    zoxide = import ../../modules/zoxide.nix {
      inherit pkgs;
    };

    atuin = import ../../modules/atuin.nix {
      inherit pkgs;
    };

    spicetify = import ../../modules/spicetify.nix {
      inherit inputs lib pkgs;
    };

    ghostty = import ../../modules/ghostty.nix {
      inherit config device pkgs;
    };

    wezterm = import ../../modules/wezterm.nix {
      inherit config device pkgs;
    };
  };

  # ───────────────────────────────────────────────
  # ▶ Services
  # ───────────────────────────────────────────────
  services.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${system}; [
      awww-switcher
      bluetooth
      nix
      port-killer
      power-profile
      process-manager
      wifi-commander
    ];

    settings = {
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;

      font.normal = {
        size = 10.5;
        family = "Outfit";
      };

      launcher_window.opacity = 0.7;

      theme.dark = {
        name = "matugen";
        icon_theme = "Papirus-Dark";
      };

      providers."@sovereign/vicinae-extension-awww-switcher-0".preferences = {
        wallpaperPath = "${homeDirectory}/Pictures/Wallpapers";
        colorGenTool = "none";
        postCommand = "${homeDirectory}/dotfiles/config/matugen/run.sh \"\${wallpaper}\"";
      };
    };
  };

  # Vicinae needs the live Hyprland/Wayland environment. If it starts before
  # graphical-session.target has the compositor env, it exits with a broken
  # Wayland connection and stays dead at login.
  systemd.user.services.vicinae = {
    Unit = {
      After = lib.mkForce [ "default.target" ];
      PartOf = lib.mkForce [ ];
    };

    Service = {
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "XDG_CURRENT_DESKTOP=Hyprland"
        "XDG_SESSION_TYPE=wayland"
      ];
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce 5;
    };

    Install.WantedBy = lib.mkForce [ "default.target" ];
  };

  # ───────────────────────────────────────────────
  # ▶ GNOME / dconf
  # ───────────────────────────────────────────────
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";

      gtk-theme = theme.gtk;
      icon-theme = theme.icons;

      cursor-theme = cursor.name;
      cursor-size = cursor.size;

      font-name = theme.font;
      document-font-name = theme.font;
      monospace-font-name = theme.monospaceFont;
    };

    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
    };

    "org/gnome/desktop/default-applications/terminal" = {
      exec = "wezterm";
      exec-arg = "-e";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = gnomeKeybindingPaths;
    };
  }
  // gnomeKeybindingSettings;

  # ───────────────────────────────────────────────
  # ▶ GTK
  # ───────────────────────────────────────────────
  gtk = {
    enable = true;

    theme = {
      name = theme.gtk;
      package = gtkThemePackage;
    };

    iconTheme = {
      name = theme.icons;
      package = pkgs.catppuccin-papirus-folders;
    };

    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };
}
