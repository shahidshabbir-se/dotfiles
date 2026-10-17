{ lib, pkgs, device, ... }:

let
  d = device.display;
  hdr = device.hdr or { };
  hasHdr = hdr != { };
  hasNvidiaGpu = (device.gpu.vendor or null) == "nvidia";

  monitor = {
    output = d.connector;
    mode = "${toString d.width}x${toString d.height}@${toString d.refreshRate}";
    position = "auto";
    scale = d.scale;
  } // lib.optionalAttrs hasHdr {
    bitdepth = 10;
    cm = hdr.cm or "hdredid";
    supports_hdr = 1;
    supports_wide_color = 1;
    sdrbrightness = hdr.sdrBrightness or 1.0;
    sdrsaturation = hdr.sdrSaturation or 1.0;
    sdr_max_luminance = hdr.sdrMaxLuminance or 280;
    sdr_min_luminance = hdr.sdrMinLuminance or 0.005;
    min_luminance = hdr.minLuminance or 0.005;
    max_avg_luminance = hdr.maxAvgLuminance or 600;
    max_luminance = hdr.maxLuminance or 1000;
    vrr = 0;
  };

  fixHdrScreensharePlugin = pkgs.callPackage ../pkgs/hyprland-fix-hdr-screenshare.nix { };
in
{
  wayland.windowManager.hyprland = {
    plugins = lib.mkIf hasHdr [ fixHdrScreensharePlugin ];

    settings = {
      monitor = [ monitor ];

      config = {
        render = {
          cm_enabled = true;
          cm_sdr_eotf = "2";
          cm_auto_hdr = 0;
          # Keep this disabled: the HDR screencopy plugin requires the mirror path.
          keep_unmodified_copy = 0;
          # This avoids blur artifacts on HDR/10-bit displays.
          use_shader_blur_blend = device.type == "desktop";
          direct_scanout = false;
        };

        opengl = lib.mkIf hasNvidiaGpu {
          nvidia_anti_flicker = false;
        };

        cursor = lib.mkIf hasNvidiaGpu {
          no_hardware_cursors = true;
        };
      };
    };
  };
}
