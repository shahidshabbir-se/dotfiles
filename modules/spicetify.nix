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
in
{
  # ───────────────────────────────────────────────
  # ▶ Enable Spicetify with Customizations
  # ───────────────────────────────────────────────
  enable = true;
  spotifyPackage = pkgs.spotify;

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
