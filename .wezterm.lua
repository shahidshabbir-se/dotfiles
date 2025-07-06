--
--  ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
--  ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
--  ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
--  ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
--  ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--   ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
--     https://github.com/shahidshabbir-se/dotfiles

local wezterm = require("wezterm")

-- ▶ Appearance
return {
  color_scheme = "tokyonight_night",
  font = wezterm.font("BlexMono Nerd Font"),
  font_size = 13.7,
  window_padding = {
    left = 24,
    right = 24,
    top = 24,
    bottom = 24,
  },
  window_decorations = "RESIZE",
  enable_tab_bar = false,
  adjust_window_size_when_changing_font_size = false,
  native_macos_fullscreen_mode = true,
  macos_window_background_blur = 30,
  -- window_background_opacity = 0.92,
  -- window_background_image = "/Users/shahid/Pictures/Wallpapers/sfd.jpg",
  -- window_background_image_hsb = {
  --   brightness = 0.43,
  --   hue = 0.88,
  --   saturation = 1.0,
  -- },

  -- ▶ Behavior
  default_prog = { "/etc/profiles/per-user/shahid/bin/zsh", "-l", "-c", "tmux" },
  send_composed_key_when_left_alt_is_pressed = false,
  send_composed_key_when_right_alt_is_pressed = false,
  exit_behavior = "CloseOnCleanExit",
  window_close_confirmation = "NeverPrompt",

  -- ▶ Key Bindings
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
  },

  -- ▶ Mouse Bindings
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  },
}
