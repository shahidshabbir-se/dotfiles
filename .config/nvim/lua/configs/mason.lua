local mason = require "mason"
local mason_lspconfig = require "mason-lspconfig"
local mason_tool_installer = require "mason-tool-installer"

mason_tool_installer.setup {
  ensure_installed = {
    "prettierd",
    "eslint_d",
    "js-debug-adapter",
    "gofumpt",
    "goimports-reviser",
    "golines",
    "delve",
    "taplo",
    "sqlfluff",
    "hadolint",
    "dockerls",
    "jsonls",
    "yamlls",
  },
  automatic_installation = true,
}

mason.setup {
  ui = {
    icons = {
      package_installed = "",
      package_pending = "",
      package_uninstalled = "",
    },
    border = "single",
    winhighlight = "Normal:MyHighlight,FloatBorder:FloatBorder",
  },
}

mason_lspconfig.setup {
  ensure_installed = {
    "ts_ls",
    "rnix",
    "html",
    "cssls",
    "tailwindcss",
    "svelte",
    "lua_ls",
    "graphql",
    "emmet_ls",
    "prismals",
    "astro",
    "gopls",
    "sqlls",
  },
  automatic_installation = true,
}
