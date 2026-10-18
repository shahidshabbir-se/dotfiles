{
  config,
  lib,
  pkgs,
  ...
}:

let
  npmGlobal = "${config.home.homeDirectory}/.npm-global";
in
{
  home = {
    packages = [
      pkgs.nodejs_24
      pkgs.bun
    ];
    sessionPath = [
      "${npmGlobal}/bin"
      "${config.home.homeDirectory}/.bun/bin"
    ];
  };

  home.activation.setNpmGlobalPrefix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.nodejs_24}/bin/npm config set "prefix=${npmGlobal}"
  '';
}
