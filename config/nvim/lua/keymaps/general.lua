local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<C-a>", "ggVG$", { desc = "Select all in NORMAL mode" })
map("v", "<C-a>", "<Esc>ggVG$", { desc = "Select all in VISUAL mode" })
map("i", "<C-a>", "<Esc>ggVG$", { desc = "Select all in INSERT mode" })

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

map("n", "K", function()
  vim.lsp.buf.hover {
    border = "rounded",
    title = " Docs ",
  }
end)

-- Smart text objects for quotes
local function smart_quote(inner)
  return function()
    -- Grab character under cursor
    local c = vim.fn.getline("."):sub(vim.fn.col ".", vim.fn.col ".")
    -- Candidates: double, single, backtick
    local quotes = { '"', "'", "`" }

    -- If cursor is on a quote, use that
    for _, q in ipairs(quotes) do
      if c == q then
        return (inner and "i" or "a") .. q
      end
    end

    -- Otherwise, look backwards for nearest quote on this line
    local line = vim.fn.getline "."
    local col = vim.fn.col "."
    local left = line:sub(1, col)
    local found = left:match "[\"'`][^\"'`]*$"
    if found then
      local q = found:sub(1, 1)
      return (inner and "i" or "a") .. q
    end

    -- Fallback: double quotes
    return (inner and 'i"' or 'a"')
  end
end

map({ "o", "x" }, "iq", smart_quote(true), { expr = true })
map({ "o", "x" }, "aq", smart_quote(false), { expr = true })
