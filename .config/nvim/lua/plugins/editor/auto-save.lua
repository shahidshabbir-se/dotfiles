return {
  "Shatur/neovim-session-manager",
  dependencies = "nvim-lua/plenary.nvim",
  config = function()
    local Path = require("plenary.path")
    local config = require("session_manager.config")

    -- Set up session manager
    require("session_manager").setup({
      sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"), -- Directory for session files
      autoload_mode = config.AutoloadMode.LastSession, -- Auto load last session
      autosave_last_session = true, -- Auto-save the last session on exit
      autosave_ignore_not_normal = true, -- Don't save when no buffers are open
      autosave_ignore_filetypes = { "gitcommit", "gitrebase" }, -- Ignore certain filetypes
      autosave_ignore_buftypes = {}, -- Ignore certain buffer types
      autosave_only_in_session = false, -- Always autosave session
    })
  end,
}
