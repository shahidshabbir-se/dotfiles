{
  config,
  lib,
  pkgs,
  ...
}:

let
  lua = lib.generators.mkLuaInline;
  browser = "zen-beta";
  cursorTheme = config.home.pointerCursor.name;
  cursorSize = config.home.pointerCursor.size;

  startupCommands = [
    "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORM NAUTILUS_4_EXTENSION_DIR && ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORM NAUTILUS_4_EXTENSION_DIR"
    "pkill -x eww 2>/dev/null || true"
    "awww-daemon &"
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "xdg-mime default vlc.desktop video/mp4"
    "xdg-mime default vlc.desktop video/x-matroska"
    "xdg-mime default vlc.desktop video/avi"
    "xdg-mime default vlc.desktop video/webm"
    "xdg-mime default vlc.desktop audio/mpeg"
    "xdg-mime default vlc.desktop audio/x-wav"
    "xdg-mime default vlc.desktop audio/flac"
    "xdg-mime default org.gnome.gThumb.desktop image/png"
    "xdg-mime default org.gnome.gThumb.desktop image/jpeg"
    "xdg-mime default org.gnome.gThumb.desktop image/gif"
    "xdg-mime default org.gnome.gThumb.desktop image/webp"
    "xdg-mime default org.gnome.gThumb.desktop image/bmp"
    "xdg-mime default org.gnome.gThumb.desktop image/svg+xml"
    "xdg-mime default org.gnome.gThumb.desktop image/tiff"
    "xdg-mime default org.gnome.gThumb.desktop image/avif"
    "xdg-mime default org.gnome.gThumb.desktop image/heic"
    "hyprctl setcursor ${cursorTheme} ${toString cursorSize}"
  ];
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      mod._var = "SUPER";
      terminal._var = "ghostty";
      browser._var = browser;
      fileManager._var = "nautilus";

      env = [
        {
          _args = [
            "XDG_MIME_APPS"
            (lua ''os.getenv("HOME") .. "/.config/mimeapps.list"'')
          ];
        }
        {
          _args = [
            "TERMINAL"
            "ghostty"
          ];
        }
        {
          _args = [
            "BROWSER"
            browser
          ];
        }
        {
          _args = [
            "EDITOR"
            "nvim"
          ];
        }
        {
          _args = [
            "NAUTILUS_4_EXTENSION_DIR"
            "/run/current-system/sw/lib/nautilus/extensions-4"
          ];
        }
        {
          _args = [
            "XCURSOR_THEME"
            cursorTheme
          ];
        }
        {
          _args = [
            "XCURSOR_SIZE"
            (toString cursorSize)
          ];
        }
        {
          _args = [
            "HYPRCURSOR_SIZE"
            (toString cursorSize)
          ];
        }
        {
          _args = [
            "HYPRCURSOR_THEME"
            cursorTheme
          ];
        }
        {
          _args = [
            "GTK_THEME"
            "catppuccin-mocha-blue-standard"
          ];
        }
      ];

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 0;
          col = {
            active_border = "rgba(ffffff35)";
            inactive_border = "rgba(ffffff10)";
          };
          resize_on_border = true;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          blur = {
            enabled = true;
            size = 12;
            passes = 3;
            ignore_opacity = true;
            new_optimizations = true;
            vibrancy = 0.1696;
          };
        };

        dwindle.preserve_split = true;
        master.new_status = "master";
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = true;
          focus_on_activate = true;
          vrr = 0;
        };

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          sensitivity = 0.8;
          numlock_by_default = true;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap_to_click = true;
            middle_button_emulation = false;
          };
        };

        xwayland = {
          use_nearest_neighbor = false;
          force_zero_scaling = true;
        };
      };

      curve = [
        {
          _args = [
            "easeOutBack"
            {
              type = "bezier";
              points = [
                [
                  0.34
                  1.56
                ]
                [
                  0.64
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInBack"
            {
              type = "bezier";
              points = [
                [
                  0.36
                  0
                ]
                [
                  0.66
                  (-0.56)
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInCubic"
            {
              type = "bezier";
              points = [
                [
                  0.32
                  0
                ]
                [
                  0.67
                  0
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0
                ]
                [
                  0.35
                  1
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 3;
          bezier = "default";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 3;
          bezier = "easeOutBack";
          style = "popin";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 3;
          bezier = "easeInBack";
          style = "popin";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 3;
          bezier = "easeInOutCubic";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 3;
          bezier = "easeInCubic";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 3;
          bezier = "easeInOutCubic";
          style = "slide";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 3;
          bezier = "easeInOutCubic";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 3;
          bezier = "easeInCubic";
          style = "fade";
        }
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];

      device = {
        name = "epic-mouse-v1";
        sensitivity = 0.5;
      };
    };

    # Home Manager registers its own systemd start hook before extraConfig.
    # Keep these exec-once actions in this hook so they run after that setup.
    extraConfig = ''
      hl.on("hyprland.start", function()
      ${lib.concatMapStringsSep "\n" (
        command: "  hl.exec_cmd(${builtins.toJSON command})"
      ) startupCommands}
      end)
    '';
  };
}
