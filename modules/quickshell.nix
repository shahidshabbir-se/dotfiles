{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDirectory = config.home.homeDirectory;
  launchScript = "${homeDirectory}/dotfiles/config/quickshell/scripts/launch.sh";
in
{
  # Live-editable shell config (same pattern as nvim/rofi/zed).
  xdg.configFile.quickshell.source =
    config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/quickshell";

  # Best practice with home-manager Hyprland: session-scoped user unit.
  # Restart=always recovers the bar after suspend/resume crashes.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
      Documentation = [ "https://quickshell.outfoxxed.me/" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Conflicts = [ "swaync.service" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${launchScript}";
      Restart = "always";
      RestartSec = 2;
      TimeoutStopSec = 5;
      KillMode = "control-group";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
