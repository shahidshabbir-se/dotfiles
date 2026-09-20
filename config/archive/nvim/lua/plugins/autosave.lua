return {
  "okuuva/auto-save.nvim",
  version = "^1.0.0", -- pin to the current stable API
  cmd = "ASToggle",
  event = { "InsertLeave", "TextChanged" },
  opts = {
    enabled = true,
    trigger_events = {
      -- save immediately when you leave the buffer or Neovim loses focus
      immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
      -- save after `debounce_delay` ms of inactivity
      defer_save = { "InsertLeave", "TextChanged", "TextChangedI" },
      -- reset the deferred timer once you start typing again
      cancel_deferred_save = { "InsertEnter" },
    },
    condition = function(buf)
      if not buf or not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
        return false
      end
      if not vim.bo[buf].modified then
        return false
      end
      local fn = vim.fn
      local buftype = fn.getbufvar(buf, "&buftype")
      local modifiable = fn.getbufvar(buf, "&modifiable")
      if buftype ~= "" or modifiable ~= 1 then
        return false
      end
      local filetype = fn.getbufvar(buf, "&filetype")
      local excluded = {
        gitcommit = true,
        ["neo-tree"] = true,
        NvimTree = true,
        TelescopePrompt = true,
        oil = true,
      }
      if excluded[filetype] then
        return false
      end
      return true
    end,
    write_all_buffers = false,
    noautocmd = true,
    debounce_delay = 1000,
    callbacks = {
      before_saving = function()
        vim.opt.eventignore:append({ "BufWritePre", "BufWritePost" })
      end,
      after_saving = function()
        vim.opt.eventignore:remove({ "BufWritePre", "BufWritePost" })
      end,
    },
  },
}
