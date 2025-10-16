local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")
local go_config = require("lang.go")
local ts_config = require("lang.typescript")

-- Base tools to install (excluding TypeScript/Node.js related)
local ensure_installed = {
  "taplo",
  "sqlfluff",
  "hadolint",
  "dockerls",
  "yamlls",
  -- "ruff",
  -- "black",
  -- "mypy",
  -- "debugpy",
  -- "delve",
}

-- Add Go tools
if go_config.tools then
  vim.list_extend(ensure_installed, go_config.tools)
end

-- Add TypeScript/Node.js tools
if ts_config.tools then
  vim.list_extend(ensure_installed, ts_config.tools)
end

mason_tool_installer.setup({
  ensure_installed = ensure_installed,
  automatic_installation = true,
})

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

-- Base LSP servers (excluding TypeScript/Node.js related)
local lsp_servers = {
  "rnix",
  "lua_ls",
  -- "pyright",
  "sqlls",
}

-- Add Go LSP servers
if go_config.mason then
  vim.list_extend(lsp_servers, go_config.mason)
end

-- Add TypeScript/Node.js LSP servers
if ts_config.mason then
  vim.list_extend(lsp_servers, ts_config.mason)
end

mason_lspconfig.setup({
  ensure_installed = lsp_servers,
  automatic_installation = true,
  handlers = {
    -- Default handler that will use vim.lsp.config
    function(server_name)
      -- The server will be configured by the lspconfig.lua file
      -- which uses vim.lsp.config
    end,
  },
})
