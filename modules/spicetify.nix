#  ███████╗██████╗ ██╗ ██████╗███████╗████████╗██╗███████╗██╗   ██╗
#  ██╔════╝██╔══██╗██║██╔════╝██╔════╝╚══██╔══╝██║██╔════╝╚██╗ ██╔╝
#  ███████╗██████╔╝██║██║     █████╗     ██║   ██║█████╗   ╚████╔╝ 
#  ╚════██║██╔═══╝ ██║██║     ██╔══╝     ██║   ██║██╔══╝    ╚██╔╝  
#  ███████║██║     ██║╚██████╗███████╗   ██║   ██║██║        ██║   
#  ╚══════╝╚═╝     ╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝╚═╝        ╚═╝   
#  https://github.com/shahidshabbir-se/dotfiles

{ inputs, lib, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  
  # Override Spotify package with correct hash
  spotifyOverride = pkgs.spotify.overrideAttrs (oldAttrs: {
    src = pkgs.fetchurl {
      url = "https://download.scdn.co/SpotifyARM64.dmg";
      sha256 = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
    };
  });
in
{
  # ───────────────────────────────────────────────
  # ▶ Enable Spicetify with Customizations
  # ───────────────────────────────────────────────
  enable = true;
  spotifyPackage = spotifyOverride;

  # ───────────────────────────────────────────────
  # ▶ Extensions
  # ───────────────────────────────────────────────
  enabledExtensions = with spicePkgs.extensions;
    [
      adblock
      hidePodcasts
      keyboardShortcut
      shuffle
    ];

  # ───────────────────────────────────────────────
  # ▶ Custom Apps
  # ───────────────────────────────────────────────
  enabledCustomApps = with spicePkgs.apps; [
    newReleases
    ncsVisualizer
  ];

  # ───────────────────────────────────────────────
  # ▶ Snippets
  # ───────────────────────────────────────────────
  enabledSnippets = with spicePkgs.snippets; [
    rotatingCoverart
  ];

  # ───────────────────────────────────────────────
  # ▶ Theme Configuration
  # ───────────────────────────────────────────────
  theme = spicePkgs.themes.lucid;
  # colorScheme = "TokyoNight";
}
