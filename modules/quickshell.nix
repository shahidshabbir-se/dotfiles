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

  # Omarchy's shell needs the patched Quickshell from modules/pkgs: nixpkgs'
  # 0.3.1 lacks OmarchyLoadPatch and deadlocks on plugin reload.
  patchedQuickshell = pkgs.callPackage ./pkgs/quickshell.nix { };

  # The vendored Omarchy tree; see docs/adr/0006-fork-omarchy-shell.md.
  omarchyPath = "${homeDirectory}/dotfiles/vendor/omarchy";

  # systemd user units start with a minimal PATH. Pin every binary the launch
  # and restart scripts need instead of relying on the graphical session env.
  runtimePath = lib.makeBinPath [
    patchedQuickshell
    pkgs.jq
    pkgs.hyprland
    pkgs.systemd
    pkgs.coreutils
    pkgs.bash
    # Tools the vendored helpers on the default bar call. NixOS does not put
    # most of these on a non-login PATH, and systemd user units start with a
    # minimal environment, so name them here instead of relying on the
    # graphical session (see docs/helper-adaptation.md).
    pkgs.pulseaudio # pactl
    pkgs.pipewire # pw-link
    pkgs.wireplumber # wpctl
    pkgs.networkmanager # nmcli
    pkgs.bluez # bluetoothctl
    pkgs.util-linux # rfkill
    pkgs.iproute2 # ip
    pkgs.curl
    pkgs.qrencode
    pkgs.upower
    pkgs.power-profiles-daemon # powerprofilesctl
    pkgs.brightnessctl
    pkgs.ddcutil
    pkgs.gtk3 # gtk-launch for the menu app library
    pkgs.procps # top, pgrep, ps
    pkgs.findutils
    pkgs.gawk # the helpers parse command output with awk
    pkgs.gnugrep
    pkgs.gnused
    pkgs.fontconfig # fc-match
    pkgs.libxkbcommon # xkbcli
  ];

  # Omarchy's helpers must win over any same-named system commands.
  unitPath = "${omarchyPath}/bin:${runtimePath}";

  qsRestart = pkgs.writeShellScriptBin "qs-restart" ''
    export PATH=${unitPath}:$PATH
    export OMARCHY_PATH=${omarchyPath}
    exec ${pkgs.bash}/bin/bash ${restartScript} "$@"
  '';
in
{
  home.packages = with pkgs; [
    patchedQuickshell
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

  # Omarchy's shell reads ~/.config/omarchy/shell.json; this symlink keeps our
  # tracked config canonical instead of letting the shell fork its own copy.
  xdg.configFile.omarchy.source = config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/omarchy";

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
      Environment = [
        "PATH=${unitPath}"
        "OMARCHY_PATH=${omarchyPath}"
      ];
      ExecStart = "${pkgs.bash}/bin/bash ${launchScript}";
      Restart = "always";
      RestartSec = 2;
      TimeoutStopSec = 5;
      KillMode = "control-group";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
