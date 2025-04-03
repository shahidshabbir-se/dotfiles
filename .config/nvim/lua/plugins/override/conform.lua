---@diagnostic disable: different-requires

---@type NvPluginSpec
return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	init = function()
		vim.keymap.set("n", "<leader>fm", function()
			require("conform").format({ lsp_fallback = true })
		end, { desc = "General format file" })
	end,
	---@type conform.setupOpts
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			css = { "prettierd" },
			html = { "prettierd" },
			nix = { "nixpkgs-fmt" },
			svelte = { "prettierd" },
			toml = { "taplo" },
			sql = { "sqlfluff" },
			astro = { "prettierd" },
			json = { "prettierd" },
			python = { "black" },
		},
		format_on_save = function(bufnr)
			-- Disable autoformat with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 5000, lsp_fallback = true }
		end,
		formatters = {
			sqlfluff = {
				args = { "format", "--dialect=ansi", "-" },
			},
		},
	},
}
