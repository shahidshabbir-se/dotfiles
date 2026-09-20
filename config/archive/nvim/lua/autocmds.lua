require "nvchad.autocmds"

-- Auto-restore cursor position when opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
    if mark[1] > 0 and mark[1] <= #lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})



-- Unlist filetree buffers and directory buffers from tabufline
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("UnlistSpecialBufs", { clear = true }),
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local name = vim.api.nvim_buf_get_name(buf)
    if ft == "NvimTree" or ft == "neo-tree" or (name ~= "" and vim.fn.isdirectory(name) == 1) then
      vim.bo[buf].buflisted = false
    end
  end,
})

-- Enforce transparent background for sidebar & tabufline
local function fix_transparency()
  local transparent_hls = {
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeEndOfBuffer",
    "NvimTreeNormal",
    "NvimTreeNormalNC",
    "NvimTreeEndOfBuffer",
    "TbLineFill",
  }
  for _, hl in ipairs(transparent_hls) do
    vim.api.nvim_set_hl(0, hl, { bg = "none", ctermbg = "none" })
  end

  local win_sep = vim.api.nvim_get_hl(0, { name = "WinSeparator", link = false })
  local sep_style = vim.deepcopy(win_sep)
  sep_style.bg = "none"
  sep_style.ctermbg = "none"
  vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", sep_style)
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", sep_style)
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "FileType", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("FixTransparentSidebar", { clear = true }),
  callback = fix_transparency,
})

-- When opening a directory (`nvim .`), focus on the editor file window instead of Neo-tree sidebar
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("FocusFileWindowOnDir", { clear = true }),
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype
          if ft ~= "neo-tree" and ft ~= "NvimTree" then
            vim.api.nvim_set_current_win(win)
            break
          end
        end
      end, 100)
    end
  end,
})

-- Automatically reload file if changed outside of Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("AutoReloadFileOnDiskChange", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when a buffer is reloaded from disk change
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("NotifyFileReload", { clear = true }),
  callback = function(args)
    vim.notify("File changed on disk. Reloaded buffer!", vim.log.levels.WARN, { title = vim.fn.expand("%:t") })
  end,
})
