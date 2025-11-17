local M = {}

M.treesitter = {
  "go",
  "gomod",
  "gosum",
  "gowork",
}

M.mason = {
  "gopls",
}

M.lsp = {
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = true,
      },
    },
  },
}

M.conform = {
  formatters = {
    gofumpt = {
      command = "gofumpt",
      args = {}, -- no -w, no --lang, no stdin args required
      stdin = true,
    },
    goimports = {
      command = "goimports",
      args = {},
      stdin = true,
    },
  },
  formatters_by_ft = {
    go = { "gofumpt", "goimports" }, -- chained formatting
  },
}

M.tools = {
  "goimports",
  "gofumpt",
  "gomodifytags",
}

return M
