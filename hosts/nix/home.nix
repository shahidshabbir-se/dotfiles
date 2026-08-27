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
    fileManagerDesktopFile = "org.gnome.Nautilus.desktop";
  };

  inherit (apps) browser;

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

  # # Store prebuild (source package is blocked upstream: node-gyp/usocket).
  # # Update hash when https://api.vicinae.com/v1/store/gelei/bluetooth/download changes.
  # vicinaeBluetoothStore = pkgs.stdenv.mkDerivation {
  #   pname = "vicinae-extension-bluetooth";
  #   version = "store";
  #   src = pkgs.fetchurl {
  #     url = "https://api.vicinae.com/v1/store/gelei/bluetooth/download";
  #     hash = "sha256-sTeXs4bYU604wQ/V2vRjvwK/ouaqj+rbq2Bw8C9Yj6Q=";
  #   };
  #   nativeBuildInputs = [ pkgs.unzip ];
  #   unpackPhase = ''
  #     unzip -q $src
  #   '';
  #   installPhase = ''
  #     mkdir -p $out
  #     cp -r bluetooth/. $out/
  #   '';
  # };

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
    file://${homeDirectory}/Desktop Desktop
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

  # t3codePackage = import ../../modules/pkgs/t3code.nix {
  #   inherit pkgs lib;
  # };

  zedPackage = import ../../modules/pkgs/zed.nix {
    inherit pkgs lib;
  };

  # paseoPackage = import ../../modules/pkgs/paseo.nix {
  #   inherit pkgs lib;
  # };


  # chatgptPackage = import ../../modules/pkgs/chatgpt.nix {
  #   inherit pkgs lib;
  # };

  zenBrowserPackage = inputs.zen-browser.packages.${system}.default;

  # codexCliPackage = inputs.codex-cli-nix.packages.${system}.default;

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

  # antigravityFhs = pkgs.symlinkJoin {
  #   name = "antigravity-ide-fhs";
  #
  #   paths = [
  #     pkgs.antigravity-ide-fhs
  #   ];
  #
  #   buildInputs = [
  #     pkgs.makeWrapper
  #   ];
  #
  #   postBuild = ''
  #     wrapProgram $out/bin/antigravity-ide \
  #       --add-flags "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement" \
  #       --add-flags "--force-color-profile=srgb" \
  #       --add-flags "--enable-features=WaylandLinuxDrmSyncobj"
  #   '';
  # };

  # vscodeFhs = pkgs.symlinkJoin {
  #   name = "vscode-fhs";
  #
  #   paths = [
  #     pkgs.vscode-fhs
  #   ];
  #
  #   buildInputs = [
  #     pkgs.makeWrapper
  #   ];
  #
  #   postBuild = ''
  #     wrapProgram $out/bin/code \
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
    # antigravityFhs
    # codexCliPackage
    gcc
    moon
    jetbrains-toolbox
    git-filter-repo
    mpv
    gnumake
    python3
    # vscodeFhs
  ];

  desktopPackages = with pkgs; [
    brave
    # chatgptPackage
    obsidian
    onlyoffice-desktopeditors
    proton-vpn
    qbittorrent
    zedPackage
    # paseoPackage
    nautilus
    rustdesk-flutter
    # t3codePackage
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
    pavucontrol
    glycin-loaders
    libnotify
    matugen
    unzip
    webp-pixbuf-loader
    time
    wmctrl
    zip
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

  fileManagerMimeTypes = [
    "inode/directory"
    "inode/mount-point"
    "x-directory/normal"
  ];

  mimeDefaultApplications =
    lib.genAttrs browserMimeTypes (_: [ apps.browserDesktopFile ])
    // lib.genAttrs imageMimeTypes (_: [ apps.imageViewerDesktopFile ])
    // lib.genAttrs fileManagerMimeTypes (_: [ apps.fileManagerDesktopFile ]);

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

  # Nautilus 50 treats file:// SVG custom-icon as a document. Use themed names.
  folderIconEntries = [
    { path = "${homeDirectory}/Android"; name = "folder-android"; symbolic = "folder-android"; }
    { path = "${homeDirectory}/Desktop"; name = "user-desktop"; symbolic = "user-desktop-symbolic"; }
    { path = "${homeDirectory}/Documents"; name = "folder-documents"; symbolic = "folder-documents"; }
    { path = "${dotfilesDirectory}"; name = "folder-git"; symbolic = "folder-git"; }
    { path = "${homeDirectory}/Downloads"; name = "folder-download"; symbolic = "folder-download-symbolic"; }
    { path = "${homeDirectory}/Extras"; name = "folder-applications"; symbolic = "folder-applications"; }
    { path = "${homeDirectory}/Games"; name = "folder-games"; symbolic = "folder-games"; }
    { path = "${homeDirectory}/Music"; name = "folder-music"; symbolic = "folder-music-symbolic"; }
    { path = "${homeDirectory}/Pictures"; name = "folder-pictures"; symbolic = "folder-pictures-symbolic"; }
    { path = workspaceDirectory; name = "folder-code"; symbolic = "folder-code"; }
    { path = "${homeDirectory}/Storage"; name = "folder-sync"; symbolic = "folder-sync"; }
    { path = "${homeDirectory}/Public"; name = "folder-publicshare"; symbolic = "folder-publicshare-symbolic"; }
    { path = "${homeDirectory}/Templates"; name = "folder-templates"; symbolic = "folder-templates-symbolic"; }
    { path = "${homeDirectory}/Videos"; name = "folder-videos"; symbolic = "folder-videos-symbolic"; }
  ];

  setNautilusFolderIconsScript = ''
    set_folder_icon() {
      folder="$1"
      icon_name="$2"

      [ -d "$folder" ] || return 0

      ${bin.gio} set -t unset "$folder" metadata::custom-icon 2>/dev/null || true
      ${bin.gio} set -t string "$folder" metadata::custom-icon-name "$icon_name" 2>/dev/null || true
    }

    ${lib.concatMapStringsSep "\n" (e: ''
      set_folder_icon "${e.path}" "${e.name}"
    '') folderIconEntries}
  '';

  nautilusBookmarkIcons =
    let
      inherit (lib.hm.gvariant) mkArray mkDictionaryEntry type;
    in
    mkArray (type.dictionaryEntryOf [
      type.string
      type.string
    ]) (
      map (e: mkDictionaryEntry [
        "file://${e.path}"
        e.symbolic
      ]) folderIconEntries
    );

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
    ../../modules/hypridle.nix
    ../../modules/wlogout.nix
    ../../modules/quickshell.nix

    ../../modules/cliproxyapi.nix
  ];

  # ───────────────────────────────────────────────
  # ▶ Home Manager
  # ───────────────────────────────────────────────
  home = {
    inherit username homeDirectory;

    stateVersion = "26.05";

    pointerCursor = {
      enable = true;
      x11.enable = true;
      gtk.enable = true;

      inherit (cursor) package;
      inherit (cursor) name;
      inherit (cursor) size;
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

      "btop/btop.conf".text = ''
        color_theme = "tokyo-night"
        background_update = false
      '';

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

    # codexDesktopLinux = {
    #   enable = true;
    #   cliPackage = codexCliPackage;
    #
    #   linuxFeatures = [
    #     "codex-wrapper-updater"
    #     "directory-only-working-tree-watch"
    #     "frameless-titlebar"
    #     "mcp-helper-reaper"
    #     "node-repl-reaper"
    #     "open-target-discovery"
    #     "persistent-status-panel"
    #     "remote-control-ui"
    #     "remote-mobile-control"
    #     "ui-tweaks"
    #   ];
    #
    #   remoteControl = {
    #     enable = true;
    #     package = codexCliPackage;
    #   };
    # };

    ghostty = import ../../modules/ghostty.nix {
      inherit config device pkgs;
    };

    wezterm = import ../../modules/wezterm.nix {
      inherit config device pkgs;
    };
  };

  # ───────────────────────────────────────────────
  # ▶ Vicinae (disabled)
  # ───────────────────────────────────────────────
  # programs.vicinae = {
  #   enable = true;
  #
  #   systemd = {
  #     enable = true;
  #     autoStart = true;
  #     environment = {
  #       USE_LAYER_SHELL = 1;
  #     };
  #   };
  #
  #   extensions = with inputs.vicinae-extensions.packages.${system}; [
  #     # awww-switcher
  #     # wifi-commander
  #     # bluetooth via store zip: vicinaeBluetoothStore
  #     nix
  #     port-killer
  #     power-profile
  #     process-manager
  #   ];
  #
  #   settings = {
  #     close_on_focus_loss = true;
  #     consider_preedit = true;
  #     pop_to_root_on_close = true;
  #     favicon_service = "twenty";
  #     search_files_in_root = true;
  #
  #     font.normal = {
  #       size = 10.5;
  #       family = "Outfit";
  #     };
  #
  #     launcher_window.opacity = 0.7;
  #
  #     theme.dark = {
  #       name = "matugen";
  #       icon_theme = "Papirus-Dark";
  #     };
  #
  #     # providers."@sovereign/vicinae-extension-awww-switcher-0".preferences = {
  #     #   wallpaperPath = "${homeDirectory}/Pictures/Wallpapers";
  #     #   colorGenTool = "none";
  #     #   postCommand = "${homeDirectory}/dotfiles/config/matugen/run.sh \"\${wallpaper}\"";
  #     # };
  #   };
  # };
  #
  # # Vicinae needs the live Hyprland/Wayland environment. If it starts before
  # # graphical-session.target has the compositor env, it exits with a broken
  # # Wayland connection and stays dead at login.
  # systemd.user.services.vicinae = {
  #   Unit = {
  #     After = lib.mkForce [ "default.target" ];
  #     PartOf = lib.mkForce [ ];
  #   };
  #
  #   Service = {
  #     Environment = [
  #       "QT_QPA_PLATFORM=wayland"
  #       "XDG_CURRENT_DESKTOP=Hyprland"
  #       "XDG_SESSION_TYPE=wayland"
  #     ];
  #     Restart = lib.mkForce "always";
  #     RestartSec = lib.mkForce 5;
  #   };
  #
  #   Install.WantedBy = lib.mkForce [ "default.target" ];
  # };

  # Libadwaita and GTK applications use this preference for dark mode.
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";

    "io/github/yannmasoch/nautilus-my-computer" = {
      custom-bookmark-icons = nautilusBookmarkIcons;
      preferred-folders = [
        "home"
        "documents"
        "downloads"
        "file://~/Extras"
        "music"
        "pictures"
        "file://~/Projects"
        "starred"
        "videos"
      ];
    };
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.FileManager1
    Exec=${pkgs.nautilus}/bin/nautilus --new-window
  '';

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
