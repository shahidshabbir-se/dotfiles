-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.api.nvim_set_keymap(
	"n",
	"<A-1>",
	":ToggleTerm size=10 direction=horizontal<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<A-2>",
	":ToggleTerm size=20 direction=vertical<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<A-3>",
	":ToggleTerm size=30 direction=float<CR>",
	{ noremap = true, silent = true }
)

vim.api.nvim_set_keymap(
	"t",
	"<A-1>",
	"<C-\\><C-n>:ToggleTerm size=10 direction=horizontal<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"t",
	"<A-2>",
	"<C-\\><C-n>:ToggleTerm size=20 direction=vertical<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"t",
	"<A-3>",
	"<C-\\><C-n>:ToggleTerm size=30 direction=float<CR>",
	{ noremap = true, silent = true }
)

vim.api.nvim_set_keymap(
	"n",
	"<Tab>",
	"<cmd>BufferLineCycleNext<CR>",
	{ noremap = true, silent = true, desc = "Next Buffer" }
)
vim.api.nvim_set_keymap(
	"n",
	"<S-Tab>",
	"<cmd>BufferLineCyclePrev<CR>",
	{ noremap = true, silent = true, desc = "Prev Buffer" }
)
