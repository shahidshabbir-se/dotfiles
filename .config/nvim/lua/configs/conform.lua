local options = {
	formatters_by_ft = {
		lua = { "stylua" },
		css = { "prettier" },
		html = { "prettier" },
		nix = { "nixpkgs-fmt" },
		lua = { "stylua" },
		go = { "gofmt" },
	},

	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
}

return options
