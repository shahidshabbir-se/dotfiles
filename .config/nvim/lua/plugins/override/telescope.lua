return {
	"nvim-telescope/telescope.nvim",
	opts = function(_, opts)
		local map = vim.keymap.set
		local pickers = require("configs.telescope").pickers
		local SIZES = {
			HEIGHT = 0.75,
			WIDTH = 0.66,
			PREVIEW_WIDTH = 0.5,
		}

		opts = vim.tbl_deep_extend("force", opts, {
			defaults = {
				preview = {
					hide_on_startup = false,
				},
				results_title = false,
				selection_caret = " ",
				entry_prefix = " ",
				layout_config = {
					horizontal = {
						width = SIZES.WIDTH,
						height = SIZES.HEIGHT,
						preview_width = SIZES.PREVIEW_WIDTH,
					},
				},
				file_ignore_patterns = { "node_modules" },
				mappings = {
					i = {
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
						["<C-h>"] = require("telescope.actions.layout").toggle_preview,
					},
					n = {
						["<C-h>"] = require("telescope.actions.layout").toggle_preview,
					},
				},
				borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			},
			pickers = {
				builtin = {
					prompt_title = "Builtin Pickers",
				},
			},
		})

		return opts
	end,
}
