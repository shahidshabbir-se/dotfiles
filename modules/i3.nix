{ config, pkgs, lib, homeDirectory, browser, ... }:

let
  mod = "Mod4"; # SUPER key
  terminal = "ghostty";
  fileManager = "ghostty --title=yazi -e yazi";
  menu = "${homeDirectory}/dotfiles/config/rofi/app-menu-x11-launch.sh";
in
{
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

    # ───────────────────────────────────────────────
    # Workspace assignments per monitor
    # ───────────────────────────────────────────────
    workspaceOutputAssign = [
      { workspace = "1"; output = "HDMI-A-0 HDMI-1 eDP-1 eDP1"; }
      { workspace = "2"; output = "HDMI-A-0 HDMI-1 eDP-1 eDP1"; }
      { workspace = "3"; output = "HDMI-A-0 HDMI-1 eDP-1 eDP1"; }
      { workspace = "4"; output = "eDP-1 eDP1 HDMI-A-0 HDMI-1"; }
      { workspace = "5"; output = "eDP-1 eDP1 HDMI-A-0 HDMI-1"; }
      { workspace = "6"; output = "eDP-1 eDP1 HDMI-A-0 HDMI-1"; }
    ];

    # ───────────────────────────────────────────────
    # Window rules (replaces windowrulev2)
    # ───────────────────────────────────────────────
    assigns = {};

    # Handled via for_window in extraConfig since home-manager
    # window.commands format is limited

    # ───────────────────────────────────────────────
    # Keybindings (translated from Hyprland)
    # ───────────────────────────────────────────────
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
      "${mod}+Mod1+q" = "exec i3-msg exit";
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

      # Scratchpad (replaces special workspace)
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

      # Polybar toggle (replaces waybar toggle)
      "${mod}+z" = "exec polybar-msg cmd toggle";

      # Media keys
      "F7" = "exec playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      "F8" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      "F9" = "exec playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";

      # Volume (XF86 keys handled in extraConfig)
      "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";
      "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";
      "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${homeDirectory}/dotfiles/scripts/volume-notify.sh";

      # Brightness
      "XF86MonBrightnessUp" = "exec brightnessctl s 10%+ && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh";
      "XF86MonBrightnessDown" = "exec brightnessctl s 10%- && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh";

      # Media (XF86 keys)
      "XF86AudioNext" = "exec playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      "XF86AudioPrev" = "exec playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      "XF86AudioPlay" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
      "XF86AudioPause" = "exec playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh";
    };

    # ───────────────────────────────────────────────
    # Mouse bindings
    # ───────────────────────────────────────────────
    # floating_modifier $mod (move with left click, resize with right) is default

    # ───────────────────────────────────────────────
    # Startup applications (replaces exec-once)
    # ───────────────────────────────────────────────
    startup = [
      { command = "sh -c '[ -f ~/.fehbg ] && sh ~/.fehbg || feh --bg-fill ${homeDirectory}/.cache/wallpaper-cache/wallpaper.jpg'"; always = true; notification = false; }
      # Picom compositor (started directly to avoid home-manager double --config issue)
      { command = "picom --config ${homeDirectory}/dotfiles/config/picom/picom.conf"; notification = false; }
      { command = "killall polybar; sleep 0.5; polybar --config=${homeDirectory}/dotfiles/config/polybar/config.ini main"; always = true; notification = false; }

      # dunst is managed by home-manager services.dunst - no manual start needed
      { command = "greenclip daemon"; notification = false; }
      # Touchpad 3-finger swipe to switch workspaces
      { command = "libinput-gestures"; notification = false; }
      # Super+scroll to switch workspaces (mouse)
      { command = "xbindkeys"; notification = false; }
      # Apply GTK/font settings for X11 (dconf -> xsettingsd)
      { command = "xsettingsd"; notification = false; }
      # Natural scrolling (matches Hyprland touchpad setting)
      { command = "xinput set-prop 'ETPS/2 Elantech Touchpad' 'libinput Natural Scrolling Enabled' 1"; notification = false; }
      # Set cursor
      { command = "xsetroot -cursor_name left_ptr"; notification = false; }
      # Numlock on
      { command = "numlockx on"; notification = false; }
      # MIME type defaults
      { command = "xdg-mime default vlc.desktop video/mp4"; notification = false; }
      { command = "xdg-mime default vlc.desktop video/x-matroska"; notification = false; }
      { command = "xdg-mime default vlc.desktop video/avi"; notification = false; }
      { command = "xdg-mime default vlc.desktop video/webm"; notification = false; }
      { command = "xdg-mime default vlc.desktop audio/mpeg"; notification = false; }
      { command = "xdg-mime default vlc.desktop audio/x-wav"; notification = false; }
      { command = "xdg-mime default vlc.desktop audio/flac"; notification = false; }
      { command = "xdg-mime default feh.desktop image/png"; notification = false; }
      { command = "xdg-mime default feh.desktop image/jpeg"; notification = false; }
      { command = "xdg-mime default feh.desktop image/gif"; notification = false; }
      { command = "xdg-mime default feh.desktop image/webp"; notification = false; }
      { command = "xdg-mime default feh.desktop image/bmp"; notification = false; }
    ];

    bars = [ ]; # Disable i3bar (we use polybar)
  };

  extraConfig = ''
    # ───────────────────────────────────────────────
    # Monitor setup (xrandr)
    # ───────────────────────────────────────────────
    exec --no-startup-id xrandr --dpi 120 --output HDMI-A-0 --mode 1920x1080 --rate 120 --primary --output eDP-1 --mode 1920x1080 --rate 60 --right-of HDMI-A-0

    # ───────────────────────────────────────────────
    # Mouse settings
    # ───────────────────────────────────────────────
    focus_follows_mouse yes

    # Super + scroll to cycle workspaces is handled by xbindkeys

    # ───────────────────────────────────────────────
    # Window rules (replaces Hyprland windowrulev2)
    # ───────────────────────────────────────────────
    for_window [title="yazi"] floating enable, resize set 800 500, move position center
    for_window [title="btop"] floating enable, resize set 900 600, move position center
    for_window [class="podman-tui"] floating enable, resize set 1000 600, move position center
    for_window [class="Rofi"] floating enable
    for_window [class="^.*$"] border pixel 0

    # ───────────────────────────────────────────────
    # Lid switch handling (via systemd-logind)
    # ───────────────────────────────────────────────
    # Handled by /etc/acpi/ or systemd - see configuration.nix
  '';
}
