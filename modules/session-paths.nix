{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDirectory = config.home.homeDirectory;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.sessionPath =
    lib.optionals isDarwin [ "/opt/homebrew/opt/libpq/bin" ]
    ++ [
      "${homeDirectory}/.local/bin"
      "${homeDirectory}/.cargo/bin"
      "${homeDirectory}/go/bin"
      "${homeDirectory}/.npm-global/bin"
      "${homeDirectory}/.bun/bin"
    ]
    ++ lib.optionals isLinux [ "${homeDirectory}/.nix-profile/bin" ];
}
