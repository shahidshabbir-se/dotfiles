#  ███████╗██████╗ ██╗ ██████╗███████╗████████╗██╗███████╗██╗   ██╗
#  ██╔════╝██╔══██╗██║██╔════╝██╔════╝╚══██╔══╝██║██╔════╝╚██╗ ██╔╝
#  ███████╗██████╔╝██║██║     █████╗     ██║   ██║█████╗   ╚████╔╝ 
#  ╚════██║██╔═══╝ ██║██║     ██╔══╝     ██║   ██║██╔══╝    ╚██╔╝  
#  ███████║██║     ██║╚██████╗███████╗   ██║   ██║██║        ██║   
#  ╚══════╝╚═╝     ╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝╚═╝        ╚═╝   
#  https://github.com/shahidshabbir-se/dotfiles

{ inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  # ───────────────────────────────────────────────
  # ▶ Enable Spicetify with Customizations
  # ───────────────────────────────────────────────
  enable = true;

  # ───────────────────────────────────────────────
  # ▶ Extensions
  # ───────────────────────────────────────────────
  enabledExtensions = with spicePkgs.extensions; [
    adblock
    hidePodcasts
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
  theme = spicePkgs.themes.text;
  colorScheme = "TokyoNight";
}
