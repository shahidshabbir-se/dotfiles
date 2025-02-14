local wezterm = require("wezterm")
return {
	adjust_window_size_when_changing_font_size = false,
	-- color_scheme = 'termnial.sexy',
	color_scheme = "Catppuccin Mocha",
	enable_tab_bar = false,
	font_size = 10.0,
	font = wezterm.font("JetBrains Mono"),
	macos_window_background_blur = 30,

	-- window_background_opacity = 0.92,
	-- window_background_opacity = 1.0,
	-- window_background_opacity = 0.78,
	-- window_background_opacity = 0.20,
	window_decorations = "NONE",
	exit_behavior = "CloseOnCleanExit",
	window_close_confirmation = "NeverPrompt",
	default_prog = { "tmux" },
	window_padding = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
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
