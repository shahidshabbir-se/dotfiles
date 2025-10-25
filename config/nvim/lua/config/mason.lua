local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")
local go = require("lang.go")
-- local templ = require("lang.templ")
mason.setup({
  ui = {
    icons = {
      package_installed = "",
      package_pending = "",
      package_uninstalled = "",
    },
    border = "single",
    winhighlight = "Normal:MyHighlight,FloatBorder:FloatBorder",
  },
})

mason_lspconfig.setup({
  ensure_installed = vim.tbl_flatten({
    {
      -- "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "svelte",
      "lua_ls",
      "graphql",
      "emmet_ls",
      "prismals",
      "astro",
      -- "pyright",
      "sqlls",
    },
    go.mason,
    -- templ.mason,
  }),
  automatic_installation = true,
})

mason_tool_installer.setup({
  ensure_installed = vim.tbl_flatten({
    {
      "prettierd",
      "eslint_d",
      -- "codelldb",
      "js-debug-adapter",
      -- "rust-analyzer",
      "taplo",
      "sqlfluff",
      -- "hadolint",
      "dockerls",
      "jsonls",
      -- "rnix-lsp",
      "yamlls",
      -- "nixpkgs-fmt"
      -- "ruff",
      -- "black",
      -- "mypy",
      -- "debugpy",
    },
    go.tools
  }),
  automatic_installation = true,
})
