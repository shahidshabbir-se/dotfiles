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
	["ts_ls"] = {
		root_dir = function(bufnr, on_dir)
			local fname = vim.api.nvim_buf_get_name(bufnr)
			local util = require("lspconfig.util")
			-- Prefer the nearest tsconfig.json so monorepo sub-projects resolve their own node_modules
			local root = util.root_pattern("tsconfig.json")(fname)
				or util.root_pattern("package.json", "jsconfig.json", ".git")(fname)
			if root then
				on_dir(root)
			end
		end,
	},
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
	javascript = { "prettier" },
	typescript = { "prettier" },
	tsx = { "prettier" },
	css = { "prettier" },
	html = { "prettier" },
	json = { "prettier" },
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
	"biome",
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
