return {
  condition = function(buf)
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    return ft ~= "go"
  end,

  callbacks = {
    before_saving = function()
      vim.g.OLD_AUTOFORMAT = vim.g.autoformat_enabled
      vim.g.autoformat_enabled = false
      vim.g.OLD_AUTOFORMAT_BUFFERS = {}

      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.b[bufnr].autoformat_enabled then
          table.insert(vim.g.OLD_AUTOFORMAT_BUFFERS, bufnr)
          vim.b[bufnr].autoformat_enabled = false
        end
      end
    end,

    after_saving = function()
      for _, bufnr in ipairs(vim.g.OLD_AUTOFORMAT_BUFFERS or {}) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.b[bufnr].autoformat_enabled = true
        end
      end
    end,
  },
}
