local M = {}

-- Treesitter parsers for Docker
M.treesitter = {
	"dockerfile",
}

-- Mason servers (LSP servers that should be installed via Mason)
M.mason = {
	"dockerls", -- Docker Language Server
}

-- LSP configuration
M.lsp = {
	["dockerls"] = {
		settings = {
			docker = {
				languageserver = {
					formatter = {
						ignoreMultilineInstructions = true,
					},
				},
			},
		},
	},
	["docker-compose-language-service"] = {}, -- Docker Compose LSP
}

-- Formatters
M.formatters = {
	-- dockerls LSP server handles formatting via LSP
	-- No separate formatter needed - formatting is done by LSP
}

-- Linters
M.linters = {
	dockerfile = { "hadolint" },
}

-- Tools to ensure installed via Mason
M.tools = {
	"dockerfile-language-server", -- dockerls
	"docker-compose-language-service",
	"hadolint", -- Dockerfile linter and formatter
}

return M
