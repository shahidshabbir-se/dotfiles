return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    require("auto-session").setup({
      enabled = true,
      root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_save = true,
      auto_restore = true,
      auto_create = true,
      suppressed_dirs = nil,
      allowed_dirs = nil,
      auto_restore_last_session = false,
      git_use_branch_name = false,
      git_auto_restore_on_branch_change = false,
      lazy_support = true,
      bypass_save_filetypes = nil,
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

      session_lens = {
        load_on_setup = true,
        picker_opts = nil,
        mappings = {
          delete_session = { "i", "<C-D>" },
          alternate_session = { "i", "<C-S>" },
          copy_session = { "i", "<C-Y>" },
        },
        session_control = {
          control_dir = vim.fn.stdpath("data") .. "/auto_session/",
          control_filename = "session_control.json",
        },
      },
    })
  end,
}
