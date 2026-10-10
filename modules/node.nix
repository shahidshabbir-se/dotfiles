{
  config,
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
    file.".npmrc".text = ''
      prefix=${npmGlobal}
    '';
    sessionVariables = {
      PATH = "${npmGlobal}/bin:$PATH";
    };
    file."${npmGlobal}/.keep".text = "";
  };
}
