local map = vim.keymap.set

require("keymaps.nvim-tree")
require("keymaps.indent-blankline")
require("keymaps.bufferline")
require("keymaps.lspconfig")

map("n", "<C-a>", "ggVG$", { desc = "Select all in NORMAL mode" })
map("v", "<C-a>", "<Esc>ggVG$", { desc = "Select all in VISUAL mode" })
map("i", "<C-a>", "<Esc>ggVG$", { desc = "Select all in INSERT mode" })
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<C-s>", ":w<CR>", { desc = "Save file in NORMAL mode" })
map("v", "<C-s>", "<Esc>:w<CR>", { desc = "Save file in VISUAL mode" })
map("i", "<C-s>", "<Esc>:w<CR>", { desc = "Save file in INSERT mode" })
map("n", "<esc>", ":nohlsearch<CR><CR>", { noremap = true, silent = true })

map("n", "<leader>lc", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = pos[1] - 1 })

  if diagnostics and #diagnostics > 0 then
    local msg = diagnostics[1].message
    vim.fn.setreg("+", msg)
    vim.notify(" Copied: " .. msg, vim.log.levels.INFO, { title = "LSP Diagnostic" })
  else
    vim.notify("No diagnostic under cursor", vim.log.levels.WARN, { title = "LSP Diagnostic" })
  end
end, { desc = "Copy LSP diagnostic under cursor" })

map("n", "<leader>hs", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>vs", ":vsplit<CR>", { desc = "Vertical split" })

vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fw", function()
  require("telescope.builtin").live_grep({
    layout_strategy = "vertical",
    sorting_strategy = "ascending", -- Ensures first item is at the top
  })
end, { desc = "Live Grep (Vertical Layout)" })
vim.api.nvim_set_keymap('n', '<leader>fr', "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })

vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover({
    border = 'rounded',
    title = ' Docs ',
  })
end)
