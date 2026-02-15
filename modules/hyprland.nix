{ homeDirectory, ... }:

{
  enable = true;
  xwayland.enable = true;
  systemd.enable = true;

  settings = {
    "$mod" = "SUPER";
    "$terminal" = "ghostty";
    "$browser" = "zen";
    "$fileManager" = "ghostty --title=yazi -e yazi";
    "$menu" = "${homeDirectory}/dotfiles/config/rofi/app-menu-launch.sh";

    monitor = [
      "HDMI-A-1,1920x1080@120,0x0,1.2,bitdepth,10,cm,hdr,sdrbrightness,1.2,sdrsaturation,0.98,vrr,1"
      "eDP-1,1920x1080@60,auto,1.3333"
    ];

    exec-once = [
      "swww-daemon &"
      "eww --config ~/.config/eww daemon &"
      "waybar &"
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
      "xdg-mime default feh.desktop image/png"
      "xdg-mime default feh.desktop image/jpeg"
      "xdg-mime default feh.desktop image/gif"
      "xdg-mime default feh.desktop image/webp"
      "xdg-mime default feh.desktop image/bmp"
      "hyprctl setcursor Banana 36"
      # "hyprctl setcursor catppuccin-mocha-dark-cursors 24"
    ];

    env = [
      "XDG_MIME_APPS,$HOME/.config/mimeapps.list"
      "TERMINAL,wezterm"
      "BROWSER,zen"
      "EDITOR,nvim"
      "XCURSOR_THEME,Banana"
      "XCURSOR_SIZE,36"
      "HYPRCURSOR_SIZE,36"
      "HYPRCURSOR_THEME,Banana"
      # "XCURSOR_THEME,catppuccin-mocha-dark-cursors"
      # "XCURSOR_SIZE,24"
      # "HYPRCURSOR_SIZE,24"
      # "HYPRCURSOR_THEME,catppuccin-mocha-dark-cursors"
      "GTK_THEME,catppuccin-mocha-blue-standard"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 0;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 8;
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
        size = 3;
        passes = 1;
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
      "windowsIn,1,5,easeOutBack,popin"
      "windowsOut,1,5,easeInBack,popin"
      "fadeIn,1,5,easeInOutCubic"
      "fadeOut,1,10,easeInCubic"
      "workspaces,1,4,easeInOutCubic,slide"
      "layersIn, 1, 5, easeInOutCubic, fade"
      "layersOut, 1, 3, easeInCubic, fade"
    ];

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    misc = {
      force_default_wallpaper = -1;
      disable_hyprland_logo = true;
      vfr = true;
    };

    input = {
      kb_layout = "us";
      follow_mouse = 1;
      sensitivity = 0.5;
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
      sensitivity = -0.5;
    };

    bind = [
      "$mod, Return, workspace, 1"
      "$mod, Return, exec, $terminal"
      "$mod, Q, killactive,"
      "$mod, E, exec, $fileManager"
      "CTRL_SHIFT, ESCAPE, exec, ghostty --title=btop -e btop"
      "$mod, B, workspace, 2"
      "$mod, B, exec, $browser"
      "$mod SHIFT, B, workspace, 8"
      "$mod SHIFT, B, exec, $browser --private-window"
      "$mod, X, exec, code --enable-features=UseOzonePlatform --ozone-platform=wayland"
      # "$mod, D, exec, kitty --class=podman-tui -e podman-tui"
      "$mod, O, exec, obsidian"
      "$mod + alt, p, exec, shutdown -h 0"
      "$mod + alt, r, exec, reboot"
      "$mod + alt, q, exec, sudo systemctl restart display-manager.service"
      "$mod SHIFT, L, exec, hyprlock"
      "$mod, M, workspace, 6"
      "$mod, M, exec, spotify"
      # "$mod, C, exec, kitty -e tmux new-session -A -s nvim nvim"
      "$mod CTRL, S, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
      "$mod, R, exec, kooha"
      "$mod SHIFT, R, exec, killall kooha"
      # "$mod SHIFT, F, exec, kitty -e bash -c 'nitch -f; read -p \"\"'"
      "$mod, T, togglefloating,"
      "$mod, F, fullscreen, 0"
      "$mod, P, pseudo,"
      "$mod SHIFT, J, togglesplit,"
      "$mod, W, exec, ags run"
      "$mod SHIFT, W, exec, bash -c \"kill -9 $(pgrep hyprpanel) || hyprpanel\""
      "$mod, N, exec, swaync-client -t -sw"
      "$mod, Z, exec, pkill -SIGUSR1 waybar"
      "ALT SHIFT, B, exec, ${homeDirectory}/dotfiles/config/rofi/bluetooth-launch.sh"
      "ALT SHIFT, N, exec, ${homeDirectory}/dotfiles/config/rofi/wifi-launch.sh"
      "ALT SHIFT, W, exec, bash ~/.config/rofi/WallSelect"
      "ALT SHIFT, P, exec, ${homeDirectory}/dotfiles/config/rofi/power-launch.sh"
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
    ] ++ (
      builtins.concatLists (builtins.genList
        (
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
        )
        6)
    );

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${homeDirectory}/dotfiles/scripts/volume-notify.sh"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${homeDirectory}/dotfiles/scripts/volume-notify.sh"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+ && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%- && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh"
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${homeDirectory}/dotfiles/scripts/volume-notify.sh"
      ", XF86AudioNext, exec, playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ", XF86AudioPause, exec, playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ", XF86AudioPlay, exec, playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ", XF86AudioPrev, exec, playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh"
      ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,disable\""
      ", switch:off:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,1920x1080@60,auto,1.3333\""
    ];

    windowrulev2 = [
      "float, title:^(yazi)$"
      "size 800 500, title:^(yazi)$"
      "center, title:^(yazi)$"
      "noblur,class:^(Brave-browser)$"
      "float, title:^(btop)$"
      "size 900 600, title:^(btop)$"
      "center, title:^(btop)$"
      "float, class:^(podman-tui)$"
      "size 1000 600, class:^(podman-tui)$"
      "center, class:^(podman-tui)$"
      "float, class:^(Rofi)$"
      "suppressevent maximize, class:.*"
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
    ];

    xwayland = {
      use_nearest_neighbor = false;
    };
  };

  extraConfig = ''
    gesture = 3, horizontal, workspace
  '';
}
