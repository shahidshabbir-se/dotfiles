# ███╗   ██╗██╗██╗  ██╗    ███████╗██╗      █████╗ ██╗  ██╗███████╗
# ████╗  ██║██║╚██╗██╔╝    ██╔════╝██║     ██╔══██╗██║ ██╔╝██╔════╝
# ██╔██╗ ██║██║ ╚███╔╝     █████╗  ██║     ███████║█████╔╝ █████╗
# ██║╚██╗██║██║ ██╔██╗     ██╔══╝  ██║     ██╔══██║██╔═██╗ ██╔══╝
# ██║ ╚████║██║██╔╝ ██╗    ██║     ███████╗██║  ██║██║  ██╗███████╗
# ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
# https://github.com/shahidshabbir-se/dotfiles

{
  description = "My NixOS + macOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };

    catppuccin.url = "github:catppuccin/nix";

    # macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

  };

  outputs = inputs@{ self, nixpkgs, unstable, home-manager, spicetify-nix, catppuccin, nix-darwin, nix-homebrew, zen-browser, ... }:
    let
      lib = nixpkgs.lib;

      # Systems
      systemLinux = "x86_64-linux";
      systemDarwin = "aarch64-darwin"; # or x86_64-darwin for Intel Macs

      # Users
      user = "shahid";
      host = "mini";

      # Device configurations
      devices = {
        thinkpad-e14 = {
          name = "ThinkPad E14";
          type = "laptop";
          display = {
            connector = "eDP-1";
            width = 1920;
            height = 1080;
            scale = 1.3333;
            refreshRate = 60;
          };
          fontSize = 14.0;
        };

        pc = {
          name = "PC + MAG 255F E20";
          type = "desktop";
          display = {
            connector = "HDMI-A-1";
            width = 1920;
            height = 1080;
            scale = 1.2;
            refreshRate = 200;
          };
          fontSize = 14.0;
        };
      };

      # Active device selection
      # Change this to switch between configurations:
      #   devices.thinkpad-e14  — for laptop
      #   devices.pc            — for PC with external monitor
      activeDevice = devices.pc;

      pkgsDarwin = import nixpkgs {
        system = systemDarwin;
        config.allowUnfree = true;
      };

    in
    {
      # ──────────────────────────────
      # ▶ Linux (NixOS)
      # ──────────────────────────────
      nixosConfigurations.nixos = lib.nixosSystem {
        system = systemLinux;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs unstable;
              device = activeDevice;
            };
            home-manager.sharedModules = [ inputs.spicetify-nix.homeManagerModules.default ];
            home-manager.users.shahid = import ./hosts/nix/home.nix;
          }
        ];
      };

      # ──────────────────────────────
      # ▶ macOS (Darwin)
      # ──────────────────────────────
      darwinConfigurations.${host} = nix-darwin.lib.darwinSystem {
        system = systemDarwin;
        modules = [
          # ./modules/yabai.nix
          # ./modules/skhd.nix

          # ───────────────────────────────────────────────
          # ▶ Core System Configuration
          # ───────────────────────────────────────────────
          {
            nixpkgs.hostPlatform = systemDarwin;
            nixpkgs.config.allowUnfree = true;

            system.primaryUser = user;
            users.users.${user} = {
              home = "/Users/${user}";
              shell = pkgsDarwin.zsh;
            };

            fonts.packages = with pkgsDarwin; [
              nerd-fonts.jetbrains-mono
              nerd-fonts.lilex
            ];

            # System defaults (macOS settings)
            system.defaults = {
              dock.autohide = true;
              dock.persistent-apps = [
                "/System/Applications/Apps.app"
                # "/System/Applications/Launchpad.app"
                "/System/Applications/System Settings.app"
                "/Applications/Microsoft Excel.app"
                "/Applications/Microsoft PowerPoint.app"
                "/Applications/Microsoft Word.app"
                "/Applications/WhatsApp.app"
                "/Applications/Obsidian.app"
                "/Applications/VLC.app"
                "/Users/${user}/Applications/Home Manager Apps/Spotify.app"
                # "${pkgsDarwin.ghostty-bin}/Applications/Ghostty.app"
                "${pkgsDarwin.wezterm}/Applications/Wezterm.app"
                "/Applications/Docker.app"
                "/Applications/Xcode.app"
                "/Applications/Zen.app"
              ];
              finder.FXPreferredViewStyle = "clmv";
              loginwindow.GuestEnabled = false;
              NSGlobalDomain = {
                AppleICUForce24HourTime = false;
                AppleInterfaceStyle = "Dark";
                KeyRepeat = 2;
              };
            };

            # ───────────────────────────────────────────────
            # ▶ Create /Applications aliases for Nix Apps
            # ───────────────────────────────────────────────
            system.activationScripts.applications.text =
              let
                systemPackages = [
                  # pkgsDarwin.alacritty
                  # pkgsDarwin.ghostty-bin
                  pkgsDarwin.wezterm
                  pkgsDarwin.mkalias
                ];

                env = pkgsDarwin.buildEnv {
                  name = "system-applications";
                  paths = systemPackages;
                  pathsToLink = [ "/Applications" ];
                };
              in
              pkgsDarwin.lib.mkForce ''
                # Set up applications.
                echo "setting up /Applications..." >&2
                rm -rf /Applications/Nix\ Apps
                mkdir -p /Applications/Nix\ Apps
                find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                while read -r src; do
                  app_name=$(basename "$src")
                  echo "copying $src" >&2
                  ${pkgsDarwin.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done
              '';

            homebrew =
              {
                enable = true;
                taps = [ ];

                brews = [
                  # "cliproxyapi"
                  "libpq"
                ];

                casks = [
                  "qbittorrent"
                  # "droid"
                  "notunes"
                  "tailscale-app"
                  "betterdisplay"
                  "raycast"
                  "whatsapp"
                  "obsidian"
                  "karabiner-elements"
                  "protonvpn"
                  "zen"
                  "google-chrome"
                  "vlc"
                  "docker-desktop"
                  "camo-studio"
                ];

                masApps = {
                  # Xcode = 497799835;
                };

                onActivation.cleanup = "zap";
              };

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            system.configurationRevision = self.rev or self.dirtyRev or null;
            system.stateVersion = 6;
          }

          # Home Manager (macOS)
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs unstable;
              device = activeDevice;
            };
            home-manager.sharedModules = [ inputs.spicetify-nix.homeManagerModules.default ];

            home-manager.users.${user} = import ./hosts/mac/home.nix;
          }

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = user;
              autoMigrate = true;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations.${host}.pkgs;
    };
}


