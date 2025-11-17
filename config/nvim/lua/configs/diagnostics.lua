local M = {}

function M.setup()
  -- Diagnostic signs
  local signs = {
    Error = " ",
    Warn = " ",
    Hint = "󰛩",
    Info = " ",
  }

  vim.diagnostic.config {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = signs.Error,
        [vim.diagnostic.severity.WARN] = signs.Warn,
        [vim.diagnostic.severity.HINT] = signs.Hint,
        [vim.diagnostic.severity.INFO] = signs.Info,
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "single",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      vim.diagnostic.open_float(nil, {
        focus = false,
        border = "rounded",
        source = "always",
        scope = "line",
      })
    end,
  })

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
    max_height = 20,
    focusable = false,
  })

  vim.o.updatetime = 300

  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return M
