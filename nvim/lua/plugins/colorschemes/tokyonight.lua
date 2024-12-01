return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		local transparent = true
		require("tokyonight").setup({
			style = "moon",
			transparent = transparent,
			styles = {
				sidebars = transparent and "transparent" or "dark",
				floats = transparent and "transparent" or "dark",
			},
		})
	end,
}
