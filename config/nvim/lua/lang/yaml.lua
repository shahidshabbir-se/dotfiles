local M = {}

-- Treesitter parsers for YAML
M.treesitter = {
	"yaml",
}

-- Mason servers (LSP servers that should be installed via Mason)
M.mason = {
	"yamlls", -- YAML Language Server
}

-- LSP configuration
M.lsp = {
	["yamlls"] = {
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					["https://json.schemastore.org/github-action.json"] = "/.github/action.{yml,yaml}",
					["https://json.schemastore.org/ansible-stable-2.9.json"] = "/ansible/**/*.{yml,yaml}",
					["https://json.schemastore.org/prettierrc.json"] = "/.prettierrc.{yml,yaml}",
					["https://json.schemastore.org/kustomization.json"] = "/kustomization.{yml,yaml}",
					["https://json.schemastore.org/chart.json"] = "/Chart.{yml,yaml}",
					["https://json.schemastore.org/circlecci-config-schema.json"] = "/.circleci/**/*.{yml,yaml}",
					["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
					kubernetes = "/*.yaml",
				},
				format = {
					enable = true,
					singleQuote = false,
					bracketSpacing = true,
				},
				validate = true,
				completion = true,
				hover = true,
				schemaStore = {
					enable = true,
					url = "https://www.schemastore.org/api/json/catalog.json",
				},
			},
		},
	},
}

-- Formatters
M.formatters = {
	yaml = { "prettier" },
}

-- Linters
M.linters = {
	yaml = { "yamllint" },
}

-- Tools to ensure installed via Mason
M.tools = {
	"yaml-language-server", -- yamlls
	"prettier",
	"yamllint",
}

return M
