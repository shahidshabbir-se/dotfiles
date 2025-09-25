local M = {}

M.treesitter = {
  "templ"
}

M.mason = {
  "templ",
  "htmx"
}

M.lsp = {
  templ = {
    cmd = { "templ", "lsp" },
    filetypes = { "templ" },
    root_dir = function(fname)
      return vim.lsp.util.root_pattern("go.mod", ".git")(fname)
    end,
    settings = {},
  },
}

M.conform = {
  formatters_by_ft = {
    templ = {
      "gofumpt",
      "templ",
      "injected",
    },
  },
}

return M
