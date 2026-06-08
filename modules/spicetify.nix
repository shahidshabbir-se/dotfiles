#  ███████╗██████╗ ██╗ ██████╗███████╗████████╗██╗███████╗██╗   ██╗
#  ██╔════╝██╔══██╗██║██╔════╝██╔════╝╚══██╔══╝██║██╔════╝╚██╗ ██╔╝
#  ███████╗██████╔╝██║██║     █████╗     ██║   ██║█████╗   ╚████╔╝ 
#  ╚════██║██╔═══╝ ██║██║     ██╔══╝     ██║   ██║██╔══╝    ╚██╔╝  
#  ███████║██║     ██║╚██████╗███████╗   ██║   ██║██║        ██║   
#  ╚══════╝╚═╝     ╚═╝ ╚═════╝╚══════╝   ╚═╝   ╚═╝╚═╝        ╚═╝   
#  https://github.com/shahidshabbir-se/dotfiles

{ inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # Lucid was dropped from spicetify-nix; fetch upstream directly.
  lucidSrc = pkgs.fetchFromGitHub {
    owner = "sanoojes";
    repo = "Spicetify-Lucid";
    rev = "3746c1eb8cdda4d5b680dcc769ad629b467a4520";
    hash = "sha256-ciA3LptZeflCwkUq66E2ZCvxpLH8/XVJyMimjdU9Fk0=";
  };

  lucidTheme = {
    name = "Lucid";
    src = "${lucidSrc}/src";
    overwriteAssets = true;
    requiredExtensions = [
      {
        src = "${lucidSrc}/src";
        name = "theme.js";
      }
    ];
  };

  # Override Spotify package with correct hash for macOS only
  # spotifyOverride =
  #   if pkgs.stdenv.isDarwin then
  #     pkgs.spotify.overrideAttrs
  #       (oldAttrs: {
  #         src = pkgs.fetchurl {
  #           url = "https://download.scdn.co/SpotifyARM64.dmg";
  #           sha256 = "sha256-0gwoptqLBJBM0qJQ+dGAZdCD6WXzDJEs0BfOxz7f2nQ=";
  #         };
  #       })
  #   else
  #     pkgs.spotify;
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
  theme = lucidTheme;
  # Valid schemes in this Lucid pin: dark, use-lucid, settings, to-change, colors
  colorScheme = "use-lucid";
}
