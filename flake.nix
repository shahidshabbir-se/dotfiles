# ███╗   ██╗██╗██╗  ██╗    ███████╗██╗      █████╗ ██╗  ██╗███████╗
# ████╗  ██║██║╚██╗██╔╝    ██╔════╝██║     ██╔══██╗██║ ██╔╝██╔════╝
# ██╔██╗ ██║██║ ╚███╔╝     █████╗  ██║     ███████║█████╔╝ █████╗
# ██║╚██╗██║██║ ██╔██╗     ██╔══╝  ██║     ██╔══██║██╔═██╗ ██╔══╝
# ██║ ╚████║██║██╔╝ ██╗    ██║     ███████╗██║  ██║██║  ██╗███████╗
# ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
# https://github.com/shahidshabbir-se/dotfiles

{
  description = "My NixOS + macOS Configuration Flake";

  # ───────────────────────────────────────────────
  # ▶ Inputs
  # ───────────────────────────────────────────────
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    vicinae.url = "github:vicinaehq/vicinae";

    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  # ───────────────────────────────────────────────
  # ▶ Outputs
  # ───────────────────────────────────────────────
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      spicetify-nix,
      nix-darwin,
      nix-homebrew,
      zen-browser,
      vicinae,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # ───────────────────────────────────────────────
      # ▶ System Constants
      # ───────────────────────────────────────────────
      systems = {
        linux = "x86_64-linux";
        darwin = "aarch64-darwin";
      };

      user = "shahid";
      darwinHost = "mini";

      # ───────────────────────────────────────────────
      # ▶ Device Profiles
      # ───────────────────────────────────────────────
      devices = {
        thinkpad-e14 = {
          name = "ThinkPad E14";
          type = "laptop";

          power = {
            acProfile = "performance";
            batteryProfile = "power-saver";
            hibernateDelay = "2h";
            resumeDevice = "/dev/disk/by-uuid/361fb99a-9f91-4765-a37d-27fc19d07e57";
            chargeEndThreshold = 80;

            idle = {
              battery = {
                lockAndDisplayOff = 300;
                sleep = 900;
              };
              ac = {
                lockAndDisplayOff = 600;
                sleep = 1800;
              };
            };
          };

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

          power = {
            acProfile = "performance";
            hibernateDelay = "2h";
            resumeDevice = "/dev/disk/by-uuid/a0bafec0-8980-4f08-a450-32c8f13f43d2";

            idle = {
              lock = 600;
              displayOff = 900;
              sleep = 1800;
            };
          };

          display = {
            connector = "DP-4";
            width = 3440;
            height = 1440;
            scale = 1.3333;
            refreshRate = 250;
          };

          # HDR luminance tuning: https://github.com/hyprwm/Hyprland/discussions/14682
          # Panel-reported values (drm_info | grep -i luminance):
          #   Max display mastering luminance: 417 cd/m²
          #   Min display mastering luminance: 0.0108 cd/m²
          #   Max content light level (MaxCLL): 417 cd/m²
          hdr = {
            cm = "hdredid";
            # Brightness dial — safe to raise; keep sdrMaxLuminance at panel peak.
            sdrBrightness = 0.70;
            sdrSaturation = 1.0;
            sdrMaxLuminance = 417;
            sdrMinLuminance = 0.0108;
            # HDR metadata: match the panel's actual reported capabilities.
            minLuminance = 0.0108;
            maxAvgLuminance = 417;
            maxLuminance = 417;
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
            scale = 1.0;
            refreshRate = 250;
          };

          fontSize = 14.0;
        };
      };

      # ───────────────────────────────────────────────
      # ▶ Package Sets
      # ───────────────────────────────────────────────
      pkgsDarwin = import nixpkgs {
        system = systems.darwin;
        config.allowUnfree = true;
      };

      # ───────────────────────────────────────────────
      # ▶ Shared Home Manager Config
      # ───────────────────────────────────────────────
      mkHomeManagerConfig =
        {
          device,
          homeFile,
          extraSharedModules ? [ ],
        }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = {
              inherit inputs device;
            };

            sharedModules = [
              inputs.spicetify-nix.homeManagerModules.default
            ]
            ++ extraSharedModules;

            users.${user} = import homeFile;
          };
        };

      # ───────────────────────────────────────────────
      # ▶ NixOS Helper
      # ───────────────────────────────────────────────
      mkNixos =
        {
          device,
          hardwareConfig,
        }:
        lib.nixosSystem {
          system = systems.linux;

          specialArgs = {
            inherit inputs device;
          };

          modules = [
            hardwareConfig
            ./configuration.nix

            vicinae.nixosModules.default
            home-manager.nixosModules.home-manager

            (mkHomeManagerConfig {
              inherit device;
              homeFile = ./hosts/nix/home.nix;
              extraSharedModules = [ vicinae.homeManagerModules.default ];
            })
          ];
        };

      # ───────────────────────────────────────────────
      # ▶ macOS Application Aliases
      # ───────────────────────────────────────────────
      darwinAliasPackages = with pkgsDarwin; [
        wezterm
        mkalias
      ];

      darwinAppAliasEnv = pkgsDarwin.buildEnv {
        name = "system-applications";
        paths = darwinAliasPackages;
        pathsToLink = [ "/Applications" ];
      };

      darwinApplicationAliasesScript = pkgsDarwin.lib.mkForce ''
        echo "setting up /Applications..." >&2

        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps

        find ${darwinAppAliasEnv}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgsDarwin.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      # ───────────────────────────────────────────────
      # ▶ macOS Helper
      # ───────────────────────────────────────────────
      mkDarwin =
        {
          hostName,
          device,
        }:
        nix-darwin.lib.darwinSystem {
          system = systems.darwin;

          modules = [
            # ./modules/yabai.nix
            # ./modules/skhd.nix

            {
              nixpkgs.hostPlatform = systems.darwin;
              nixpkgs.config.allowUnfree = true;

              # ───────────────────────────────────────────────
              # ▶ Core macOS System Config
              # ───────────────────────────────────────────────
              system = {
                primaryUser = user;

                defaults = {
                  dock = {
                    autohide = true;

                    persistent-apps = [
                      "/System/Applications/Apps.app"
                      # "/System/Applications/Launchpad.app"
                      "/System/Applications/System Settings.app"

                      "/Applications/Microsoft Excel.app"
                      "/Applications/Microsoft PowerPoint.app"
                      "/Applications/Microsoft Word.app"
                      "/Applications/WhatsApp.app"
                      "/Applications/Obsidian.app"
                      "/Applications/VLC.app"
                      "/Applications/Docker.app"
                      "/Applications/Xcode.app"
                      "/Applications/Zen.app"

                      "/Users/${user}/Applications/Home Manager Apps/Spotify.app"

                      # "${pkgsDarwin.ghostty-bin}/Applications/Ghostty.app"
                      "${pkgsDarwin.wezterm}/Applications/Wezterm.app"
                    ];
                  };

                  finder.FXPreferredViewStyle = "clmv";

                  loginwindow.GuestEnabled = false;

                  NSGlobalDomain = {
                    AppleICUForce24HourTime = false;
                    AppleInterfaceStyle = "Dark";
                    KeyRepeat = 2;
                  };
                };

                activationScripts.applications.text = darwinApplicationAliasesScript;

                configurationRevision = self.rev or self.dirtyRev or null;

                stateVersion = 6;
              };

              # ───────────────────────────────────────────────
              # ▶ macOS User
              # ───────────────────────────────────────────────
              users.users.${user} = {
                home = "/Users/${user}";
                shell = pkgsDarwin.zsh;
              };

              # ───────────────────────────────────────────────
              # ▶ Fonts
              # ───────────────────────────────────────────────
              fonts.packages = with pkgsDarwin; [
                nerd-fonts.jetbrains-mono
                nerd-fonts.lilex
              ];

              # ───────────────────────────────────────────────
              # ▶ Homebrew
              # ───────────────────────────────────────────────
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

              # ───────────────────────────────────────────────
              # ▶ Nix Settings
              # ───────────────────────────────────────────────
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            }

            # Home Manager
            home-manager.darwinModules.home-manager

            (mkHomeManagerConfig {
              inherit device;
              homeFile = ./hosts/mac/home.nix;
            })

            # Nix Homebrew
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

    in
    {
      # ───────────────────────────────────────────────
      # ▶ Linux: NixOS Hosts
      # ───────────────────────────────────────────────
      nixosConfigurations = {
        laptop = mkNixos {
          device = devices.thinkpad-e14;
          hardwareConfig = ./hardware-laptop.nix;
        };

        pc = mkNixos {
          device = devices.pc;
          hardwareConfig = ./hardware-pc.nix;
        };
      };

      # ───────────────────────────────────────────────
      # ▶ macOS: Darwin Hosts
      # ───────────────────────────────────────────────
      darwinConfigurations.${darwinHost} = mkDarwin {
        hostName = darwinHost;
        device = devices.mac-mini;
      };

      darwinPackages = self.darwinConfigurations.${darwinHost}.pkgs;
    };
}
