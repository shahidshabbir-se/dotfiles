require("nvchad.configs.lspconfig").defaults()

local lspconfig = require("lspconfig")

local servers = {
	"html",
	"astro",
	"cssls",
	"lua_ls",
	"ts_ls",
	"rnix",
	"prismals",
	"svelte",
	"taplo",
	"jsonls",
	"dockerls",
	"pyright",
}
local nvlsp = require("nvchad.configs.lspconfig")

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	})
end

lspconfig.tailwindcss.setup({
	on_attach = nvlsp.on_attach,
	capabilities = nvlsp.capabilities,
	filetypes = {
		"html",
		"css",
		"typescriptreact",
		"typescript",
		"javascriptreact",
		"javascript",
		"astro",
		"svelte",
	},
	root_dir = require("lspconfig.util").root_pattern(
		"tailwind.config.mjs",
		"tailwind.config.ts",
		"tailwind.config.js"
	),
})

lspconfig.emmet_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = {
		"html",
		"css",
		"typescriptreact",
		"javascriptreact",
		"vue",
		"svelte",
		"astro",
	},
	settings = {
		emmet = {
			html = { enable = true },
			css = { enable = true },
			typescriptreact = { enable = true },
			javascriptreact = { enable = true },
			vue = { enable = true },
			svelte = { enable = true },
		},
	},
})

lspconfig.sqlls.setup({
	capabilities = capabilities,
	filetypes = { "sql" },
	root_dir = function(_)
		return vim.loop.cwd()
	end,
})

lspconfig.yamlls.setup({
	capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
	},
	-- lazy-load schemastore when needed
	on_new_config = function(new_config)
		new_config.settings.yaml.schemas =
			vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, require("schemastore").yaml.schemas())
	end,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			keyOrdering = false, -- Disable key ordering validation
			format = { enable = true }, -- Enable auto-formatting
			validate = true,
			foldingRange = { -- Enable line folding
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
			schemaStore = {
				enable = false, -- Disable built-in schema store
				url = "", -- Prevent errors
			},
			schemas = vim.tbl_deep_extend("force", {}, require("schemastore").yaml.schemas()),
		},
	},
})
