return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim", -- Ensure this is listed in dependencies
    "WhoIsSethDaniel/mason-tool-installer.nvim", -- Ensure this is also included
  },
  config = function()
    -- Import mason and its modules
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason_tool_installer.setup({
      ensure_installed = {

        "prettier", -- Prettier formatter
        "stylua", -- Lua formatter
        "eslint_d", -- ESLint D
        "goimports",
        "gofumpt",
      },
    })

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
        winhighlight = "Normal:MyHighlight,FloatBorder:FloatBorder",
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "astro",
        "azure_pipelines_ls",
        "gopls",
      },
    })

    -- Setup Mason Tool Installer
  end,
}
