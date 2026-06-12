# ╔══════════════════════════════════════════════════════════════╗
# ║  Hyprland Module (self-contained)                           ║
# ║  Import this in home.nix to enable Hyprland.                ║
# ║  Also requires in configuration.nix:                        ║
# ║    programs.hyprland.enable = true;                         ║
# ║    programs.hyprland.xwayland.enable = true;                ║
# ╚══════════════════════════════════════════════════════════════╝

{
  config,
  pkgs,
  lib,
  inputs,
  device,
  ...
}:

let
  homeDirectory = "/home/shahid";
  browser = "zen-beta";
  exitScript = pkgs.writeShellScript "exit.sh" ''
    if env -u GTK_THEME zenity --question --title="Exit Hyprland" --text="Do you wish to exit?"; then
      hyprctl -i 0 dispatch exit
    fi
  '';

  d = device.display;
  desktopRefreshRate = if device.type == "desktop" then 240 else d.refreshRate;
  cursorTheme = "Banana";
  cursorSize = if device.type == "laptop" then 48 else 36;

  layerRuleNamespaces = [
    "logout_dialog"
  ];

  # Hyprland 0.55+ layerrules need named blocks in extraConfig.
  # ignore_alpha must stay low (0–0.2): higher values skip blur on more pixels;
  # at 1.0 layer blur is effectively invisible.
  layerRuleBlock = ns: ''
    layerrule {
      name = blur-${lib.replaceStrings [ "_" ] [ "-" ] ns}
      match:namespace = ${ns}
      blur = on
      ignore_alpha = 0
    }'';

  layerRuleBlocks = lib.concatStringsSep "\n\n" (map layerRuleBlock layerRuleNamespaces);

  windowRules = [
    "float on, match:title ^(yazi)$"
    "size 800 500, match:title ^(yazi)$"
    "center on, match:title ^(yazi)$"
    "float on, match:class ^(org.gnome.Nautilus|Nautilus|nautilus)$"
    "size 1100 700, match:class ^(org.gnome.Nautilus|Nautilus|nautilus)$"
    "center on, match:class ^(org.gnome.Nautilus|Nautilus|nautilus)$"
    "float on, match:class ^(gthumb|org\\.gnome\\.gThumb)$"
    "size 1200 800, match:class ^(gthumb|org\\.gnome\\.gThumb)$"
    "center on, match:class ^(gthumb|org\\.gnome\\.gThumb)$"
    "no_blur on, match:class ^(Brave-browser)$"
    "no_blur on, match:class ^(zen|google-chrome|Chrome|chromium|Chromium|Cursor|code|Code|obsidian|discord|slack|Spotify)$"
    "opacity 1.00 override 1.00 override 1.00 override, match:class ^(zen|google-chrome|Chrome|chromium|Chromium|Cursor|code|Code|obsidian|discord|slack|Spotify)$"
    "float on, match:title ^(btop)$"
    "size 900 600, match:title ^(btop)$"
    "center on, match:title ^(btop)$"
    "float on, match:class ^(podman-tui)$"
    "size 1000 600, match:class ^(podman-tui)$"
    "center on, match:class ^(podman-tui)$"
    "float on, match:class ^(Rofi)$"
    "opacity 1.00 override 1.00 override 1.00 override, match:class ^(com.mitchellh.ghostty)$, match:fullscreen 1"
    "force_rgbx on, match:class ^(com.mitchellh.ghostty)$, match:fullscreen 1"
    "no_blur on, match:class ^(com.mitchellh.ghostty)$, match:fullscreen 1"
    "suppress_event maximize on, match:class .*"
    "no_focus on, match:class ^$, match:title ^$, match:xwayland 1, match:float 1, match:fullscreen 0"
  ];
  # HDR desktop. Screencopy tone-mapping for PNGs was fixed in Hyprland PR
  # #12204 (0.54+). Keep sdrbrightness for panel brightness; run `nix flake update`
  # so nixpkgs ships a new enough Hyprland.
  monitorLine =
    "${d.connector},${toString d.width}x${toString d.height}@${toString desktopRefreshRate},auto,${toString d.scale}"
    + (if device.type == "desktop" then ",bitdepth,10,cm,hdredid,sdrbrightness,4.0,vrr,0" else "");
