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
    sessionVariables.PATH = "${npmGlobal}/bin:$PATH";
  };

  home.activation.setNpmGlobalPrefix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.nodejs_24}/bin/npm config set "prefix=${npmGlobal}"
  '';
}
