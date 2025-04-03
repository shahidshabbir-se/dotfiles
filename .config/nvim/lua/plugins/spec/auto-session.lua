return {
  "rmagatti/auto-session",
  lazy = false,

  opts = {
    -- Specify a directory to store all session files.
    root_dir = vim.fn.stdpath "data" .. "/sessions/", -- Store all sessions in this directory (e.g., ~/.local/share/nvim/sessions/)

    -- Auto-save and auto-restore settings
    auto_save = true, -- Enable auto-save of sessions on exit
    auto_restore = false, -- Enable auto-restore of sessions on startup
    auto_create = true, -- Enable automatic creation of a new session if no session exists
    auto_restore_last_session = false, -- Restore the last session automatically on startup, if no session for cwd exists

    -- Control the directories where sessions are not handled
    suppressed_dirs = { "~/", "~/Downloads", "/" }, -- Don't manage sessions in these directories

    -- Manual session control (you can choose to save, restore, or delete a session based on cwd or session name)
    session_lens = {
      load_on_setup = true, -- Enable session picker for sessions (requires Telescope)
      previewer = false, -- Disable session file preview
    },

    -- Logging and error handling options
    log_level = "error", -- Set the log level to "error" to reduce log noise

    -- Optionally, configure any other settings
    lazy_support = true, -- Automatically detect if Lazy.nvim is used and wait for it to finish loading
  },
}
