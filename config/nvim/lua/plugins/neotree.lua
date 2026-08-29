return {
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree reveal toggle<cr>",
        desc = "Toggle Neo-tree & reveal file",
      },
      {
        "<C-n>",
        "<cmd>Neotree reveal toggle<cr>",
        desc = "Toggle Neo-tree & reveal file",
      },
      {
        "<leader>o",
        "<cmd>Neotree focus<cr>",
        desc = "Focus Neo-tree",
      },
    },
    opts = {
      hide_root_node = false,
      close_if_last_window = false,
      popup_border_style = "single",
      enable_git_status = true,
      enable_diagnostics = true,
      -- event_handlers
      window = {
        width = 30,
        mappings = {
          ["<cr>"] = "open",
          ["l"] = "open",
          ["<leftrelease>"] = "open",
          ["<2-LeftMouse>"] = "open",
        },
      },
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          with_expanders = true,
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "󰉋",
          folder_open = "󰝰",
          folder_empty = "󰉖",
          folder_empty_open = "󰷏",
          default = "󰈚",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "●",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            added = "✚",
            modified = "",
            conflict = "",
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "➜",
            untracked = "",
            deleted = "",
            ignored = "◌",
            highlight = "NeoTreeGitStatus",
          },
        },
      },
      filesystem = {
        hijack_netrw_behavior = "disabled",
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".git",
            ".DS_Store",
            "thumbs.db",
          },
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        components = {
          name = function(config, node, state)
            local cc = require("neo-tree.sources.common.components")
            local result = cc.name(config, node, state)
            if node:get_depth() == 1 then
              local dir_name = vim.fn.fnamemodify(node.path, ":t")
              if dir_name == "" then
                dir_name = node.path
              end
              result.text = dir_name
            end
            return result
          end,
        },
      },
    },
  },
}
