return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			opts = {
				border = "single",
				position = {
					row = "10%",
					col = "50%",
				},
			},
		},
		messages = {
			enabled = true,
		},
		popupmenu = {
			enabled = false,
		},
		notify = {
			enabled = false,
		},
		lsp = {
			hover = {
				enabled = true,
				opts = {
					border = "single",
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			signature = {
				enabled = true,
				opts = {
					border = "single",
				},
			},
			progress = {
				enabled = true,
			},
			message = {
				enabled = false,
			},
		},
	},
}