in
{
  # ───────────────────────────────────────────────
  # ▶ Hyprland Packages
  # ───────────────────────────────────────────────
  home.packages = with pkgs; [
    # Wallpaper
    awww
    mpvpaper

    # Launcher / Menus
    wofi
    rofi
    rofi-bluetooth

    # Screenshot
    grimblast

    # Clipboard
    cliphist
    wl-clipboard

    # Notifications
    swaynotificationcenter
    libnotify

    # Media / Audio / Brightness
    playerctl
    brightnessctl
    alsa-utils

    # Image viewer (hyprland mime defaults)
    gthumb
  ];

  # ───────────────────────────────────────────────
  # ▶ Swaync (Notification Center)
  # ───────────────────────────────────────────────
  services.swaync = import ./swaync.nix {
    inherit pkgs homeDirectory;
  };

  # Only auto-start SwayNC for Hyprland sessions. i3 uses Dunst instead.
  systemd.user.services.swaync = {
    Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland";
    Service = {
      Type = lib.mkForce "simple";
      BusName = lib.mkForce "";
    };
  };

  # ───────────────────────────────────────────────
  # ▶ Hyprland Window Manager
  # ───────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    xwayland.enable = true;
    systemd.enable = false;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      "$browser" = "${browser}";
      "$fileManager" = "ghostty --title=yazi -e yazi";
      "$menu" = "${homeDirectory}/dotfiles/config/rofi/app-menu-launch.sh";

      monitor = [
        monitorLine
        # "${d.connector},addreserved,68,0,0,0"
      ];

      exec-once = [
        "pkill -x dunst 2>/dev/null || true"
        "pkill -x swaync 2>/dev/null || true"
        "pkill -x glava 2>/dev/null || true"
        "pkill -x waybar 2>/dev/null || true"
        "pkill -x eww 2>/dev/null || true"
        "awww-daemon &"
        "sleep 4 && sh ${homeDirectory}/dotfiles/config/matugen/from-cache.sh 2>/dev/null || true"
        # "mpvpaper -o \'no-audio --loop-playlist hwdec=auto profile=low-latency vo=gpu\' \'*\' ${homeDirectory}/dotfiles/assets/login-background.mp4"
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
        ''sleep 2 && socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do case "$line" in windowtitlev2\>\>*) data="''${line#windowtitlev2>>}"; addr="''${data%%,*}"; title="''${data#*,}"; case "$title" in *Bitwarden*) floating=$(hyprctl -i 0 clients -j | jq -r ".[] | select(.address == \"0x$addr\") | .floating"); [ "$floating" = "false" ] && hyprctl -i 0 dispatch togglefloating "address:0x$addr" && hyprctl -i 0 dispatch resizewindowpixel exact 500 600,"address:0x$addr" && hyprctl -i 0 dispatch centerwindow "address:0x$addr" ;; esac ;; esac; done &''
      ];

      env = [
        "XDG_MIME_APPS,$HOME/.config/mimeapps.list"
        "TERMINAL,wezterm"
        "BROWSER,${browser}"
        "EDITOR,nvim"
        # HDR + cm on desktop makes Chromium/Electron render dim without these.
        "CHROMIUM_FLAGS,--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb"
        "CHROMIUM_USER_FLAGS,--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb"
        "XCURSOR_THEME,${cursorTheme}"
        "XCURSOR_SIZE,${toString cursorSize}"
        "HYPRCURSOR_SIZE,${toString cursorSize}"
        "HYPRCURSOR_THEME,${cursorTheme}"
        # "XCURSOR_THEME,catppuccin-mocha-dark-cursors"
        # "XCURSOR_SIZE,24"
        # "HYPRCURSOR_SIZE,24"
        # "HYPRCURSOR_THEME,catppuccin-mocha-dark-cursors"
        "GTK_THEME,catppuccin-mocha-blue-standard"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 5;
        active_opacity = 1.0;
        inactive_opacity = 0.98;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 12;
          passes = 3;
          ignore_opacity = true;
          new_optimizations = true;
          vibrancy = 0.1696;
        };
      };

      bezier = [
        "easeOutBack,0.34,1.56,0.64,1"
        "easeInBack,0.36,0,0.66,-0.56"
        "easeInCubic,0.32,0,0.67,0"
        "easeInOutCubic,0.65,0,0.35,1"
      ];

      animation = [
        "global,1,3,default"
        "windowsIn,1,3,easeOutBack,popin"
        "windowsOut,1,3,easeInBack,popin"
        "fadeIn,1,3,easeInOutCubic"
        "fadeOut,1,3,easeInCubic"
        "workspaces,1,3,easeInOutCubic,slide"
        "layersIn,1,3,easeInOutCubic,fade"
        "layersOut,1,3,easeInCubic,fade"
      ];

      dwindle = {
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
        vrr = 0;
      };

      render = {
        cm_enabled = true;
        cm_sdr_eotf = 1;
        # Blur is broken on HDR/10-bit outputs in Hyprland 0.55 without this.
        use_shader_blur_blend = device.type == "desktop";
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0.8;
        numlock_by_default = true;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          middle_button_emulation = false;
        };
      };

      device = {
        name = "epic-mouse-v1";
        sensitivity = 0.5;
      };

      bind = [
        "$mod, Return, exec, hyprctl dispatch workspace 1 && $terminal"
        "$mod, Q, killactive,"
        "$mod, E, exec, $fileManager"
        "$mod SHIFT, E, exec, nautilus"
        "CTRL_SHIFT, ESCAPE, exec, ghostty --title=btop -e btop"
        "$mod, B, exec, hyprctl dispatch workspace 2 && $browser"
        "$mod CTRL, B, exec, hyprctl dispatch workspace 5 && chromium"
        "$mod SHIFT, B, exec, hyprctl dispatch workspace 5 && $browser --private-window"
        "$mod, X, exec, code --enable-features=UseOzonePlatform --ozone-platform=wayland"
        # "$mod, D, exec, kitty --class=podman-tui -e podman-tui"
        "$mod, O, exec, obsidian"
        "$mod + alt, p, exec, shutdown -h 0"
        "$mod + alt, r, exec, reboot"
        "$mod + alt, q, exec, hyprctl keyword monitor ${d.connector},${toString d.width}x${toString d.height}@${toString desktopRefreshRate},auto,${toString d.scale} && sleep 1 && sudo systemctl restart display-manager.service"
        "$mod SHIFT, L, exec, sh ${homeDirectory}/.config/lock-screen/lock.sh"
        "$mod, M, exec, hyprctl dispatch workspace 6 && spotify"
        # "$mod, C, exec, kitty -e tmux new-session -A -s nvim nvim"
        "$mod CTRL, S, exec, sh ${homeDirectory}/dotfiles/scripts/screenshot-capture.sh --notify copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
        "$mod, R, exec, kooha"
        "$mod SHIFT, R, exec, killall kooha"
        # "$mod SHIFT, F, exec, kitty -e bash -c 'nitch -f; read -p \"\"'"
        "$mod, T, togglefloating,"
        "$mod, F, fullscreen, 0"
        "$mod, P, pseudo,"
        "$mod SHIFT, J, layoutmsg, togglesplit,"
        "$mod, W, exec, ags run"
        "$mod SHIFT, W, exec, bash -c \"kill -9 $(pgrep hyprpanel) || hyprpanel\""
        "$mod SHIFT, Q, exec, ${exitScript}"
        "ALT SHIFT, B, exec, ${homeDirectory}/dotfiles/config/rofi/bluetooth-launch.sh"
        "ALT SHIFT, N, exec, ${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh"
        "ALT SHIFT, P, exec, ${homeDirectory}/.config/wlogout/launch.sh"
        "ALT SHIFT, S, exec, ${homeDirectory}/dotfiles/config/rofi/screenshot-launch.sh"
        "ALT, C, exec, ${homeDirectory}/dotfiles/config/rofi/clipboard-launch.sh"
        "SUPER, SUPER_L, exec, $menu"
        "$mod, left, workspace, -1"
        "ALT,Tab,cyclenext, next"
        "ALT SHIFT,Tab,cyclenext, prev"
        "$mod, right, workspace, +1"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod CTRL, right, workspace, e+1"
        "$mod CTRL, left, workspace, e-1"
        ", F7, exec, playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
        ", F8, exec, playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
        ", F9, exec, playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          x:
          let
            ws =
              let
                c = (x + 1) / 10;
              in
              builtins.toString (x + 1 - (c * 10));
          in
          [
            "$mod, ${ws}, workspace, ${toString (x + 1)}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
          ]
        ) 6
      ));

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+ && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%- && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${homeDirectory}/dotfiles/scripts/volume-notify.sh"
        ", XF86AudioNext, exec, playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
        ", XF86AudioPause, exec, playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
        ", XF86AudioPlay, exec, playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
        ", XF86AudioPrev, exec, playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ]
      ++ (
        if device.type == "laptop" then
          [
            ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,disable\""
            ", switch:off:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,${toString d.width}x${toString d.height}@${toString d.refreshRate},auto,${toString d.scale}\""
          ]
        else
          [ ]
      );

      windowrule = windowRules;

      xwayland = {
        use_nearest_neighbor = false;
        force_zero_scaling = true;
      };
    };

    extraConfig = ''
      source = ${homeDirectory}/dotfiles/config/hypr/matugen-borders.conf

      gesture = 3, horizontal, workspace

      ${layerRuleBlocks}
    '';
  };
}
