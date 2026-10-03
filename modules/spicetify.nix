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

  # Lucid ships its prebuilt theme in `remote/user.css` as a stub
  # that `@import`s the bundled CSS from a jsdelivr URL. The CDN URL
  # is stale, so we fetch the actual built artifacts straight from
  # the project docs site and assemble a theme directory that
  # spicetify-nix can copy into Themes/Lucid/.
  lucidUserCss = pkgs.fetchurl {
    url = "https://spicetify-lucid.sanooj.uk/spice/user.css";
    sha256 = "sha256-70N9VgIrroy+wDzmY2i5hgddOOVBtP4zyVT3mAB1qbo=";
  };
  lucidThemeJs = pkgs.fetchurl {
    url = "https://spicetify-lucid.sanooj.uk/spice/theme.js";
    sha256 = "sha256-+GZJ+dqCG6wbKo0WMrZrDSplBNpH7r3LhMMa4JSYxRE=";
  };
  lucidColorIni = pkgs.fetchurl {
    url = "https://spicetify-lucid.sanooj.uk/spice/color.ini";
    sha256 = "sha256-iVxVBO1HvI0trHsw7GC3sEGvyOzHHTdkRvpqyfqlcVk";
  };
  lucidTheme = pkgs.runCommand "spicetify-lucid-theme" { } ''
    mkdir -p $out
    cp ${lucidUserCss} $out/user.css
    cp ${lucidThemeJs} $out/theme.js
    cp ${lucidColorIni} $out/color.ini
  '';
in
{
  # ───────────────────────────────────────────────
  # ▶ Enable Spicetify with Customizations
  # ───────────────────────────────────────────────
  enable = true;
  spotifyPackage = pkgs.spotify;

  # Hyprland HDR/color management makes Electron applications render dim.
  # Use spicetify-nix's launch flag option so the flags are applied to the
  # final spiced Spotify package without replacing its derivation.
  spotifyLaunchFlags = pkgs.lib.optionalString pkgs.stdenv.isLinux ''
    --disable-features=WaylandWpColorManagerV1,WaylandColorManagement
    --force-color-profile=srgb
    --enable-features=WaylandLinuxDrmSyncobj
  '';

  # ───────────────────────────────────────────────
  # ▶ Extensions
  # ───────────────────────────────────────────────
  enabledExtensions = with spicePkgs.extensions; [
    adblock
    hidePodcasts
    keyboardShortcut
    shuffle
  ];

  # ───────────────────────────────────────────────
  # ▶ Custom Apps
  # ───────────────────────────────────────────────
  enabledCustomApps = with spicePkgs.apps; [
    marketplace
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
  theme = {
    name = "Lucid";
    src = lucidTheme;
    injectCss = true;
    injectThemeJs = true;
    replaceColors = true;
    homeConfig = true;
    overwriteAssets = false;
  };
  colorScheme = "dark";
}
