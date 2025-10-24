return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `toggle()`.
		{
			"folke/snacks.nvim",
			opts = {
				input = {},
				picker = {},
			},
		},
	},
	config = function()
		vim.g.opencode_opts = {
			-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on `opencode_opts`.
		}

		-- Required for `vim.g.opencode_opts.auto_reload`.
		vim.o.autoread = true
	end,
}
