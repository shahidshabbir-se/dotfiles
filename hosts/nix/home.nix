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
  defaults = import ./defaults.nix { inherit pkgs device; };
  inherit (defaults)
    username
    userGmail
    userGithub
    apps
    theme
    cursor
    gtkThemePackage
    ;
  homeDirectory = defaults.paths.home;
  workspaceDirectory = defaults.paths.workspace;
  dotfilesDirectory = defaults.paths.dotfiles;
  inherit (apps) browser;

  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (pkgs.stdenv.hostPlatform) system;

  dotfileLink = path: mkOutOfStoreSymlink "${dotfilesDirectory}/${path}";
  packageGroups = import ./packages.nix {
    inherit
      pkgs
      inputs
      system
      gtkThemePackage
      ;
  };
  inherit (packageGroups)
    commonPackages
    developmentPackages
    desktopPackages
    mediaPackages
    systemUtilityPackages
    themePackages
    ;
in
{
  imports = [
    ../../modules/herdr.nix
    ../../modules/node.nix
    ../../modules/nvim.nix

    # Hyprland session
    ../../modules/hyprland/core.nix
    ../../modules/hyprland/display.nix
    ../../modules/hyprland/bindings.nix
    ../../modules/hyprland/rules.nix
    ../../modules/hyprland/desktop.nix
    ../../modules/hypridle.nix

    ../../modules/wlogout.nix
    # ../../modules/quickshell.nix
    ../../modules/cliproxyapi.nix

    (import ./mime.nix {
      inherit (apps) browserDesktopFile imageViewerDesktopFile fileManagerDesktopFile;
    })
    (import ./workspace.nix {
      inherit
        homeDirectory
        workspaceDirectory
        dotfilesDirectory
        userGithub
        ;
    })
    (import ./icons.nix {
      inherit homeDirectory workspaceDirectory dotfilesDirectory;
    })
    (import ./vicinae.nix { inherit inputs system; })
    (import ./theme.nix { inherit theme gtkThemePackage; })
  ];

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

    file = {
      ".hidden".text = ''
        go
        tmp
      '';
      ".p10k.zsh".source = ../../config/p10k.zsh;
      ".zsh/aliases".source = dotfileLink "config/zsh/aliases";
    };

    sessionVariables = {
      AGENT_BROWSER_EXECUTABLE_PATH = "/etc/profiles/per-user/${username}/bin/chromium";
      CHROME_EXTRA_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      CHROMIUM_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      CHROMIUM_USER_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      ELECTRON_EXTRA_LAUNCH_ARGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
    };
  };

  xdg = {
    enable = true;

    desktopEntries = {
      microsoft-word = {
        name = "Microsoft Word";
        icon = "solstice-microsoft-365-word";
        exec = "chromium --app=https://word.cloud.microsoft/";
        terminal = false;
        categories = [ "Office" "WordProcessor" ];
      };

      microsoft-excel = {
        name = "Microsoft Excel";
        icon = "solstice-microsoft-365-excel";
        exec = "chromium --app=https://excel.cloud.microsoft/";
        terminal = false;
        categories = [ "Office" "Spreadsheet" ];
      };

      microsoft-powerpoint = {
        name = "Microsoft PowerPoint";
        icon = "solstice-microsoft-365-powerpoint";
        exec = "chromium --app=https://powerpoint.cloud.microsoft/";
        terminal = false;
        categories = [ "Office" "Presentation" ];
      };
    };

    configFile = {
      "chromium-flags.conf".text = ''
        --disable-features=WaylandWpColorManagerV1,WaylandColorManagement
        --force-color-profile=srgb
        --enable-features=WaylandLinuxDrmSyncobj
      '';
      "electron-flags.conf".text = ''
        --disable-features=WaylandWpColorManagerV1,WaylandColorManagement
        --force-color-profile=srgb
        --enable-features=WaylandLinuxDrmSyncobj
      '';

      "btop/btop.conf".text = ''
        color_theme = "tokyo-night"
        background_update = false
      '';

      nvim.source = dotfileLink "config/nvim";
      yazi.source = dotfileLink "config/yazi";
    };

  };

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
    bat = import ../../modules/bat.nix {
      inherit pkgs lib;
    };
    zoxide = import ../../modules/zoxide.nix;
    atuin = import ../../modules/atuin.nix {
      inherit pkgs;
    };
    # spicetify = import ../../modules/spicetify.nix {
    #   inherit inputs lib pkgs;
    # };
    ghostty = import ../../modules/ghostty.nix {
      inherit config device pkgs;
    };
  };

  xdg.dataFile."dbus-1/services/org.freedesktop.FileManager1.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.FileManager1
    Exec=${pkgs.nautilus}/bin/nautilus --gapplication-service
  '';
}
