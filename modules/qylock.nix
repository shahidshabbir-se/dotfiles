{ inputs, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  lib = pkgs.lib;
  qylock = inputs.qylock.packages.${system}.qylock-quickshell;
  gstPlugins = with pkgs.gst_all_1; [
    gstreamer.out
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
  gstPluginPath = lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins;
in
pkgs.writeShellScriptBin "qylock-lock" ''
  # Set plugin paths here, rather than relying on the graphical session's
  # inherited environment (which can still contain an older GStreamer path
  # after a system switch).
  export GST_PLUGIN_SYSTEM_PATH_1_0=${lib.escapeShellArg gstPluginPath}
  exec ${qylock}/bin/qylock-lock "$@"
''
