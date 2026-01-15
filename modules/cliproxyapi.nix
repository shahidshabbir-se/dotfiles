{ config, pkgs, lib, ... }:

let
  version = "6.6.104";
  
  sources = {
    x86_64-linux = {
      url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_amd64.tar.gz";
      sha256 = "cd898b326e3fc1f886c24a28592a26ed7ba9ccd4e3be3176a2a4a48f383c07f7";
    };
    aarch64-linux = {
      url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_linux_arm64.tar.gz";
      sha256 = "fee358eb0516cbeb9066bd788ad5951d26d4094d36950e004de1f1d8921e55c0";
    };
    aarch64-darwin = {
      url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_darwin_arm64.tar.gz";
      sha256 = "e69dacb197649232315bfa530c3db639734019964e9ce68cb749304a5b180276";
    };
    x86_64-darwin = {
      url = "https://github.com/router-for-me/CLIProxyAPI/releases/download/v${version}/CLIProxyAPI_${version}_darwin_amd64.tar.gz";
      sha256 = "bc319a0ea57683ece70f85bc1287c15d1abbcf835283bec33a338a3dbd5aff87";
    };
  };
  
  source = sources.${pkgs.stdenv.hostPlatform.system} or (throw "Unsupported platform: ${pkgs.stdenv.hostPlatform.system}");
  
  cliproxyapi = pkgs.stdenv.mkDerivation {
    pname = "cliproxyapi";
    inherit version;
    
    src = pkgs.fetchurl {
      url = source.url;
      sha256 = source.sha256;
    };
    
    sourceRoot = ".";
    
    installPhase = ''
      mkdir -p $out/bin
      tar -xzf $src
      cp cli-proxy-api $out/bin/cliproxyapi
      chmod +x $out/bin/cliproxyapi
    '';
  };
  
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # Install the package
  home.packages = [ cliproxyapi ];
  
  # Setup config file
  xdg.configFile."cliproxyapi/config.yaml".source = ../config/cliproxyapi/config.yaml;
  
  # Linux systemd service
  systemd.user.services.cliproxyapi = lib.mkIf isLinux {
    Unit = {
      Description = "CLIProxyAPI Service";
      Documentation = "https://github.com/router-for-me/CLIProxyAPI";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${cliproxyapi}/bin/cliproxyapi -config %h/.config/cliproxyapi/config.yaml";
      WorkingDirectory = "%h";
      Environment = [ "HOME=%h" ];
    };
    Install.WantedBy = [ "default.target" ];
  };
  
  # macOS launchd service
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
      WorkingDirectory = config.home.homeDirectory;
    };
  };
}
