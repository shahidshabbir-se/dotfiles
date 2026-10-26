{ musicPlayer }:

{
  config,
  inputs,
  lib,
  pkgs,
  device,
  ...
}:

let
  qylock = import ../qylock.nix { inherit inputs pkgs; };
  lua = lib.generators.mkLuaInline;
  homeDirectory = config.home.homeDirectory;
  d = device.display;

  key = value: lua (builtins.toJSON value);
  modKey = suffix: lua ''mod .. " + ${suffix}"'';
  exec = command: lua "hl.dsp.exec_cmd(${builtins.toJSON command})";
  modExec = variable: lua "hl.dsp.exec_cmd(${variable})";
  focus = workspace: lua "hl.dsp.focus({ workspace = ${workspace} })";
  moveToWorkspace = workspace: lua "hl.dsp.window.move({ workspace = ${workspace} })";

  bind = keys: dispatcher: flags: {
    _args = [
      keys
      dispatcher
    ]
    ++ lib.optional (flags != { }) flags;
  };

  plain = keys: dispatcher: bind keys dispatcher { };
  modBind = suffix: dispatcher: plain (modKey suffix) dispatcher;
  shell = keys: command: plain keys (exec command);
  modShell = suffix: command: modBind suffix (exec command);

  ghosttyFocusOrLaunch = pkgs.writeShellScript "ghostty-focus-or-launch" ''
    set -eu

    clients="$(hyprctl -j clients)"
    if printf '%s' "$clients" | ${pkgs.jq}/bin/jq -e 'any(.[]; .class == "com.mitchellh.ghostty")' >/dev/null; then
      hyprctl dispatch 'hl.dsp.focus({ window = "class:com.mitchellh.ghostty" })'
    else
      hyprctl dispatch 'hl.dsp.exec_cmd("[workspace 1] ghostty")'
    fi
  '';

  altTab = pkgs.writeShellScript "hypr-alt-tab" ''
    set -eu

    dir="''${1:-next}"
    jq="${pkgs.jq}/bin/jq"

    ws="$(hyprctl -j activeworkspace)" || exit 0
    count="$(printf '%s' "$ws" | $jq -r '.windows')"
    wsid="$(printf '%s' "$ws" | $jq -r '.id')"

    if [ "$count" -gt 1 ]; then
      hyprctl dispatch cyclenext "$dir"
      exit 0
    fi

    target="$(hyprctl -j clients | $jq -r --argjson cur "$wsid" --arg dir "$dir" '
      [ .[] | select(.workspace.id >= 0 and .workspace.id != $cur and .focusHistoryID >= 0) ]
      | sort_by(.focusHistoryID)
      | if length == 0 then "" elif $dir == "prev" then .[-1].address else .[0].address end
    ')"

    [ -n "$target" ] && hyprctl dispatch focuswindow "address:$target"

    exit 0
  '';

  exitScript = pkgs.writeShellScript "exit.sh" ''
    if env -u GTK_THEME zenity --question --title="Exit Hyprland" --text="Do you wish to exit?"; then
      hyprctl -i 0 dispatch exit
    fi
  '';

  mainBindings = [
    # Apps
    (modShell "RETURN" "${ghosttyFocusOrLaunch}")
    (modBind "B" (focus "2"))
    (modBind "B" (lua "hl.dsp.exec_cmd(browser)"))
    (modBind "SHIFT + B" (focus "5"))
    (modBind "SHIFT + B" (lua ''hl.dsp.exec_cmd(browser .. " --private-window")''))
    (modShell "O" "obsidian")
    (modShell "E" "ghostty --title=yazi -e yazi")
    (modBind "Q" (lua "hl.dsp.window.close()"))
    (modShell "SHIFT + E" "env NAUTILUS_4_EXTENSION_DIR=/run/current-system/sw/lib/nautilus/extensions-4 nautilus")
    (shell (key "F10") "ghostty --title=btop -e btop")

    # System and power actions
    (modShell "ALT + P" "shutdown -h 0")
    (modShell "ALT + R" "reboot")
    (modShell "ALT + Q" "hyprctl keyword monitor ${d.connector},${toString d.width}x${toString d.height}@${toString d.refreshRate},auto,${toString d.scale} && sleep 1 && sudo systemctl restart display-manager.service")
    (modShell "SHIFT + L" "${qylock}/bin/qylock-lock sword")
    (modShell "CTRL + S" "sh ${homeDirectory}/dotfiles/scripts/screenshot-capture.sh copysave area ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png")
    (modShell "R" "kooha")
    (modShell "SHIFT + R" "killall kooha")
    (modShell "SHIFT + Q" "${exitScript}")

    # Window management and layout
    (modBind "T" (lua ''hl.dsp.window.float({ action = "toggle" })''))
    (modShell "F" "hyprctl dispatch fullscreen 0")
    (modBind "P" (lua "hl.dsp.window.pseudo()"))
    (modBind "SHIFT + J" (lua ''hl.dsp.layout("togglesplit")''))

    # Shell / overlays
    (modShell "W" "ags run")
    (modShell "SHIFT + W" ''bash -c "kill -9 $(pgrep hyprpanel) || hyprpanel"'')
    (shell (key "ALT + SHIFT + S") "qs ipc call screenshot toggle")
    (modShell "SPACE" "vicinae toggle")
    (shell (key "ALT + C") "vicinae 'vicinae://launch/clipboard/history?toggle=true'")
    (modShell "TAB" "qs ipc call expose toggle")
    (shell (key "ALT + TAB") "${altTab} next")
    (shell (key "ALT + SHIFT + TAB") "${altTab} prev")

    # Directional focus
    (modBind "LEFT" (lua ''hl.dsp.focus({ direction = "left" })''))
    (modBind "RIGHT" (lua ''hl.dsp.focus({ direction = "right" })''))
    (modBind "UP" (lua ''hl.dsp.focus({ direction = "up" })''))
    (modBind "DOWN" (lua ''hl.dsp.focus({ direction = "down" })''))
    (modBind "H" (lua ''hl.dsp.focus({ direction = "left" })''))
    (modBind "J" (lua ''hl.dsp.focus({ direction = "down" })''))
    (modBind "K" (lua ''hl.dsp.focus({ direction = "up" })''))
    (modBind "L" (lua ''hl.dsp.focus({ direction = "right" })''))
    (modBind "LEFT" (focus (builtins.toJSON "-1")))
    (modBind "RIGHT" (focus (builtins.toJSON "+1")))

    # Special workspace and workspace cycling
    (modBind "S" (lua ''hl.dsp.workspace.toggle_special("magic")''))
    (modBind "SHIFT + S" (moveToWorkspace (builtins.toJSON "special:magic")))
    (modBind "mouse_down" (focus (builtins.toJSON "e+1")))
    (modBind "mouse_up" (focus (builtins.toJSON "e-1")))
    (modBind "CTRL + RIGHT" (focus (builtins.toJSON "e+1")))
    (modBind "CTRL + LEFT" (focus (builtins.toJSON "e-1")))

    # Media keys
    (shell (key "F7") "playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
    (shell (key "F8") "playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
    (shell (key "F9") "playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
  ]
  ++ lib.optionals (builtins.elem musicPlayer [ "spotify" "limusic" ]) [
    (modBind "M" (focus "6"))
    (modShell "M" musicPlayer)
  ]
  ++ builtins.concatLists (
    builtins.genList (
      index:
      let
        workspace = index + 1;
        keyName = toString workspace;
      in
      [
        (modBind keyName (focus (toString workspace)))
        (modBind "SHIFT + ${keyName}" (moveToWorkspace (toString workspace)))
      ]
    ) 6
  )
  ++ [
    (bind (modKey "mouse:272") (lua "hl.dsp.window.drag()") { mouse = true; })
    (bind (modKey "mouse:273") (lua "hl.dsp.window.resize()") { mouse = true; })
    (bind (key "XF86AudioRaiseVolume") (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") {
      locked = true;
      repeating = true;
    })
    (bind (key "XF86AudioLowerVolume") (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
      locked = true;
      repeating = true;
    })
    (bind (key "XF86MonBrightnessUp")
      (exec "brightnessctl s 10%+ && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh")
      {
        locked = true;
        repeating = true;
      }
    )
    (bind (key "XF86MonBrightnessDown")
      (exec "brightnessctl s 10%- && ${homeDirectory}/dotfiles/scripts/brightness-notify.sh")
      {
        locked = true;
        repeating = true;
      }
    )
    (bind (key "XF86AudioMute")
      (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ${homeDirectory}/dotfiles/scripts/volume-notify.sh")
      { locked = true; }
    )
    (bind (key "XF86AudioNext")
      (exec "playerctl next && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
      { locked = true; }
    )
    (bind (key "XF86AudioPause")
      (exec "playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
      { locked = true; }
    )
    (bind (key "XF86AudioPlay")
      (exec "playerctl play-pause && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
      { locked = true; }
    )
    (bind (key "XF86AudioPrev")
      (exec "playerctl previous && sleep 0.3 && ${homeDirectory}/dotfiles/scripts/music-notify.sh")
      { locked = true; }
    )
  ]
  ++ lib.optionals (device.type == "laptop") [
    (shell (key "switch:on:Lid Switch") ''hyprctl keyword monitor "eDP-1,disable"'')
    (shell (key "switch:off:Lid Switch") ''hyprctl keyword monitor "eDP-1,${toString d.width}x${toString d.height}@${toString d.refreshRate},auto,${toString d.scale}"'')
  ];
in
{
  wayland.windowManager.hyprland.settings.bind = mainBindings;
}
