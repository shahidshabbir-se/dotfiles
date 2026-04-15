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
  homeDirectory = "/home/shahid";
  browser = "zen-beta";
  userGmail = "shahidshabbirse@gmail.com";
  userGithub = "shahidshabbir-se";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  inherit (pkgs.stdenv.hostPlatform) system;

  unstable = import inputs.unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # Allow unfree packages for corefonts
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "corefonts" ];

in
{
  imports = [
    ../../modules/node.nix
    ../../modules/i3.nix
    # ../../modules/hyprland.nix
    # ../../modules/cliproxyapi.nix
    ../../modules/television.nix
  ];

  # ───────────────────────────────────────────────
  # ▶ Home Directory & Package Set
  # ───────────────────────────────────────────────
  # home.pointerCursor = {
  #   x11.enable = true;
  #   gtk.enable = true;
  #   package = import ../../modules/banana-cursor.nix { inherit pkgs; };
  #   size = 36;
  #   name = "Banana";
  # };
  home = {
    username = "shahid";
    inherit homeDirectory;
    stateVersion = "24.05";
    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;
      name = "catppuccin-mocha-dark-cursors";
    };

    packages =
      (import ../../modules/pkgs/common.nix { inherit pkgs; })
      # ++ [ (import ../../modules/pkgs/cursor.nix { inherit pkgs lib; }) ]
      # ++ [ (import ../../modules/pkgs/antigravity.nix { inherit pkgs lib; }) ]
      # ++ [ (import ../../modules/pkgs/zed.nix { inherit pkgs lib; }) ]
      # ++ [ (import ../../modules/pkgs/t3code.nix { inherit pkgs lib; }) ]
      ++ (with unstable; [
        # zed-editor --still not the latest update
        # jetbrains.rust-rover
        vscode
      ])
      ++ (with pkgs; [
        upwork
        git-filter-repo
        wmctrl
        chromium
        matugen
        corefonts
        fastfetch
        gcc
        gnumake
        inputs.zen-browser.packages.${system}.default
        protonvpn-gui
        # poppins
        xfce.thunar
        nitch
        python3
        (pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "blue" ];
          size = "standard";
        })
        unzip
        catppuccin-papirus-folders
        anydesk
        pulsemixer
        zip
        # (import ../../modules/void.nix { inherit pkgs; })
      ]);
  };
  xdg = {

    # ───────────────────────────────────────────────
    # ▶ XDG Configuration
    # ───────────────────────────────────────────────
    enable = true;
    configFile = {
      nvim.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";
      # zed.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zed";
      yazi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/yazi";
      eww.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/eww";
      rofi.source = mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/rofi";
    };

    desktopEntries = {
      whatsapp = {
        name = "Whatsapp";
        genericName = "Messaging";
        comment = "Whatsapp Web";
        icon = "whatsapp";
        exec = "chromium --disable-features=UseOzonePlatform --app=https://web.whatsapp.com";
        terminal = false;
        categories = [
          "Network"
          "Chat"
        ];
      };

      microsoft-excel = {
        name = "Microsoft Excel";
        genericName = "Spreadsheet";
        comment = "Microsoft Excel Online";
        icon = "ms-excel";
        exec = "chromium --disable-features=UseOzonePlatform --app=https://excel.cloud.microsoft/";
        terminal = false;
        categories = [
          "Office"
          "Spreadsheet"
        ];
      };
      microsoft-word = {
        name = "Microsoft Word";
        genericName = "Word Processor";
        comment = "Microsoft Word Online";
        icon = "ms-word";
        exec = "chromium --disable-features=UseOzonePlatform --app=https://word.cloud.microsoft/";
        terminal = false;
        categories = [
          "Office"
          "WordProcessor"
        ];
      };
      microsoft-powerpoint = {
        name = "Microsoft PowerPoint";
        genericName = "Presentation";
        comment = "Microsoft PowerPoint Online";
        icon = "ms-powerpoint";
        exec = "chromium --disable-features=UseOzonePlatform --app=https://powerpoint.cloud.microsoft/";
        terminal = false;
        categories = [
          "Office"
          "Presentation"
        ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "zen-beta.desktop" ];
        "x-scheme-handler/https" = [ "zen-beta.desktop" ];
        "x-scheme-handler/chrome" = [ "zen-beta.desktop" ];
        "text/html" = [ "zen-beta.desktop" ];
        "application/x-extension-htm" = [ "zen-beta.desktop" ];
        "application/x-extension-html" = [ "zen-beta.desktop" ];
        "application/x-extension-shtml" = [ "zen-beta.desktop" ];
        "application/xhtml+xml" = [ "zen-beta.desktop" ];
        "application/x-extension-xhtml" = [ "zen-beta.desktop" ];
        "application/x-extension-xht" = [ "zen-beta.desktop" ];
      };
    };
  };

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
  home.file.".zsh/aliases".source =
    mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/zsh/aliases";
  # home.file.".ideavimrc".source =
  #   mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/jetbrains/.ideavimrc";

  # ───────────────────────────────────────────────
  # ▶ Program Configurations
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
    fzf = import ../../modules/fzf.nix { inherit pkgs; };
    zoxide = import ../../modules/zoxide.nix { inherit pkgs; };
    atuin = import ../../modules/atuin.nix;
    spicetify = import ../../modules/spicetify.nix { inherit inputs lib pkgs; };
    # wezterm = import ../../modules/wezterm.nix { inherit pkgs; };
    # kitty = import ../../modules/kitty.nix { inherit pkgs; };
    ghostty = import ../../modules/ghostty.nix { inherit config device pkgs; };
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
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
        size = "standard";
      };
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
