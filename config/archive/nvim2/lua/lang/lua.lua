local M = {}

-- Mason packages to ensure installed
M.mason = {
  "lua_ls",
}

-- Treesitter parsers
M.treesitter = {
  "lua",
}

-- LSP configuration
M.lsp = {
  ["lua_ls"] = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT", -- Lua version used by Neovim
        },
        diagnostics = {
          globals = {
            "vim",
          },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  },
}

-- Formatters by filetype
M.formatters = {
  lua = { "stylua" },
}

-- Linters by filetype
M.linters = {
  lua = { "selene" },
}

-- Extra tools to install
M.tools = {
  "stylua",
  "selene",
}

return M
