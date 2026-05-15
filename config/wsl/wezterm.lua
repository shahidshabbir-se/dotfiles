local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night"
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.initial_rows = 40
config.initial_cols = 120
config.window_decorations = "RESIZE"
config.default_prog = {
	"wsl.exe",
	"-d",
	"ubuntu",
	"--cd",
	"~",
	"--exec",
	"tmux",
	"new-session",
	"-A",
	"-s",
	"main",
	"-c",
	"/home/shahid",
	"zsh",
}
config.window_padding = {
	left = "0.5cell",
	right = "0.5cell",
	top = "0.2cell",
	bottom = "0.2cell",
}
config.window_content_alignment = {
	horizontal = "Center",
	vertical = "Center",
}
config.font_dirs = { "C:/Users/shahid/AppData/Local/Microsoft/Windows/Fonts" }
config.font = wezterm.font_with_fallback({
	{ family = "GeistMono Nerd Font", weight = "Regular" },
	"Symbols Nerd Font Mono",
	"BabelStone Shapes",
	"Noto Color Emoji",
	"Segoe UI Emoji",
	"Segoe UI Symbol",
	"Segoe UI Historic",
	"Segoe Fluent Icons",
	"Segoe MDL2 Assets",
})
config.font_size = 14.0
config.warn_about_missing_glyphs = false
config.audible_bell = "Disabled"

config.keys = {
	{
		key = "v",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local ps = "powershell.exe"
			local cmd = table.concat({
				"$ErrorActionPreference='Stop';",
				"Add-Type -AssemblyName System.Windows.Forms;",
				"Add-Type -AssemblyName System.Drawing;",
				"$img=[System.Windows.Forms.Clipboard]::GetImage();",
				"if ($null -eq $img) { exit 1 }",
				"$ts=Get-Date -Format 'yyyyMMdd_HHmmss';",
				'$path="$env:TEMP\\wez_clip_$ts.png";',
				"$img.Save($path,[System.Drawing.Imaging.ImageFormat]::Png);",
				"Write-Output $path;",
			}, " ")
			local ok, stdout = wezterm.run_child_process({ ps, "-NoProfile", "-NonInteractive", "-Command", cmd })
			if ok and stdout and #stdout > 0 then
				local path = stdout:gsub("%s+$", "")
				local wsl_path = path:gsub("\\", "/")
				wsl_path = wsl_path:gsub("^(%a):", function(drive)
					return "/mnt/" .. drive:lower()
				end)
				pane:send_paste(wsl_path)
			else
				pane:send_paste("# No image found in clipboard")
			end
		end),
	},
}

-- local mux = wezterm.mux

-- wezterm.on("gui-startup", function(cmd)
-- 	---@diagnostic disable-next-line: unused-local
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	window:gui_window():maximize()
-- end)

return config
