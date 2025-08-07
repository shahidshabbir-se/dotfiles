local go = require("lang.go")
local templ = require("lang.templ")

require("conform").setup({
  formatters_by_ft = vim.tbl_extend("force", {
      lua = { "stylua" },
      -- nix = { "nixpkgs-fmt" },
      svelte = { "prettier" },
      toml = { "taplo" },
      sql = { "sqlfluff" },
      astro = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      markdown = { "prettier" },
      yaml = { "prettier" },
      -- python = { "black" },
    }, go.conform.formatters_by_ft,
    templ.conform.formatters_by_ft
  ),

  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { timeout_ms = 5000, lsp_fallback = true }
  end,

  formatters = vim.tbl_extend("force", {
    -- prettier = {
    --   command = "prettier",
    --   args = { "--stdin-filepath", "$FILENAME" },
    --   stdin = true,
    --   cwd = require("conform.util").root_file({ ".prettierrc", "package.json", ".git" }),
    -- },
    sqlfluff = {
      args = { "format", "--dialect=ansi", "-" },
      stdin = true,
    },
  }, go.conform.formatters),
})
