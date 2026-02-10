return {
  -- Disable persistence.nvim (LazyVim default)
  { "folke/persistence.nvim", enabled = false },

  -- Auto-session: auto save and restore sessions
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/tmp", "/" },
      root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_save = true,
      auto_restore = true,
      auto_create = true,
      allowed_dirs = nil,
      auto_restore_last_session = false,
      git_use_branch_name = false,
      git_auto_restore_on_branch_change = false,
      lazy_support = true,
      close_unsupported_windows = true,
      args_allow_single_directory = true,
      args_allow_files_auto_save = false,
      continue_restore_on_error = true,
      show_auto_restore_notif = false,
      cwd_change_handling = false,
      lsp_stop_on_restore = false,
      restore_error_handler = nil,
      purge_after_minutes = nil,
      log_level = "error",
      bypass_save_filetypes = { "alpha", "neo-tree" },
      pre_save_cmds = {
        "Neotree close",
      },
    },
    keys = {
      { "<leader>qs", "<cmd>SessionSearch<cr>", desc = "Search Sessions" },
      { "<leader>qS", "<cmd>SessionSave<cr>", desc = "Save Session" },
      { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete Session" },
      { "<leader>qr", "<cmd>SessionRestore<cr>", desc = "Restore Session" },
    },
  },
}
