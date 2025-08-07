{ config, pkgs, ... }:

{
  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;

    settings = {
      after-login-command = [ ];

      enable-normalization-flatten-containers = false;
      enable-normalization-opposite-orientation-for-nested-containers = false;
      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      key-mapping.preset = "qwerty";

      gaps = {
        outer = {
          bottom = [
            { monitor."^built-in retina display$" = 15; }
            15
          ];
          top = [
            { monitor."^built-in retina display$" = 15; }
            15
          ];
          left = 15;
          right = 15;
        };
        inner = {
          horizontal = 15;
          vertical = 15;
        };
      };

      on-window-detected = [
        {
          check-further-callbacks = false;
          "if" = {
            app-id = "org.wezfurlong.wezterm";
          };
          run = [
            "move-node-to-workspace 2"
          ];
        }
      ];

      mode = {
        main.binding = {
          "cmd-space" = "layout floating tiling";
          "cmd-r" = [
            "mode resize"
            "exec-and-forget sketchybar --trigger send_message MESSAGE=\"RESIZE MODE\" HOLD=\"true\""
          ];
          "cmd-keypadMinus" = "resize smart -70";
          "cmd-keypadPlus" = "resize smart +70";
          "cmd-g" = "mode join";
          "cmd-q" = [ "close --quit-if-last-window" ];
          "cmd-shift-f" = "macos-native-fullscreen";
          "alt-g" = "split horizontal";
          "alt-v" = "split vertical";
          "cmd-h" = "focus --boundaries all-monitors-outer-frame --boundaries-action stop left";
          "cmd-j" = "focus --boundaries all-monitors-outer-frame --boundaries-action stop down";
          "cmd-k" = "focus --boundaries all-monitors-outer-frame --boundaries-action stop up";
          "cmd-l" = "focus --boundaries all-monitors-outer-frame --boundaries-action stop right";

          "cmd-shift-h" = "move left";
          "cmd-shift-j" = "move down";
          "cmd-shift-k" = "move up";
          "cmd-shift-l" = "move right";

          "cmd-1" = "workspace --auto-back-and-forth 1";
          "cmd-2" = "workspace --auto-back-and-forth 2";
          "cmd-3" = "workspace --auto-back-and-forth 3";
          "cmd-4" = "workspace --auto-back-and-forth 4";
          "cmd-5" = "workspace --auto-back-and-forth 5";
          "cmd-6" = "workspace --auto-back-and-forth 6";
          "cmd-7" = "workspace --auto-back-and-forth 7";
          "cmd-8" = "workspace --auto-back-and-forth 8";
          "cmd-9" = "workspace --auto-back-and-forth 9";
          "cmd-0" = "workspace --auto-back-and-forth 10";

          "cmd-shift-1" = "move-node-to-workspace 1";
          "cmd-shift-2" = "move-node-to-workspace 2";
          "cmd-shift-3" = "move-node-to-workspace 3";
          "cmd-shift-4" = "move-node-to-workspace 4";
          "cmd-shift-5" = "move-node-to-workspace 5";
          "cmd-shift-6" = "move-node-to-workspace 6";
          "cmd-shift-7" = "move-node-to-workspace 7";
          "cmd-shift-8" = "move-node-to-workspace 8";
          "cmd-shift-9" = "move-node-to-workspace 9";
          "cmd-shift-0" = "move-node-to-workspace 10";

          "cmd-tab" = "workspace-back-and-forth";

          # Application Shortcuts
          "cmd-enter" = "exec-and-forget /opt/homebrew/bin/wezterm";
          "cmd-b" = "exec-and-forget open -na Zen";
          "cmd-m" = "exec-and-forget open -n Spotify";
        };

        resize.binding = {
          keypadMinus = "resize smart -70";
          keypadPlus = "resize smart +70";
          h = [ "resize width -64" ];
          j = [ "resize height -64" ];
          k = [ "resize height +64" ];
          l = [ "resize width +64" ];
          esc = [ "mode main" "exec-and-forget sketchybar --trigger hide_message" ];
          enter = [ "mode main" "exec-and-forget sketchybar --trigger hide_message" ];
        };

        join.binding = {
          h = [ "join-with left" "mode main" ];
          j = [ "join-with down" "mode main" ];
          k = [ "join-with up" "mode main" ];
          l = [ "join-with right" "mode main" ];
          "cmd-h" = [ "join-with left" "mode main" ];
          "cmd-alt-h" = [ "join-with left" "mode main" ];
        };

        service.binding = {
          backspace = [ "close-all-windows-but-current" "mode main" ];
        };
      };
    };
  };
}
