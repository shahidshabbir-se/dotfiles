{ pkgs, homeDirectory, ... }:

{
  enable = true;
  package = pkgs.polybar.override {
    i3Support = true;
    pulseSupport = true;
  };

  # ───────────────────────────────────────────────
  # Polybar config - Daniela theme (Catppuccin Mocha)
  # Adapted from gh0stzk/dotfiles
  # ───────────────────────────────────────────────
  config = {

    # ─────────────────────────────────────────
    # Main Bar
    # ─────────────────────────────────────────
    "bar/main" = {
      monitor = "\${env:MONITOR:}";
      monitor-strict = false;
      override-redirect = false;

      bottom = false;
      fixed-center = true;

      width = "100%";
      height = "1%";

      offset-x = 0;
      offset-y = 0;

      background = "#181825";
      foreground = "#cdd6f4";

      radius = 0;

      line-size = 2;
      line-color = "#89b4fa";

      border = 0;

      padding = 4;

      module-margin-left = 0;
      module-margin-right = 0;

      # Fonts
      font-0 = "JetBrainsMono Nerd Font:style=Bold:size=12;4";
      font-1 = "Font Awesome 6 Free Solid:size=11;3";
      font-2 = "JetBrainsMono Nerd Font:style=Bold:size=14;4";
      font-3 = "Material Design Icons Desktop:size=19;5";
      font-4 = "JetBrainsMono Nerd Font:size=12;4";

      modules-left = "launcher sep sep cpu sep memory sep disk sep tray";
      modules-center = "i3";
      modules-right = "mplayer power bluetooth sep prev play-pause next sep battery sep network sep pulseaudio sep updates sep date";

      separator = "  ";
      dim-value = "1.0";

      wm-restack = "i3";
      enable-ipc = true;

      cursor-click = "pointer";
    };

    # ─────────────────────────────────────────
    # Separator
    # ─────────────────────────────────────────
    "module/sep" = {
      type = "custom/text";
      label = " ";
      label-foreground = "#181825";
    };

    # ─────────────────────────────────────────
    # Launcher
    # ─────────────────────────────────────────
    "module/launcher" = {
      type = "custom/text";
      format-prefix = "󰣇";
      format-prefix-font = 4;
      format-prefix-foreground = "#a6e3a1";
      label = "NixOS";
      label-font = 1;
      click-left = "${homeDirectory}/dotfiles/config/rofi/app-menu-x11-launch.sh";
    };

    # ─────────────────────────────────────────
    # CPU
    # ─────────────────────────────────────────
    "module/cpu" = {
      type = "internal/cpu";
      interval = "0.5";
      format = "<label>";
      format-prefix = "CPU";
      format-prefix-font = 1;
      format-prefix-foreground = "#89b4fa";
      label = "%percentage%%";
      label-padding = "2pt";
      label-font = 5;
    };

    # ─────────────────────────────────────────
    # Memory
    # ─────────────────────────────────────────
    "module/memory" = {
      type = "internal/memory";
      interval = 3;
      format = "<label>";
      format-prefix = "RAM";
      format-prefix-font = 1;
      format-prefix-foreground = "#f9e2af";
      label = "%used%";
      label-padding = "2pt";
      label-font = 5;
    };

    # ─────────────────────────────────────────
    # Disk
    # ─────────────────────────────────────────
    "module/disk" = {
      type = "internal/fs";
      mount-0 = "/";
      interval = 60;
      fixed-values = true;
      format-mounted = "<label-mounted>";
      format-mounted-prefix = "DISK";
      format-mounted-prefix-font = 1;
      format-mounted-prefix-foreground = "#f38ba8";
      label-mounted = "%used%";
      label-mounted-padding = "2pt";
      label-mounted-font = 5;
    };

    # ─────────────────────────────────────────
    # Tray
    # ─────────────────────────────────────────
    "module/tray" = {
      type = "internal/tray";
      format = "<tray>";
      format-background = "#181825";
      tray-background = "#181825";
      tray-foreground = "#cdd6f4";
      tray-spacing = "8px";
      tray-padding = "0px";
      tray-size = "40%";
    };

    # ─────────────────────────────────────────
    # i3 Workspaces
    # ─────────────────────────────────────────
    "module/i3" = {
      type = "internal/i3";

      enable-click = true;
      enable-scroll = false;
      pin-workspaces = true;

      format = "<label-state> <label-mode>";
      format-font = 1;

      # Active workspace
      label-focused = "%index%";
      label-focused-font = 3;
      label-focused-padding = 3;
      label-focused-foreground = "#cba6f7";

      # Occupied workspace
      label-unfocused = "%index%";
      label-unfocused-padding = 3;
      label-unfocused-foreground = "#73739c";

      # Visible on other monitor
      label-visible = "%index%";
      label-visible-padding = 3;
      label-visible-foreground = "#73739c";

      # Empty workspace
      label-separator = "";

      # Urgent
      label-urgent = "%index%";
      label-urgent-padding = 3;
      label-urgent-foreground = "#f38ba8";
    };

    # ─────────────────────────────────────────
    # Music player icon
    # ─────────────────────────────────────────
    "module/mplayer" = {
      type = "custom/text";
      label = "";
      label-padding = "2pt";
      label-foreground = "#cba6f7";
      click-left = "eww open --toggle music";
    };

    # ─────────────────────────────────────────
    # Power
    # ─────────────────────────────────────────
    "module/power" = {
      type = "custom/text";
      label = "";
      label-padding = "2pt";
      label-foreground = "#f38ba8";
      click-left = "${homeDirectory}/dotfiles/config/rofi/power-x11-launch.sh";
    };

    # ─────────────────────────────────────────
    # Bluetooth
    # ─────────────────────────────────────────
    "module/bluetooth" = {
      type = "custom/script";
      exec = "echo 󰂯";
      interval = 3;
      format = "<label>";
      format-font = 4;
      label = "%output%";
      label-foreground = "#89b4fa";
      click-left = "${homeDirectory}/dotfiles/config/rofi/bluetooth-launch.sh";
    };

    # ─────────────────────────────────────────
    # Media controls (playerctl)
    # ─────────────────────────────────────────
    "module/prev" = {
      type = "custom/text";
      label = "";
      label-font = 2;
      label-foreground = "#89b4fa";
      click-left = "playerctl previous";
    };

    "module/play-pause" = {
      type = "custom/script";
      exec = "playerctl status 2>/dev/null | grep -q 'Playing' && echo '' || echo ''";
      interval = 1;
      click-left = "playerctl play-pause";
      format = "<label>";
      label = "%output%";
      label-font = 2;
      label-foreground = "#a6e3a1";
    };

    "module/next" = {
      type = "custom/text";
      label = "";
      label-font = 2;
      label-foreground = "#89b4fa";
      click-left = "playerctl next";
    };

    # ─────────────────────────────────────────
    # Battery
    # ─────────────────────────────────────────
    "module/battery" = {
      type = "internal/battery";
      full-at = 99;
      battery = "BAT0";
      adapter = "AC";
      poll-interval = 2;
      time-format = "%H:%M";

      format-charging = "<animation-charging><label-charging>";
      label-charging = "%percentage%%";
      label-charging-padding = "2pt";
      label-charging-font = 5;

      format-discharging = "<ramp-capacity><label-discharging>";
      label-discharging = "%percentage%%";
      label-discharging-font = 5;
      label-discharging-padding = "2pt";

      format-full = "<label-full>";
      format-full-prefix = "";
      format-full-prefix-font = 2;
      format-full-prefix-foreground = "#a6e3a1";
      label-full = "%percentage%%";
      label-full-padding = "2pt";
      label-full-font = 5;

      ramp-capacity-0 = "";
      ramp-capacity-1 = "";
      ramp-capacity-2 = "";
      ramp-capacity-3 = "";
      ramp-capacity-4 = "";
      ramp-capacity-foreground = "#cba6f7";
      ramp-capacity-font = 2;

      animation-charging-0 = "";
      animation-charging-1 = "";
      animation-charging-2 = "";
      animation-charging-3 = "";
      animation-charging-4 = "";
      animation-charging-foreground = "#a6e3a1";
      animation-charging-font = 2;
      animation-charging-framerate = 700;
    };

    # ─────────────────────────────────────────
    # Network
    # ─────────────────────────────────────────
    "module/network" = {
      type = "internal/network";
      interface-type = "wireless";
      interval = 3;
      accumulate-stats = true;
      unknown-as-up = true;

      format-connected = "<label-connected>";
      format-connected-prefix = "NET";
      format-connected-prefix-foreground = "#a6e3a1";
      format-connected-prefix-font = 1;

      label-connected = "%{A1:${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh:}%netspeed%%{A}";
      label-connected-padding = "2pt";
      label-connected-font = 5;

      format-disconnected = "<label-disconnected>";
      format-disconnected-prefix = "NET";
      format-disconnected-prefix-font = 1;
      format-disconnected-prefix-foreground = "#f38ba8";

      label-disconnected = "%{A1:${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh:}Offline%{A}";
      label-disconnected-padding = "2pt";
      label-disconnected-font = 5;
    };

    # ─────────────────────────────────────────
    # Pulseaudio
    # ─────────────────────────────────────────
    "module/pulseaudio" = {
      type = "internal/pulseaudio";
      use-ui-max = true;
      interval = 5;

      format-volume = "<label-volume>";
      format-volume-prefix = "VOL";
      format-volume-prefix-font = 1;
      format-volume-prefix-foreground = "#b4befe";

      label-volume = "%percentage%";
      label-volume-padding = "2pt";
      label-volume-font = 5;

      format-muted = "<label-muted>";
      label-muted = "Muted";
      label-muted-padding = "2pt";
      label-muted-font = 1;
      label-muted-foreground = "#f38ba8";

      click-right = "pavucontrol";
    };

    # ─────────────────────────────────────────
    # Updates
    # ─────────────────────────────────────────
    "module/updates" = {
      type = "custom/script";
      exec = "cat $HOME/.cache/Updates.txt 2>/dev/null || echo 0";
      interval = 1;
      format = "<label>";
      format-prefix = "UPDATES";
      format-prefix-font = 1;
      format-prefix-foreground = "#cba6f7";
      label = "%output%";
      label-padding = "2pt";
      label-font = 5;
    };

    # ─────────────────────────────────────────
    # Date
    # ─────────────────────────────────────────
    "module/date" = {
      type = "custom/script";
      exec = "date +'%I:%M %p'";
      interval = 1;
      format = "<label>";
      format-foreground = "#fab387";
      label = "%output%";
      click-left = "eww open --toggle date";
    };

    # ─────────────────────────────────────────
    # Settings
    # ─────────────────────────────────────────
    "settings" = {
      screenchange-reload = false;
      compositing-background = "source";
      compositing-foreground = "over";
      compositing-overline = "over";
      compositing-underline = "over";
      compositing-border = "over";
      pseudo-transparency = false;
    };
  };

  # ─────────────────────────────────────────
  # Launch script for multi-monitor
  # ─────────────────────────────────────────
  script = ''
    # Terminate already running bar instances
    polybar-msg cmd quit 2>/dev/null

    # Launch bar on all monitors
    for m in $(polybar --list-monitors | cut -d":" -f1); do
      MONITOR=$m polybar main &
    done
  '';
}
