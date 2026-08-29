return {
  "okuuva/auto-save.nvim",
  cmd = "ASToggle",
  event = { "InsertLeave", "FocusLost" },
  opts = {
    enabled = true,
    execution_message = {
      message = function()
        return ""
      end,
    },
    trigger_events = { "InsertLeave", "FocusLost" },
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
      if filetype == "gitcommit" or filetype == "neo-tree" or filetype == "NvimTree" or filetype == "TelescopePrompt" or filetype == "oil" then
        return false
      end
      return true
    end,
    write_all_buffers = false,
    debounce_delay = 2000,
  },
}
