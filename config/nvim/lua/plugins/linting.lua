return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "biomejs", "eslint_d" },
      typescript = { "biomejs", "eslint_d" },
      javascriptreact = { "biomejs", "eslint_d" },
      typescriptreact = { "biomejs", "eslint_d" },
      json = { "biomejs" },
      jsonc = { "biomejs" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint(nil, { ignore_errors = true })
      end,
    })
  end,
}
