return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    init = function()
      -- Override LazyVim's default init that auto-opens neo-tree on directory buffers.
      -- This prevents neo-tree from stealing focus on session restore.
    end,
    opts = {
      hide_root_node = true,
      retain_hidden_root_indent = false,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".next", "dist", ".git", ".claude", ".husky" },
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
            -- Change type
            added = "", -- or "✚"
            modified = "", -- or ""
            -- Status type
            conflict = "",
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
      window = {
        width = 30,
      },
    },
  },
}
