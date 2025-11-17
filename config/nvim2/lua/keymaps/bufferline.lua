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
map("n", "<Leader>bd", function()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local target

  for i, buf in ipairs(buffers) do
    if buf.bufnr == current then
      target = buffers[i - 1] and buffers[i - 1].bufnr or buffers[i + 1] and buffers[i + 1].bufnr
      break
    end
  end

  if target then
    vim.api.nvim_set_current_buf(target)
  end

  vim.cmd("bdelete " .. current)
end, opts)

-- Close all but current
map("n", "<Leader>bo", "<Cmd>BufferLineCloseOthers<CR>", opts)

-- Close buffers to the left/right
map("n", "<Leader>bh", "<Cmd>BufferLineCloseLeft<CR>", opts)
map("n", "<Leader>bl", "<Cmd>BufferLineCloseRight<CR>", opts)

-- Sort buffers
map("n", "<Leader>bsd", "<Cmd>BufferLineSortByDirectory<CR>", opts)
map("n", "<Leader>bse", "<Cmd>BufferLineSortByExtension<CR>", opts)
