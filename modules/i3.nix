# ╔══════════════════════════════════════════════════════════════╗
# ║  i3 Module (self-contained)                                 ║
# ║  Import this in home.nix to enable i3.                      ║
# ║  Also requires in configuration.nix:                        ║
# ║    services.xserver.enable = true;                          ║
# ║    services.xserver.windowManager.i3.enable = true;         ║
# ╚══════════════════════════════════════════════════════════════╝

{
  config,
  pkgs,
  lib,
  device,
  ...
}:

let
  homeDirectory = "/home/shahid";
  browser = "zen-beta";
  inherit (config.lib.file) mkOutOfStoreSymlink;

  mod = "Mod4";
  terminal = "ghostty";
  fileManager = "ghostty --title=yazi -e yazi";
  menu = "${homeDirectory}/dotfiles/config/rofi/app-menu-x11-launch.sh";
in
{
  # ───────────────────────────────────────────────
  # ▶ i3 / X11 Packages
  # ───────────────────────────────────────────────
  home.packages = with pkgs; [
    # Window management
    i3lock-color

    # Screenshot / Clipboard
    maim
    xclip
    xsel

    # X11 utilities
    xdotool
    xorg.xrandr
    numlockx
    autorandr
    bc
    jq

    # Clipboard manager
    haskellPackages.greenclip

    # GTK bridge for X11
    xsettingsd

    # Touchpad gestures / mouse bindings
    libinput-gestures
    xbindkeys

    # Image viewer
    feh

    # Media / Audio / Brightness
    playerctl
    brightnessctl
    alsa-utils

    # Rofi launcher
    rofi
    rofi-bluetooth

    # Notifications
    libnotify

    # Bar / Widgets
    eww

    # Audio visualizer
    glava
  ];

  # ───────────────────────────────────────────────
  # ▶ GLava (audio visualizer)
  # ───────────────────────────────────────────────
  home.activation.glavaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Copy default shaders if missing, then symlink our overrides
    if [ ! -d "${homeDirectory}/.config/glava/bars" ]; then
      ${pkgs.glava}/bin/glava --copy-config 2>/dev/null || true
    fi
    ln -sf ${homeDirectory}/dotfiles/config/glava/rc.glsl ${homeDirectory}/.config/glava/rc.glsl
    ln -sf ${homeDirectory}/dotfiles/config/glava/bars.glsl ${homeDirectory}/.config/glava/bars.glsl
  '';

  # ───────────────────────────────────────────────
  # ▶ libinput-gestures (touchpad 3-finger swipe)
  # ───────────────────────────────────────────────
  xdg.configFile."libinput-gestures.conf".text = ''
    gesture swipe right 3 i3-msg workspace prev
    gesture swipe left 3 i3-msg workspace next
  '';

  # ───────────────────────────────────────────────
  # ▶ xbindkeys (Super+scroll to switch workspaces)
  # ───────────────────────────────────────────────
  home.file.".xbindkeysrc".text = ''
    "i3-msg workspace prev"
      Mod4 + b:4

    "i3-msg workspace next"
      Mod4 + b:5
  '';

  # ───────────────────────────────────────────────
  # ▶ xsettingsd (bridges GTK/font settings to X11)
  # ───────────────────────────────────────────────
  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Net/ThemeName "catppuccin-mocha-blue-standard"
    Net/IconThemeName "Papirus-Dark"
    Gtk/CursorThemeName "${
      if device.type == "laptop" then "Banana" else "catppuccin-mocha-dark-cursors"
    }"
    Gtk/CursorThemeSize ${builtins.toString (if device.type == "laptop" then 48 else 24)}
    Gtk/FontName "SF Pro Display 10"
    Net/EnableEventSounds 0
    Net/EnableInputFeedbackSounds 0
    Xft/Antialias 1
    Xft/Hinting 1
    Xft/HintStyle "hintfull"
    Xft/DPI ${builtins.toString (112 * 1024)}
  '';

  # ───────────────────────────────────────────────
  # ▶ X11 DPI / Xresources (scaling for i3)
  # ───────────────────────────────────────────────
  xresources.properties = {
    "Xft.dpi" = 112;
    "Xft.autohint" = 0;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintfull";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
  };

  # ───────────────────────────────────────────────
  # ▶ Picom Compositor
  # ───────────────────────────────────────────────
  services.picom = import ./picom.nix { };

  # ───────────────────────────────────────────────
  # ▶ Dunst Notifications
  # ───────────────────────────────────────────────
  services.dunst = import ./dunst.nix { };

  # ───────────────────────────────────────────────
  # ▶ i3 Window Manager
  # ───────────────────────────────────────────────
  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;
      terminal = terminal;
      defaultWorkspace = "workspace number 1";

      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 11.0;
      };

      gaps = {
        inner = 5;
        outer = 10;
        top = 65;
        smartGaps = false;
        smartBorders = "off";
      };

      window = {
        border = 0;
        titlebar = false;
        hideEdgeBorders = "none";
      };

      floating = {
        border = 0;
        titlebar = false;
        modifier = mod;
        criteria = [
          { title = "yazi"; }
          { title = "btop"; }
          { class = "podman-tui"; }
          { class = "Rofi"; }
        ];
      };

      colors = {
        focused = {
          border = "#33ccff";
          background = "#1a1b26";
          text = "#c0caf5";
          indicator = "#00ff99";
          childBorder = "#33ccff";
        };
        unfocused = {
          border = "#595959";
          background = "#1a1b26";
          text = "#565f89";
          indicator = "#595959";
          childBorder = "#595959";
        };
        focusedInactive = {
          border = "#595959";
          background = "#1a1b26";
          text = "#565f89";
          indicator = "#595959";
          childBorder = "#595959";
        };
        urgent = {
          border = "#f7768e";
          background = "#1a1b26";
          text = "#f7768e";
          indicator = "#f7768e";
          childBorder = "#f7768e";
        };
      };

      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "HDMI-A-0 HDMI-1 eDP-1 eDP1";
        }
        {
          workspace = "2";
          output = "HDMI-A-0 HDMI-1 eDP-1 eDP1";
        }
        {
          workspace = "3";
          output = "HDMI-A-0 HDMI-1 eDP-1 eDP1";
        }
        {
          workspace = "4";
          output = "eDP-1 eDP1 HDMI-A-0 HDMI-1";
        }
        {
          workspace = "5";
          output = "eDP-1 eDP1 HDMI-A-0 HDMI-1";
        }
        {
          workspace = "6";
          output = "eDP-1 eDP1 HDMI-A-0 HDMI-1";
        }
      ];

      assigns = { };

      keybindings = lib.mkOptionDefault {
        # Launch applications
        "${mod}+Return" = "workspace number 1; exec ${terminal}";
        "${mod}+q" = "kill";
        "${mod}+e" = "exec ${fileManager}";
        "Ctrl+Shift+Escape" = "exec ghostty --title=btop -e btop";
        "${mod}+b" = "workspace number 2; exec ${browser}";
        "${mod}+Shift+b" = "workspace number 5; exec ${browser} --private-window";
        "${mod}+x" = "exec code";
        "${mod}+o" = "exec obsidian";
        "${mod}+Mod1+p" = "exec systemctl poweroff";
        "${mod}+Mod1+r" = "exec systemctl reboot";
        "${mod}+Mod1+q" = "exit";
        "${mod}+Shift+l" = "exec ${homeDirectory}/dotfiles/scripts/i3lock-screen.sh";
        "${mod}+m" = "workspace number 6; exec spotify";
        "${mod}+Ctrl+s" = "exec ${homeDirectory}/dotfiles/scripts/screenshot-x11.sh area";
        "${mod}+r" = "exec kooha";
        "${mod}+Shift+r" = "exec killall kooha";

        # Window management
        "${mod}+t" = "floating toggle";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+v" = "layout toggle split";

        # Focus movement (arrow keys)
        "${mod}+Left" = "focus left";
        "${mod}+Right" = "focus right";
        "${mod}+Up" = "focus up";
        "${mod}+Down" = "focus down";

        # Focus movement (vim keys)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move windows
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+Right" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Down" = "move down";

        # Workspaces
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";

        # Move to workspace
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";

        # Scratchpad
        "${mod}+s" = "scratchpad show";
        "${mod}+Shift+s" = "move scratchpad";

        # Cycle workspaces
        "${mod}+Ctrl+Right" = "workspace next";
        "${mod}+Ctrl+Left" = "workspace prev";

        # Alt-Tab cycling
        "Mod1+Tab" = "focus right";
        "Mod1+Shift+Tab" = "focus left";

        # Rofi menus
        "${mod}+space" = "exec ${menu}";
        "Mod1+Shift+b" = "exec ${homeDirectory}/dotfiles/config/rofi/bluetooth-launch.sh";
        "Mod1+Shift+n" = "exec ${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh";
        "Mod1+Shift+w" = "exec bash ~/.config/rofi/WallSelect-x11";
        "Mod1+Shift+p" = "exec ${homeDirectory}/dotfiles/config/rofi/power-x11-launch.sh";
        "Mod1+Shift+s" = "exec ${homeDirectory}/dotfiles/config/rofi/screenshot-x11-launch.sh";
        "Mod1+c" = "exec ${homeDirectory}/dotfiles/config/rofi/clipboard-x11-launch.sh";

        # Bar toggle
        "${mod}+z" = "exec ${homeDirectory}/dotfiles/config/eww/bar/launch_bar";

        # Media keys
        "F7" = "exec playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
        "F8" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
        "F9" = "exec playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";

        # Volume
        "XF86AudioRaiseVolume" =
          "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";
        "XF86AudioLowerVolume" =
          "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";
        "XF86AudioMute" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";

        # Brightness
        "XF86MonBrightnessUp" =
          "exec brightnessctl s 10%+ && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh";
        "XF86MonBrightnessDown" =
          "exec brightnessctl s 10%- && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh";

        # Media (XF86 keys)
        "XF86AudioNext" =
          "exec playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
        "XF86AudioPrev" =
          "exec playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
        "XF86AudioPlay" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
        "XF86AudioPause" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      };

      startup = [
        {
          command = "sh -c '[ -f ~/.fehbg ] && sh ~/.fehbg || feh --bg-fill ${homeDirectory}/.cache/wallpaper-cache/wallpaper.jpg'";
          always = true;
          notification = false;
        }
        {
          command = "picom --config ${homeDirectory}/dotfiles/config/picom/picom.conf";
          notification = false;
        }
        {
          command = "sh ${homeDirectory}/dotfiles/config/eww/bar/launch_bar";
          always = true;
          notification = false;
        }
        {
          command = "${homeDirectory}/dotfiles/config/eww/bar/scripts/fullscreen_watch";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart greenclip.service";
          notification = false;
        }
        {
          command = "libinput-gestures";
          notification = false;
        }
        {
          command = "xbindkeys";
          notification = false;
        }
        {
          command = "xsettingsd";
          notification = false;
        }
        {
          command = "xinput set-prop 'ETPS/2 Elantech Touchpad' 'libinput Natural Scrolling Enabled' 1";
          notification = false;
        }
        {
          command = "xsetroot -cursor_name left_ptr";
          notification = false;
        }
        {
          command = "numlockx on";
          notification = false;
        }
        {
          command = "sh -c 'sleep 3 && glava'";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop video/mp4";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop video/x-matroska";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop video/avi";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop video/webm";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop audio/mpeg";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop audio/x-wav";
          notification = false;
        }
        {
          command = "xdg-mime default vlc.desktop audio/flac";
          notification = false;
        }
        {
          command = "xdg-mime default feh.desktop image/png";
          notification = false;
        }
        {
          command = "xdg-mime default feh.desktop image/jpeg";
          notification = false;
        }
        {
          command = "xdg-mime default feh.desktop image/gif";
          notification = false;
        }
        {
          command = "xdg-mime default feh.desktop image/webp";
          notification = false;
        }
        {
          command = "xdg-mime default feh.desktop image/bmp";
          notification = false;
        }
      ];

      bars = [ ];
    };

    extraConfig = ''
      exec --no-startup-id xrandr --dpi 112 --output HDMI-A-0 --mode 1920x1080 --rate 200 --primary --output eDP-1 --mode 1920x1080 --rate 60 --right-of HDMI-A-0

      focus_follows_mouse yes

      for_window [title="yazi"] floating enable, resize set 800 500, move position center
      for_window [title="btop"] floating enable, resize set 1100 800, move position center
      for_window [class="podman-tui"] floating enable, resize set 1000 600, move position center
      for_window [class="Rofi"] floating enable
      for_window [class="^.*$"] border pixel 0
    '';
  };

  # ───────────────────────────────────────────────
  # ▶ Greenclip systemd user service
  # ───────────────────────────────────────────────
  systemd.user.services.greenclip = {
    Unit = {
      Description = "Greenclip clipboard manager";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.haskellPackages.greenclip}/bin/greenclip daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
