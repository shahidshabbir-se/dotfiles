local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigate between buffers
map("n", "L", "<Cmd>BufferLineCycleNext<CR>", opts)
map("n", "H", "<Cmd>BufferLineCyclePrev<CR>", opts)

-- Re-order buffers
map("n", "<Leader>bn", "<Cmd>BufferLineMoveNext<CR>", opts)
map("n", "<Leader>bp", "<Cmd>BufferLineMovePrev<CR>", opts)

-- Pick buffer (interactive selection)
map("n", "<Leader>bb", "<Cmd>BufferLinePick<CR>", opts)

-- Close current buffer
map("n", "<Leader>bd", "<Cmd>bdelete<CR>", opts)

-- Close all but current
map("n", "<Leader>bo", "<Cmd>BufferLineCloseOthers<CR>", opts)

-- Close buffers to the left/right
map("n", "<Leader>bh", "<Cmd>BufferLineCloseLeft<CR>", opts)
map("n", "<Leader>bl", "<Cmd>BufferLineCloseRight<CR>", opts)

-- Sort buffers
map("n", "<Leader>bsd", "<Cmd>BufferLineSortByDirectory<CR>", opts)
map("n", "<Leader>bse", "<Cmd>BufferLineSortByExtension<CR>", opts)
