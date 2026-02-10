local M = {}

M.mason = {
	"rust_analyzer",
}

M.treesitter = {
	"rust",
	"toml",
}

M.lsp = {
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					buildScripts = {
						enable = true,
					},
				},
				checkOnSave = {
					enable = true,
					command = "clippy",
				},
				procMacro = {
					enable = true,
				},
				diagnostics = {
					enable = true,
					experimental = {
						enable = true,
					},
				},
				inlayHints = {
					bindingModeHints = {
						enable = false,
					},
					chainingHints = {
						enable = true,
					},
					closingBraceHints = {
						minLines = 25,
					},
					closureReturnTypeHints = {
						enable = "never",
					},
					lifetimeElisionHints = {
						enable = "never",
						useParameterNames = false,
					},
					maxLength = 25,
					parameterHints = {
						enable = true,
					},
					reborrowHints = {
						enable = "never",
					},
					renderColons = true,
					typeHints = {
						enable = true,
						hideClosureInitialization = false,
						hideNamedConstructor = false,
					},
				},
			},
		},
	},
}

M.formatters = {
	rust = { "rustfmt" },
}

M.tools = {
	"rustfmt",
	"codelldb", -- Debugger
}

M.linters = {}

return M
