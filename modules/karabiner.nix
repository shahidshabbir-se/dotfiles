{ pkgs, ... }:

{
  # Ensure the config directory exists
  xdg.configFile."karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON {
      global = {
        check_for_updates_on_startup = true;
        show_in_menu_bar = false;
        show_profile_name_in_menu_bar = false;
      };
      profiles = [
        {
          name = "Default";
          selected = true;
          complex_modifications = {
            parameters = {
              "basic.to_if_alone_timeout_milliseconds" = 200;
              "basic.to_if_held_down_threshold_milliseconds" = 200;
            };
            rules = [
              # CapsLock -> Control (hold) / Escape (tap)
              {
                description = "CapsLock -> Control (hold) / Escape (tap)";
                manipulators = [
                  {
                    from = {
                      key_code = "caps_lock";
                      modifiers = { optional = [ "any" ]; };
                    };
                    to = [{ key_code = "left_control"; }];
                    to_if_alone = [{ key_code = "escape"; }];
                    type = "basic";
                  }
                ];
              }
              # Physical Escape -> CapsLock
              {
                description = "Escape -> CapsLock";
                manipulators = [
                  {
                    from = {
                      key_code = "escape";
                      modifiers = { optional = [ "any" ]; };
                    };
                    to = [{ key_code = "caps_lock"; }];
                    type = "basic";
                  }
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
