return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    init = function()
      -- Override LazyVim's default init that auto-opens neo-tree on directory buffers.
      -- This prevents neo-tree from stealing focus on session restore.
    end,
    opts = {
      source_selector = {
        winbar = false,
        statusline = false,
      },
      hide_root_node = true,
      retain_hidden_root_indent = false,
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            "node_modules",
            ".next",
            "dist",
            ".git",
            ".claude",
            ".husky",
          },
        },
      },
      enable_git_status = true,
      default_component_configs = {
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          symlink = "",
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            conflict = "",
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "➜",
            untracked = "",
            deleted = "",
            ignored = "◌",
          },
        },
      },
      window = {
        width = 30,
      },
    },
  },

  -- Override bufferline offset title
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "left",
            highlight = "BufferLineOffsetText",
            separator = true,
          },
        },
      },
    },
  },
}
