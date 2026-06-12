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

    # macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      unstable,
      home-manager,
      spicetify-nix,
      nix-darwin,
      nix-homebrew,
      zen-browser,
      ...
    }:
    let
      inherit (nixpkgs) lib;

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
          name = "workstation";
          type = "desktop";
          display = {
            connector = "DP-4";
            width = 3440;
            height = 1440;
            scale = 1.3333;
            refreshRate = 250;
          };
          fontSize = 14.0;
        };

        mac-mini = {
          name = "Mac Mini M4";
          type = "desktop";
          display = {
            connector = "DP-4";
            width = 3440;
            height = 1440;
            refreshRate = 250;
            scale = 1.0;
          };
          fontSize = 14.0;
        };
      };

      pkgsDarwin = import nixpkgs {
        system = systemDarwin;
        config.allowUnfree = true;
      };

      # Helper to create a NixOS configuration for a given device
      mkNixos =
        { device, hardwareConfig }:
        lib.nixosSystem {
          system = systemLinux;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            hardwareConfig
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit
                    inputs
                    unstable
                    device
                    ;
                };
                sharedModules = [ inputs.spicetify-nix.homeManagerModules.default ];
                users.shahid = import ./hosts/nix/home.nix;
              };
            }
          ];
        };

    in
    {
      # ──────────────────────────────
      # ▶ Linux (NixOS)
      # ──────────────────────────────
      nixosConfigurations.laptop = mkNixos {
        device = devices.thinkpad-e14;
        hardwareConfig = ./hardware-laptop.nix;
      };

      nixosConfigurations.pc = mkNixos {
        device = devices.pc;
        hardwareConfig = ./hardware-pc.nix;
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
            system = {

              primaryUser = user;

              # System defaults (macOS settings)
              defaults = {
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
              activationScripts.applications.text =
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

              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 6;
            };
            users.users.${user} = {
              home = "/Users/${user}";
              shell = pkgsDarwin.zsh;
            };

            fonts.packages = with pkgsDarwin; [
              nerd-fonts.jetbrains-mono
              nerd-fonts.lilex
            ];

            homebrew = {
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

            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }

          # Home Manager (macOS)
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs unstable;
                device = devices.mac-mini;
              };
              sharedModules = [ inputs.spicetify-nix.homeManagerModules.default ];

              users.${user} = import ./hosts/mac/home.nix;
            };
          }

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              inherit user;
              autoMigrate = true;
            };
          }
        ];
      };

      darwinPackages = self.darwinConfigurations.${host}.pkgs;
    };
}
