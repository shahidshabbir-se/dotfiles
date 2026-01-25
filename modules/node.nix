{ config, pkgs, lib, ... }:

let
  unstable = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "15ypswq0yiwk5rsmkp2zkprs1gb2va5gj2nvwqai3d4d5l5vp79h";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
    config = { allowUnfree = true; };
  };

  npmGlobal = "${config.home.homeDirectory}/.npm-global";
in
{
  home.packages = [
    pkgs.nodejs_24
    unstable.bun
  ];

  home.file.".npmrc".text = ''
    prefix=${npmGlobal}
  '';

  home.sessionVariables = {
    # This adds the bin folder to your path.
    PATH = "${npmGlobal}/bin:$PATH";
  };

  home.file."${npmGlobal}/.keep".text = "";

  home.activation.installNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Export paths so post-install scripts (like opencode's) can find bun/node
    export PATH="${unstable.bun}/bin:${pkgs.nodejs_24}/bin:$PATH"

    echo "Installing/Updating global NPM packages..."
    mkdir -p "${npmGlobal}/bin"
    mkdir -p "${npmGlobal}/lib"

    # We still use --prefix here just to be double-safe during activation
    ${pkgs.nodejs_24}/bin/npm install --prefix "${npmGlobal}" -g opencode-ai better-commits
  '';
}
