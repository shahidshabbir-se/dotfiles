local M = {}

-- TypeScript/Node.js related treesitter parsers
M.treesitter = {
	"typescript",
	"javascript",
	"tsx",
	"html",
	"css",
	"scss",
	"json",
	"jsonc",
	"json5",
	"svelte",
	"astro",
	"graphql",
	"prisma",
}

-- Mason packages for TypeScript/Node.js development (LSP servers only)
M.mason = {
	"svelte",
	"astro",
	"prismals",
	"emmet_ls",
	"tailwindcss",
	"html",
	"cssls",
	"jsonls",
	"graphql",
}

-- Tools for TypeScript/Node.js development
M.tools = {
	"prettierd",
	"eslint_d",
	"js-debug-adapter",
}

-- Conform formatters for TypeScript/Node.js
M.conform = {
	formatters_by_ft = {
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		css = { "prettierd" },
		scss = { "prettierd" },
		html = { "prettierd" },
		svelte = { "prettierd" },
		astro = { "prettierd" },
		json = { "prettierd" },
		jsonc = { "prettierd" },
		graphql = { "prettierd" },
	},
}

-- nvim-lint linters for TypeScript/Node.js
M.lint = {
	linters_by_ft = {
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
		javascriptreact = { "eslint_d" },
		typescriptreact = { "eslint_d" },
		svelte = { "eslint_d" },
		astro = { "eslint_d" },
	},
}

-- LSP configuration for TypeScript/Node.js
function M.setup_lsp()
	local lsp = vim.lsp
	local nvlsp = require("nvchad.configs.lspconfig")

	-- Helper function to get common config
	local function get_common_config()
		return {
			on_attach = nvlsp.on_attach,
			on_init = nvlsp.on_init,
			capabilities = nvlsp.capabilities,
		}
	end

	-- Configure TypeScript Tools (replaces ts_ls)
	require("typescript-tools").setup({
		on_attach = nvlsp.on_attach,
		on_init = nvlsp.on_init,
		capabilities = nvlsp.capabilities,
		settings = {
			separate_diagnostic_server = true,
			publish_diagnostic_on = "insert_leave",
			expose_as_code_action = {},
			tsserver_file_preferences = {
				includeCompletionsForModuleExports = true,
				includeCompletionsWithInsertText = true,
				includeCompletionsForImports = true,
				includeCompletionsWithSnippetText = true,
				allowIncompleteCompletions = true,
				includeAutomaticOptionalChainCompletions = true,
				includeCompletionsForClassMembers = true,
				includeCompletionsForClassMemberSnippets = true,
				includeCompletionsForJsxTags = true,
				includeCompletionsForJson = true,
				includeCompletionsForJsDocComments = true,
				autoImportFileExcludePatterns = {
					"node_modules",
					"@types/*",
				},
			},
			tsserver_max_memory = "auto",
			tsserver_plugins = {
				"@styled/typescript-styled-plugin",
			},
			jsx_close_tag = {
				enable = true,
				filetypes = { "javascriptreact", "typescriptreact" },
			},
		},
	})

	-- Configure Svelte
	lsp.config(
		"svelte",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "svelte" },
			settings = {
				svelte = {
					plugin = {
						typescript = {
							enabled = true,
						},
						html = {
							enable = true,
							completions = {
								enable = true,
								emmet = true,
							},
						},
						css = {
							enable = true,
							completions = {
								enable = true,
								emmet = true,
							},
						},
						svelte = {
							enable = true,
						},
					},
				},
			},
		})
	)

	-- Configure Astro
	lsp.config(
		"astro",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "astro" },
			settings = {
				astro = {
					plugin = {
						typescript = {
							enabled = true,
						},
						html = {
							enable = true,
						},
						css = {
							enable = true,
						},
					},
				},
			},
		})
	)

	-- Configure Tailwind CSS
	lsp.config(
		"tailwindcss",
		vim.tbl_deep_extend("force", get_common_config(), {
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
			settings = {
				tailwindCSS = {
					classAttributes = { "class", "className", "classList", "ngClass" },
					lint = {
						classConflict = "warning",
						invalidScreen = "error",
					},
					validate = true,
				},
			},
		})
	)

	-- Configure Emmet
	lsp.config(
		"emmet_ls",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = {
				"html",
				"css",
				"scss",
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
					scss = { enable = true },
					typescriptreact = { enable = true },
					javascriptreact = { enable = true },
					vue = { enable = true },
					svelte = { enable = true },
				},
			},
		})
	)

	-- Configure HTML
	lsp.config(
		"html",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "html", "xhtml", "svelte", "astro" },
			settings = {
				html = {
					format = {
						enabled = true,
						wrapLineLength = 120,
						wrapAttributes = "auto",
					},
					hover = {
						documentation = true,
						references = true,
					},
					suggest = {
						html5 = true,
					},
				},
			},
		})
	)

	-- Configure CSS Language Server
	lsp.config(
		"cssls",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "css", "scss", "svelte", "astro" },
			settings = {
				css = {
					validate = true,
					lint = {
						unknownProperties = "ignore",
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownProperties = "ignore",
					},
				},
			},
		})
	)

	-- Configure JSON Language Server
	lsp.config(
		"jsonls",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "json", "jsonc" },
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = {
						enable = true,
					},
					format = {
						enable = true,
					},
				},
			},
		})
	)

	-- Configure GraphQL
	lsp.config(
		"graphql",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = {
				"graphql",
				"gql",
				"svelte",
				"typescriptreact",
				"javascriptreact",
			},
			settings = {
				graphql = {
					validate = true,
					loadSchemaOnIdle = true,
				},
			},
		})
	)

	-- Configure Prisma
	lsp.config(
		"prismals",
		vim.tbl_deep_extend("force", get_common_config(), {
			filetypes = { "prisma" },
			settings = {
				prisma = {
					prismaFmtBinPath = "",
				},
			},
		})
	)
