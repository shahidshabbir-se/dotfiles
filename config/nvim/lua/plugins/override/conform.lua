---@diagnostic disable: different-requires

---@type NvPluginSpec
return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	init = function()
		local go_config = require("lang.go")
		vim.keymap.set("n", "<leader>fm", function()
			require("conform").format({ lsp_fallback = true })
		end, { desc = "General format file" })
	end,
	---@type conform.setupOpts
	opts = function()
			local go_config = require("lang.go")
			local ts_config = require("lang.typescript")

			local opts = {
				formatters_by_ft = {
					lua = { "stylua" },
					nix = { "nixpkgs-fmt" },
					toml = { "taplo" },
					sql = { "sqlfluff" },
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
			}

			-- Add Go formatters
			if go_config.conform then
				opts.formatters_by_ft.go = go_config.conform.formatters_by_ft.go
				opts.formatters = vim.tbl_deep_extend("force", opts.formatters, go_config.conform.formatters)
			end

			-- Add TypeScript/Node.js formatters
			if ts_config.conform then
				opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft, ts_config.conform.formatters_by_ft)
				opts.formatters = vim.tbl_deep_extend("force", opts.formatters, ts_config.conform.formatters or {})
			end

			return opts
		end,
}
