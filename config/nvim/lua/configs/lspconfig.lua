require("nvchad.configs.lspconfig").defaults()

local lsp = vim.lsp
local go_config = require("lang.go")
local ts_config = require("lang.typescript")

local nvlsp = require("nvchad.configs.lspconfig")

-- Setup TypeScript/Node.js LSP servers
ts_config.setup_lsp()

-- Helper function to get common config
local function get_common_config()
	return {
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
	}
end

-- Define servers using vim.lsp.config (excluding TypeScript/Node.js related)
local servers = {
	"lua_ls",
	"rnix",
	"taplo",
	"dockerls",
	-- "pyright",
}

-- Add Go mason servers
if go_config.mason then
	for _, server in ipairs(go_config.mason) do
		table.insert(servers, server)
	end
end

-- Configure all standard servers
for _, lsp_name in ipairs(servers) do
	lsp.config(lsp_name, get_common_config())
end

-- Setup gopls with custom config from go.lua
if go_config.lsp and go_config.lsp.gopls then
	lsp.config("gopls", vim.tbl_deep_extend("force", get_common_config(), go_config.lsp.gopls))
end

-- Configure sqlls
lsp.config(
	"sqlls",
	vim.tbl_deep_extend("force", get_common_config(), {
		filetypes = { "sql" },
		root_dir = function(_)
			return vim.loop.cwd()
		end,
	})
)

-- Configure yamlls
lsp.config(
	"yamlls",
	vim.tbl_deep_extend("force", get_common_config(), {
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
			new_config.settings.yaml.schemas = vim.tbl_deep_extend(
				"force",
				new_config.settings.yaml.schemas or {},
				require("schemastore").yaml.schemas()
			)
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
)