end

-- DAP (Debug Adapter Protocol) configuration for TypeScript/Node.js
function M.setup_dap()
	local dap = require("dap")

	-- Get js-debug-adapter path
	local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

	-- Try to get the actual path from mason if available
	local ok, mr = pcall(require, "mason-registry")
	if ok then
		local ok2, pkg = pcall(mr.get_package, mr, "js-debug-adapter")
		if ok2 and pkg then
			js_debug_path = pkg:get_install_path() .. "/js-debug/src/dapDebugServer.js"
		end
	end

	-- PWA Node.js Adapter
	if not dap.adapters["pwa-node"] then
		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = {
					js_debug_path,
					"${port}",
				},
			},
		}
	end

	-- PWA Chrome Adapter
	if not dap.adapters["pwa-chrome"] then
		dap.adapters["pwa-chrome"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = {
					js_debug_path,
					"${port}",
					"--inspect",
				},
			},
		}
	end

	-- Node.js configurations
	local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

	for _, language in ipairs(js_filetypes) do
		if not dap.configurations[language] then
			dap.configurations[language] = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
					sourceMaps = true,
				},
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch Jest test",
					-- change to your jest command
					runtimeExecutable = "npm",
					runtimeArgs = { "test" },
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch Chrome",
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}/src",
					sourceMaps = true,
					userDataDir = "${workspaceFolder}/.vscode/chrome-debug",
				},
				{
					type = "pwa-chrome",
					request = "attach",
					name = "Attach to Chrome",
					port = 9222,
					webRoot = "${workspaceFolder}/src",
					sourceMaps = true,
				},
			}
		end
	end

	-- Svelte specific configurations
	if not dap.configurations.svelte then
		dap.configurations.svelte = dap.configurations.typescript
	end

	-- Astro specific configurations
	if not dap.configurations.astro then
		dap.configurations.astro = dap.configurations.typescript
	end
end

return M

