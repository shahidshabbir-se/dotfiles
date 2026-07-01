{
  config,
  pkgs,
  lib,
  ...
}:

let
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
in
{
  home.packages = [
    pkgs.nodejs_24
    pkgs.bun
  ];

  home.file.".npmrc".text = ''
    prefix=${npmGlobal}
  '';

  home.sessionVariables = {
    # This adds the bin folder to your path.
    PATH = "${npmGlobal}/bin:$PATH";
  };

  home.file."${npmGlobal}/.keep".text = "";

  # home.activation.installNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   # Export paths so post-install scripts (like opencode's) can find bun/node
  #   export PATH="${pkgs.bun}/bin:${pkgs.nodejs_24}/bin:$PATH"
  #
  #   echo "Installing/Updating global NPM packages..."
  #   mkdir -p "${npmGlobal}/bin"
  #   mkdir -p "${npmGlobal}/lib"
  #
  #   # We still use --prefix here just to be double-safe during activation
  #   ${pkgs.nodejs_24}/bin/npm install --prefix "${npmGlobal}" -g opencode-ai better-commits
  # '';
}
