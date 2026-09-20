-- vim-herdr-navigation — Neovim side (fixed for NvChad + tmux-navigator)
-- Everything runs on VimEnter so we win over any other plugin.

local function is_valid_pane_id(id)
  return id and id ~= "" and not id:match("[pP][nN]")
end

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return
  end

  local herdr = vim.env.HERDR_BIN_PATH
  if not herdr or herdr == "" then
    herdr = "herdr"
  end

  if is_valid_pane_id(vim.env.HERDR_PANE_ID) then
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--pane", vim.env.HERDR_PANE_ID })
  elseif vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
  end
end

local function setup_herdr_nav()
  for _, lhs in ipairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
    pcall(vim.keymap.del, "n", lhs)
  end

  local function map(lhs, wincmd, dir, desc)
    vim.keymap.set("n", lhs, function()
      nav(wincmd, dir)
    end, { silent = true, noremap = true, desc = desc })
  end

  map("<C-h>", "h", "left", "Navigate left (vim/herdr)")
  map("<C-j>", "j", "down", "Navigate down (vim/herdr)")
  map("<C-k>", "k", "up", "Navigate up (vim/herdr)")
  map("<C-l>", "l", "right", "Navigate right (vim/herdr)")
end

-- Run immediately + on VimEnter + 100ms later (to beat NvChad / lazy / anything else)
setup_herdr_nav()

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    setup_herdr_nav()
    vim.defer_fn(setup_herdr_nav, 100)
  end,
})
