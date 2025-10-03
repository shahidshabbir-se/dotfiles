{ config, pkgs, homeDirectory, ... }:

{
  enable = true;
  xwayland.enable = true;
  systemd.enable = true;

  settings = {
    "$mod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "kitty --class=yazi -e yazi";
    "$menu" = "wofi --show drun";

    monitor = [
      # "HDMI-A-1,1920x1080@120,auto,1.2"
      "eDP-1,1920x1080@60,auto,1.3333"
    ];

    exec-once = [
      "swww-daemon &"
      "swww img $HOME/Pictures/Wallpapers/1.png"
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
      "hyprctl setcursor Banana-Catppuccin-Mocha 36"
    ];

    env = [
      "XDG_MIME_APPS,$HOME/.config/mimeapps.list"
      "TERMINAL,kitty"
      "EDITOR,nvim"
      "XCURSOR_THEME,Banana-Catppuccin-Mocha"
      "XCURSOR_SIZE,36"
      "HYPRCURSOR_SIZE,36"
      "HYPRCURSOR_THEME,Banana-Catppuccin-Mocha"
      "GTK_THEME,Tokyonight-Dark-BL"
    ];

    general = {
      gaps_in = 10;
      gaps_out = 27;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      resize_on_border = false;
      allow_tearing = false;
      layout = "dwindle";
    };

    decoration = {
      rounding = 10;
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
      "fadeIn,0"
      "fadeOut,1,10,easeInCubic"
      "workspaces,1,4,easeInOutCubic,slide"
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
      "$mod, Return, exec, $terminal"
      "$mod, Q, killactive,"
      "$mod, E, exec, $fileManager"
      "CTRL_SHIFT, ESCAPE, exec, kitty --class=btop -e btop"
      "$mod, B, exec, zen"
      "$mod, X, exec, code --enable-features=UseOzonePlatform --ozone-platform=wayland"
      "$mod, D, exec, kitty --class=podman-tui -e podman-tui"
      "$mod, O, exec, obsidian"
      "$mod + alt, p, exec, shutdown -h 0"
      "$mod + alt, r, exec, reboot"
      "$mod + alt, q, exec, sudo systemctl restart display-manager.service"
      "$mod, L, exec, hyprlock"
      "$mod, M, exec, spotify"
      "$mod, C, exec, kitty -e tmux new-session -A -s nvim nvim"
      "$mod SHIFT, B, exec, zen --private-window"
      "$mod CTRL, S, exec, grimblast --notify copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png"
      "$mod SHIFT, F, exec, kitty -e bash -c 'nitch -f; read -p \"\"'"
      "$mod, F, togglefloating,"
      "$mod, G, fullscreen, 0"
      "$mod, P, pseudo,"
      "$mod SHIFT, J, togglesplit,"
      "$mod SHIFT, W, exec, bash -c \"kill -9 $(pgrep hyprpanel) || hyprpanel\""
      "ALT, C, exec, ~/.config/wofi/clipboard.sh"
      "SUPER, Space, exec, ~/.config/wofi/launcher.sh"
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
      ", F7, exec, playerctl previous"
      ", F8, exec, playerctl play-pause"
      ", F9, exec, playerctl next"
    ] ++ (
      builtins.concatLists (builtins.genList (
        x: let
          ws = let
            c = (x + 1) / 10;
          in
            builtins.toString (x + 1 - (c * 10));
        in [
          "$mod, ${ws}, workspace, ${toString (x + 1)}"
          "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
        ]
      )
      10)
    );

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    windowrulev2 = [
      "float, class:^(yazi)$"
      "size 800 500, class:^(yazi)$"
      "center, class:^(yazi)$"
      "noblur,class:^(Brave-browser)$"
      "float, class:^(btop)$"
      "size 800 500, class:^(btop)$"
      "center, class:^(btop)$"
      "float, class:^(podman-tui)$"
      "size 1000 600, class:^(podman-tui)$"
      "center, class:^(podman-tui)$"
      "suppressevent maximize, class:.*"
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      "workspace 9,class:^(Spotify)$"
    ];

    xwayland = {
      use_nearest_neighbor = false;
    };
  };

  extraConfig = ''
    gesture = 3, horizontal, workspace
  '';
}
