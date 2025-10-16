return {
	"nvim-neo-tree/neo-tree.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		-- Disable netrw to prevent conflicts
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
				hijack_netrw = true,
				use_libuv_file_watcher = true,
			},
			window = {
				width = 30,
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<CR>"] = "open",
					["q"] = "close_window",
				},
			},
		})
	end,
}
