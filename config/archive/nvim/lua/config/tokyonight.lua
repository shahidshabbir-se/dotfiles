return {
	style = "moon", -- options: "storm", "moon", "night", "day"
	transparent = true,
	terminal_colors = true,
	styles = {
		comments = { italic = true },
		keywords = { italic = true },
		functions = {},
		variables = {},
		sidebars = "transparent",
		floats = "transparent",
	},
	-- sidebars = { "qf", "help", "nvimtree", "lualine", "packer" },
	hide_inactive_statusline = true,
	dim_inactive = false,
	lualine_bold = true,
	on_highlights = function(hl, c)
		hl.WinSeparator = {
			fg = c.blue,
		}
		hl.NvimTreeWinSeparator = {
			fg = c.blue,
		}
	end,
}
