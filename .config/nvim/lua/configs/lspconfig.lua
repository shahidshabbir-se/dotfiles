require("nvchad.configs.lspconfig").defaults()

local lspconfig = require("lspconfig")

local servers = { "html", "cssls", "lua_ls", "ts_ls", "rnix", "prismals", "svelte" }
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

lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})
