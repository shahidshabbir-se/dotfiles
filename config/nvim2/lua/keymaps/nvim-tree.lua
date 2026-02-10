local map = vim.keymap.set

-- Toggle or focus the NvimTree file explorer
map("n", "<leader>e", function()
  require("nvim-tree.api").tree.toggle({
    path = vim.loop.cwd(),
    current_window = false,
  })
end, { desc = "File Explorer (floating)" })
