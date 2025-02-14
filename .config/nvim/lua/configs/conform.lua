local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettierd" },
    html = { "prettierd" },
    nix = { "nixpkgs-fmt" },
    go = { "gofmt" },
    svelte = { "prettierd" },
    toml = { "taplo" },
    sql = { "sqlfluff" },
  },

  formatters = {
    sqlfluff = {
      args = { "format", "--dialect=ansi", "-" },
    },
  },

  format_on_save = {
    timeout_ms = 2000,
    lsp_fallback = true,
  },
}

return options
