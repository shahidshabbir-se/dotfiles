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

  spotifyWrapped = pkgs.spotify.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=1.4"
    '';
  });

  # Lucid ships its prebuilt theme in `remote/user.css` as a stub
  # that `@import`s the bundled CSS from a jsdelivr URL. The CDN URL
  # is stale, so we fetch the actual built artifacts straight from
  # the project docs site and assemble a theme directory that
  # spicetify-nix can copy into Themes/Lucid/.
  lucidUserCss = pkgs.fetchurl {
    url = "https://spicetify-lucid.sanooj.uk/spice/user.css";
    sha256 = "sha256-wO0L0O1tdcBfEXeBuZN6vG9wviDLucaYY71mYw/0eHI";
  };
  lucidThemeJs = pkgs.fetchurl {
    url = "https://spicetify-lucid.sanooj.uk/spice/theme.js";
    sha256 = "sha256-fnsCi48U7BO9XqxhTNi5KUHJC8FUQQKjnp3KdFJQdvk";
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
  spotifyPackage = spotifyWrapped;

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
