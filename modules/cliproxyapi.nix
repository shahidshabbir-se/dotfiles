{
  config,
  pkgs,
  lib,
  ...
}:

let
  version = "6.8.55"; # ← update this only

  inherit (pkgs.stdenv.hostPlatform) system;

  platformMap = {
    x86_64-linux = "linux_amd64";
    aarch64-linux = "linux_arm64";
    x86_64-darwin = "darwin_amd64";
    aarch64-darwin = "darwin_arm64";
  };

  platform = platformMap.${system} or (throw "Unsupported platform: ${system}");

  src = pkgs.fetchurl {
    url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_${platform}.tar.gz";

    sha256 = "uBjD1p4IfLT/aqdRR/ALsJaUShB4Ds5/0VkZHVVAQAk=";
  };

  cliproxyapi = pkgs.stdenv.mkDerivation {
    pname = "cliproxyapi";
    inherit version src;

    nativeBuildInputs = [ pkgs.gnutar ];

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src
      cp cli-proxy-api $out/bin/cliproxyapi
      chmod +x $out/bin/cliproxyapi
    '';
  };

  inherit (pkgs.stdenv) isLinux;
  inherit (pkgs.stdenv) isDarwin;

in
{
  home.packages = [ cliproxyapi ];

  xdg.configFile."cliproxyapi/config.yaml".source = ../config/cliproxyapi/config.yaml;

  systemd.user.services.cliproxyapi = lib.mkIf isLinux {
    Unit = {
      Description = "CLIProxyAPI Service";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${cliproxyapi}/bin/cliproxyapi -config %h/.config/cliproxyapi/config.yaml";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  launchd.agents.cliproxyapi = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${cliproxyapi}/bin/cliproxyapi"
        "-config"
        "${config.home.homeDirectory}/.config/cliproxyapi/config.yaml"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/cliproxyapi.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/cliproxyapi.error.log";
    };
  };
}
