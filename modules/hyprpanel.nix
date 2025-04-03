{ pkgs, ... }:
{
  enable = true;
  overwrite.enable = true;
  theme = "tokyo_night";
  layout = {
    "bar.layouts" = {
      "*" = {
        "left" = [
          "dashboard"
          "media"
          "windowtitle"
        ];
        "middle" = [
          "cava"
          "workspaces"
          "cava"
        ];
        "right" = [
          "network"
          "bluetooth"
          "volume"
          "battery"
          "clock"
          "power"
        ];
      };
    };
  };




  settings = {
    bar.workspaces.show_icons = true;
    theme = {
      font.size = "13px";
      font.name = "JetBrainsMono Nerd Font";
      bar = {
        transparent = true;
        outer_spacing = "0.4rem";
      };
    };
    wallpaper.enable = false;
    bar.bluetooth.label = false;
    bar.network.label = false;
    bar.clock.format = "%a %b %d %I:%M %p";
    bar.media.show_active_only = true;
    bar.customModules.cava.showIcon = false;
    bar.customModules.cava.showActiveOnly = true;
    menus.dashboard.powermenu.avatar.image = "/home/shahid/Pictures/unnamed.png";
    menus.dashboard.powermenu.avatar.name = "Shahid Shabbir";

    theme.bar.menus.menu.clock.scaling = 80;
    theme.bar.menus.menu.dashboard.scaling = 80;
    bar.media.truncation_size = 20;
    bar.launcher.autoDetectIcon = true;
    bar.workspaces.showApplicationIcons = false;
    theme.bar.buttons.modules.power.spacing = "0";
    bar.workspaces.monitorSpecific = false;
    bar.workspaces.applicationIconEmptyWorkspace = "";

    menus.clock = {
      time = {
        military = true;
        hideSeconds = true;
      };
      weather = {
        enabled = false;
        location = "14000";
        unit = "metric";
      };
    };
  };
}
