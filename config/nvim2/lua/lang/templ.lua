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
      return vim.fs.root(fname, { "go.mod", ".git" })
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
