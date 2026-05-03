local M = {}

-- Treesitter parsers for web development
M.treesitter = {
	"html",
	"css",
	"javascript",
	"typescript",
	"tsx",
	"json",
	"vue",
	"svelte",
	"markdown",
	"graphql", -- GraphQL syntax
	"prisma", -- Prisma schema files
	"astro", -- Astro components
}

M.mason = {
	"ts_ls", -- JavaScript/TypeScript
	-- "marksman", -- Markdown
}

-- LSP configuration
M.lsp = {
	["html-lsp"] = {},
	["css-lsp"] = {},
	["ts_ls"] = {},
	["json-lsp"] = {
		settings = {
			json = {
				schemas = (function()
					local ok, schemastore = pcall(require, "schemastore")
					if ok and schemastore then
						return schemastore.json.schemas()
					else
						return {}
					end
				end)(),
				validate = { enable = true },
			},
		},
	},
	["svelte-language-server"] = {
		settings = {
			svelte = {
				plugin = {
					svelte = {
						compilerWarnings = {
							["a11y-missing-attribute"] = "ignore",
						},
					},
				},
			},
		},
	},
	["marksman"] = {}, -- Markdown
	["graphql-language-service-cli"] = {},
	["prisma-language-server"] = {},
	["astro-ls"] = {},
	["tailwindcss"] = {},
}

-- Formatters
M.formatters = {
	javascript = { "biome", "prettier" },
	typescript = { "biome", "prettier" },
	tsx = { "biome", "prettier" },
	css = { "biome", "prettier" },
	html = { "prettier" },
	json = { "prettier" },
	jsonc = { "prettier" },
	vue = { "prettier" },
	svelte = { "prettier" },
	markdown = { "prettier" },
	graphql = { "prettier" },
	astro = { "prettier" },
}

-- Linters
M.linters = {
	javascript = { "eslint" },
	typescript = { "eslint" },
	tsx = { "eslint" },
	vue = { "eslint" },
	svelte = { "eslint" },
	css = { "stylelint" },
	scss = { "stylelint" },
	html = { "htmlhint" },
	json = { "jsonlint" },
	markdown = { "markdownlint" },
	graphql = { "graphql-lint" },
	astro = { "prettier" }, -- Astro formatting via Prettier
}

-- Tools to ensure installed via Mason
M.tools = {
	"prettier",
	"eslint",
	"stylelint",
	"htmlhint",
	"html-lsp",
	"css-lsp",
	"tailwindcss-language-server",
	"astro-language-server",
	"svelte-language-server",
	"prisma-language-server", -- Prisma
	"json-lsp",
	"jsonlint",
	"js-debug-adapter",
	"graphql-language-service-cli",
}

return M
