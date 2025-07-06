return {
  filters = {
    dotfiles = false,
    custom = { "^.git$", "^node_modules", ".mypy_cache", "__pycache__" },
  },
  -- disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    preserve_window_proportions = true,
  },
  filesystem_watchers = {
    ignore_dirs = {
      "node_modules",
      ".git",
    },
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "󰈚",
        folder = {
          default = "",
          empty = "",
          empty_open = "",
          open = "",
          symlink = "",
        },
        git = {
          unstaged = "", -- File modified
          staged = "", -- File staged
          unmerged = "", -- Merge conflict
          renamed = "➜", -- Renamed file
          untracked = "", -- Untracked file
          deleted = "", -- Deleted file
          ignored = "◌", -- Ignored file
        },
      },
    },
  },
}
