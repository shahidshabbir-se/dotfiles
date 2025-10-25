return {
  filters = {
    dotfiles = false,
    custom = { "^.git$", "^node_modules", ".mypy_cache", "__pycache__" },
  },
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  view = {
    width = 30,
    -- side = "left",
    -- float = {
    --   enable = true,
    --   open_win_config = function()
    --     local columns = vim.o.columns
    --     local lines = vim.o.lines
    --     local width = 35
    --     local height = math.floor(lines * 0.7) -- 80% of screen height
    --
    --     return {
    --       relative = "editor",
    --       border = "rounded",
    --       width = width,
    --       height = height,
    --       row = (lines - height) / 2.5,
    --       col = (columns - width),
    --       title = " File Explorer ",
    --       title_pos = "center",
    --     }
    --   end,
    -- },
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
