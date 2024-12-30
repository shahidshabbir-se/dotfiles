return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	opts = function(_, opts)
		local auto = require("lualine.themes.auto")
		local lualine_modes = {
			"insert",
			"normal",
			"visual",
			"command",
			"replace",
			"inactive",
			"terminal",
		}
		for _, field in ipairs(lualine_modes) do
			if auto[field] and auto[field].c then
				auto[field].c.bg = "NONE"
			end
		end
		opts.options.theme = auto
		-- opts.options.section_separators = { left = "", right = "" }
		-- opts.options.component_separators = { left = "", right = "" } -- Add component separators if needed
	end,
}
