{
  pkgs,
  ...
}: {
  enable = true;
  package = pkgs.wezterm;

  extraConfig = ''
    return {
      adjust_window_size_when_changing_font_size = false,
      color_scheme = "tokyonight_night",
      enable_tab_bar = false,
      font_size = 17.0,
      font = wezterm.font("JetBrainsMono Nerd Font"),
      window_decorations = "RESIZE",

      window_padding = {
        left = 16,
        right = 8,
        top = "20",
        bottom = 0,
      },

      keys = {
        {
          key = "q",
          mods = "CTRL",
          action = wezterm.action.ToggleFullScreen,
        },
        {
          key = "'",
          mods = "CTRL",
          action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
        },
        { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
      },

      mouse_bindings = {
        -- Ctrl-click will open the link under the mouse cursor
        {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "CTRL",
          action = wezterm.action.OpenLinkAtMouseCursor,
        },
      },
    }
  '';
}
