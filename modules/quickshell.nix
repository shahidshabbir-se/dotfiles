{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDirectory = config.home.homeDirectory;
  launchScript = "${homeDirectory}/dotfiles/config/quickshell/scripts/launch.sh";
  restartScript = "${homeDirectory}/dotfiles/config/quickshell/scripts/restart.sh";

  # systemd user units start with a minimal PATH. Pin every binary the launch
  # and restart scripts need instead of relying on the graphical session env.
  runtimePath = lib.makeBinPath [
    pkgs.quickshell
    pkgs.jq
    pkgs.hyprland
    pkgs.systemd
    pkgs.coreutils
    pkgs.bash
  ];

  qsRestart = pkgs.writeShellScriptBin "qs-restart" ''
    export PATH=${runtimePath}:$PATH
    exec ${pkgs.bash}/bin/bash ${restartScript} "$@"
  '';
in
{
  home.packages = with pkgs; [
    quickshell
    jq
    qt6.qtdeclarative # qmllint / qmlformat
    # qylock session lock (lock-screen) needs these QML modules / codecs
    qt6.qtmultimedia
    qt6.qt5compat
    qt6.qtsvg
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
    qsRestart
  ];

  # Live-editable shell config (same pattern as nvim/zed).
  xdg.configFile.quickshell.source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/quickshell";

  # Session-scoped user unit. launch.sh owns monitor readiness; systemd owns
  # crash restart. qs-restart is the one lock-aware lifecycle path.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
      Documentation = [ "https://quickshell.outfoxxed.me/" ];
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
      StartLimitIntervalSec = 60;
      StartLimitBurst = 5;
    };

    Service = {
      Type = "exec";
      Environment = [ "PATH=${runtimePath}" ];
      ExecStart = "${pkgs.bash}/bin/bash ${launchScript}";
      Restart = "always";
      RestartSec = 2;
      TimeoutStopSec = 5;
      KillMode = "control-group";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
