require "nvchad.mappings"

local map = vim.keymap.set

-- ============================================================================
-- 1. General & Navigation
-- ============================================================================
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlights" })

-- Select All
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("i", "<C-a>", "<esc>ggVG", { desc = "Select all" })
map("v", "<C-a>", "<esc>ggVG", { desc = "Select all" })

-- Line movement
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered during half-page jumps & searches
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search match (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search match (centered)" })

-- ============================================================================
-- 2. Buffer Navigation & Management (<leader>b / <leader>x)
vim.keymap.del("n", "<leader>b")
-- ============================================================================
-- Fast buffer switching
map("n", "<S-l>", function() require("nvchad.tabufline").next() end, { desc = "Next buffer" })
map("n", "<S-h>", function() require("nvchad.tabufline").prev() end, { desc = "Previous buffer" })
map("n", "]b", function() require("nvchad.tabufline").next() end, { desc = "Next buffer" })
map("n", "[b", function() require("nvchad.tabufline").prev() end, { desc = "Previous buffer" })

-- Reorder tabs
map("n", "]B", function() require("nvchad.tabufline").move_buf(1) end, { desc = "Move buffer right" })
map("n", "[B", function() require("nvchad.tabufline").move_buf(-1) end, { desc = "Move buffer left" })

-- Buffer actions
map("n", "<leader>x", function() require("nvchad.tabufline").close_buffer() end, { desc = "Close buffer" })
map("n", "<leader>bd", function() require("nvchad.tabufline").close_buffer() end, { desc = "Delete buffer" })
map("n", "<leader>bj", "<cmd>Telescope buffers<cr>", { desc = "Pick buffer" })
map("n", "<leader>bl", function() require("nvchad.tabufline").closeBufs_at_direction("left") end, { desc = "Close buffers to left" })
map("n", "<leader>br", function() require("nvchad.tabufline").closeBufs_at_direction("right") end, { desc = "Close buffers to right" })
map("n", "<leader>bo", function() require("nvchad.tabufline").closeAllBufs(false) end, { desc = "Close other buffers" })
map("n", "<leader>ba", function()
  vim.bo.buflisted = not vim.bo.buflisted
  vim.notify("Buffer listed: " .. tostring(vim.bo.buflisted), vim.log.levels.INFO)
end, { desc = "Toggle buffer pin" })

-- ============================================================================
-- 3. File Explorer (Neo-tree)
-- ============================================================================
map("n", "<leader>e", "<cmd>Neotree reveal toggle<cr>", { desc = "Toggle Neo-tree & reveal file" })
map("n", "<C-n>", "<cmd>Neotree reveal toggle<cr>", { desc = "Toggle Neo-tree & reveal file" })
map("n", "<leader>fe", "<cmd>Neotree focus<cr>", { desc = "Focus Neo-tree" })

-- ============================================================================
-- 4. Fuzzy Finder & Search (<leader>f)
-- ============================================================================
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "Live grep (Search text)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in buffer" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume last search" })

-- ============================================================================
-- 5. Code & Formatting (<leader>c / <leader>f)
-- ============================================================================
map({ "n", "x" }, "<leader>fm", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format document" })

map({ "n", "x" }, "<leader>cf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format document" })

map({ "n", "v" }, "<leader>ca", function()
  require("actions-preview").code_actions()
end, { desc = "LSP Code Actions (Floating Preview)" })

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
end, { desc = "Copy diagnostic under cursor" })

-- ============================================================================
-- 6. Window Splits & Navigation (<leader>w)
-- ============================================================================
map("n", "<leader>hs", ":split<CR>", { desc = "Split horizontal" })
map("n", "<leader>vs", ":vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close window split" })

-- Tmux / Window seamless navigation
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Window left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Window down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Window up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Window right" })

-- ============================================================================
-- 7. Git Operations (<leader>g)
-- ============================================================================
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git status" })
map("n", "<leader>gb", function() require("gitsigns").blame_line() end, { desc = "Git blame line" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview git hunk" })

-- ============================================================================
-- 8. Sessions (<leader>s)
-- ============================================================================
map("n", "<leader>sr", "<cmd>AutoSession restore<cr>", { desc = "Restore session" })
map("n", "<leader>ss", "<cmd>AutoSession search<cr>", { desc = "Search sessions" })
map("n", "<leader>sa", "<cmd>AutoSession save<cr>", { desc = "Save session" })

-- ============================================================================
-- 9. Tools & Utilities (<leader>u / <leader>t / <leader>l / <leader>m)
-- ============================================================================
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Toggle Undotree" })
map("n", "<leader>th", function() require("nvchad.themes").open() end, { desc = "NvChad themes" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason package manager" })

-- ============================================================================
-- 10. Debugging / DAP (<leader>d)
-- ============================================================================
-- Handled by lua/plugins/dap.lua:
-- <leader>db ➜ Toggle Breakpoint (🛑)
-- <leader>dB ➜ Conditional Breakpoint (🔍)
-- <leader>dc ➜ Continue / Start Debugger
-- <leader>di ➜ Step Into
-- <leader>do ➜ Step Over
-- <leader>dO ➜ Step Out
-- <leader>dr ➜ Toggle REPL
-- <leader>du ➜ Toggle DAP UI
-- <leader>dt ➜ Terminate Debugger

