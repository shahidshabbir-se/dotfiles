return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["a="] = { query = "@assignment.outer", desc = "Select outer assignment" },
              ["i="] = { query = "@assignment.inner", desc = "Select inner assignment" },
              ["l="] = { query = "@assignment.lhs", desc = "Select left-hand assignment" },
              ["r="] = { query = "@assignment.rhs", desc = "Select right-hand assignment" },

              ["a:"] = { query = "@property.outer", desc = "Select outer property" },
              ["i:"] = { query = "@property.inner", desc = "Select inner property" },
              ["l:"] = { query = "@property.lhs", desc = "Select left property" },
              ["r:"] = { query = "@property.rhs", desc = "Select right property" },

              ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
              ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },

              ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },

              ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
              ["il"] = { query = "@loop.inner", desc = "Select inner loop" },

              ["afc"] = { query = "@call.outer", desc = "Select outer function call" },
              ["ifc"] = { query = "@call.inner", desc = "Select inner function call" },

              ["af"] = { query = "@function.outer", desc = "Select outer method" },
              ["if"] = { query = "@function.inner", desc = "Select inner method" },

              ["am"] = { query = "@function.outer", desc = "Select outer method" },
              ["im"] = { query = "@function.inner", desc = "Select inner method" },

              ["ac"] = { query = "@class.outer", desc = "Select outer class" },
              ["ic"] = { query = "@class.inner", desc = "Select inner class" },

              ["a/"] = { query = "@comment.outer", desc = "Select outer comment" },
              ["i/"] = { query = "@comment.inner", desc = "Select inner comment" },
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.inner",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.inner",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.inner",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.inner",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ["]s"] = "@parameter.inner", -- Swap parameter with next
              ["]p"] = "@property.outer", -- Swap property with next
              ["]m"] = "@function.outer", -- Swap function with next
            },
            swap_previous = {
              ["[s"] = "@parameter.inner", -- Swap parameter with previous
              ["[p"] = "@property.outer", -- Swap property with previous
              ["[m"] = "@function.outer", -- Swap function with previous
            },
          },
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local treesitter = require("nvim-treesitter.configs")
      local go_config = require("lang.go")

      local ensure_installed = {
          "yaml",
          "markdown",
          "markdown_inline",
          "bash",
          "lua",
          "vim",
          "dockerfile",
          -- "python",
          "gitignore",
          "query",
          "nix",
        }

      -- Add Go parsers
      if go_config.treesitter then
        vim.list_extend(ensure_installed, go_config.treesitter)
      end

      -- Add TypeScript/Node.js parsers
      local ts_config = require("lang.typescript")
      if ts_config.treesitter then
        vim.list_extend(ensure_installed, ts_config.treesitter)
      end

      treesitter.setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = ensure_installed,
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },
  {
    "Wansmer/treesj",
    keys = { { "<leader>m", "<CMD>TSJToggle<CR>", desc = "Toggle Treesitter Join" } },
    cmd = { "TSJToggle" },
    opts = { use_default_keymaps = false },
    init = function()
      local map = vim.keymap.set

      map("n", "<leader>tt", "<CMD>TSJToggle<CR>", { desc = "Toggle Treesitter Join/Split" })
    end,
  },
  {
    "RRethy/vim-illuminate",
    event = { "CursorHold", "CursorHoldI" },
    dependencies = "nvim-treesitter",
    config = function()
      require("illuminate").configure({
        under_cursor = true,
        max_file_lines = nil,
        delay = 100,
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
        filetypes_denylist = {
          "NvimTree",
          "Trouble",
          "Outline",
          "TelescopePrompt",
          "Empty",
          "dirvish",
          "fugitive",
          "alpha",
          "packer",
          "neogitstatus",
          "spectre_panel",
          "toggleterm",
          "DressingSelect",
          "aerial",
        },
      })
    end,
  },
}
