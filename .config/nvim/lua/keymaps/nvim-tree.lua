local map = vim.keymap.set

-- Toggle or focus the NvimTree file explorer
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
