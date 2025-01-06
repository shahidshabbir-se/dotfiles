{
  description = "My NixOS Configuration Flake";

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
    hyprpanel = { 
      url = "github:jas-singhfsu/hyprpanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, zen-browser, hyprpanel, ... } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      overlay.enable = true;

      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
                {nixpkgs.overlays = [inputs.hyprpanel.overlay];}  
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Let Home Manager derive config automatically
            home-manager.users.shahid = import ./home.nix {
              inherit pkgs nixpkgs lib system inputs;
            };
          }
        ];
      };
    };
  };
}
