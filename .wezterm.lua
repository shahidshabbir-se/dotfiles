local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Font configuration
config.font = wezterm.font_with_fallback {
  {
    family = 'JetBrainsMono Nerd Font',
    weight = 'Regular',
    italic = true,
  },
  'JetBrainsMono Nerd Font',
}
config.font_size = 14

-- Enable font features for better italics
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Shell configuration
config.default_prog = { '/etc/profiles/per-user/shahid/bin/tmux', 'new-session', '-A', '-s', 'main' }

-- Window configuration
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_background_opacity = 0.95
config.text_background_opacity = 1.0

-- Cursor configuration
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 500

-- Key bindings
config.keys = {
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
}

-- Performance tweaks
config.scrollback_lines = 10000
config.enable_scroll_bar = false

return config
