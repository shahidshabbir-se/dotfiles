return {
  "rktjmp/highlight-current-n.nvim",
  event = "BufReadPost",
  config = function()
    require("highlight_current_n").setup({
      highlight_group = "IncSearch",
    })

    -- Rebind n and N to highlight current search match dynamically
    vim.keymap.set("n", "n", "<Plug>(highlight-current-n-n)", { silent = true })
    vim.keymap.set("n", "N", "<Plug>(highlight-current-n-N)", { silent = true })
  end,
}
