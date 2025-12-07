return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "single",
				backdrop = 100,
        width = 0.75,
        height = 0.8,
			},
		})
		local langs = require("lang").langs

		local servers = {}
		local tools = {}

		for _, lang in ipairs(langs) do
			if lang.mason then
				for _, server in ipairs(lang.mason) do
					table.insert(servers, server)
				end
			end
			if lang.tools then
				for _, tool in ipairs(lang.tools) do
					table.insert(tools, tool)
				end
			end
		end

		-- Mason setup
		local mason_ok, mason = pcall(require, "mason")
		if mason_ok then
			mason.setup()
		end

		-- LSP server installation
		local mason_lsp_ok, mason_lsp = pcall(require, "mason-lspconfig")
		if mason_lsp_ok then
			mason_lsp.setup({
				ensure_installed = servers,
				automatic_installation = true,
			})
		end

		-- Tools installation
		local installer_ok, tool_installer = pcall(require, "mason-tool-installer")
		if installer_ok then
			tool_installer.setup({
				ensure_installed = tools,
				run_on_start = true,
				auto_update = true,
			})
		end
	end,
}
