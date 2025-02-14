local M = {}

M.setup = function()
  require("copilot").setup {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      keymap = {
        accept = false, -- handled by nvim-cmp / blink.cmp
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    panel = { enabled = true },
    filetypes = {
      markdown = true,
      help = true,
      javascript = true,
      typescript = true,
      typescriptreact = true,
      javascriptreact = true,
      lua = true,
      sql = true,
      go = true,
    },
  }
end

return M
