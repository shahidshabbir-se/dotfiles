{
  description = "My NixOS + macOS Configuration Flake";

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

  outputs = inputs@{ self, nixpkgs, home-manager, spicetify-nix, zen-browser, nix-darwin, nix-homebrew, ... }:
    let
      lib = nixpkgs.lib;

      # Systems
      systemLinux = "x86_64-linux";
      systemDarwin = "aarch64-darwin"; # or x86_64-darwin for Intel Macs

      # Users
      user = "shahid";
      host = "mini";

      # Packages
      pkgsLinux = import nixpkgs {
        system = systemLinux;
        config.allowUnfree = true;
      };

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
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
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
              nerd-fonts.geist-mono
            ];

            # System defaults (macOS settings)
            system.defaults = {
              dock.autohide = true;
              dock.persistent-apps = [
                "/System/Applications/Apps.app"
                "/System/Applications/System Settings.app"
                "/Applications/Microsoft Excel.app"
                "/Applications/Microsoft PowerPoint.app"
                "/Applications/Microsoft Word.app"
                "/Applications/WhatsApp.app"
                "/Applications/Obsidian.app"
                "/Applications/VLC.app"
                "/Applications/Nix Apps/kitty.app"
                "/Applications/Nix Apps/Spotify.app"
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
                  pkgsDarwin.kitty
                  pkgsDarwin.mkalias
                ];

                env = pkgsDarwin.buildEnv {
                  name = "system-applications";
                  paths = systemPackages;
                  pathsToLink = "/Applications";
                };
              in
              pkgsDarwin.lib.mkForce ''
                echo "Setting up /Applications..." >&2
                rm -rf /Applications/Nix\ Apps
                mkdir -p /Applications/Nix\ Apps

                # Link system packages with mkalias
                find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                while IFS= read -r src; do
                  app_name=$(basename "$src")
                  echo "Aliasing $src to /Applications/Nix Apps/$app_name" >&2
                  ${pkgsDarwin.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
                done

                # Link Spotify from Home Manager with mkalias
                if [ -L "/Users/${user}/Applications/Spotify.app" ]; then
                  spotify_src=$(readlink "/Users/${user}/Applications/Spotify.app")
                  echo "Aliasing Spotify..." >&2
                  ${pkgsDarwin.mkalias}/bin/mkalias "$spotify_src" "/Applications/Nix Apps/Spotify.app"
                fi
              '';

            homebrew = {
              enable = true;
              taps = [ ];

              brews = [
                "git-graph"
                "sqlc"
                "gitleaks"
                "lazygit"
                "infisical"
                "golang-migrate"
                "node"
                "ncdu"
              ];

              casks = [
                "qbittorrent"
                "notunes"
                "betterdisplay"
                "tailscale-app"
                "raycast"
                "whatsapp"
                "obsidian"
                "karabiner-elements"
                "vlc"
                "zen"
                "localsend"
                "orbstack"
              ];

              masApps = {
                Xcode = 497799835;
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
            home-manager.extraSpecialArgs = { inherit inputs; };
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
