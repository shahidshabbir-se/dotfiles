return {
	"folke/noice.nvim",
	enabled = false, -- Disable noice.nvim
	opts = {
		views = {
			mini = {
				win_options = {
					winblend = 0,
				},
			},
		},
		lsp = {
			hover = {
				silent = true,
			},
			signature = {
				auto_open = {
					enabled = false,
				},
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = true,
			lsp_doc_border = true,
		},
	},
}
