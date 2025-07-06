local map = vim.keymap.set

require("keymaps.nvimtree")
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
