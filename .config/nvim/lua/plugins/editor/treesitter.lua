return {
	"nvim-treesitter/nvim-treesitter",
	-- event = "BufReadPost", -- Load on buffer read
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "html", "javascript", "typescript", "astro", "svelte" },
			highlight = { enable = true },
			autotag = { enable = true },
		})
	end,
}
