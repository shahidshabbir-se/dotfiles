local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		css = { "prettierd" },
		html = { "prettierd" },
		nix = { "nixpkgs-fmt" },
		lua = { "stylua" },
		go = { "gofmt" },
		svelte = { "prettierd" },
		kotlin = { "ktlint" },
	},

	format_on_save = {
		timeout_ms = 2000,
		lsp_fallback = true,
	},
}

return options
