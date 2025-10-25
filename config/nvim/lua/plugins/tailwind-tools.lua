return {
  "luckasRanarison/tailwind-tools.nvim",
  name = "tailwind-tools",
  event = { "BufReadPre", "BufNewFile" },
  build = ":UpdateRemotePlugins",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim", -- optional
    "neovim/nvim-lspconfig",
  },
  opts = {
    document_color = {
      enabled = true,
      kind = "inline", -- inline color block (requires Neovim 0.10+)
    },
    cmp = {
      enabled = false,
      highlight = "background", -- color preview style, "foreground" | "background"
    },
    conceal = {
      enabled = false, -- can be toggled by commands
      min_length = nil, -- only conceal classes exceeding the provided length
      symbol = "󱏿", -- only a single character is allowed
      highlight = { -- extmark highlight options, see :h 'highlight'
        fg = "#38BDF8",
      },
    },
    extension = {
    },
    keymaps = {
      smart_increment = { -- increment tailwindcss units using <C-a> and <C-x>
        enabled = false,
        units = {         -- see lua/tailwind/units.lua to see all the defaults
          {
            prefix = "border",
            values = { "2", "4", "6", "8" },
          },
          -- ...
        }
      }
    },
    server = {
      override = false, -- Disabled: using vim.lsp.config.tailwindcss instead
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              'class:([^=]+)="([^"]*)"',     -- class:active="..."
              'className:([^=]+)="([^"]*)"', -- class:active="..."
            },
          },
        },
      },
    },
  },
}
