return {
  "Wansmer/treesj",
  keys = { { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle Treesitter Join" } },
  cmd = { "TSJToggle" },
  opts = { use_default_keymaps = false },
  init = function()
    vim.keymap.set("n", "<leader>tt", "<CMD>TSJToggle<CR>", { desc = "Toggle Treesitter Join/Split" })
  end,
}
