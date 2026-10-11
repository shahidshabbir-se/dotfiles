{ inputs, system }:
{ lib, ... }:
{
  programs.vicinae = {
    enable = true;

    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    extensions = with inputs.vicinae-extensions.packages.${system}; [
      # wifi-commander
      # bluetooth via store zip: vicinaeBluetoothStore
      nix
      port-killer
      power-profile
      process-manager
    ];

    settings = {
      close_on_focus_loss = true;
      consider_preedit = true;
      pop_to_root_on_close = true;
      favicon_service = "twenty";
      search_files_in_root = true;

      font.normal = {
        size = 10.5;
        family = "SF Pro Display";
      };

      launcher_window.opacity = 0.9;

      theme.dark = {
        name = "tokyo-night";
        icon_theme = "Papirus-Dark";
      };
    };
  };

  # Vicinae needs the live Hyprland/Wayland environment. If it starts before
  # graphical-session.target has the compositor env, it exits with a broken
  # Wayland connection and stays dead at login.
  systemd.user.services.vicinae = {
    Unit = {
      After = lib.mkForce [ "default.target" ];
      PartOf = lib.mkForce [ ];
    };

    Service = {
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "XDG_CURRENT_DESKTOP=Hyprland"
        "XDG_SESSION_TYPE=wayland"
      ];
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce 5;
    };

    Install.WantedBy = lib.mkForce [ "default.target" ];
  };
}
