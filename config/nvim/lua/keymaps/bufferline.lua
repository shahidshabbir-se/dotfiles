-- keymaps/bufferline.lua
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigate buffers
map("n", "H", "<Cmd>BufferLineCyclePrev<CR>", opts)
map("n", "L", "<Cmd>BufferLineCycleNext<CR>", opts)

-- Delete buffer or close others
map("n", "<leader>bd", "<Cmd>bdelete<CR>", opts)
map("n", "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", opts)

-- Move buffer left/right
map("n", "<leader>bh", "<Cmd>BufferLineMovePrev<CR>", opts)
map("n", "<leader>bl", "<Cmd>BufferLineMoveNext<CR>", opts)

-- Jump to specific buffer (1–9)
for i = 1, 9 do
  map("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", opts)
end
